import 'package:shared_preferences/shared_preferences.dart';

abstract class HintManager {
  Future<void> init();
  Future<int> getHintsUsed();
  Future<void> useHint();
  Future<int> getHintsAvailable();
  Future<void> addHints(int count);
  Future<void> reset();
}

class SharedPreferencesHintManager implements HintManager {
  SharedPreferences? _prefs;
  static const String _hintsUsedKey = 'hints_used';
  static const String _hintsAvailableKey = 'hints_available';
  static const int _initialHints = 3;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<int> getHintsUsed() async {
    await _ensureInit();
    return _prefs!.getInt(_hintsUsedKey) ?? 0;
  }

  @override
  Future<void> useHint() async {
    await _ensureInit();
    final used = await getHintsUsed();
    await _prefs!.setInt(_hintsUsedKey, used + 1);
  }

  @override
  Future<int> getHintsAvailable() async {
    await _ensureInit();
    final available = _prefs!.getInt(_hintsAvailableKey);
    if (available == null) {
      await _prefs!.setInt(_hintsAvailableKey, _initialHints);
      return _initialHints;
    }
    return available;
  }

  @override
  Future<void> addHints(int count) async {
    await _ensureInit();
    final available = await getHintsAvailable();
    await _prefs!.setInt(_hintsAvailableKey, available + count);
  }

  @override
  Future<void> reset() async {
    await _ensureInit();
    await _prefs!.remove(_hintsUsedKey);
    await _prefs!.remove(_hintsAvailableKey);
  }

  Future<void> _ensureInit() async {
    if (_prefs == null) {
      await init();
    }
  }
}

class InMemoryHintManager implements HintManager {
  int _hintsUsed = 0;
  int _hintsAvailable = 3;

  @override
  Future<void> init() async {}

  @override
  Future<int> getHintsUsed() async => _hintsUsed;

  @override
  Future<void> useHint() async {
    _hintsUsed++;
  }

  @override
  Future<int> getHintsAvailable() async => _hintsAvailable;

  @override
  Future<void> addHints(int count) async {
    _hintsAvailable += count;
  }

  @override
  Future<void> reset() async {
    _hintsUsed = 0;
    _hintsAvailable = 3;
  }
}

HintManager createHintManager({bool useInMemory = false}) {
  return useInMemory ? InMemoryHintManager() : SharedPreferencesHintManager();
}