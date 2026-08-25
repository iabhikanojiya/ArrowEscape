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

  static void initialize(SettingsService settings) {
    _settings = settings;
    _loadSettings();
  }

  static Future<void> _loadSettings() async {
    if (_settings != null) {
      _cachedEnabled = await _settings!.getHapticsEnabled();
    }
  }

  static bool get enabled => _cachedEnabled;

  static void setEnabled(bool enabled) {
    _cachedEnabled = enabled;
    _settings?.setHapticsEnabled(enabled);
  }

  static void lightImpact() {
    if (!_cachedEnabled) return;
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    if (!_cachedEnabled) return;
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    if (!_cachedEnabled) return;
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    if (!_cachedEnabled) return;
    HapticFeedback.selectionClick();
  }

  static void success() {
    if (!_cachedEnabled) return;
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_cachedEnabled) HapticFeedback.lightImpact();
    });
  }

  static void warning() {
    if (!_cachedEnabled) return;
    HapticFeedback.heavyImpact();
  }

  static void error() {
    if (!_cachedEnabled) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_cachedEnabled) HapticFeedback.heavyImpact();
    });
  }
}