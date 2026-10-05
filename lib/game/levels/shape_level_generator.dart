import 'dart:math' as math;

import '../../models/arrow.dart';
import '../../models/level.dart';
import '../../models/puzzle_path.dart';
import 'curated_levels.dart';
import 'dense_tiler.dart';
import 'expansion_catalog.dart';
import 'extended_templates.dart';
import 'level_quality.dart';
import 'level_world.dart';

/// Shape-driven level generator.
///
/// Levels 1-20 are the curated boards, returned verbatim. Levels 21-2000
/// are built from the designed silhouette for the level's name
/// ([ExtendedTemplates.buildMask]) and filled completely with arrows by
/// [DenseTiler]. Board size ([LevelWorlds.gridSizeFor]) and puzzle settings
/// ([paramsFor]) rise continuously with the level number, and every level
/// is validated with [PuzzleSolver] before it is accepted. Levels 1001-2000
/// take their settings from [ExpansionCatalog] and must also reach a
/// minimum dependency depth; Levels 21-1000 are generated exactly as before.
class ShapeLevelGenerator {
  /// Dev-time quality-gate counters (no gameplay impact).
  static int candidatesTested = 0;
  static int rejectedUnsolvable = 0;
  static int rejectedShape = 0;

  static void resetStats() {
    candidatesTested = 0;
    rejectedUnsolvable = 0;
    rejectedShape = 0;
  }

  /// Valid candidate tilings compared per level (more as levels rise); the
  /// one with the deepest dependency chains is kept.
  static int _candidatesFor(int levelId) {
    if (ExpansionCatalog.covers(levelId)) {
      return ExpansionCatalog.candidatesFor(levelId);
    }
    return levelId < 56 ? 1 : (levelId < 200 ? 2 : (levelId < 901 ? 3 : 4));
  }

  /// Public entry: generates a shape-driven level for [levelId] that is
  /// guaranteed solvable and shows its named shape.
  static Level generate(int levelId) {
    // Hard boundary: Levels 1-20 are the curated boards, used verbatim.
    if (levelId <= 20) {
      final curated = getCuratedLevel(levelId);
      if (curated != null) return curated;
    }
    return _generateExtended(levelId);
  }

  /// Puzzle settings for [levelId] (21-2000), rising continuously: a
  /// mix of short, medium and long arrows that gets longer and more bent,
  /// deeper dependency chains, fewer free opening moves. The board itself
  /// grows via [LevelWorlds.gridSizeFor].
  static TilerParams paramsFor(int levelId) {
    if (ExpansionCatalog.covers(levelId)) {
      return ExpansionCatalog.paramsFor(levelId);
    }
    final t = ((levelId - 21) / (1000 - 21)).clamp(0.0, 1.0);
    final d = math.pow(t, 0.7).toDouble();
    return TilerParams(
      shortChance: 0.25 - 0.1 * d,
      longChance: 0.1 + 0.25 * d,
      mediumMean: 4.5 + 2.5 * d,
      longMin: (7 + 3 * d).round(),
      maxSize: (10 + 14 * d).round(),
      bendWeight: 16 + 20 * d,
      turnChance: 0.5 + 0.3 * d,
      depthWeight: 4 + 14 * d,
      freePenalty: 80 + 170 * d,
      freeLengthBonus: 6 * d,
      blockedBias: 0.3 + 0.6 * d,
    );
  }

