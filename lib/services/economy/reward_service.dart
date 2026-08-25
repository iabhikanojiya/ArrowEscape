import '../../core/constants/app_constants.dart';
import '../../models/level.dart';
import 'economy_service.dart';

class RewardResult {
  final int coinsAwarded;
  final int totalCoins;
  final int levelId;
  final bool isFirstCompletion;

  const RewardResult({
    required this.coinsAwarded,
    required this.totalCoins,
    required this.levelId,
    required this.isFirstCompletion,
  });
}

abstract class RewardService {
  /// Calculate reward without awarding.
  int calculateReward(Level level);

  /// Award reward if not already awarded for this level. Returns result.
  /// Non-aggressive: small amounts, no penalty.
  Future<RewardResult> awardRewardForLevel(Level level);

  /// Award coins for generic action (e.g., daily bonus). Kept for future.
  Future<int> awardCoins(int amount);
}

class SimpleRewardService implements RewardService {
  final EconomyService _economy;
  final Set<int> _awardedCache = {};

  SimpleRewardService({EconomyService? economy}) : _economy = economy ?? EconomyProvider.instance;

  @override
  int calculateReward(Level level) {
    // Base + difficulty bonus + mild level progression
    // Keeps game generous: levels 1-20 ~10-14 coins, 21-50 ~15-19 etc
    final base = AppConstants.coinsRewardBase;
    final diff = level.difficulty ?? 1;
    final diffBonus = diff * AppConstants.coinsRewardPerDifficulty;
    // Every 10 levels add a small step
    final step = (level.levelId ~/ 10) * 1;
    // Grid size bonus: larger board slightly more
    final sizeBonus = (level.gridSize - 5).clamp(0, 3);
    return base + diffBonus + step + sizeBonus;
  }

  @override
  Future<RewardResult> awardRewardForLevel(Level level) async {
    await _economy.init();
    // Ideally we would check if level already completed before awarding,
    // but caller (GameScreen) already checks storage. We double-check via cache
    // and via economy transaction log could be added later.
    final isFirst = !_awardedCache.contains(level.levelId);
    // We award anyway; if player replays, give reduced reward (50%)
    final fullReward = calculateReward(level);
    final reward = isFirst ? fullReward : (fullReward ~/ 2).clamp(5, fullReward);

    final total = await _economy.addCoins(reward);
    _awardedCache.add(level.levelId);
    return RewardResult(
      coinsAwarded: reward,
      totalCoins: total,
      levelId: level.levelId,
      isFirstCompletion: isFirst,
    );
  }

  @override
  Future<int> awardCoins(int amount) async {
    await _economy.init();
    return _economy.addCoins(amount);
  }
}

/// Global provider for reward service.
class RewardProvider {
  static RewardService? _instance;
  static RewardService get instance => _instance ??= SimpleRewardService();
  static void setInstance(RewardService service) => _instance = service;
  static Future<void> init({RewardService? service}) async {
    _instance = service ?? SimpleRewardService();
    await EconomyProvider.instance.init();
  }
}
