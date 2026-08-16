import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'config.dart';
import 'screens/home_shell.dart';
import 'screens/splash_screen.dart';
import 'services/history_service.dart';
import 'services/radio_handler.dart';
import 'services/settings_service.dart';
import 'theme.dart';

late RadioHandler radio;
final historyService = HistoryService();
final settingsService = SettingsService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: RumbaColors.bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  radio = await AudioService.init(
    builder: () => RadioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.rumbapuntocom.radio.audio',
      androidNotificationChannelName: 'Rumba.Com',
      androidNotificationChannelDescription: 'Reproducción de la radio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'drawable/ic_notification',
      notificationColor: RumbaColors.accent,
    ),
  );

  await Future.wait([
    historyService.load(),
    settingsService.load(),
  ]);

  // Guarda en el historial cada cancion nueva que anuncia el stream.
  radio.songChanged.listen(historyService.add);

  // Mantiene la restriccion de "solo Wi-Fi" sincronizada.
  radio.wifiOnly = settingsService.wifiOnly;
  settingsService.addListener(() {
    radio.wifiOnly = settingsService.wifiOnly;
  });

  await radio.setVolume(settingsService.volume);

  // En Android 13+ sin este permiso la notificacion multimedia
  // no se muestra, aunque el audio si suene.
  unawaited(_requestNotificationPermission());

  runApp(const RumbaApp());
}

Future<void> _requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (status.isDenied) {
    await Permission.notification.request();
  }
}

class RumbaApp extends StatelessWidget {
  const RumbaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: buildRumbaTheme(),
      home: const SplashScreen(next: HomeShell()),
    );
  }
}
