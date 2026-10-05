import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../game/levels/level_world.dart';
import '../economy/economy_service.dart';
import '../storage/storage_service.dart';

enum AchievementKind { firstLevel, category }

enum AchievementState { locked, claimable, claimed }

/// A static achievement definition. Category achievements are derived from
/// [LevelWorlds.all], so new worlds get an achievement automatically.
class AchievementDef {
  final String id;
  final AchievementKind kind;
  final String title;
  final String description;
  final int reward;
  final int startLevel;
  final int endLevel;

  const AchievementDef({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    required this.reward,
    required this.startLevel,
    required this.endLevel,
  });

  int get totalLevels => endLevel - startLevel + 1;

  bool isMet(Set<int> completedLevels) =>
      completedIn(completedLevels) == totalLevels;

  int completedIn(Set<int> completedLevels) =>
      completedLevels.where((id) => id >= startLevel && id <= endLevel).length;
}

class AchievementStatus {
  final AchievementDef def;
  final AchievementState state;
  final int completedLevels;

  const AchievementStatus({
    required this.def,
    required this.state,
    required this.completedLevels,
  });
}

/// Achievement unlock / claim state.
///
/// Persisted as one JSON document under [storageKey], separate from the coin
/// balance. Rewards are paid only through [EconomyProvider], so the existing
/// coin listener (Play Games "Coins Earned" submission) picks them up with no
/// achievement-specific leaderboard code.
///
/// Unlocked and claimed ids are never removed, so an achievement pays out at
/// most once per install, including after replays or a progress reset.
class AchievementService {
  AchievementService({StorageService? storage})
    : _storage = storage ?? createStorageService();

  static AchievementService? _instance;
  static AchievementService get instance => _instance ??= AchievementService();
  static void setInstance(AchievementService? service) => _instance = service;

  static const String storageKey = 'achievements_state';
  static const int firstStepReward = 20;
  static const int categoryReward = 50;

  final StorageService _storage;
  // Serialises load/claim so rapid taps can't pay a reward twice.
  Future<void> _queue = Future<void>.value();

  static const AchievementDef firstStep = AchievementDef(
    id: 'first_step',
    kind: AchievementKind.firstLevel,
    title: 'First Step',
    description: 'Complete Level 1',
    reward: firstStepReward,
    startLevel: 1,
    endLevel: 1,
  );

  static final List<AchievementDef> definitions = [
    firstStep,
    for (final w in LevelWorlds.all)
      AchievementDef(
        id: 'category_world_${w.world}',
        kind: AchievementKind.category,
        title: w.title,
        description: 'Complete all ${w.title} levels',
        reward: categoryReward,
        startLevel: w.startId,
        endLevel: w.endId,
      ),
  ];

  static AchievementDef? definitionFor(String id) {
    for (final d in definitions) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// Unlocks any achievement whose levels are all completed, then returns the
  /// status of every achievement in display order.
  Future<List<AchievementStatus>> load() => _serial(() async {
    final completed = await _completedLevels();
    final state = await _sync(completed);
    return [
      for (final d in definitions)
        AchievementStatus(
          def: d,
          state: state.claimed.contains(d.id)
              ? AchievementState.claimed
              : state.unlocked.contains(d.id)
              ? AchievementState.claimable
              : AchievementState.locked,
          completedLevels: d.completedIn(completed),
        ),
    ];
  });

  /// Unlocks any achievement whose levels are all completed. Never pays
  /// rewards and never throws, so callers on the level-complete path are
  /// unaffected by storage errors.
  Future<void> syncUnlocks() async {
    try {
      await _serial(() async => _sync(await _completedLevels()));
    } catch (e) {
      if (kDebugMode) debugPrint('[Achievements] sync failed: $e');
    }
  }

  /// Claims [id]'s reward. Returns the coins awarded, or null when the
  /// achievement is unknown, still locked or already claimed.
  Future<int?> claim(String id) => _serial(() async {
    final def = definitionFor(id);
    if (def == null) return null;
    final state = await _sync(await _completedLevels());
    if (!state.unlocked.contains(id) || state.claimed.contains(id)) {
      return null;
    }
    // Marked claimed before paying: a failure can lose a reward but can
    // never pay it twice.
    state.claimed.add(id);
    await _write(state);
    await EconomyProvider.instance.addCoins(def.reward);
    return def.reward;
  });

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<Set<int>> _completedLevels() async {
    await _storage.init();
    return _storage.getCompletedLevels();
  }

  Future<_StoredState> _sync(Set<int> completed) async {
    final state = await _read();
    var changed = false;
    for (final d in definitions) {
      if (!state.unlocked.contains(d.id) && d.isMet(completed)) {
        state.unlocked.add(d.id);
        changed = true;
      }
    }
    if (changed) await _write(state);
    return state;
  }

  Future<_StoredState> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null) return _StoredState({}, {});
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _StoredState(
        {...(map['unlocked'] as List? ?? const []).cast<String>()},
        {...(map['claimed'] as List? ?? const []).cast<String>()},
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Achievements] bad stored state: $e');
      return _StoredState({}, {});
    }
  }

  Future<void> _write(_StoredState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      storageKey,
      jsonEncode({
        'v': 1,
        'unlocked': state.unlocked.toList()..sort(),
        'claimed': state.claimed.toList()..sort(),
      }),
    );
  }
}

class _StoredState {
  final Set<String> unlocked;
  final Set<String> claimed;

  _StoredState(this.unlocked, this.claimed);
}
