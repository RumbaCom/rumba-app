import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../config.dart';
import 'metadata.dart';

/// Estado simple que consume la interfaz.
enum RadioState { idle, connecting, playing, paused, error, blockedByWifiOnly }

/// Maneja la reproduccion del stream en segundo plano.
///
/// audio_service se encarga de la notificacion multimedia,
/// los controles en la pantalla de bloqueo, Android Auto y CarPlay.
/// just_audio se encarga del stream y de leer la metadata ICY,
/// que es de donde sale el titulo de la cancion.
class RadioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  /// Titulo de la cancion que suena ahora, ya limpio.
  final BehaviorSubject<String?> nowPlaying =
      BehaviorSubject<String?>.seeded(null);

  /// Estado de alto nivel para la interfaz.
  final BehaviorSubject<RadioState> radioState =
      BehaviorSubject<RadioState>.seeded(RadioState.idle);

  /// Se emite cada vez que empieza una cancion distinta.
  final PublishSubject<String> songChanged = PublishSubject<String>();

  /// Cuanto falta para que se apague sola. Null = temporizador apagado.
  final BehaviorSubject<Duration?> sleepRemaining =
      BehaviorSubject<Duration?>.seeded(null);

  Timer? _reconnectTimer;
  Timer? _sleepTimer;
  Timer? _metaTimer;
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  final http.Client _http = http.Client();

  String? _lastTitle;
  bool _disposed = false;

  /// El usuario pauso o detuvo a proposito. Sirve para no "resucitar"
  /// la radio con un error que llega tarde.
  bool _userStopped = true;

  /// El usuario pidio cerrar del todo (boton Stop de la notificacion).
  /// Es distinto de pausar: aqui SI hay que dejar morir el servicio,
  /// o la notificacion se queda pegada para siempre.
  bool _serviceStopped = false;

  /// Intentos de reconexion seguidos, para espaciarlos progresivamente.
  int _retries = 0;
  static const int _maxRetries = 8;

  /// Lo mantiene sincronizado main.dart con la preferencia del usuario.
  bool _wifiOnly = false;

  bool get wifiOnly => _wifiOnly;

  set wifiOnly(bool v) {
    if (_wifiOnly == v) return;
    _wifiOnly = v;
    // Si acaba de activarlo y esta sonando por datos, corta.
    if (v && _player.playing) _enforceWifiOnly();
  }

  RadioHandler() {
    _init();
  }

  Future<void> _init() async {
    _player.playbackEventStream.listen(
      _broadcastState,
      onError: (Object e, StackTrace st) => _handleError(),
    );

    _player.playerStateStream.listen((state) {
      if (_disposed) return;

      if (state.processingState == ProcessingState.buffering ||
          state.processingState == ProcessingState.loading) {
        radioState.add(RadioState.connecting);
      } else if (state.playing) {
        // Conexion buena: reinicia el contador de reintentos.
        _retries = 0;
        radioState.add(RadioState.playing);
        _startMetaPolling();
      } else if (!_userStopped) {
        // Se detuvo sin que el usuario lo pidiera.
        radioState.add(RadioState.connecting);
      } else {
        radioState.add(RadioState.paused);
        _stopMetaPolling();
      }
    });

    // Fuente de metadata. El panel de la emisora es mas fiable y da el
    // historial; se usa si esta configurado. Si no, se lee la metadata
    // cruda del propio stream (ICY).
    if (AppConfig.nowPlayingApiUrl.isEmpty) {
      _player.icyMetadataStream.listen((icy) {
        _onNewTitle(Metadata.clean(icy?.info?.title));
      });
    }

    // Si el stream se corta solo, reintenta.
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed && !_userStopped) {
        _scheduleReconnect();
      }
    });

    _connSub = Connectivity().onConnectivityChanged.listen((_) {
      if (_wifiOnly && _player.playing) {
        // Paso de Wi-Fi a datos moviles con la restriccion activa.
        _enforceWifiOnly();
      } else if (!_userStopped && !_player.playing) {
        // Volvio la red despues de una caida: reintenta de inmediato,
        // aunque ya se hubiera agotado la cuenta de reintentos.
        _retries = 0;
        _scheduleReconnect();
      }
    });

    _publishMediaItem(null);
  }

  /// Procesa un titulo ya limpio venga de donde venga (panel o ICY).
  void _onNewTitle(String? clean) {
    if (clean == null || clean == _lastTitle) return;

    _lastTitle = clean;
    nowPlaying.add(clean);
    _publishMediaItem(clean);

    // Los jingles e identificaciones del locutor se muestran en pantalla
    // pero no se guardan en el historial de canciones.
    if (!Metadata.looksLikeJingle(clean)) {
      songChanged.add(clean);
    }
  }

  // ----------------------------------------------------------------
  // Metadata desde el panel de la emisora
  // ----------------------------------------------------------------
  void _startMetaPolling() {
    if (AppConfig.nowPlayingApiUrl.isEmpty) return;
    if (_metaTimer != null) return;

    _fetchNowPlaying();
    _metaTimer = Timer.periodic(
      const Duration(seconds: AppConfig.nowPlayingPollSeconds),
      (_) => _fetchNowPlaying(),
    );
  }

  void _stopMetaPolling() {
    _metaTimer?.cancel();
    _metaTimer = null;
  }

  Future<void> _fetchNowPlaying() async {
    try {
      final res = await _http
          .get(Uri.parse(AppConfig.nowPlayingApiUrl))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      // El campo "title" suele venir vacio en este panel; la cancion
      // actual es el primer elemento del historial.
      String? current = Metadata.clean(data['title'] as String?);
      if (current == null) {
        final history = data['history'];
        if (history is List && history.isNotEmpty) {
          current = Metadata.clean(history.first.toString());
        }
      }

      _onNewTitle(current);
    } catch (_) {
      // Un fallo puntual del panel no debe afectar la reproduccion.
    }
  }

  void _publishMediaItem(String? full) {
    String title = AppConfig.appName;
    String artist = AppConfig.tagline;

    if (full != null) {
      final (t, a) = Metadata.split(full);
      title = t;
      artist = a ?? AppConfig.appName;
    }

    mediaItem.add(
      MediaItem(
        id: AppConfig.streamUrl,
        title: title,
        artist: artist,
        album: AppConfig.appName,
        displayTitle: title,
        displaySubtitle: artist,
      ),
    );
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;

    // Cuando el usuario pausa, soltamos la conexion de red pero NO
    // reportamos "idle": eso destruiria el servicio en primer plano y
    // con el la notificacion, la pantalla de bloqueo y Android Auto.
    var processing = switch (_player.processingState) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };

    if (processing == AudioProcessingState.idle &&
        _userStopped &&
        !_serviceStopped) {
      processing = AudioProcessingState.ready;
    }

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
        ],
        systemActions: const {MediaAction.stop},
        androidCompactActionIndices: const [0],
        processingState: processing,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }

  void _handleError() {
    if (_disposed || _userStopped) return;
    radioState.add(RadioState.error);
    _scheduleReconnect();
  }

  /// Reintenta espaciando cada vez mas: 5, 10, 20, 40, 60, 60...
  void _scheduleReconnect() {
    if (_disposed || _userStopped) return;

    _reconnectTimer?.cancel();

    if (_retries >= _maxRetries) {
      radioState.add(RadioState.error);
      return;
    }

    final seconds =
        (AppConfig.reconnectDelaySeconds * (1 << _retries)).clamp(5, 60);
    _retries++;

    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      if (_disposed || _userStopped) return;
      play();
    });
  }

  /// Devuelve false si el usuario pidio "solo Wi-Fi" y no hay Wi-Fi.
  Future<bool> _connectionAllowed() async {
    if (!_wifiOnly) return true;

    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }

  Future<void> _enforceWifiOnly() async {
    if (await _connectionAllowed()) return;
    await pause();
    radioState.add(RadioState.blockedByWifiOnly);
  }

  @override
  Future<void> play() async {
    _reconnectTimer?.cancel();
    _userStopped = false;
    _serviceStopped = false;

    if (!await _connectionAllowed()) {
      _userStopped = true;
      radioState.add(RadioState.blockedByWifiOnly);
      return;
    }

    radioState.add(RadioState.connecting);

    try {
      // Un stream en vivo no se puede reanudar: al volver hay que abrir
      // la conexion de nuevo para no oir audio viejo del bufer.
      if (_player.processingState == ProcessingState.idle ||
          _player.audioSource == null) {
        await _player.setAudioSource(
          AudioSource.uri(Uri.parse(AppConfig.streamUrl)),
          preload: false,
        );
      }
      await _player.play();
    } catch (_) {
      _handleError();
    }
  }

  @override
  Future<void> pause() async {
    _reconnectTimer?.cancel();
    // Se marca antes de tocar el reproductor para que el error que
    // dispara stop() no se confunda con una caida del stream.
    _userStopped = true;
    _serviceStopped = false;
    _retries = 0;

    await _player.pause();
    // Suelta la conexion para no gastar datos en pausa. La notificacion
    // sigue viva porque _broadcastState reporta "ready", no "idle".
    await _player.stop();

    radioState.add(RadioState.paused);
  }

  @override
  Future<void> stop() async {
    _reconnectTimer?.cancel();
    cancelSleepTimer();
    _userStopped = true;
    // Debe ir antes de tocar el reproductor: asi _broadcastState deja
    // pasar el estado "idle" y audio_service cierra el servicio.
    _serviceStopped = true;
    _retries = 0;

    await _player.stop();
    radioState.add(RadioState.idle);
    await super.stop();
  }

  Future<void> togglePlayPause() =>
      _player.playing ? pause() : play();

  Future<void> setVolume(double v) => _player.setVolume(v.clamp(0.0, 1.0));

  // ----------------------------------------------------------------
  // Temporizador de apagado
  // ----------------------------------------------------------------
  void startSleepTimer(Duration duration) {
    cancelSleepTimer();

    var remaining = duration;
    sleepRemaining.add(remaining);

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      remaining -= const Duration(seconds: 1);

      if (remaining.inSeconds <= 0) {
        t.cancel();
        sleepRemaining.add(null);
        pause();
      } else {
        sleepRemaining.add(remaining);
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    sleepRemaining.add(null);
  }

  /// Libera todo. En la practica no se llama: el servicio de audio vive
  /// mientras viva el proceso. Esta aqui para las pruebas y por si algun
  /// dia se engancha a onTaskRemoved.
  // ignore: unused_element
  Future<void> shutdown() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    _sleepTimer?.cancel();
    _metaTimer?.cancel();
    _http.close();
    await _connSub?.cancel();
    await _player.dispose();
    await nowPlaying.close();
    await radioState.close();
    await songChanged.close();
    await sleepRemaining.close();
  }
}
