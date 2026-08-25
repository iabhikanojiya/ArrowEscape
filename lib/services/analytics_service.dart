import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static FirebaseAnalytics? _analytics;

  static bool get _isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static FirebaseAnalytics? _safeAnalytics() {
    if (!_isFirebaseAvailable) return null;
    try {
      _analytics ??= FirebaseAnalytics.instance;
      return _analytics;
    } catch (_) {
      return null;
    }
  }

  static FirebaseCrashlytics? _safeCrashlytics() {
    if (!_isFirebaseAvailable) return null;
    try {
      return FirebaseCrashlytics.instance;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _logEvent(String name,
      {Map<String, Object>? parameters}) async {
    final analytics = _safeAnalytics();
    if (analytics == null) {
      if (kDebugMode) debugPrint('[Analytics] $name $parameters (no Firebase)');
      return;
    }
    try {
      await analytics.logEvent(name: name, parameters: parameters);
      if (kDebugMode) {
        debugPrint('[Analytics] $name $parameters');
      }
    } catch (e, stack) {
      if (kDebugMode) debugPrint('[Analytics] failed $name: $e');
      try {
        await _safeCrashlytics()
            ?.recordError(e, stack, reason: 'Analytics logEvent failed: $name');
      } catch (_) {}
    }
  }

  static Future<void> _logCrash(String message) async {
    try {
      await _safeCrashlytics()?.log(message);
    } catch (_) {}
  }

  static Future<void> logLevelStarted(int level) async {
    await _logEvent('level_started', parameters: {'level': level});
    await _setCrashlyticsContext(level: level);
    await _logCrash('level_started level=$level');
  }

  static Future<void> logLevelCompleted(
      int level, int moves, int durationSeconds) async {
    await _logEvent('level_completed', parameters: {
      'level': level,
      'moves': moves,
      'duration_seconds': durationSeconds,
    });
    await _logCrash(
        'level_completed level=$level moves=$moves duration=$durationSeconds');
  }

  static Future<void> logLevelRestarted(int level, String reason) async {
    await _logEvent('level_restarted',
        parameters: {'level': level, 'reason': reason});
    await _logCrash('level_restarted level=$level reason=$reason');
  }

  static Future<void> logLifeLost(int level) async {
    await _logEvent('life_lost', parameters: {'level': level});
    await _logCrash('life_lost level=$level');
  }

  static Future<void> logOutOfLives(int level) async {
    await _logEvent('out_of_lives', parameters: {'level': level});
    await _logCrash('out_of_lives level=$level');
  }

  static Future<void> logArrowBlocked(int level) async {
    await _logEvent('arrow_blocked', parameters: {'level': level});
  }

  static Future<void> logHintUsed(int level, String method) async {
    await _logEvent('hint_used',
        parameters: {'level': level, 'method': method});
    await _logCrash('hint_used level=$level method=$method');
  }

  static Future<void> logRewardedAdStarted(
      String placement, int? level) async {
    final params = <String, Object>{'placement': placement};
    if (level != null) params['level'] = level;
    await _logEvent('rewarded_ad_started', parameters: params);
    await _logCrash(
        'rewarded_ad_started placement=$placement level=$level');
  }

  static Future<void> logRewardedAdCompleted(
      String placement, int? level) async {
    final params = <String, Object>{'placement': placement};
    if (level != null) params['level'] = level;
    await _logEvent('rewarded_ad_completed', parameters: params);
    await _logCrash(
        'rewarded_ad_completed placement=$placement level=$level');
  }

  static Future<void> logRewardedAdFailed(
      String placement, String reason) async {
    await _logEvent('rewarded_ad_failed',
        parameters: {'placement': placement, 'reason': reason});
    await _logCrash(
        'rewarded_ad_failed placement=$placement reason=$reason');
  }

  static Future<void> logExtraLifeEarned(int level, int amount) async {
    await _logEvent('extra_life_earned',
        parameters: {'level': level, 'amount': amount});
  }

  static Future<void> logCoinsEarned(
      int amount, String source, int? level) async {
    final params = <String, Object>{'amount': amount, 'source': source};
    if (level != null) params['level'] = level;
    await _logEvent('coins_earned', parameters: params);
  }

  static Future<void> logCoinsSpent(
      int amount, String source, int? level) async {
    final params = <String, Object>{'amount': amount, 'source': source};
    if (level != null) params['level'] = level;
    await _logEvent('coins_spent', parameters: params);
  }

  static Future<void> _setCrashlyticsContext({int? level}) async {
    final c = _safeCrashlytics();
    if (c == null) return;
    try {
      if (level != null) {
        await c.setCustomKey('current_level', level);
      }
    } catch (_) {}
  }

  static Future<void> setCrashlyticsContext(
      {int? level, int? lives, int? coins}) async {
    final c = _safeCrashlytics();
    if (c == null) return;
    try {
      if (level != null) {
        await c.setCustomKey('current_level', level);
      }
      if (lives != null) {
        await c.setCustomKey('lives', lives);
      }
      if (coins != null) {
        await c.setCustomKey('coins', coins);
      }
    } catch (_) {}
  }

  static Future<void> logCrashlytics(String message) async {
    await _logCrash(message);
  }

  static Future<void> recordError(dynamic error, StackTrace? stack,
      {String? reason}) async {
    try {
      await _safeCrashlytics()
          ?.recordError(error, stack, reason: reason, fatal: false);
    } catch (_) {}
  }

  static Future<void> testCrash() async {
    try {
      throw StateError('Test crash for Crashlytics verification');
    } catch (e, stack) {
      await _safeCrashlytics()
          ?.recordError(e, stack, reason: 'Test crash - remove before production');
      if (kDebugMode) debugPrint('[Crashlytics] test crash recorded');
    }
  }
}
