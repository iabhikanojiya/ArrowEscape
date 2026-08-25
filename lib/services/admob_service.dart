import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/config/ad_config.dart';
import '../models/reward_purpose.dart';

class AdmobService {
  AdmobService._();

  static final AdmobService instance = AdmobService._();

  static Future<bool> Function(RewardPurpose purpose)? debugShowRewardedHandler;

  bool _isInitialized = false;
  bool _isLoadingRewarded = false;
  RewardedAd? _rewardedAd;

  bool get isInitialized => _isInitialized;
  bool get isRewardedReady => _rewardedAd != null;

  void debugReset() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isLoadingRewarded = false;
    _isInitialized = false;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
    } catch (_) {
      _isInitialized = false;
    }
    loadRewarded();
  }

  void loadRewarded() {
    if (_isLoadingRewarded) return;
    if (_rewardedAd != null) return;
    _isLoadingRewarded = true;
    try {
      RewardedAd.load(
        adUnitId: AdConfig.rewardedUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoadingRewarded = false;
            _setRewardedCallbacks(ad);
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _isLoadingRewarded = false;
          },
        ),
      );
    } catch (_) {
      _isLoadingRewarded = false;
      _rewardedAd = null;
    }
  }

  void _setRewardedCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewarded();
      },
    );
  }

  /// Shows a rewarded ad and resolves ONLY after the user returns from it
  /// (dismissal), so callers can safely update UI state at that point.
  ///
  /// Returns true only when the reward was actually earned via
  /// onUserEarnedReward. Returns false for: no ad available, show
  /// failure, or ad closed without earning the reward.
  Future<bool> showRewarded({required RewardPurpose purpose}) async {
    if (debugShowRewardedHandler != null) {
      return debugShowRewardedHandler!(purpose);
    }
    if (_rewardedAd == null) {
      if (!_isLoadingRewarded) loadRewarded();
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_rewardedAd != null) break;
        if (!_isLoadingRewarded && _rewardedAd == null) break;
      }
      if (_rewardedAd == null) {
        return false;
      }
    }
    final ad = _rewardedAd!;
    _rewardedAd = null;

    var earned = false;
    var settled = false;
    final settledCompleter = Completer<void>();

    void settle() {
      if (settled) return;
      settled = true;
      if (!settledCompleter.isCompleted) settledCompleter.complete();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewarded();
        settle();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewarded();
        settle();
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (adWithoutView, reward) {
          earned = true;
        },
      );
    } catch (_) {
      settle();
      loadRewarded();
      return false;
    }

    // Resume the caller only AFTER the user is back on the screen, so any
    // state update (e.g. hint glow) happens while PlayScreen is visible
    // and its clear-timer starts fresh.
    if (!settled) {
      await settledCompleter.future.timeout(
        const Duration(seconds: 90),
        onTimeout: settle,
      );
    }
    return earned;
  }
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isLoadingRewarded = false;
  }

  BannerAd createBanner({
    required AdSize size,
    void Function(Ad ad)? onLoaded,
    void Function(Ad ad, LoadAdError error)? onFailed,
  }) {
    return BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded ?? (ad) {},
        onAdFailedToLoad: onFailed ??
            (ad, error) {
              ad.dispose();
            },
        onAdOpened: (ad) {},
        onAdClosed: (ad) {},
      ),
    );
  }
}