  static Level _generateExtended(int levelId) {
    final world = LevelWorlds.worldFor(levelId);
    final grid = LevelWorlds.gridSizeFor(levelId);
    // All arrows share one colour, so the whole silhouette is one region
    // (arrows may run across the design's parts).
    final regions = {
      for (final c in ExtendedTemplates.buildMask(levelId, grid)) c: 0,
    };
    final target = regions.keys.toSet();
    final params = paramsFor(levelId);

    Level? best;
    List<num>? bestKey;
    final candidates = _candidatesFor(levelId);
    final expansion = ExpansionCatalog.covers(levelId);
    final attemptsPerPiece = expansion
        ? ExpansionCatalog.attemptsPerPieceFor(levelId)
        : 48 + (levelId * 32 ~/ 1000);
    // Expansion levels: candidates below the target depth don't count as
    // accepted, so extra seeds are tried until enough reach it.
    final minDepth = expansion ? ExpansionCatalog.targetDepthFor(levelId) : 0;
    var accepted = 0;
    var bestDepth = 0;
    // Extra seeds are only used if a candidate fails validation. Expansion
    // levels also keep trying (up to 8 more seeds) while the best candidate
    // is below the level's depth floor.
    final floor = expansion ? ExpansionCatalog.depthFloorFor(levelId) : 0;
    for (int attempt = 0;
        (attempt < candidates + 4 && accepted < candidates) ||
            (expansion && attempt < candidates + 12 && bestDepth < floor);
        attempt++) {
      final seed = (levelId * 2654435761 + attempt * 7919) & 0x7FFFFFFF;
      final rescue = expansion && attempt >= candidates + 4;
      final paths = DenseTiler.tile(regions, grid,
          seed: seed,
          params: rescue ? ExpansionCatalog.rescueParamsFor(levelId) : params,
          attemptsPerPiece: attemptsPerPiece);
      candidatesTested++;
      final level = _withMeta(levelId, world, grid, paths);
      // Validate (solver, silhouette coverage, noise) before accepting.
      final q = expansion
          ? LevelQuality.measureFast(level, target)
          : LevelQuality.measure(level, target);
      if (!q.solvable) {
        rejectedUnsolvable++;
        continue;
      }
      // Rescue candidates may use a few more one-cell arrows.
      final ok = q.acceptable ||
          (rescue &&
              q.solvable &&
              q.shapeCoverage >= 0.98 &&
              q.outsideNoise == 0 &&
              q.singles <=
                  (q.arrows * ExpansionCatalog.rescueSingleShare).floor());
      if (!ok) {
        rejectedShape++;
        // Expansion levels rank every candidate (acceptable ones first).
        if (best != null && !expansion) continue;
      } else if (q.depth >= minDepth) {
        accepted++;
      }
      // Prefer acceptable, then deeper chains, then fewer free openings.
      // Expansion levels prefer reaching the target depth, staying close to
      // it (a steady ramp) with the fewest opening moves; else the deepest.
      final reach = q.depth >= minDepth;
      final key = expansion
          ? [
              ok ? 0 : 1,
              reach ? 0 : 1,
              reach ? (q.depth - minDepth) ~/ 4 : -q.depth,
              q.initialMoves,
              q.depth,
            ]
          : [q.acceptable ? 0 : 1, -q.depth, q.freeRatio];
      if (bestKey == null || _less(key, bestKey)) {
        bestKey = key;
        best = level;
        bestDepth = q.depth;
      }
    }
    return best ?? _withMeta(levelId, world, grid, const []);
  }

  static Level _withMeta(
      int levelId, WorldInfo world, int grid, List<PuzzlePath> paths) {
    return Level(
      levelId: levelId,
      gridSize: grid,
      puzzlePaths: paths,
      name: LevelWorlds.shapeFor(levelId),
      shapeName: LevelWorlds.shapeFor(levelId),
      category: world.category,
      world: world.world,
      worldName: world.title,
      difficulty: LevelWorlds.difficultyFor(levelId),
      difficultyName: LevelWorlds.difficultyNameFor(levelId),
    );
  }

  static bool _less(List<num> a, List<num> b) {
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return a[i] < b[i];
    }
    return false;
  }

  /// Arrowhead/direction consistency gate for generated levels.
  ///
  /// The renderer draws the arrowhead from the final path segment, and the
  /// generator stores the escape direction from that same segment, so a
  /// valid generated arrow must satisfy: stored direction == final tangent.
  /// (Single-point arrows draw their head along the stored direction.)
  /// Curated Levels 1-20 follow the same rule.
  static bool directionsConsistent(Level level) {
    for (final p in level.puzzlePaths) {
      if (p.points.isEmpty) return false;
      if (p.points.length == 1) continue;
      final a = p.points[p.points.length - 2];
      final b = p.points.last;
      if (a.x != b.x && a.y != b.y) return false;
      ArrowDirection tangent;
      if (b.x > a.x) {
        tangent = ArrowDirection.right;
      } else if (b.x < a.x) {
        tangent = ArrowDirection.left;
      } else if (b.y > a.y) {
        tangent = ArrowDirection.down;
      } else if (b.y < a.y) {
        tangent = ArrowDirection.up;
      } else {
        return false;
      }
      if (p.direction != tangent) return false;
    }
    return true;
  }
}
