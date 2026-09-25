@Timeout(Duration(minutes: 25))
import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/game/levels/level_world.dart';
import 'package:arrow_escape/game/levels/shape_level_generator.dart';
import 'package:arrow_escape/models/level.dart';

String _hash(Level l) {
  final parts = l.puzzlePaths
      .map(
        (p) =>
            '${p.points.map((c) => '${c.x},${c.y}').join(';')}:${p.direction.name}',
      )
      .toList()
    ..sort();
  return '${l.gridSize}|${parts.join('|')}';
}

// SWEEP_SHARD_START SWEEP_SHARD_END
const int _start = 21;
const int _end = 300;

void main() {
  test('sweep $_start-$_end valid, consistent, deterministic, unique', () {
    ShapeLevelGenerator.resetStats();
    final hashes = <String, int>{};
    for (int id = _start; id <= _end; id++) {
      final level = ShapeLevelGenerator.generate(id);
      expect(level.levelId, equals(id));
      expect(level.isValid, isTrue, reason: 'L$id isValid');
      expect(ShapeLevelGenerator.directionsConsistent(level), isTrue,
          reason: 'L$id directions');
      expect(level.shapeName, equals(LevelWorlds.shapeFor(id)),
          reason: 'L$id label');
      expect(level.world, equals(LevelWorlds.worldFor(id).world));
      expect(level.gridSize, equals(LevelWorlds.gridSizeFor(id)));
      final h = _hash(level);
      hashes[h] = (hashes[h] ?? 0) + 1;
      // Determinism spot-check every 25th level.
      if (id % 25 == 0) {
        final again = ShapeLevelGenerator.generate(id);
        expect(_hash(again), equals(h), reason: 'L$id deterministic');
      }
    }
    final dupes = hashes.values.where((c) => c > 1).length;
    expect(dupes, equals(0), reason: 'no duplicate geometry in shard');
    // ignore: avoid_print
    print(
      'sweep $_start-$_end: ${hashes.length} unique levels, '
      'candidates=${ShapeLevelGenerator.candidatesTested} '
      'rejUnsolvable=${ShapeLevelGenerator.rejectedUnsolvable} '
      'rejShape=${ShapeLevelGenerator.rejectedShape}',
    );
  });
}
