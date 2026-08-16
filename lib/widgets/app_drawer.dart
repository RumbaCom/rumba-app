import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../screens/settings_screen.dart';
import '../theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static IconData iconFor(String name) => switch (name) {
        'facebook' => Icons.facebook,
        'instagram' => Icons.camera_alt_outlined,
        'whatsapp' => Icons.chat_bubble_outline_rounded,
        'youtube' => Icons.play_circle_outline,
        'tiktok' => Icons.music_note_outlined,
        'x' => Icons.alternate_email,
        _ => Icons.language,
      };

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: RumbaColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset('assets/logo.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppConfig.appName,
                          style: TextStyle(
                            color: RumbaColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppConfig.tagline,
                          style: const TextStyle(
                            color: RumbaColors.dim,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            const _SectionLabel('SÍGUENOS'),
            for (final s in AppConfig.socials)
              _Item(
                icon: iconFor(s.icon),
                label: s.name,
                onTap: () => _open(context, s.url),
              ),

            const SizedBox(height: 6),
            const Divider(),
            const _SectionLabel('MÁS'),

            _Item(
              icon: Icons.settings_outlined,
              label: 'Configuración',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            _Item(
              icon: Icons.share_outlined,
              label: 'Compartir la app',
              onTap: () {
                Navigator.pop(context);
                Share.share(
                  'Escucha ${AppConfig.appName} — ${AppConfig.playStoreUrl}',
                );
              },
            ),
            _Item(
              icon: Icons.star_border_rounded,
              label: 'Califica la app',
              onTap: () => _open(context, AppConfig.playStoreUrl),
            ),
            _Item(
              icon: Icons.shield_outlined,
              label: 'Política de privacidad',
              onTap: () => _open(context, AppConfig.privacyPolicyUrl),
            ),

            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Text(
                'Versión ${AppConfig.version}',
                style: TextStyle(color: RumbaColors.faint, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    Navigator.pop(context);
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
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

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      leading: Icon(icon, size: 21, color: RumbaColors.dim),
      title: Text(
        label,
        style: const TextStyle(color: RumbaColors.text2, fontSize: 14.5),
      ),
    );
  }
}
