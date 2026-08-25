import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// Abstract economy service for hearts & coins.
/// Keeps game playable without monetization. Hearts are not consumed
/// on level completion in v1; architecture is ready for future rules.
abstract class EconomyService {
  Future<void> init();

  // Coins
  Future<int> getCoins();
  Future<void> setCoins(int value);
  Future<int> addCoins(int amount);
  Future<bool> spendCoins(int amount); // returns false if insufficient

  // Hearts
  Future<int> getHearts();
  Future<void> setHearts(int value);
  Future<int> addHearts(int amount);
  Future<bool> consumeHeart(); // returns false if no hearts
  Future<bool> canPlay(); // hearts > 0
  int get maxHearts => AppConstants.maxHearts;
  int get initialHearts => AppConstants.initialHearts;

  // For future: refill timer, etc. Keep no-op now.
  Future<void> refillHeartsIfNeeded();
  Future<DateTime?> getLastRefillTime();

  // Streams for UI reactivity (optional)
  ValueListenable<int> get coinsListenable;
  ValueListenable<int> get heartsListenable;

  Future<void> reset();
}

class SharedPreferencesEconomy implements EconomyService {
  SharedPreferences? _prefs;
  final ValueNotifier<int> _coinsNotifier = ValueNotifier<int>(AppConstants.initialCoins);
  final ValueNotifier<int> _heartsNotifier = ValueNotifier<int>(AppConstants.initialHearts);

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final coins = _prefs!.getInt(AppConstants.storageKeyCoins) ?? AppConstants.initialCoins;
    final hearts = _prefs!.getInt(AppConstants.storageKeyHearts) ?? AppConstants.initialHearts;
    _coinsNotifier.value = coins;
    _heartsNotifier.value = hearts.clamp(0, AppConstants.maxHearts);
  }

  Future<void> _ensureInit() async {
    if (_prefs == null) await init();
  }

  // Coins
  @override
  Future<int> getCoins() async {
    await _ensureInit();
    return _prefs!.getInt(AppConstants.storageKeyCoins) ?? AppConstants.initialCoins;
  }

  @override
  Future<void> setCoins(int value) async {
    await _ensureInit();
    final clamped = value < 0 ? 0 : value;
    await _prefs!.setInt(AppConstants.storageKeyCoins, clamped);
    _coinsNotifier.value = clamped;
  }

  @override
  Future<int> addCoins(int amount) async {
    final current = await getCoins();
    final next = (current + amount).clamp(0, 999999);
    await setCoins(next);
    return next;
  }

  @override
  Future<bool> spendCoins(int amount) async {
    final current = await getCoins();
    if (current < amount) return false;
    await setCoins(current - amount);
    return true;
  }

  // Hearts
  @override
  Future<int> getHearts() async {
    await _ensureInit();
    return _prefs!.getInt(AppConstants.storageKeyHearts) ?? AppConstants.initialHearts;
  }

  @override
  Future<void> setHearts(int value) async {
    await _ensureInit();
    final clamped = value.clamp(0, AppConstants.maxHearts);
    await _prefs!.setInt(AppConstants.storageKeyHearts, clamped);
    _heartsNotifier.value = clamped;
  }

  @override
  Future<int> addHearts(int amount) async {
    final current = await getHearts();
    final next = (current + amount).clamp(0, AppConstants.maxHearts);
    await setHearts(next);
    return next;
  }

  @override
  Future<bool> consumeHeart() async {
    final current = await getHearts();
    if (current <= 0) return false;
    await setHearts(current - 1);
    return true;
  }

  @override
  Future<bool> canPlay() async {
    final hearts = await getHearts();
    return hearts > 0;
  }

  @override
  int get maxHearts => AppConstants.maxHearts;

  @override
  int get initialHearts => AppConstants.initialHearts;

  @override
  Future<void> refillHeartsIfNeeded() async {
    // v1: always full, no timer. Keep architecture for future timed refill.
    await _ensureInit();
  }

  @override
  Future<DateTime?> getLastRefillTime() async {
    await _ensureInit();
    final ms = _prefs!.getInt(AppConstants.storageKeyLastHeartRefill);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  @override
  ValueListenable<int> get coinsListenable => _coinsNotifier;

  @override
  ValueListenable<int> get heartsListenable => _heartsNotifier;

  @override
  Future<void> reset() async {
    await _ensureInit();
    await _prefs!.setInt(AppConstants.storageKeyCoins, AppConstants.initialCoins);
    await _prefs!.setInt(AppConstants.storageKeyHearts, AppConstants.initialHearts);
    await _prefs!.remove(AppConstants.storageKeyLastHeartRefill);
    _coinsNotifier.value = AppConstants.initialCoins;
    _heartsNotifier.value = AppConstants.initialHearts;
  }
}

