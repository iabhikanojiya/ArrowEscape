import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsService {
  Future<void> init();
  Future<bool> getHapticsEnabled();
  Future<void> setHapticsEnabled(bool enabled);
  Future<bool> getSoundEnabled();
  Future<void> setSoundEnabled(bool enabled);
  Future<void> reset();
}

class SharedPreferencesSettings implements SettingsService {
  SharedPreferences? _prefs;

  static const String _hapticsKey = 'settings_haptics_enabled';
  static const String _soundKey = 'settings_sound_enabled';

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<bool> getHapticsEnabled() async {
    await _ensureInit();
    return _prefs!.getBool(_hapticsKey) ?? true;
  }

  @override
  Future<void> setHapticsEnabled(bool enabled) async {
    await _ensureInit();
    await _prefs!.setBool(_hapticsKey, enabled);
  }

  @override
  Future<bool> getSoundEnabled() async {
    await _ensureInit();
    return _prefs!.getBool(_soundKey) ?? true;
  }

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    await _ensureInit();
    await _prefs!.setBool(_soundKey, enabled);
  }

  @override
  Future<void> reset() async {
    await _ensureInit();
    await _prefs!.remove(_hapticsKey);
    await _prefs!.remove(_soundKey);
  }

  Future<void> _ensureInit() async {
    if (_prefs == null) {
      await init();
    }
  }
}

class InMemorySettings implements SettingsService {
  bool _hapticsEnabled = true;
  bool _soundEnabled = true;

  @override
  Future<void> init() async {}

  @override
  Future<bool> getHapticsEnabled() async => _hapticsEnabled;

  @override
  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
  }

  @override
  Future<bool> getSoundEnabled() async => _soundEnabled;

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
  }

  @override
  Future<void> reset() async {
    _hapticsEnabled = true;
    _soundEnabled = true;
  }
}

SettingsService createSettingsService({bool useInMemory = false}) {
  return useInMemory ? InMemorySettings() : SharedPreferencesSettings();
}