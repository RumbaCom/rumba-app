import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../config.dart';
import '../main.dart';
import '../services/history_service.dart';
import '../theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: historyService,
      builder: (context, _) {
        final items = historyService.items;

        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.music_note_outlined,
                      size: 44, color: RumbaColors.faint),
                  SizedBox(height: 16),
                  Text(
                    'Todavía no ha sonado nada',
                    style: TextStyle(
                      color: RumbaColors.text2,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Las canciones aparecerán aquí mientras escuchas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: RumbaColors.dim, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
              child: Row(
                children: [
                  Text(
                    '${items.length} canciones',
                    style: const TextStyle(
                      color: RumbaColors.dim,
                      fontSize: 12.5,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _confirmClear(context),
                    child: const Text(
                      'Borrar',
                      style: TextStyle(
                        color: RumbaColors.dim,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(indent: 20),
                itemBuilder: (context, i) => _SongTile(
                  entry: items[i],
                  isCurrent: i == 0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar historial'),
        content: const Text('Se eliminarán todas las canciones guardadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: RumbaColors.dim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Borrar',
                style: TextStyle(color: RumbaColors.danger)),
          ),
        ],
      ),
    );

    if (ok == true) await historyService.clear();
  }
}

class _SongTile extends StatelessWidget {
  final SongEntry entry;
  final bool isCurrent;

  const _SongTile({required this.entry, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final t = entry.playedAt;
    final time = '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isCurrent ? RumbaColors.accent : RumbaColors.surfaceHigh,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          isCurrent ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
          size: 19,
          color: isCurrent ? RumbaColors.onAccent : RumbaColors.dim,
        ),
      ),
      title: Text(
        entry.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: RumbaColors.text,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        entry.artist == null ? time : '${entry.artist}  ·  $time',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: RumbaColors.dim, fontSize: 12.5),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.share_outlined,
            size: 19, color: RumbaColors.faint),
        onPressed: () => Share.share(
          'Escuché "${entry.display}" en ${AppConfig.appName} '
          '— ${AppConfig.playStoreUrl}',
        ),
      ),
    );
  }
}
