class AppConstants {
  static const String appName = 'Arrow Escape';
  static const String tagline = 'A relaxing arrow logic puzzle';
  
  static const int maxLevels = 2000;
  static const int initialUnlockedLevel = 1;

  /// TEMPORARY (UI review): shows every level as unlocked in level select.
  /// Stored progress is untouched. Set back to false before release.
  static const bool unlockAllLevels = false;
  
  static const Duration splashDuration = Duration(milliseconds: 1200);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double iconSize = 28.0;
  static const double largeIconSize = 48.0;
  
  static const int boardSize = 6;
  static const double cellSize = 60.0;
  static const double cellSpacing = 4.0;
  
  static const String storageKeyUnlockedLevel = 'unlocked_level';
  static const String storageKeyCompletedLevels = 'completed_levels';
  static const String storageKeyCurrentLevel = 'current_level';
  static const String storageKeyCoins = 'economy_coins';
  static const String storageKeyHearts = 'economy_hearts';
  static const String storageKeyLastHeartRefill = 'economy_last_heart_refill';

  static const int initialHearts = 5;
  static const int maxHearts = 5;
  static const int initialCoins = 10;
  static const int hintCostCoins = 10;
  static const int coinsRewardBase = 10;
  static const int coinsRewardPerDifficulty = 2;
  static const int coinsRewardPerLevelStep = 5;
  
  static const List<int> levelThresholds = [
    1, 5, 10, 20, 35, 55, 80, 110, 145, 185,
    230, 280, 335, 395, 460, 530, 605, 685, 770, 860,
  ];
}