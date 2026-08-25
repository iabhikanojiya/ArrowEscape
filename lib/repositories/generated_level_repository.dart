import 'dart:math' as math;

import '../core/constants/app_constants.dart';
import '../game/engine/level_generator.dart';
import '../models/level.dart';
import 'level_repository.dart';

class GeneratedLevelRepository implements LevelRepository {
  GeneratedLevelRepository._internal();

  static final GeneratedLevelRepository _instance =
      GeneratedLevelRepository._internal();

  factory GeneratedLevelRepository() => _instance;

  final Map<int, Level> _cache = {};
  List<Level>? _allLevels;

  @override
  Future<void> init() async {}

  Level? getLevelSync(int levelId) {
    final clamped = math.min(math.max(levelId, 1), AppConstants.maxLevels);
    return _cache[clamped] ??= LevelGenerator.generate(clamped);
  }

  @override
  Future<Level?> getLevel(int levelId) async {
    return getLevelSync(levelId);
  }

  @override
  Future<List<Level>> getAllLevels() async {
    return _allLevels ??= [
      for (int i = 1; i <= AppConstants.maxLevels; i++) getLevelSync(i)!,
    ];
  }

  @override
  Future<List<Level>> getLevelsInRange(int start, int end) async {
    final result = <Level>[];
    for (int i = math.max(1, start); i <= math.min(AppConstants.maxLevels, end); i++) {
      result.add(getLevelSync(i)!);
    }
    return result;
  }

  @override
  Future<int> getTotalLevelCount() async {
    return AppConstants.maxLevels;
  }

  @override
  Future<Level?> getNextLevel(int currentLevelId) async {
    if (currentLevelId >= AppConstants.maxLevels) return null;
    return getLevelSync(currentLevelId + 1);
  }

  @override
  Future<Level?> getPreviousLevel(int currentLevelId) async {
    if (currentLevelId <= 1) return null;
    return getLevelSync(currentLevelId - 1);
  }
}
