import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_escape/game/engine/puzzle_engine.dart';
import 'package:arrow_escape/game/levels/curated_levels.dart';
import 'package:arrow_escape/game/path/path_collision_service.dart';
import 'package:arrow_escape/game/rendering/path_geometry.dart';
import 'package:arrow_escape/game/solver/puzzle_solver.dart';
import 'package:arrow_escape/models/arrow.dart';
import 'package:arrow_escape/models/level.dart';
import 'package:arrow_escape/models/puzzle_path.dart';

PuzzlePath _path(String id, List<List<int>> pts, ArrowDirection dir) {
  return PuzzlePath(
    id: id,
    points: [for (final p in pts) GridPoint(p[0], p[1])],
    direction: dir,
  );
}

/// Direction the renderer visibly draws the arrowhead in.
ArrowDirection _drawnHeadDirection(PuzzlePath path) {
  const cell = 40.0;
  final shape = PathGeometry.buildTracedPath(path, cell);
  final head = PathGeometry.arrowHead(
    vertices: shape.vertices,
    stroke: 4,
    cornerRadius: PathGeometry.cornerRadiusFor(cell),
    fallbackAngle: path.direction.rotationRadians,
  );
  final deg = head.angle * 180 / math.pi;
  if ((deg - 0).abs() < 1) return ArrowDirection.right;
  if ((deg - 90).abs() < 1) return ArrowDirection.down;
  if ((deg + 90).abs() < 1) return ArrowDirection.up;
  return ArrowDirection.left;
}

void main() {
  group('arrowhead is the single source of the escape direction', () {
    // Bent arrows whose stored direction deliberately disagrees with the
    // arrowhead: the arrowhead must win everywhere.
    final cases = <ArrowDirection, PuzzlePath>{
      ArrowDirection.up: _path('u', [
        [2, 6],
        [2, 4],
        [4, 4],
        [4, 3],
      ], ArrowDirection.right),
      ArrowDirection.down: _path('d', [
        [2, 2],
        [4, 2],
        [4, 4],
      ], ArrowDirection.left),
      ArrowDirection.left: _path('l', [
        [5, 2],
        [5, 4],
        [3, 4],
      ], ArrowDirection.up),
      ArrowDirection.right: _path('r', [
        [3, 6],
        [3, 4],
        [5, 4],
      ], ArrowDirection.down),
    };

    cases.forEach((dir, path) {
      test('arrowhead ${dir.name} -> moves ${dir.name}', () {
        expect(_drawnHeadDirection(path), dir,
            reason: 'renderer draws the head ${dir.name}');
        expect(path.direction, dir,
            reason: 'gameplay direction must equal the drawn arrowhead');
      });

      test('arrowhead ${dir.name}: only obstacles in the ${dir.name} '
          'sweep block it', () {
        const grid = 9;
        final v = dir.vector;
        // A blocker straight ahead of the head in the arrowhead direction.
        final ahead = GridPoint(
          path.head.x + v.dx.toInt() * 2,
          path.head.y + v.dy.toInt() * 2,
        );
        final blocker = _path('b', [
          [ahead.x, ahead.y],
        ], ArrowDirection.up);
        expect(
            PathCollisionService.canPathEscape(path, [path, blocker], grid),
            isFalse);

        // The same blocker placed behind the arrow (opposite side) must not
        // block: the arrow never moves that way.
        final behind = GridPoint(
          path.tail.x - v.dx.toInt() * 1,
          path.tail.y - v.dy.toInt() * 1,
        );
        if (!path.occupiedCells.contains(behind) &&
            behind.x >= 0 &&
            behind.y >= 0 &&
            behind.x < grid &&
            behind.y < grid) {
          var sweptHitsBehind = false;
          for (final c in path.occupiedCells) {
            var x = c.x + v.dx.toInt(), y = c.y + v.dy.toInt();
            while (x >= 0 && y >= 0 && x < grid && y < grid) {
              if (x == behind.x && y == behind.y) sweptHitsBehind = true;
              x += v.dx.toInt();
              y += v.dy.toInt();
            }
          }
          final back = _path('k', [
            [behind.x, behind.y],
          ], ArrowDirection.up);
          expect(PathCollisionService.canPathEscape(path, [path, back], grid),
              !sweptHitsBehind);
        }
      });
    });

    test('single-point arrows keep their stored direction', () {
      final p = _path('s', [
        [3, 3],
      ], ArrowDirection.left);
      expect(p.direction, ArrowDirection.left);
      expect(p.copyWith().direction, ArrowDirection.left);
    });
  });

  group('rigid body sweep for bent arrows', () {
    // Arrowhead points UP at (4,3); the body's lower-left leg sits in
    // column 2. Moving up rigidly sweeps columns 2..4, not just the head.
    final bent = _path('m', [
      [2, 6],
      [2, 4],
      [4, 4],
      [4, 3],
    ], ArrowDirection.right);

    test('a blocker above a non-head body cell blocks', () {
      final b = _path('b', [
        [2, 0],
      ], ArrowDirection.up);
      expect(PathCollisionService.canPathEscape(bent, [bent, b], 9), isFalse);
      expect(PathCollisionService.getBlockingPath(bent, [bent, b], 9), same(b));
    });

    test('a blocker outside the swept columns does not block', () {
      final b = _path('b', [
        [6, 0],
        [8, 0],
      ], ArrowDirection.right);
      final side = _path('s', [
        [0, 5],
        [1, 5],
      ], ArrowDirection.right);
      expect(PathCollisionService.canPathEscape(bent, [bent, b, side], 9),
          isTrue);
    });

    test('the arrow never blocks itself', () {
      expect(PathCollisionService.canPathEscape(bent, [bent], 9), isTrue);
    });

    test('engine moves it in the arrowhead direction and removes it', () {
      final level = Level(levelId: 1, gridSize: 9, puzzlePaths: [bent]);
      final engine = PuzzleEngine(boardSize: 9)..loadLevel(level);
      final p = engine.getPathById('m')!;
      expect(p.direction, ArrowDirection.up);
      expect(engine.beginMove(p), isTrue);
      expect(engine.completeMove('m'), isTrue);
    });
  });

  group('Levels 1-20 follow the arrowhead rule', () {
    for (int id = 1; id <= 20; id++) {
      test('Level $id: every stored direction matches its arrowhead and the '
          'level is solvable', () {
        final level = getCuratedLevel(id)!;
        expect(level.isValid, isTrue);
        for (final p in level.puzzlePaths) {
          expect(_drawnHeadDirection(p), p.direction,
              reason: 'Level $id path ${p.id}');
        }
        final res = PuzzleSolver.solve(level);
        expect(res.solvable, isTrue);
        expect(res.solutionDepth, level.puzzlePaths.length);
      });
    }
  });
}
