import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

abstract class StorageService {
  Future<void> init();
  Future<int> getUnlockedLevel();
  Future<void> setUnlockedLevel(int level);
  Future<Set<int>> getCompletedLevels();
  Future<void> addCompletedLevel(int level);
  Future<int> getCompletedLevelsCount();
  Future<void> resetProgress();
}

class SharedPreferencesStorage implements StorageService {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<int> getUnlockedLevel() async {
    await _ensureInit();
    return _prefs!.getInt(AppConstants.storageKeyUnlockedLevel) ??
        AppConstants.initialUnlockedLevel;
  }

  @override
  Future<void> setUnlockedLevel(int level) async {
    await _ensureInit();
    await _prefs!.setInt(AppConstants.storageKeyUnlockedLevel, level);
  }

  @override
  Future<Set<int>> getCompletedLevels() async {
    await _ensureInit();
    final jsonString = _prefs!.getString(AppConstants.storageKeyCompletedLevels);
    if (jsonString == null) return <int>{};
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.cast<int>().toSet();
  }

  @override
  Future<void> addCompletedLevel(int level) async {
    await _ensureInit();
    final completed = await getCompletedLevels();
    completed.add(level);
    await _prefs!.setString(
      AppConstants.storageKeyCompletedLevels,
      jsonEncode(completed.toList()),
    );

    final unlocked = await getUnlockedLevel();
    if (level + 1 > unlocked) {
      await setUnlockedLevel(level + 1);
    }
  }

  @override
  Future<int> getCompletedLevelsCount() async {
    final completed = await getCompletedLevels();
    return completed.length;
  }

  @override
  Future<void> resetProgress() async {
    await _ensureInit();
    await _prefs!.remove(AppConstants.storageKeyUnlockedLevel);
    await _prefs!.remove(AppConstants.storageKeyCompletedLevels);
    await _prefs!.remove(AppConstants.storageKeyCurrentLevel);
  }

  Future<void> _ensureInit() async {
    if (_prefs == null) {
      await init();
    }
  }
}

class InMemoryStorage implements StorageService {
  int _unlockedLevel = AppConstants.initialUnlockedLevel;
  final Set<int> _completedLevels = <int>{};

  @override
  Future<void> init() async {}

  @override
  Future<int> getUnlockedLevel() async => _unlockedLevel;

  @override
  Future<void> setUnlockedLevel(int level) async {
    _unlockedLevel = level;
  }

  @override
  Future<Set<int>> getCompletedLevels() async => _completedLevels;

  @override
  Future<void> addCompletedLevel(int level) async {
    _completedLevels.add(level);
    if (level + 1 > _unlockedLevel) {
      _unlockedLevel = level + 1;
    }
  }

  @override
  Future<int> getCompletedLevelsCount() async => _completedLevels.length;

  @override
  Future<void> resetProgress() async {
    _unlockedLevel = AppConstants.initialUnlockedLevel;
    _completedLevels.clear();
  }
}

StorageService createStorageService({bool useInMemory = false}) {
  return useInMemory ? InMemoryStorage() : SharedPreferencesStorage();
}