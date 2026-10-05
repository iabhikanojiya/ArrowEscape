import 'dart:math' as math;

import '../../models/level.dart';
import '../../models/puzzle_path.dart';
import '../solver/puzzle_solver.dart';

/// Measured quality of a generated level against its target silhouette.
class LevelQuality {
  /// Share of target silhouette cells covered by arrows.
  final double shapeCoverage;

  /// Share of arrow cells lying outside the target silhouette.
  final double outsideNoise;

  /// Share of the whole board covered by arrows.
  final double occupancy;

  final int arrows;
  final double avgLength;
  final int maxLength;
  final double bendsPerArrow;

  /// Arrows with a single cell (unavoidable specks; kept rare).
  final int singles;

  final bool solvable;

  /// Longest dependency chain (peel rounds).
  final int depth;

  /// Arrows that can escape at the start.
  final int initialMoves;

  const LevelQuality({
    required this.shapeCoverage,
    required this.outsideNoise,
    required this.occupancy,
    required this.arrows,
    required this.avgLength,
    required this.maxLength,
    required this.bendsPerArrow,
    required this.singles,
    required this.solvable,
    required this.depth,
    required this.initialMoves,
  });

  double get freeRatio => arrows == 0 ? 1 : initialMoves / arrows;

  /// Shape fully built from arrows, nothing outside it, solvable, and at
  /// most 6% one-cell arrows (specks left where thin strokes meet).
  bool get acceptable =>
      solvable &&
      shapeCoverage >= 0.98 &&
      outsideNoise == 0 &&
      singles <= math.max(3, (arrows * 0.06).floor());

  /// Same measurements as [measure] from a single [PuzzleSolver.peelRounds]
  /// pass (the algorithm [PuzzleSolver.solve] itself uses for boards of
  /// more than 12 arrows): solvable when every arrow is peeled, depth is
  /// the number of rounds, opening moves the first round. Used to compare
  /// many candidates quickly on the large expansion boards.
  static LevelQuality measureFast(Level level, Set<GridPoint> target) {
    final paths = level.puzzlePaths;
    final cells = <GridPoint>{};
    var totalLength = 0, maxLength = 0, bends = 0, singles = 0;
    for (final p in paths) {
      final occ = p.occupiedCells;
      cells.addAll(occ);
      totalLength += occ.length;
      maxLength = math.max(maxLength, occ.length);
      if (p.points.length >= 3) bends += p.points.length - 2;
      if (occ.length == 1) singles++;
    }
    final inside = cells.where(target.contains).length;
    final n = paths.length;
    final rounds = PuzzleSolver.peelRounds(
      level.createPuzzlePaths(),
      level.gridSize,
    );
    final removed = rounds.fold<int>(0, (s, r) => s + r.length);
    final solvable = n > 12 && removed == n;
    return LevelQuality(
      shapeCoverage: target.isEmpty ? 0 : inside / target.length,
      outsideNoise: cells.isEmpty ? 1 : (cells.length - inside) / cells.length,
      occupancy: cells.length / (level.gridSize * level.gridSize),
      arrows: n,
      avgLength: n == 0 ? 0 : totalLength / n,
      maxLength: maxLength,
      bendsPerArrow: n == 0 ? 0 : bends / n,
      singles: singles,
      solvable: solvable,
      depth: solvable ? rounds.length : 0,
      initialMoves: rounds.isEmpty ? 0 : rounds.first.length,
    );
  }

  static LevelQuality measure(Level level, Set<GridPoint> target) {
    final paths = level.puzzlePaths;
    final cells = <GridPoint>{};
    var totalLength = 0, maxLength = 0, bends = 0, singles = 0;
    for (final p in paths) {
      final occ = p.occupiedCells;
      cells.addAll(occ);
      totalLength += occ.length;
      maxLength = math.max(maxLength, occ.length);
      if (p.points.length >= 3) bends += p.points.length - 2;
      if (occ.length == 1) singles++;
    }
    final inside = cells.where(target.contains).length;
    final res = PuzzleSolver.solve(level);
    final n = paths.length;
    return LevelQuality(
      shapeCoverage: target.isEmpty ? 0 : inside / target.length,
      outsideNoise: cells.isEmpty ? 1 : (cells.length - inside) / cells.length,
      occupancy: cells.length / (level.gridSize * level.gridSize),
      arrows: n,
      avgLength: n == 0 ? 0 : totalLength / n,
      maxLength: maxLength,
      bendsPerArrow: n == 0 ? 0 : bends / n,
      singles: singles,
      solvable: res.solvable && res.solutionDepth == n,
      depth: res.solvable ? PuzzleSolver.dependencyDepth(level) : 0,
      initialMoves: res.initialMoves,
    );
  }
}
