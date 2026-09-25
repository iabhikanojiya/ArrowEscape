import 'package:flutter/services.dart';

import '../settings/settings_service.dart';

enum HapticType {
  light,
  medium,
  heavy,
  selection,
  success,
  warning,
  error,
}

class HapticService {
  static SettingsService? _settings;
  static bool _cachedEnabled = true;

  static Future<void> initialize(SettingsService settings) async {
    _settings = settings;
    await _loadSettings();
  }

  static Future<void> _loadSettings() async {
    if (_settings != null) {
      try {
        _cachedEnabled = await _settings!.getHapticsEnabled();
      } catch (_) {
        _cachedEnabled = true;
      }
    }
  }

  /// Ensures [_cachedEnabled] is up-to-date by re-reading from [_settings]
  static Future<void> _ensureFresh() async {
    if (_settings != null) {
      try {
        _cachedEnabled = await _settings!.getHapticsEnabled();
      } catch (_) {}
    }
  }

  static bool get enabled => _cachedEnabled;

  static Future<void> setEnabled(bool enabled) async {
    _cachedEnabled = enabled;
    if (_settings != null) {
      try {
        await _settings!.setHapticsEnabled(enabled);
        return;
      } catch (_) {}
    }
    // Fallback if _settings not yet set
    try {
      final s = createSettingsService();
      await s.init();
      await s.setHapticsEnabled(enabled);
      _settings = s;
    } catch (_) {}
  }

  static void lightImpact() {
    if (!_cachedEnabled) return;
    _ensureFresh();
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    if (!_cachedEnabled) return;
    _ensureFresh();
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    if (!_cachedEnabled) return;
    _ensureFresh();
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    if (!_cachedEnabled) return;
    _ensureFresh();
    HapticFeedback.selectionClick();
  }

  static void success() {
    if (!_cachedEnabled) return;
    _ensureFresh();
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_cachedEnabled) HapticFeedback.lightImpact();
    });
  }

  static void warning() {
    if (!_cachedEnabled) return;
    _ensureFresh();
    HapticFeedback.heavyImpact();
  }

  static void error() {
    if (!_cachedEnabled) return;
    _ensureFresh();
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_cachedEnabled) HapticFeedback.heavyImpact();
    });
  }
}
