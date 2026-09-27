import 'package:shared_preferences/shared_preferences.dart';

/// One-time gameplay tips, remembered for the lifetime of the install.
class TipsService {
  static const _blockedTipKey = 'tip_blocked_arrow_seen';

  /// True until the "arrow is blocked" tip has been shown once.
  static Future<bool> shouldShowBlockedTip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool(_blockedTipKey) ?? false);
    } catch (_) {
      return false;
    }
  }

  static Future<void> markBlockedTipShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_blockedTipKey, true);
    } catch (_) {}
  }
}
