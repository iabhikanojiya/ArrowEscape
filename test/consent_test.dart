import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/core/config/ad_config.dart';
import 'package:arrow_escape/models/reward_purpose.dart';
import 'package:arrow_escape/screens/settings/settings_screen.dart';
import 'package:arrow_escape/services/admob_service.dart';
import 'package:arrow_escape/services/consent_service.dart';

enum _Update { success, failure, never }

/// Stands in for Google's UMP ConsentInformation.
class _FakeConsentInfo implements ConsentInformation {
  _FakeConsentInfo({
    this.update = _Update.success,
    this.canRequest = true,
    this.privacyRequired = false,
  });

  _Update update;
  bool canRequest;
  bool privacyRequired;
  int updateRequests = 0;
  ConsentRequestParameters? lastParams;

  @override
  void requestConsentInfoUpdate(
    ConsentRequestParameters params,
    OnConsentInfoUpdateSuccessListener successListener,
    OnConsentInfoUpdateFailureListener failureListener,
  ) {
    updateRequests++;
    lastParams = params;
    switch (update) {
      case _Update.success:
        successListener();
      case _Update.failure:
        failureListener(FormError(errorCode: 2, message: 'offline'));
      case _Update.never:
        break;
    }
  }

  @override
  Future<bool> canRequestAds() async => canRequest;

  @override
  Future<PrivacyOptionsRequirementStatus>
  getPrivacyOptionsRequirementStatus() async => privacyRequired
      ? PrivacyOptionsRequirementStatus.required
      : PrivacyOptionsRequirementStatus.notRequired;

  @override
  Future<ConsentStatus> getConsentStatus() async => ConsentStatus.obtained;

  @override
  Future<bool> isConsentFormAvailable() async => true;

  @override
  Future<void> reset() async {}
}

const _umpChannel = MethodChannel('plugins.flutter.io/google_mobile_ads/ump');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> formCalls;
  final realInfo = ConsentInformation.instance;

  setUp(() {
    formCalls = [];
    ConsentService.debugForceSupported = true;
    ConsentService.instance.debugReset();
    AdmobService.debugShowRewardedHandler = null;
    AdmobService.instance.debugReset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_umpChannel, (call) async {
          formCalls.add(call.method);
          return null; // dismissed without error
        });
  });

  tearDown(() {
    ConsentInformation.instance = realInfo;
    ConsentService.debugForceSupported = false;
    ConsentService.instance.debugReset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_umpChannel, null);
  });

  test('consent obtained: form step runs, then ads are allowed', () async {
    final info = _FakeConsentInfo();
    ConsentInformation.instance = info;

    await ConsentService.instance.gatherConsent();

    expect(info.updateRequests, 1);
    expect(formCalls, [
      'UserMessagingPlatform#loadAndShowConsentFormIfRequired',
    ]);
    expect(ConsentService.instance.canRequestAds, isTrue);
  });

  test('declined / not yet given: ads stay off', () async {
    ConsentInformation.instance = _FakeConsentInfo(canRequest: false);
    await ConsentService.instance.gatherConsent();
    expect(ConsentService.instance.canRequestAds, isFalse);
  });

  test('runs once per launch, even if called repeatedly', () async {
    final info = _FakeConsentInfo();
    ConsentInformation.instance = info;
    await Future.wait([
      ConsentService.instance.gatherConsent(),
      ConsentService.instance.gatherConsent(),
    ]);
    await ConsentService.instance.gatherConsent();
    expect(info.updateRequests, 1);
    expect(formCalls, hasLength(1));
  });

  test('offline with no stored consent: no crash, no form, ads off', () async {
    ConsentInformation.instance = _FakeConsentInfo(
      update: _Update.failure,
      canRequest: false,
    );
    await ConsentService.instance.gatherConsent();
    expect(formCalls, isEmpty);
    expect(ConsentService.instance.canRequestAds, isFalse);
  });

  test('offline with consent from an earlier launch: ads allowed', () async {
    ConsentInformation.instance = _FakeConsentInfo(update: _Update.failure);
    await ConsentService.instance.gatherConsent();
    expect(ConsentService.instance.canRequestAds, isTrue);
  });

  test('UMP plugin errors never escape', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_umpChannel, (call) async {
          throw PlatformException(code: '1', message: 'boom');
        });
    ConsentInformation.instance = _FakeConsentInfo(canRequest: false);
    await ConsentService.instance.gatherConsent();
    expect(ConsentService.instance.canRequestAds, isFalse);
  });

  testWidgets('a consent update that never answers times out', (tester) async {
    ConsentInformation.instance = _FakeConsentInfo(
      update: _Update.never,
      canRequest: false,
    );
    var finished = false;
    ConsentService.instance.gatherConsent().then((_) => finished = true);
    await tester.pump(const Duration(seconds: 5));
    expect(finished, isFalse);
    await tester.pump(const Duration(seconds: 10));
    expect(finished, isTrue);
    expect(formCalls, isEmpty);
  });

  test('no debug geography unless requested via --dart-define', () async {
    final info = _FakeConsentInfo();
    ConsentInformation.instance = info;
    await ConsentService.instance.gatherConsent();
    expect(info.lastParams?.consentDebugSettings, isNull);
  });

  group('ads respect consent', () {
    test('no rewarded ad is requested without consent', () async {
      ConsentInformation.instance = _FakeConsentInfo(canRequest: false);
      await ConsentService.instance.gatherConsent();

      AdmobService.instance.loadRewarded();
      expect(AdmobService.instance.isRewardedReady, isFalse);
      // Same outcome as "no ad available": no reward, no crash.
      expect(
        await AdmobService.instance.showRewarded(purpose: RewardPurpose.coins),
        isFalse,
      );
    });

    test('release build uses production AdMob IDs only', () {
      const testPublisher = '3940256099942544';
      expect(AdConfig.isProduction, isTrue);
      for (final id in [
        AdConfig.appIdAndroid,
        AdConfig.rewardedUnitId,
        AdConfig.bannerUnitId,
      ]) {
        expect(id, isNot(contains(testPublisher)));
        expect(id, startsWith('ca-app-pub-8348005705345032'));
      }
    });
  });

  group('Settings privacy options', () {
    Future<void> pumpSettings(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();
    }

    testWidgets('hidden where consent rules do not apply', (tester) async {
      ConsentInformation.instance = _FakeConsentInfo();
      await tester.runAsync(() => ConsentService.instance.gatherConsent());
      await pumpSettings(tester);
      expect(find.text('Privacy & ad choices'), findsNothing);
    });

    testWidgets('shown when UMP requires it and opens Google form', (
      tester,
    ) async {
      ConsentInformation.instance = _FakeConsentInfo(privacyRequired: true);
      await tester.runAsync(() => ConsentService.instance.gatherConsent());
      await pumpSettings(tester);

      final tile = find.text('Privacy & ad choices');
      await tester.scrollUntilVisible(
        tile,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(formCalls.last, 'UserMessagingPlatform#showPrivacyOptionsForm');
    });
  });
}
