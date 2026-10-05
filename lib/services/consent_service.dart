import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google User Messaging Platform (UMP) consent for AdMob, using the UMP SDK
/// bundled with `google_mobile_ads`.
///
/// Follows Google's recommended flow: refresh consent info every launch,
/// show Google's consent form only when UMP says it is required (EEA, UK,
/// Switzerland and other regulated regions), and allow ad requests only when
/// [canRequestAds] is true. Consent itself is stored by the UMP SDK (and read
/// by the Mobile Ads SDK), so there is no app-side consent storage.
///
/// Every step is best-effort: offline, timeouts or UMP errors never block
/// the game; ads simply stay off until consent allows them.
class ConsentService {
  ConsentService._();
  static final ConsentService instance = ConsentService._();

  static const Duration _infoTimeout = Duration(seconds: 12);
  // The form waits on the player.
  static const Duration _formTimeout = Duration(minutes: 10);

  // DEBUG-ONLY consent testing, read from --dart-define and ignored in
  // release/profile builds (see [_requestParameters]):
  //   UMP_DEBUG_GEOGRAPHY=eea | us_state | other
  //   UMP_TEST_DEVICE_IDS=<hashed id from logcat>[,<id>...]
  //   UMP_RESET=true   (forget stored consent so the form shows again)
  static const String _debugGeography = String.fromEnvironment(
    'UMP_DEBUG_GEOGRAPHY',
  );
  static const String _debugTestDeviceIds = String.fromEnvironment(
    'UMP_TEST_DEVICE_IDS',
  );
  static const bool _debugReset = bool.fromEnvironment('UMP_RESET');

  final ValueNotifier<bool> _canRequestAds = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _privacyOptionsRequired = ValueNotifier<bool>(
    false,
  );
  Future<void>? _gatherFuture;

  /// Whether ads may be requested under the user's current consent.
  bool get canRequestAds => _canRequestAds.value;
  ValueListenable<bool> get canRequestAdsListenable => _canRequestAds;

  /// Whether the user must be offered a way to change their choices
  /// (Settings shows "Privacy & ad choices" only when this is true).
  ValueListenable<bool> get privacyOptionsRequiredListenable =>
      _privacyOptionsRequired;

  bool get _supported =>
      debugForceSupported ||
      (!kIsWeb && (Platform.isAndroid || Platform.isIOS));

  /// Runs the startup consent flow once per launch. Safe to call repeatedly.
  Future<void> gatherConsent() => _gatherFuture ??= _gather();

  Future<void> _gather() async {
    if (!_supported) return;
    final info = ConsentInformation.instance;
    try {
      if (kDebugMode && _debugReset) await info.reset();
      // Consent given in an earlier session lets ads start right away,
      // in parallel with the refresh below.
      await _refreshStatus();
      await _requestConsentInfoUpdate(info).timeout(_infoTimeout);
      await _loadAndShowFormIfRequired().timeout(_formTimeout);
    } catch (e) {
      _log('consent flow stopped: $e');
    }
    await _refreshStatus();
  }

  /// Opens Google's privacy options form so the user can change consent.
  /// Returns false if the form could not be shown.
  Future<bool> showPrivacyOptionsForm() async {
    if (!_supported) return false;
    var ok = true;
    try {
      final done = Completer<void>();
      ConsentForm.showPrivacyOptionsForm((error) {
        if (error != null) {
          ok = false;
          _log(
            'privacy options form error ${error.errorCode}: '
            '${error.message}',
          );
        }
        if (!done.isCompleted) done.complete();
      });
      await done.future.timeout(_formTimeout);
    } catch (e) {
      ok = false;
      _log('privacy options form failed: $e');
    }
    await _refreshStatus();
    return ok;
  }

  ConsentRequestParameters _requestParameters() {
    if (!kDebugMode) return ConsentRequestParameters();
    final geography = switch (_debugGeography) {
      'eea' => DebugGeography.debugGeographyEea,
      'us_state' => DebugGeography.debugGeographyRegulatedUsState,
      'other' => DebugGeography.debugGeographyOther,
      _ => null,
    };
    final ids = _debugTestDeviceIds
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (geography == null && ids.isEmpty) return ConsentRequestParameters();
    return ConsentRequestParameters(
      consentDebugSettings: ConsentDebugSettings(
        debugGeography: geography,
        testIdentifiers: ids,
      ),
    );
  }

  Future<void> _requestConsentInfoUpdate(ConsentInformation info) {
    final done = Completer<void>();
    info.requestConsentInfoUpdate(
      _requestParameters(),
      () {
        if (!done.isCompleted) done.complete();
      },
      (error) {
        if (!done.isCompleted) {
          done.completeError(
            'consent info update failed ${error.errorCode}: ${error.message}',
          );
        }
      },
    );
    return done.future;
  }

  Future<void> _loadAndShowFormIfRequired() async {
    final done = Completer<void>();
    await ConsentForm.loadAndShowConsentFormIfRequired((error) {
      if (error != null) {
        _log('consent form error ${error.errorCode}: ${error.message}');
      }
      if (!done.isCompleted) done.complete();
    });
    return done.future;
  }

  Future<void> _refreshStatus() async {
    final info = ConsentInformation.instance;
    try {
      _canRequestAds.value = await info.canRequestAds();
    } catch (e) {
      _log('canRequestAds failed: $e');
    }
    try {
      _privacyOptionsRequired.value =
          await info.getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (e) {
      _log('privacy options status failed: $e');
    }
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[Consent] $message');
  }

  @visibleForTesting
  void debugReset() {
    _gatherFuture = null;
    _canRequestAds.value = false;
    _privacyOptionsRequired.value = false;
  }

  /// Lets widget tests run the flow on the host (not Android/iOS).
  @visibleForTesting
  static bool debugForceSupported = false;
}
