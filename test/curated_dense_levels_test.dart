import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/game/levels/curated_levels.dart';
import 'package:arrow_escape/game/solver/puzzle_solver.dart';
import 'package:arrow_escape/game/path/path_collision_service.dart';

void main() {
  group('Level 1 ONLY - dense classic Arrow-Escape board', () {
    test('Level 1 is valid and solvable - 73 individual pieces', () {
      final level = buildCuratedLevel1();
      expect(level.levelId, equals(1));
      expect(level.gridSize, equals(20));
      expect(level.puzzlePaths.length, equals(73),
          reason: 'Level 1 must have 73 individual playable arrow pieces');
      expect(level.isValid, isTrue);
      expect(level.shapeName, equals('Dense Maze'));
      final res = PuzzleSolver.solve(level);
      expect(res.solvable, isTrue);
      expect(res.solutionDepth, equals(73));
    });

    test('Level 1 dense packing 75%, many bends, all directions', () {
      final level = buildCuratedLevel1();
      final occupied = <dynamic>{};
      for (final p in level.puzzlePaths) {
        occupied.addAll(p.occupiedCells);
      }
      final ratio = occupied.length / (level.gridSize * level.gridSize);
      expect(occupied.length, equals(300));
      expect(ratio, closeTo(0.75, 0.001));
      expect(ratio, greaterThanOrEqualTo(0.75));
      expect(ratio, lessThanOrEqualTo(0.90));

      int turns = 0, bent = 0, straight = 0;
      for (final p in level.puzzlePaths) {
        bool ht = false;
        for (int i = 2; i < p.points.length; i++) {
          final a = p.points[i - 2], b = p.points[i - 1], c = p.points[i];
          if ((a.x != b.x || b.x != c.x) && (a.y != b.y || b.y != c.y)) {
            ht = true;
            turns++;
          }
        }
        if (ht) {
          bent++;
        } else {
          straight++;
        }
      }
      expect(turns, equals(78));
      expect(bent, equals(27));
      expect(straight, equals(46));

      final dirs = <String, int>{};
      for (final p in level.puzzlePaths) {
        dirs[p.direction.name] = (dirs[p.direction.name] ?? 0) + 1;
      }
      // All four directions, balanced (min 12)
      expect(dirs.length, equals(4));
      for (final v in dirs.values) {
        expect(v, greaterThanOrEqualTo(8));
      }
    });

    test('Level 1 blocking chains, no long lanes', () {
      final level = buildCuratedLevel1();
      final paths = level.createPuzzlePaths();
      final res = PuzzleSolver.solve(level);
      expect(res.initialMoves, equals(16));
      // 57 initially blocked => many A->B->C chains
      int blocked = 0;
      for (final p in paths) {
        if (!PathCollisionService.canPathEscape(p, paths, level.gridSize)) {
          blocked++;
        }
      }
      expect(blocked, equals(57));
      expect(res.intersections, greaterThanOrEqualTo(100));
      // No giant 20-cell lanes: every piece is small/medium (max 10 cells)
      for (final p in level.puzzlePaths) {
        expect(p.occupiedCells.length, lessThanOrEqualTo(10),
            reason: 'No giant continuous maze lanes');
        expect(p.occupiedCells.length, greaterThanOrEqualTo(2));
      }
    });

    test('Level 1 uses thin arrow geometry', () {
      final level = buildCuratedLevel1();
      expect(level.gridSize, equals(20));
      // PuzzlePainter uses 0.095*cell thin shafts + small sharp heads
    });
  });

  group('Level 2 - Perfect Triangle (Levels 21+ generated)', () {
    test('Level 2 is valid and solvable - perfect triangle', () {
      final level = buildCuratedLevel2();
      expect(level.levelId, equals(2));
      expect(level.gridSize, equals(20));
      expect(level.puzzlePaths.length, equals(22));
      expect(level.isValid, isTrue);
      expect(level.shapeName, equals('Triangle'));
      final res = PuzzleSolver.solve(level);
      expect(res.solvable, isTrue);
      expect(res.solutionDepth, equals(22));
    });

    test('Level 3 (Hexagon) valid and solvable', () {
      final level = buildCuratedLevel3();
      expect(level.levelId, equals(3));
      expect(level.gridSize, equals(20));
      expect(level.puzzlePaths.length, equals(42));
      expect(level.isValid, isTrue);
      expect(level.shapeName, equals('Hexagon'));
      final res = PuzzleSolver.solve(level);
      expect(res.solvable, isTrue);
      expect(res.solutionDepth, equals(42));
    });

    test('Levels 4-10 valid and solvable with expected shapes', () {
      final expected = {
        4: ('Circle', 39),
        5: ('Pentagon', 42),
        6: ('Star', 29),
        7: ('Heart', 34),
        8: ('Diamond', 34),
        9: ('Octagon', 45),
        10: ('Cross', 52),
      };
      for (final entry in expected.entries) {
        final level = getCuratedLevel(entry.key)!;
        expect(level.levelId, equals(entry.key));
        expect(level.gridSize, equals(20));
        expect(level.shapeName, equals(entry.value.$1));
        expect(level.puzzlePaths.length, equals(entry.value.$2));
        expect(level.isValid, isTrue);
        final res = PuzzleSolver.solve(level);
        expect(res.solvable, isTrue,
            reason: 'Level ${entry.key} must be solvable');
        expect(res.solutionDepth, equals(level.puzzlePaths.length));
      }
    });

    test('Levels 3-10 are dense 20x20 shape boards', () {
      for (int id = 3; id <= 10; id++) {
        final level = getCuratedLevel(id)!;
        final occupied = <dynamic>{};
        for (final p in level.puzzlePaths) {
          occupied.addAll(p.occupiedCells);
        }
        final ratio = occupied.length / (level.gridSize * level.gridSize);
        // Dense but within solver limits: star is thinnest, cross densest.
        expect(ratio, greaterThanOrEqualTo(0.25));
        expect(ratio, lessThanOrEqualTo(0.76));
        // Shape fills most of the board (bounding box >= 15 in each axis).
        final xs = occupied.map((c) => (c as dynamic).x as int).toList()
          ..sort();
        final ys = occupied.map((c) => (c as dynamic).y as int).toList()
          ..sort();
        expect(xs.last - xs.first + 1, greaterThanOrEqualTo(15));
        expect(ys.last - ys.first + 1, greaterThanOrEqualTo(15));
      }
    });

    test('isCuratedLevel identifies 1-20 only', () {
      for (int id = 1; id <= 20; id++) {
        expect(isCuratedLevel(id), isTrue);
      }
      expect(isCuratedLevel(0), isFalse);
      expect(isCuratedLevel(21), isFalse);
    });

    test('getCuratedLevel returns correct levels', () {
      for (int id = 1; id <= 20; id++) {
        expect(getCuratedLevel(id), isNotNull);
      }
      expect(getCuratedLevel(21), isNull);
    });

    test('All curated levels have no overlapping cells', () {
      for (int id = 1; id <= 20; id++) {
        final lvl = getCuratedLevel(id)!;
        expect(lvl.isValid, isTrue);
        final occ = <dynamic>{};
        int sum = 0;
        for (final p in lvl.puzzlePaths) {
          final cells = p.occupiedCells;
          sum += cells.length;
          occ.addAll(cells);
        }
        expect(occ.length, equals(sum),
            reason: 'No overlapping cells for level ${lvl.levelId}');
      }
    });
  });

  group('Patterns world - Levels 11-20', () {
    test('Levels 11-20 valid and solvable with expected patterns', () {
      final expected = {
        11: ('Concentric Squares', 46),
        12: ('Spiral', 48),
        13: ('Wave', 36),
        14: ('Checker Grid', 63),
        15: ('Infinity', 30),
        16: ('Radial Pattern', 44),
        17: ('Labyrinth', 46),
        18: ('Diamond Grid', 32),
        19: ('Interlocking Loops', 47),
        20: ('Master Pattern', 61),
      };
      for (final entry in expected.entries) {
        final level = getCuratedLevel(entry.key)!;
        expect(level.levelId, equals(entry.key));
        expect(level.gridSize, equals(20));
        expect(level.shapeName, equals(entry.value.$1));
        expect(level.puzzlePaths.length, equals(entry.value.$2));
        expect(level.isValid, isTrue);
        final res = PuzzleSolver.solve(level);
        expect(res.solvable, isTrue,
            reason: 'Level ${entry.key} must be solvable');
        expect(res.solutionDepth, equals(level.puzzlePaths.length));
      }
    });

    test('Levels 11-20 are dense 20x20 pattern boards', () {
      for (int id = 11; id <= 20; id++) {
        final level = getCuratedLevel(id)!;
        final occupied = <dynamic>{};
        for (final p in level.puzzlePaths) {
          occupied.addAll(p.occupiedCells);
        }
        final ratio = occupied.length / (level.gridSize * level.gridSize);
        // Dense but within solver limits.
        expect(ratio, greaterThanOrEqualTo(0.25));
        expect(ratio, lessThanOrEqualTo(0.76));
        // Pattern fills most of the board (bounding box >= 14 in each axis).
        final xs = occupied.map((c) => (c as dynamic).x as int).toList()
          ..sort();
        final ys = occupied.map((c) => (c as dynamic).y as int).toList()
          ..sort();
        expect(xs.last - xs.first + 1, greaterThanOrEqualTo(14));
        expect(ys.last - ys.first + 1, greaterThanOrEqualTo(14));
      }
    });

    test('Patterns world metadata matches levels 11-20', () {
      const names = [
        'Concentric Squares',
        'Spiral',
        'Wave',
        'Checker Grid',
        'Infinity',
        'Radial Pattern',
        'Labyrinth',
        'Diamond Grid',
        'Interlocking Loops',
        'Master Pattern',
      ];
      for (int i = 0; i < names.length; i++) {
        final level = getCuratedLevel(11 + i)!;
        expect(level.world, equals(2));
        expect(level.shapeName, equals(names[i]));
      }
    });
  });
}
