class AdConfig {
  static const bool isProduction = true;

  static const String _prodAppIdAndroid = 'ca-app-pub-8348005705345032~7610194958';
  static const String _prodRewardedUnitId = 'ca-app-pub-8348005705345032/5315204105';
  static const String _prodBannerUnitId = 'ca-app-pub-8348005705345032/4984031614';

  static const String _testAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713';
  static const String _testRewardedUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testBannerUnitId = 'ca-app-pub-3940256099942544/6300978111';

  static String get appIdAndroid =>
      isProduction ? _prodAppIdAndroid : _testAppIdAndroid;

  static String get rewardedUnitId =>
      isProduction ? _prodRewardedUnitId : _testRewardedUnitId;

  static String get bannerUnitId =>
      isProduction ? _prodBannerUnitId : _testBannerUnitId;
}
