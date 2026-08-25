import '../../game/engine/puzzle_engine.dart';
import '../../game/path/path_collision_service.dart';
import '../../models/puzzle_path.dart';

abstract class HintService {
  Future<PuzzlePath?> getPathHint(PuzzleEngine engine);
}

class SmartHintService implements HintService {
  @override
  Future<PuzzlePath?> getPathHint(PuzzleEngine engine) async {
    final moves = engine.validMoves();
    if (moves.isEmpty) return null;

    var best = moves.first;
    var bestScore = -1;
    for (final move in moves) {
      final score = _scoreMove(move, engine);
      if (score > bestScore) {
        bestScore = score;
        best = move;
      }
    }
    return best;
  }

  int _scoreMove(PuzzlePath move, PuzzleEngine engine) {
    final remaining =
        engine.activePaths.where((p) => p.id != move.id).toList();
    int unlockedAfter = 0;
    for (final p in remaining) {
      if (PathCollisionService.canPathEscape(p, remaining, engine.boardSize)) {
        unlockedAfter++;
      }
    }
    return unlockedAfter * 50 + move.points.length;
  }
}

HintService createHintService({bool useSmart = true}) {
  return SmartHintService();
}
