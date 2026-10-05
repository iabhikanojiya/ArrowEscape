import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/theme/app_theme.dart';
import '../services/admob_service.dart';
import '../services/consent_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    final consent = ConsentService.instance;
    if (consent.canRequestAds) {
      _loadAd();
    } else {
      // Waits for the UMP consent flow; loads as soon as ads are allowed.
      consent.canRequestAdsListenable.addListener(_onConsentChanged);
    }
  }

  void _onConsentChanged() {
    final consent = ConsentService.instance;
    if (!consent.canRequestAds || !mounted) return;
    consent.canRequestAdsListenable.removeListener(_onConsentChanged);
    _loadAd();
  }

  Future<void> _loadAd() async {
    try {
      AdSize size = AdSize.banner;
      try {
        final width = MediaQuery.of(context).size.width.truncate();
        final adaptiveSize =
            await AdSize.getAnchoredAdaptiveBannerAdSize(
          Orientation.portrait,
          width,
        );
        if (adaptiveSize != null) {
          size = adaptiveSize;
        }
      } catch (_) {}

      final banner = AdmobService.instance.createBanner(
        size: size,
        onLoaded: (ad) {
          if (!mounted) return;
          setState(() => _isLoaded = true);
        },
        onFailed: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _isLoaded = false);
        },
      );
      _bannerAd = banner;
      await _bannerAd!.load();
    } catch (_) {
      if (mounted) setState(() => _isLoaded = false);
    }
  }

  @override
  void dispose() {
    ConsentService.instance.canRequestAdsListenable
        .removeListener(_onConsentChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      color: Colors.white,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

class BannerAdPlaceholder extends StatelessWidget {
  const BannerAdPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      color: AppTheme.chipFill.withValues(alpha: 0.5),
      child: Text(
        'Ad',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.subtleText.withValues(alpha: 0.6),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
