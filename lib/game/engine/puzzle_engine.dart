import '../../models/level.dart';
import '../../models/puzzle_path.dart';
import '../path/path_collision_service.dart';

class GameStateSnapshot {
  final List<PuzzlePath> paths;
  final int moveCount;

  GameStateSnapshot({required this.paths, required this.moveCount});
}

class PuzzleEngine {
  final int boardSize;

  List<PuzzlePath> _paths = [];
  int _moveCount = 0;
  bool _isLevelComplete = false;
  bool _isAnimating = false;
  String? _animatingPathId;
  final List<GameStateSnapshot> _history = [];
  static const int _maxHistorySize = 64;

  PuzzleEngine({required this.boardSize});

  List<PuzzlePath> get paths => List.unmodifiable(_paths);
  List<PuzzlePath> get activePaths =>
      _paths.where((p) => p.state == PathState.active).toList();
  int get moveCount => _moveCount;
  bool get isLevelComplete => _isLevelComplete;
  bool get isAnimating => _isAnimating;
  String? get animatingPathId => _animatingPathId;
  bool get hasPaths => _paths.isNotEmpty;
  bool get canUndo => _history.isNotEmpty && !_isAnimating && !_isLevelComplete;

  void loadLevel(Level level) {
    _paths = level.createPuzzlePaths();
    _moveCount = 0;
    _isLevelComplete = false;
    _isAnimating = false;
    _animatingPathId = null;
    _history.clear();
  }

  void restartLevel(Level level) => loadLevel(level);

  PuzzlePath? getPathById(String id) {
    for (final p in _paths) {
      if (p.id == id) return p;
    }
    return null;
  }

  PuzzlePath? getPathAt(int row, int column) {
    final pt = GridPoint(column, row);
    for (final p in _paths) {
      if (p.state == PathState.active && p.occupiedCells.contains(pt)) {
        return p;
      }
    }
    return null;
  }

  bool canPathMove(PuzzlePath path) {
    if (_isAnimating || _isLevelComplete) return false;
    if (path.state != PathState.active) return false;
    return PathCollisionService.canPathEscape(path, _paths, boardSize);
  }

  PuzzlePath? getBlockingPath(PuzzlePath path) {
    return PathCollisionService.getBlockingPath(path, _paths, boardSize);
  }

  bool beginMove(PuzzlePath path) {
    if (!canPathMove(path)) return false;
    _saveSnapshot();
    _isAnimating = true;
    _animatingPathId = path.id;
    _moveCount++;
    final idx = _paths.indexWhere((p) => p.id == path.id);
    if (idx != -1) {
      _paths[idx] = _paths[idx].copyWith(state: PathState.moving);
    }
    return true;
  }

  bool completeMove(String pathId) {
    if (_animatingPathId != pathId) return false;
    final idx = _paths.indexWhere((p) => p.id == pathId);
    if (idx != -1) {
      _paths[idx] = _paths[idx].copyWith(state: PathState.removed);
    }
    _isAnimating = false;
    _animatingPathId = null;
    final anyActive = _paths.any((p) => p.state == PathState.active);
    if (!anyActive) _isLevelComplete = true;
    return _isLevelComplete;
  }

  void cancelMove() {
    if (!_isAnimating) return;
    final idx = _paths.indexWhere((p) => p.id == _animatingPathId);
    if (idx != -1) {
      _paths[idx] = _paths[idx].copyWith(state: PathState.active);
    }
    _isAnimating = false;
    _animatingPathId = null;
  }

  void undo() {
    if (!canUndo) return;
    final snap = _history.removeLast();
    _paths = snap.paths.map((p) => p.copyWith()).toList();
    _moveCount = snap.moveCount;
    _isLevelComplete = false;
    _isAnimating = false;
    _animatingPathId = null;
  }

  List<PuzzlePath> validMoves() {
    if (_isAnimating || _isLevelComplete) return const [];
    return activePaths.where((p) => canPathMove(p)).toList();
  }

  void _saveSnapshot() {
    _history.add(GameStateSnapshot(
      paths: _paths.map((p) => p.copyWith()).toList(),
      moveCount: _moveCount,
    ));
    if (_history.length > _maxHistorySize) _history.removeAt(0);
  }
}
