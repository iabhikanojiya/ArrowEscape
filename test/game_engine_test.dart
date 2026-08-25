import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_escape/game/engine/level_generator.dart';
import 'package:arrow_escape/game/engine/puzzle_engine.dart';
import 'package:arrow_escape/game/path/path_collision_service.dart';
import 'package:arrow_escape/models/arrow.dart';
import 'package:arrow_escape/models/level.dart';
import 'package:arrow_escape/models/puzzle_path.dart';

PuzzlePath path(String id, List<List<int>> pts, ArrowDirection dir) {
  return PuzzlePath(
    id: id,
    points: [for (final p in pts) GridPoint(p[0], p[1])],
    direction: dir,
  );
}

void main() {
  group('PathCollisionService', () {
    test('straight path escapes when corridor clear', () {
      final mover = path('m', [
        [0, 4],
        [3, 4],
      ], ArrowDirection.right);
      expect(PathCollisionService.canPathEscape(mover, [mover], 9), isTrue);
    });

    test('blocked by path ahead in same row', () {
      final mover = path('m', [
        [0, 4],
        [3, 4],
      ], ArrowDirection.right);
      final blocker = path('b', [
        [6, 4],
        [7, 5],
        [7, 7],
      ], ArrowDirection.down);
      expect(
          PathCollisionService.canPathEscape(mover, [mover, blocker], 9),
          isFalse);
      expect(PathCollisionService.getBlockingPath(mover, [mover, blocker], 9),
          same(blocker));
    });

    test('multi-row path sweeps all its rows when moving right', () {
      final mover = path('m', [
        [0, 0],
        [0, 2],
        [3, 2],
      ], ArrowDirection.right);
      final blockerAbove = path('ba', [
        [6, 0],
        [8, 0],
      ], ArrowDirection.right);
      final blockerBelow = path('bb', [
        [5, 2],
        [6, 3],
      ], ArrowDirection.down);

      expect(
          PathCollisionService.canPathEscape(mover, [mover, blockerAbove], 9),
          isFalse);
      expect(
          PathCollisionService.canPathEscape(mover, [mover, blockerBelow], 9),
          isFalse);
    });

    test('removed paths no longer block', () {
      final mover = path('m', [
        [0, 4],
        [3, 4],
      ], ArrowDirection.right);
      final removed = path('r', [
        [6, 4],
      ], ArrowDirection.right)
        ..state = PathState.removed;
      expect(
          PathCollisionService.canPathEscape(mover, [mover, removed], 9),
          isTrue);
    });
  });

  group('PuzzleEngine', () {
    Level buildLevel() {
      return Level(
        levelId: 1,
        gridSize: 7,
        puzzlePaths: [
          path('1', [
            [0, 0],
            [2, 0],
          ], ArrowDirection.right),
          path('2', [
            [6, 1],
            [6, 3],
          ], ArrowDirection.down),
          path('3', [
            [5, 5],
            [2, 5],
          ], ArrowDirection.left),
          path('4', [
            [6, 6],
            [6, 4],
            [4, 4],
          ], ArrowDirection.left),
        ],
      );
    }

    test('initial state has expected free and blocked paths', () {
      final engine = PuzzleEngine(boardSize: 7)..loadLevel(buildLevel());
      final p1 = engine.getPathById('1')!;
      final p2 = engine.getPathById('2')!;
      final p3 = engine.getPathById('3')!;
      final p4 = engine.getPathById('4')!;
      expect(engine.canPathMove(p1), isTrue);
      expect(engine.canPathMove(p3), isTrue);
      expect(engine.canPathMove(p4), isFalse,
          reason: 'blocked by path 3 sweeping row 5');
      expect(engine.canPathMove(p2), isFalse,
          reason: 'blocked by path 4 occupying column 6');
    });

    test('move lifecycle removes path and completes level', () {
      final engine = PuzzleEngine(boardSize: 7)..loadLevel(buildLevel());
      final first = engine.getPathById('1')!;
      expect(engine.beginMove(first), isTrue);
      expect(engine.isAnimating, isTrue);
      expect(engine.getPathById('1')!.state, PathState.moving);
      expect(engine.moveCount, 1);

      final completed = engine.completeMove('1');
      expect(completed, isFalse);
      expect(engine.isAnimating, isFalse);
      expect(engine.getPathById('1')!.state, PathState.removed);
    });

    test('cannot start move while animating or undo mid-animation', () {
      final engine = PuzzleEngine(boardSize: 7)..loadLevel(buildLevel());
      final first = engine.getPathById('1')!;
      engine.beginMove(first);
      expect(engine.canUndo, isFalse);
      expect(engine.beginMove(engine.getPathById('2')!), isFalse);
      engine.completeMove('1');
      expect(engine.canUndo, isTrue);
    });

    test('undo restores previous snapshot exactly', () {
      final engine = PuzzleEngine(boardSize: 7)..loadLevel(buildLevel());
      final first = engine.getPathById('1')!;
      final before = engine.activePaths.map((p) => p.id).toSet();
      engine.beginMove(first);
      engine.completeMove('1');
      engine.undo();
      expect(engine.moveCount, 0);
      expect(engine.isAnimating, isFalse);
      expect(engine.getPathById('1')!.state, PathState.active);
      expect(engine.activePaths.map((p) => p.id).toSet(), before);
    });
  });

  group('LevelGenerator', () {
    bool solvable(List<PuzzlePath> all, int gridSize) {
      final byIndex = all;
      final startMask = (1 << all.length) - 1;
      final seen = <int>{};
      bool dfs(int mask) {
        if (mask == 0) return true;
        if (seen.contains(mask)) return false;
        seen.add(mask);
        final remaining = <PuzzlePath>[];
        for (int i = 0; i < byIndex.length; i++) {
          if (mask & (1 << i) != 0) remaining.add(byIndex[i]);
        }
        for (final candidate in remaining) {
          if (!PathCollisionService.canPathEscape(candidate, remaining, gridSize)) {
            continue;
          }
          if (dfs(mask & ~(1 << byIndex.indexOf(candidate)))) return true;
        }
        return false;
      }

      return dfs(startMask);
    }

    test('generated levels are valid and always have an opening move', () {
      final repoLevels = [for (int id = 1; id <= 60; id++) LevelGenerator.generate(id)];
      for (final level in repoLevels) {
        expect(level.isValid, isTrue,
            reason: 'level ${level.levelId} invalid');
        expect(level.puzzlePaths.length, greaterThanOrEqualTo(4));
        final anyMove = level.puzzlePaths.any(
            (p) => PathCollisionService.canPathEscape(p, level.puzzlePaths, level.gridSize));
        expect(anyMove, isTrue, reason: 'level ${level.levelId} has no opening');
      }
    });

    test('levels are fully solvable (DFS over removal orders)', () {
      for (final id in [1, 2, 3, 5, 8, 12, 20, 35, 61, 100]) {
        final level = LevelGenerator.generate(id);
        expect(solvable(level.puzzlePaths, level.gridSize), isTrue,
            reason: 'level $id unsolvable');
      }
    });

    test('generation is deterministic per level id', () {
      final a = LevelGenerator.generate(7);
      final b = LevelGenerator.generate(7);
      expect(a.puzzlePaths.length, b.puzzlePaths.length);
      for (int i = 0; i < a.puzzlePaths.length; i++) {
        expect(a.puzzlePaths[i].points.toString(),
            b.puzzlePaths[i].points.toString());
        expect(a.puzzlePaths[i].direction, b.puzzlePaths[i].direction);
      }
    });

    test('early levels teach with several obvious first moves', () {
      for (final id in [1, 2, 3]) {
        final level = LevelGenerator.generate(id);
        final free = level.puzzlePaths
            .where((p) =>
                PathCollisionService.canPathEscape(p, level.puzzlePaths, level.gridSize))
            .length;
        expect(free, greaterThanOrEqualTo(3), reason: 'level $id');
      }
    });
  });
}
