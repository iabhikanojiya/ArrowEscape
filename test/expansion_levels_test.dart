@Timeout(Duration(minutes: 10))
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/core/constants/app_constants.dart';
import 'package:arrow_escape/game/levels/expansion_catalog.dart';
import 'package:arrow_escape/game/levels/extended_templates.dart';
import 'package:arrow_escape/game/levels/level_quality.dart';
import 'package:arrow_escape/game/levels/level_world.dart';
import 'package:arrow_escape/game/levels/shape_level_generator.dart';
import 'package:arrow_escape/game/solver/puzzle_solver.dart';
import 'package:arrow_escape/models/level.dart';
import 'package:arrow_escape/repositories/generated_level_repository.dart';

/// FNV-1a over the level's full JSON (geometry, directions, metadata).
int _fnv(Level l) {
  var h = 0x811c9dc5;
  for (final c in jsonEncode(l.toJson()).codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
}

/// Hashes of Levels 1-1000 recorded before the 1001-2000 expansion.
const Map<int, int> _golden = {
  1: 3486862952, 2: 1795115767, 3: 668346249, 4: 707299668, //
  5: 331176834, 6: 3530141122, 7: 157908843, 8: 100720051,
  9: 209296620, 10: 3653578884, 11: 3854146527, 12: 2100290468,
  13: 1836712085, 14: 1976200609, 15: 142756069, 16: 404571155,
  17: 1426028785, 18: 2227139892, 19: 3368284022, 20: 1727766293,
  21: 4979739, 50: 3935669623, 100: 2093956016, 150: 2426730582,
  200: 4054390612, 250: 621094048, 300: 4066528860, 350: 3065345578,
  400: 615119677, 450: 456662019, 500: 3015221327, 550: 3885494578,
  600: 2254363438, 650: 4244960403, 700: 314276269, 750: 1790372674,
  800: 3694053821, 850: 928502409, 900: 86729177, 950: 1964306823,
  999: 4150387952, 1000: 2464890879,
};

const _samples = [
  1001, 1100, 1101, 1140, 1200, 1223, 1300, 1400, 1500, 1600, 1613, 1700, //
  1800, 1900, 1950, 2000,
];

const _bandTitles = [
  'Master Shapes', 'Complex Patterns', 'Nature Combinations', //
  'Animal Combinations', 'Object Combinations', 'Landmark Combinations',
  'Multi-Shape Puzzles', 'Expert Combinations', 'Master Challenges',
  'Ultimate Challenges',
];

LevelQuality _quality(Level l) =>
    LevelQuality.measure(l, ExtendedTemplates.buildMask(l.levelId, l.gridSize));

void main() {
  test('Levels 1-1000 are byte-for-byte unchanged', () {
    _golden.forEach((id, hash) {
      expect(
        _fnv(ShapeLevelGenerator.generate(id)),
        equals(hash),
        reason: 'L$id changed',
      );
    });
  });

  test('2000 levels, ten new 100-level worlds', () async {
    expect(AppConstants.maxLevels, equals(2000));
    final repo = GeneratedLevelRepository();
    expect(await repo.getTotalLevelCount(), equals(2000));
    expect((await repo.getNextLevel(1000))!.levelId, equals(1001));
    expect(await repo.getNextLevel(2000), isNull);
    for (int b = 0; b < 10; b++) {
      final w = LevelWorlds.worldFor(1001 + b * 100);
      expect(w.world, equals(12 + b));
      expect(w.title, equals(_bandTitles[b]));
      expect(w.startId, equals(1001 + b * 100));
      expect(w.endId, equals(1100 + b * 100));
    }
    // Level 1000 still belongs to the original Ultimate world.
    expect(LevelWorlds.worldFor(1000).world, equals(11));
  });

  test('sampled expansion levels are valid, solvable and on-theme', () {
    for (final id in _samples) {
      final level = ShapeLevelGenerator.generate(id);
      final res = PuzzleSolver.solve(level);
      final q = _quality(level);
      expect(level.isValid, isTrue, reason: 'L$id isValid');
      expect(res.solvable, isTrue, reason: 'L$id solvable');
      expect(res.solutionDepth, equals(level.puzzlePaths.length));
      expect(
        ShapeLevelGenerator.directionsConsistent(level),
        isTrue,
        reason: 'L$id arrowhead == escape direction',
      );
      expect(level.shapeName, equals(LevelWorlds.shapeFor(id)));
      expect(level.shapeName, equals(ExtendedTemplates.displayName(id)));
      expect(level.category, equals(LevelWorlds.categoryFor(id)));
      expect(level.gridSize, equals(ExpansionCatalog.gridSizeFor(id)));
      // The arrows build the whole silhouette and nothing outside it.
      expect(q.shapeCoverage, greaterThanOrEqualTo(0.98), reason: 'L$id');
      expect(q.outsideNoise, equals(0), reason: 'L$id');
      expect(q.depth, greaterThanOrEqualTo(ExpansionCatalog.depthFloor));
      expect(
        jsonEncode(ShapeLevelGenerator.generate(id).toJson()),
        equals(jsonEncode(level.toJson())),
        reason: 'L$id deterministic',
      );
      // ignore: avoid_print
      print(
        'L$id [${level.worldName}] "${level.shapeName}" grid=${level.gridSize} '
        'n=${q.arrows} occ=${q.occupancy.toStringAsFixed(2)} depth=${q.depth} '
        'init=${q.initialMoves} maxBranch=${res.maxBranching} '
        'avgLen=${q.avgLength.toStringAsFixed(1)} '
        'bends=${q.bendsPerArrow.toStringAsFixed(2)} '
        'intersections=${res.intersections} '
        'diff=${PuzzleSolver.estimateDifficulty(level)}',
      );
    }
  });

  test('Level 1001 is harder than Level 1000', () {
    final a = _quality(ShapeLevelGenerator.generate(1000));
    final b = _quality(ShapeLevelGenerator.generate(1001));
    expect(b.arrows, greaterThan(a.arrows));
    expect(b.depth, greaterThan(a.depth));
    expect(b.occupancy, greaterThan(a.occupancy));
    expect(b.initialMoves, lessThanOrEqualTo(a.initialMoves));
  });

  test('difficulty rises through the expansion', () {
    // Every 10th level per band (deterministic sample).
    List<LevelQuality> sample(int start) => [
      for (int id = start; id < start + 100; id += 10)
        _quality(ShapeLevelGenerator.generate(id)),
    ];
    double avg(List<LevelQuality> qs, num Function(LevelQuality) f) =>
        qs.map(f).reduce((a, b) => a + b) / qs.length;

    final old = sample(901);
    final bands = [for (int b = 0; b < 10; b++) sample(1001 + b * 100)];
    final depth = [for (final qs in bands) avg(qs, (q) => q.depth)];
    final arrows = [for (final qs in bands) avg(qs, (q) => q.arrows)];
    final occ = [for (final qs in bands) avg(qs, (q) => q.occupancy)];
    // ignore: avoid_print
    print(
      'old ultimate depth=${avg(old, (q) => q.depth)}\n'
      'band depth=${depth.map((v) => v.toStringAsFixed(1)).toList()}\n'
      'band arrows=${arrows.map((v) => v.toStringAsFixed(0)).toList()}\n'
      'band occupancy=${occ.map((v) => v.toStringAsFixed(2)).toList()}',
    );
    for (final d in depth) {
      expect(d, greaterThan(avg(old, (q) => q.depth)));
    }
    double half(List<double> v, int from) =>
        v.sublist(from, from + 5).reduce((a, b) => a + b) / 5;
    expect(half(depth, 5), greaterThan(half(depth, 0)));
    expect(half(arrows, 5), greaterThan(half(arrows, 0)));
    expect(half(occ, 5), greaterThan(half(occ, 0)));
    // Ultimate Challenges is the hardest tier.
    expect(depth.last, greaterThan(depth.first + 8));
    expect(arrows.last, equals(arrows.reduce((a, b) => a > b ? a : b)));
    expect(occ.last, equals(occ.reduce((a, b) => a > b ? a : b)));
  });

  test('Complex Patterns is not easier than Master Shapes', () {
    double avgDepth(int start) {
      var sum = 0;
      for (int id = start; id < start + 100; id++) {
        sum += _quality(ShapeLevelGenerator.generate(id)).depth;
      }
      return sum / 100;
    }

    final shapes = avgDepth(1001), patterns = avgDepth(1101);
    // ignore: avoid_print
    print('avg depth 1001-1100=$shapes 1101-1200=$patterns');
    expect(patterns, greaterThanOrEqualTo(shapes));
  });

  test('composition plans are deterministic and named after their shapes', () {
    for (int id = 1001; id <= 2000; id += 37) {
      final pieces = ExpansionCatalog.piecesFor(id);
      expect(pieces, isNotEmpty);
      expect(
        LevelWorlds.shapeFor(id),
        equals(pieces.map((p) => p.name).join(' + ')),
      );
      final mask = ExtendedTemplates.buildMask(id, LevelWorlds.gridSizeFor(id));
      expect(mask.isNotEmpty, isTrue);
      expect(
        ExtendedTemplates.buildMask(id, LevelWorlds.gridSizeFor(id)),
        equals(mask),
      );
    }
  });
}
