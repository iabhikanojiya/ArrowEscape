import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/game/levels/curated_levels.dart';
import 'package:arrow_escape/game/levels/extended_templates.dart';
import 'package:arrow_escape/game/levels/level_world.dart';
import 'package:arrow_escape/game/levels/shape_level_generator.dart';
import 'package:arrow_escape/game/path/path_collision_service.dart';
import 'package:arrow_escape/game/solver/puzzle_solver.dart';
import 'package:arrow_escape/models/level.dart';

// Representative samples from every band (per spec testing list).
const _samples = [
  21,
  25,
  30,
  35,
  36,
  40,
  45,
  50,
  55,
  56,
  60,
  65,
  70,
  75,
  76,
  80,
  85,
  90,
  95,
  96,
  100,
  125,
  150,
  175,
  200,
  201,
  250,
  300,
  350,
  400,
  401,
  450,
  500,
  550,
  600,
  650,
  700,
  701,
  750,
  800,
  850,
  900,
  901,
  925,
  950,
  975,
  1000,
];

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

void main() {
  group('Regression guard: Levels 1-20 unchanged', () {
    test('generate(1-20) returns the existing curated levels verbatim', () {
      for (int id = 1; id <= 20; id++) {
        final viaGenerate = ShapeLevelGenerator.generate(id);
        final curated = getCuratedLevel(id)!;
        expect(
          viaGenerate.toJson(),
          equals(curated.toJson()),
          reason: 'L$id identical before/after',
        );
      }
    });
  });

  group('Extended bands 21-1000 representative samples', () {
    test('samples are valid, solvable, direction-consistent', () {
      final hashes = <String>{};
      for (final id in _samples) {
        final level = ShapeLevelGenerator.generate(id);
        final res = PuzzleSolver.solve(level);
        expect(level.isValid, isTrue, reason: 'L$id isValid');
        expect(res.solvable, isTrue, reason: 'L$id solvable');
        expect(
          res.solutionDepth,
          equals(level.puzzlePaths.length),
          reason: 'L$id full-depth solution',
        );
        expect(
          ShapeLevelGenerator.directionsConsistent(level),
          isTrue,
          reason: 'L$id arrowhead/direction consistency',
        );
        // Metadata matches world/template single source of truth.
        expect(
          level.shapeName,
          equals(LevelWorlds.shapeFor(id)),
          reason: 'L$id label',
        );
        expect(
          level.world,
          equals(LevelWorlds.worldFor(id).world),
          reason: 'L$id world',
        );
        expect(
          level.gridSize,
          equals(LevelWorlds.gridSizeFor(id)),
          reason: 'L$id grid',
        );
        // No malformed arrows.
        for (final p in level.puzzlePaths) {
          expect(p.points.isNotEmpty, isTrue, reason: 'L$id non-empty path');
          expect(p.occupiedCells.isNotEmpty, isTrue);
        }
        hashes.add(_hash(level));
        // ignore: avoid_print
        print(
          'L$id [${level.worldName}] "${level.shapeName}" n=${level.puzzlePaths.length} '
          'init=${res.initialMoves} occ=${res.occupancyRatio.toStringAsFixed(2)} '
          'diff=${PuzzleSolver.estimateDifficulty(level)}',
        );
      }
      // Sample geometries are all distinct.
      expect(
        hashes.length,
        equals(_samples.length),
        reason: 'no duplicate sample geometry',
      );
    });

    test('difficulty ramps up across bands', () {
      double bandAvg(int start, int end) {
        var sum = 0.0;
        var count = 0;
        for (int id = start; id <= end; id += 7) {
          final level = ShapeLevelGenerator.generate(id);
          sum += PuzzleSolver.estimateDifficulty(level);
          count++;
        }
        return sum / count;
      }

      final nature = bandAvg(21, 35);
      final animals = bandAvg(36, 55);
      final objects = bandAvg(56, 75);
      final landmarks = bandAvg(76, 95);
      final combo = bandAvg(96, 200);
      final advanced = bandAvg(201, 400);
      final expert = bandAvg(401, 700);
      final master = bandAvg(701, 900);
      final ultimate = bandAvg(901, 1000);
      // ignore: avoid_print
      print(
        'avg difficulty: nature=$nature animals=$animals objects=$objects '
        'landmarks=$landmarks combo=$combo advanced=$advanced expert=$expert '
        'master=$master ultimate=$ultimate',
      );
      // Every band is dense, so all sit at the top of the 1-10 scale.
      for (final v in [
        nature,
        animals,
        objects,
        landmarks,
        combo,
        advanced,
        expert,
        master,
        ultimate,
      ]) {
        expect(v, greaterThanOrEqualTo(9.0));
      }

      // The scale saturates for dense boards, so the ramp is checked on the
      // share of arrows free at the start (lower = harder).
      double freeRatio(int start, int end) {
        var sum = 0.0;
        var count = 0;
        for (int id = start; id <= end; id += 5) {
          final level = ShapeLevelGenerator.generate(id);
          final free = level.puzzlePaths
              .where(
                (p) => PathCollisionService.canPathEscape(
                  p,
                  level.puzzlePaths,
                  level.gridSize,
                ),
              )
              .length;
          sum += free / level.puzzlePaths.length;
          count++;
        }
        return sum / count;
      }

      final early = freeRatio(21, 35);
      final late = freeRatio(701, 1000);
      // ignore: avoid_print
      print('free-move ratio: nature=$early late=$late');
      expect(late, lessThan(early));

      // Dependency chains (peel rounds) get deeper and boards larger.
      double avgDepth(int start, int end) {
        var sum = 0;
        var count = 0;
        for (int id = start; id <= end; id += 5) {
          sum += PuzzleSolver.dependencyDepth(ShapeLevelGenerator.generate(id));
          count++;
        }
        return sum / count;
      }

      final earlyDepth = avgDepth(21, 35);
      final lateDepth = avgDepth(701, 1000);
      // ignore: avoid_print
      print('dependency depth: nature=$earlyDepth late=$lateDepth');
      expect(lateDepth, greaterThan(earlyDepth * 1.5));
      expect(
        LevelWorlds.gridSizeFor(1000),
        greaterThan(LevelWorlds.gridSizeFor(21)),
      );
    });

    test('template labels match composed masks', () {
      for (final id in [96, 150, 201, 350, 401, 600, 701, 850, 901, 1000]) {
        final t = ExtendedTemplates.templateFor(id);
        expect(LevelWorlds.shapeFor(id), equals(t.displayName));
        final mask = ExtendedTemplates.buildMask(
          id,
          LevelWorlds.gridSizeFor(id),
        );
        expect(mask.isNotEmpty, isTrue, reason: 'L$id non-empty mask');
      }
    });
  });
}
