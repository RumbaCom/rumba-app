import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets/sleep_timer_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: AnimatedBuilder(
        animation: settingsService,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const _Label('REPRODUCCIÓN'),
            const Divider(),

            SwitchListTile(
              value: settingsService.autoPlay,
              onChanged: settingsService.setAutoPlay,
              secondary: const Icon(Icons.play_arrow_rounded),
              title: const Text('Reproducir al abrir'),
              subtitle: const Text(
                'La radio empieza sola al entrar a la app',
                style: TextStyle(color: RumbaColors.dim, fontSize: 12.5),
              ),
            ),

            SwitchListTile(
              value: settingsService.wifiOnly,
              onChanged: settingsService.setWifiOnly,
              secondary: const Icon(Icons.wifi_rounded),
              title: const Text('Solo con Wi-Fi'),
              subtitle: const Text(
                'No reproducir usando datos móviles',
                style: TextStyle(color: RumbaColors.dim, fontSize: 12.5),
              ),
            ),

            StreamBuilder<Duration?>(
              stream: radio.sleepRemaining,
              builder: (context, snap) {
                final r = snap.data;
                return ListTile(
                  leading: const Icon(Icons.bedtime_outlined),
                  title: const Text('Temporizador de apagado'),
                  subtitle: Text(
                    r == null
                        ? 'Desactivado'
                        : 'Faltan ${r.inMinutes + 1} minutos',
                    style: const TextStyle(
                      color: RumbaColors.dim,
                      fontSize: 12.5,
                    ),
                  ),
                  onTap: () => showSleepTimerSheet(context),
                );
              },
            ),

            const _Label('GENERAL'),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Compartir la app'),
              onTap: () => Share.share(
                'Escucha ${AppConfig.appName} — ${AppConfig.playStoreUrl}',
              ),
            ),

            ListTile(
              leading: const Icon(Icons.star_border_rounded),
              title: const Text('Califica la app'),
              onTap: () => _open(AppConfig.playStoreUrl),
            ),

            if (AppConfig.privacyPolicyUrl.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: const Text('Política de privacidad'),
                onTap: () => _open(AppConfig.privacyPolicyUrl),
              ),

            const _Label('ACERCA DE'),
            const Divider(),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: RumbaColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Image.asset('assets/logo.png'),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            AppConfig.appName,
                            style: TextStyle(
                              color: RumbaColors.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Versión ${AppConfig.version}',
                            style: TextStyle(
                              color: RumbaColors.dim,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    AppConfig.tagline,
                    style: TextStyle(color: RumbaColors.dim, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Text(
        text,
        style: const TextStyle(
          color: RumbaColors.faint,
          fontSize: 10.5,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
