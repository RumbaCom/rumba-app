import 'package:flutter/material.dart';

import '../main.dart';
import '../theme.dart';

const _options = <int>[15, 30, 45, 60, 90, 120];

Future<void> showSleepTimerSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temporizador de apagado',
              style: TextStyle(
                color: RumbaColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'La radio se detiene sola cuando termine el tiempo.',
              style: TextStyle(color: RumbaColors.dim, fontSize: 13),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final m in _options)
                  ActionChip(
                    label: Text('$m min'),
                    backgroundColor: RumbaColors.surfaceHigh,
                    side: BorderSide.none,
                    labelStyle: const TextStyle(color: RumbaColors.text),
                    onPressed: () {
                      radio.startSleepTimer(Duration(minutes: m));
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<Duration?>(
              stream: radio.sleepRemaining,
              builder: (context, snap) {
                if (snap.data == null) return const SizedBox(height: 8);

                return Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      radio.cancelSleepTimer();
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.close_rounded,
                        size: 18, color: RumbaColors.danger),
                    label: const Text(
                      'Cancelar temporizador',
                      style: TextStyle(color: RumbaColors.danger),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
