import '../models/level.dart';

abstract class LevelRepository {
  Future<void> init();
  Future<Level?> getLevel(int levelId);
  Future<List<Level>> getAllLevels();
  Future<List<Level>> getLevelsInRange(int start, int end);
  Future<int> getTotalLevelCount();
  Future<Level?> getNextLevel(int currentLevelId);
  Future<Level?> getPreviousLevel(int currentLevelId);
}