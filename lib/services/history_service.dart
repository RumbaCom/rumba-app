import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import 'metadata.dart';

class SongEntry {
  final String title;
  final String? artist;
  final DateTime playedAt;

  const SongEntry({
    required this.title,
    this.artist,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
        't': title,
        'a': artist,
        'p': playedAt.millisecondsSinceEpoch,
      };

  factory SongEntry.fromJson(Map<String, dynamic> j) => SongEntry(
        title: j['t'] as String? ?? '',
        artist: j['a'] as String?,
        playedAt: DateTime.fromMillisecondsSinceEpoch(
          j['p'] as int? ?? 0,
        ),
      );

  String get display => artist == null ? title : '$artist - $title';
}

/// Guarda las canciones que han sonado, para la pestana "Sonó".
class HistoryService extends ChangeNotifier {
  static const _key = 'song_history_v1';

  final List<SongEntry> _items = [];
  List<SongEntry> get items => List.unmodifiable(_items);

  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_key);
    if (raw == null) return;

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      // Se arma completo aparte: si algo falla a medias,
      // el historial que ya estaba en memoria no se corrompe.
      final parsed = list
          .map((e) => SongEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      _items
        ..clear()
        ..addAll(parsed);
      notifyListeners();
    } catch (_) {
      // Historial corrupto: se descarta sin romper la app.
      await _prefs?.remove(_key);
    }
  }

  Future<void> add(String fullTitle) async {
    final (title, artist) = Metadata.split(fullTitle);

    // No repetir la misma cancion si vuelve a llegar la metadata.
    if (_items.isNotEmpty && _items.first.display == fullTitle) return;

    _items.insert(
      0,
      SongEntry(title: title, artist: artist, playedAt: DateTime.now()),
    );

    if (_items.length > AppConfig.historyLimit) {
      _items.removeRange(AppConfig.historyLimit, _items.length);
    }

    notifyListeners();
    await _save();
  }

  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    await _prefs?.remove(_key);
  }

  Future<void> _save() async {
    final raw = jsonEncode(_items.map((e) => e.toJson()).toList());
    await _prefs?.setString(_key, raw);
  }
}
