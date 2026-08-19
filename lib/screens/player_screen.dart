import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../main.dart';
import '../services/metadata.dart';
import '../services/radio_handler.dart';
import '../theme.dart';
import '../widgets/equalizer_background.dart';
import '../widgets/sleep_timer_sheet.dart';
import '../widgets/spinning_logo.dart';

/// Sombra oscura para que el texto resalte sobre el fondo de ecualizador.
const List<Shadow> _titleShadows = [
  Shadow(color: Color(0xE60A0E1A), blurRadius: 12),
  Shadow(color: Color(0xB3000000), blurRadius: 4, offset: Offset(0, 1)),
];

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RadioState>(
      stream: radio.radioState,
      initialData: RadioState.idle,
      builder: (context, snap) {
        final state = snap.data ?? RadioState.idle;
        final isPlaying = state == RadioState.playing;
        final isConnecting = state == RadioState.connecting;

        return Stack(
          children: [
            // Fondo de ecualizador, detras de todo.
            Positioned.fill(
              child: EqualizerBackground(active: isPlaying),
            ),
            SafeArea(
              child: LayoutBuilder(
            builder: (context, constraints) {
              final discSize =
                  (constraints.maxWidth * 0.62).clamp(180.0, 260.0);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        (constraints.maxHeight - 28).clamp(0.0, double.infinity),
                  ),
                  child: Column(
                    children: [
                      _StatusRow(state: state),
                      const SizedBox(height: 20),
                      SpinningLogo(spinning: isPlaying, size: discSize),
                      const SizedBox(height: 26),
                      const _NowPlaying(),
                      const SizedBox(height: 26),
                      _Controls(
                        isPlaying: isPlaying,
                        isConnecting: isConnecting,
                      ),
                      const SizedBox(height: 24),
                      const _VolumeRow(),
                      const SizedBox(height: 20),
                      const _QuickActions(),
                    ],
                  ),
                ),
              );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatusRow extends StatelessWidget {
  final RadioState state;

  const _StatusRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      RadioState.playing => ('En vivo', RumbaColors.live),
      RadioState.connecting => ('Conectando…', RumbaColors.accent),
      RadioState.error => ('Sin conexión, reintentando…', RumbaColors.danger),
      RadioState.blockedByWifiOnly =>
        ('Activa Wi-Fi o desactiva la restricción', RumbaColors.danger),
      _ => ('Detenido', RumbaColors.dim),
    };

    return StreamBuilder<Duration?>(
      stream: radio.sleepRemaining,
      builder: (context, snap) {
        final remaining = snap.data;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                shadows: _titleShadows,
              ),
            ),
            if (remaining != null) ...[
              const SizedBox(width: 14),
              const Icon(Icons.bedtime_outlined,
                  size: 14, color: RumbaColors.dim),
              const SizedBox(width: 4),
              Text(
                _fmt(remaining),
                style: const TextStyle(color: RumbaColors.dim, fontSize: 12),
              ),
            ],
          ],
        );
      },
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

class _NowPlaying extends StatelessWidget {
  const _NowPlaying();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: radio.nowPlaying,
      builder: (context, snap) {
        final full = snap.data;

        if (full == null) {
          return Column(
            children: [
              Text(
                AppConfig.appName,
                style: const TextStyle(
                  color: RumbaColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  shadows: _titleShadows,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                AppConfig.tagline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: RumbaColors.text2,
                  fontSize: 13,
                  shadows: _titleShadows,
                ),
              ),
            ],
          );
        }

        final (title, artist) = Metadata.split(full);

        return Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: RumbaColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.25,
                shadows: _titleShadows,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              artist ?? AppConfig.appName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: RumbaColors.text2,
                fontSize: 14,
                shadows: _titleShadows,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Controls extends StatelessWidget {
  final bool isPlaying;
  final bool isConnecting;

  const _Controls({required this.isPlaying, required this.isConnecting});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundIcon(
          icon: Icons.bedtime_outlined,
          tooltip: 'Temporizador',
          onTap: () => showSleepTimerSheet(context),
        ),
        const SizedBox(width: 30),
        GestureDetector(
          onTap: radio.togglePlayPause,
          child: Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: RumbaColors.accent,
              shape: BoxShape.circle,
            ),
            child: isConnecting
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: RumbaColors.onAccent,
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 42,
                    color: RumbaColors.onAccent,
                  ),
          ),
        ),
        const SizedBox(width: 30),
        _RoundIcon(
          icon: Icons.share_outlined,
          tooltip: 'Compartir',
          onTap: () {
            final song = radio.nowPlaying.valueOrNull;
            final text = song == null
                ? 'Escucha ${AppConfig.appName} — ${AppConfig.playStoreUrl}'
                : 'Estoy escuchando "$song" en ${AppConfig.appName} '
                    '— ${AppConfig.playStoreUrl}';
            Share.share(text);
          },
        ),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, size: 25, color: RumbaColors.dim),
    );
  }
}

class _VolumeRow extends StatefulWidget {
  const _VolumeRow();

  @override
  State<_VolumeRow> createState() => _VolumeRowState();
}

class _VolumeRowState extends State<_VolumeRow> {
  late double _v = settingsService.volume;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          _v == 0 ? Icons.volume_off_rounded : Icons.volume_down_rounded,
          size: 20,
          color: RumbaColors.dim,
        ),
        Expanded(
          child: Slider(
            value: _v,
            onChanged: (v) {
              setState(() => _v = v);
              radio.setVolume(v);
            },
            onChangeEnd: settingsService.setVolume,
          ),
        ),
        const Icon(Icons.volume_up_rounded, size: 20, color: RumbaColors.dim),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Pide tu canción',
            onTap: () => _openWhatsApp(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.favorite_border_rounded,
            label: 'Manda un saludo',
            onTap: () => _openWhatsApp(context, greeting: true),
          ),
        ),
      ],
    );
  }

  Future<void> _openWhatsApp(BuildContext context,
      {bool greeting = false}) async {
    final msg = greeting
        ? 'Hola ${AppConfig.appName}! Quiero mandar un saludo:'
        : AppConfig.whatsappMessage;

    final uri = Uri.parse(
      'https://wa.me/${AppConfig.whatsappNumber}'
      '?text=${Uri.encodeComponent(msg)}',
    );

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );
    }
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RumbaColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 22, color: RumbaColors.accent),
              const SizedBox(height: 7),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: RumbaColors.text2,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