class InMemoryEconomy implements EconomyService {
  int _coins = AppConstants.initialCoins;
  int _hearts = AppConstants.initialHearts;
  final ValueNotifier<int> _coinsNotifier = ValueNotifier<int>(AppConstants.initialCoins);
  final ValueNotifier<int> _heartsNotifier = ValueNotifier<int>(AppConstants.initialHearts);
  DateTime? _lastRefill;

  @override
  Future<void> init() async {
    _coinsNotifier.value = _coins;
    _heartsNotifier.value = _hearts;
  }

  @override
  Future<int> getCoins() async => _coins;

  @override
  Future<void> setCoins(int value) async {
    _coins = value < 0 ? 0 : value;
    _coinsNotifier.value = _coins;
  }

  @override
  Future<int> addCoins(int amount) async {
    _coins = (_coins + amount).clamp(0, 999999);
    _coinsNotifier.value = _coins;
    return _coins;
  }

  @override
  Future<bool> spendCoins(int amount) async {
    if (_coins < amount) return false;
    _coins -= amount;
    _coinsNotifier.value = _coins;
    return true;
  }

  @override
  Future<int> getHearts() async => _hearts;

  @override
  Future<void> setHearts(int value) async {
    _hearts = value.clamp(0, AppConstants.maxHearts);
    _heartsNotifier.value = _hearts;
  }

  @override
  Future<int> addHearts(int amount) async {
    _hearts = (_hearts + amount).clamp(0, AppConstants.maxHearts);
    _heartsNotifier.value = _hearts;
    return _hearts;
  }

  @override
  Future<bool> consumeHeart() async {
    if (_hearts <= 0) return false;
    _hearts--;
    _heartsNotifier.value = _hearts;
    return true;
  }

  @override
  Future<bool> canPlay() async => _hearts > 0;

  @override
  int get maxHearts => AppConstants.maxHearts;

  @override
  int get initialHearts => AppConstants.initialHearts;

  @override
  Future<void> refillHeartsIfNeeded() async {}

  @override
  Future<DateTime?> getLastRefillTime() async => _lastRefill;

  @override
  ValueListenable<int> get coinsListenable => _coinsNotifier;

  @override
  ValueListenable<int> get heartsListenable => _heartsNotifier;

  @override
  Future<void> reset() async {
    _coins = AppConstants.initialCoins;
    _hearts = AppConstants.initialHearts;
    _coinsNotifier.value = _coins;
    _heartsNotifier.value = _hearts;
  }
}

EconomyService createEconomyService({bool useInMemory = false}) {
  return useInMemory ? InMemoryEconomy() : SharedPreferencesEconomy();
}

/// Global singleton helper for easy access from UI without DI framework.
/// Lazily initialized. Call EconomyProvider.init() at app start if you want eager.
class EconomyProvider {
  static EconomyService? _instance;

  static EconomyService get instance {
    _instance ??= createEconomyService();
    return _instance!;
  }

  static Future<void> init({bool useInMemory = false}) async {
    _instance = createEconomyService(useInMemory: useInMemory);
    await _instance!.init();
  }

  static void setInstance(EconomyService service) {
    _instance = service;
  }
}
