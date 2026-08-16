import 'package:flutter/material.dart';

import '../config.dart';
import '../theme.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final programs = AppConfig.schedule;

    if (programs.isEmpty) {
      return const _Empty(
        icon: Icons.calendar_today_outlined,
        title: 'Sin programación cargada',
        subtitle: 'Agrega los programas en el archivo config.dart',
      );
    }

    // Agrupa por dia, empezando por hoy.
    final today = DateTime.now().weekday;
    final days = List<int>.generate(7, (i) => ((today - 1 + i) % 7) + 1);

    final sections = <Widget>[];

    for (final day in days) {
      final items = programs.where((p) => p.day == day).toList()
        ..sort((a, b) => a.startHour.compareTo(b.startHour));

      if (items.isEmpty) continue;

      sections.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            children: [
              Text(
                items.first.dayName.toUpperCase(),
                style: const TextStyle(
                  color: RumbaColors.faint,
                  fontSize: 10.5,
                  letterSpacing: 0.8,
                ),
              ),
              if (day == today) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: RumbaColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'HOY',
                    style: TextStyle(
                      color: RumbaColors.accent,
                      fontSize: 9.5,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );

      for (final p in items) {
        sections.add(_ProgramTile(program: p));
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: sections,
    );
  }
}

class _ProgramTile extends StatelessWidget {
  final Program program;

  const _ProgramTile({required this.program});

  @override
  Widget build(BuildContext context) {
    final onAir = program.isOnAir;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: onAir ? RumbaColors.surfaceHigh : RumbaColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: onAir
            ? const Border(
                left: BorderSide(color: RumbaColors.accent, width: 3),
              )
            : null,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                program.timeLabel.split(' - ').first,
                style: TextStyle(
                  color: onAir ? RumbaColors.accent : RumbaColors.text2,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                program.timeLabel.split(' - ').last,
                style: const TextStyle(
                  color: RumbaColors.faint,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          Container(
            width: 0.5,
            height: 34,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: RumbaColors.line,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program.title,
                  style: const TextStyle(
                    color: RumbaColors.text,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  program.host,
                  style: const TextStyle(
                    color: RumbaColors.dim,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          if (onAir)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: RumbaColors.live,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Empty({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: RumbaColors.faint),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: RumbaColors.text2,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: RumbaColors.dim, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
