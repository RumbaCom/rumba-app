import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

/// Preferencias del usuario. Se guardan en el telefono.
class SettingsService extends ChangeNotifier {
  static const _kAutoPlay = 'auto_play';
  static const _kWifiOnly = 'wifi_only';
  static const _kVolume = 'volume';

  SharedPreferences? _prefs;

  bool _autoPlay = AppConfig.autoPlayByDefault;
  bool _wifiOnly = false;
  double _volume = 1.0;

  bool get autoPlay => _autoPlay;
  bool get wifiOnly => _wifiOnly;
  double get volume => _volume;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _autoPlay = _prefs?.getBool(_kAutoPlay) ?? AppConfig.autoPlayByDefault;
    _wifiOnly = _prefs?.getBool(_kWifiOnly) ?? false;
    _volume = _prefs?.getDouble(_kVolume) ?? 1.0;
    notifyListeners();
  }

  Future<void> setAutoPlay(bool v) async {
    _autoPlay = v;
    notifyListeners();
    await _prefs?.setBool(_kAutoPlay, v);
  }

  Future<void> setWifiOnly(bool v) async {
    _wifiOnly = v;
    notifyListeners();
    await _prefs?.setBool(_kWifiOnly, v);
  }

  Future<void> setVolume(double v) async {
    _volume = v;
    notifyListeners();
    await _prefs?.setDouble(_kVolume, v);
  }
}
