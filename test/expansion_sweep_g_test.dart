@Timeout(Duration(minutes: 25))
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/game/levels/expansion_catalog.dart';
import 'package:arrow_escape/game/levels/extended_templates.dart';
import 'package:arrow_escape/game/levels/level_quality.dart';
import 'package:arrow_escape/game/levels/level_world.dart';
import 'package:arrow_escape/game/levels/shape_level_generator.dart';
import 'package:arrow_escape/game/solver/puzzle_solver.dart';
import 'package:arrow_escape/models/level.dart';

String _hash(Level l) {
  final parts =
      l.puzzlePaths
          .map(
            (p) =>
                '${p.points.map((c) => '${c.x},${c.y}').join(';')}:${p.direction.name}',
          )
          .toList()
        ..sort();
  return '${l.gridSize}|${parts.join('|')}';
}

const int _start = 1501;
const int _end = 1750;

void main() {
  test('expansion sweep $_start-$_end valid, solvable, on-shape, unique', () {
    ShapeLevelGenerator.resetStats();
    final hashes = <String, int>{};
    var belowFloor = 0;
    for (int id = _start; id <= _end; id++) {
      final level = ShapeLevelGenerator.generate(id);
      expect(level.levelId, equals(id));
      expect(level.isValid, isTrue, reason: 'L$id isValid');
      final res = PuzzleSolver.solve(level);
      expect(res.solvable, isTrue, reason: 'L$id solvable');
      expect(res.solutionDepth, equals(level.puzzlePaths.length));
      expect(
        ShapeLevelGenerator.directionsConsistent(level),
        isTrue,
        reason: 'L$id directions',
      );
      expect(
        level.shapeName,
        equals(LevelWorlds.shapeFor(id)),
        reason: 'L$id label',
      );
      expect(level.world, equals(LevelWorlds.worldFor(id).world));
      expect(level.gridSize, equals(LevelWorlds.gridSizeFor(id)));
      final q = LevelQuality.measure(
        level,
        ExtendedTemplates.buildMask(id, level.gridSize),
      );
      expect(q.shapeCoverage, greaterThanOrEqualTo(0.98), reason: 'L$id');
      expect(q.outsideNoise, equals(0), reason: 'L$id');
      // Every expansion level is deeper than Level 1000. The Complex
      // Patterns floor only triggers rescue seeds, so a few may stay below.
      expect(
        q.depth,
        greaterThanOrEqualTo(ExpansionCatalog.depthFloor),
        reason: 'L$id depth',
      );
      if (q.depth < ExpansionCatalog.depthFloorFor(id)) belowFloor++;
      final h = _hash(level);
      hashes[h] = (hashes[h] ?? 0) + 1;
      if (id % 25 == 0) {
        final again = ShapeLevelGenerator.generate(id);
        expect(_hash(again), equals(h), reason: 'L$id deterministic');
      }
    }
    final dupes = hashes.values.where((c) => c > 1).length;
    expect(dupes, equals(0), reason: 'no duplicate geometry in shard');
    expect(belowFloor, lessThanOrEqualTo(5));
    // ignore: avoid_print
    print(
      'expansion sweep $_start-$_end: ${hashes.length} unique levels, '
      'belowFloor=$belowFloor '
      'candidates=${ShapeLevelGenerator.candidatesTested} '
      'rejUnsolvable=${ShapeLevelGenerator.rejectedUnsolvable} '
      'rejShape=${ShapeLevelGenerator.rejectedShape}',
    );
  });
}
