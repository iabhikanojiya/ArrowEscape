// ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:collection';

import '../../models/level.dart';
import '../../models/puzzle_path.dart';
import '../path/path_collision_service.dart';

/// Result of solving a level.
class SolverResult {
  final bool solvable;
  final int?
  solutionDepth; // number of moves to clear (== pathCount if solvable)
  final int exploredStates;
  final int maxBranching;
  final int initialMoves;
  final double occupancyRatio;
  final int intersections;
  final double avgPathLength;

  const SolverResult({
    required this.solvable,
    this.solutionDepth,
    required this.exploredStates,
    required this.maxBranching,
    required this.initialMoves,
    required this.occupancyRatio,
    required this.intersections,
    required this.avgPathLength,
  });
}

class PuzzleSolver {
  /// Checks if [level] is solvable (exists an order removing all paths).
  static bool isSolvable(Level level) => solve(level).solvable;

  /// Full solve with metrics. BFS over removal orders for small boards
  /// (<= 12 arrows); larger boards use [peelRounds], which is exact because
  /// removals never block other arrows. Gameplay/collision rules unchanged.
  static SolverResult solve(Level level) {
    final paths = level.createPuzzlePaths();
    final n = paths.length;
    if (n == 0) {
      return const SolverResult(
        solvable: false,
        exploredStates: 0,
        maxBranching: 0,
        initialMoves: 0,
        occupancyRatio: 0,
        intersections: 0,
        avgPathLength: 0,
      );
    }

    // Precompute metrics that don't need search
    final occupancy = _occupancyRatio(paths, level.gridSize);
    final avgLen = _avgPathLength(paths);
    final intersections = _estimateIntersections(paths);
    final initialMoves = _validMoves(paths, level.gridSize).length;

    // Larger boards: DFS (complete with visited set, depth-first for speed).
    // Removing an arrow never blocks another, so DFS reaches the full-depth
    // solution in ~N steps; BFS over removal orders explodes on dense boards.
    if (n > 12) {
      return _solveLarge(
        paths,
        level.gridSize,
        occupancy: occupancy,
        avgLen: avgLen,
        intersections: intersections,
        initialMoves: initialMoves,
      );
    }

    // BFS over removal order
    final visited = <String>{};
    final queue = Queue<List<PuzzlePath>>();
    final depths = Queue<int>();

    // hash = sorted ids of active paths
    String hash(List<PuzzlePath> state) {
      final ids =
          state
              .where((p) => p.state == PathState.active)
              .map((p) => p.id)
              .toList()
            ..sort();
      return ids.join(',');
    }

    final startHash = hash(paths);
    visited.add(startHash);
    queue.add(paths.map((p) => p.copyWith()).toList());
    depths.add(0);

    int explored = 0;
    int maxBranch = 0;

    while (queue.isNotEmpty) {
      final cur = queue.removeFirst();
      final d = depths.removeFirst();
      explored++;

      final active = cur.where((p) => p.state == PathState.active).toList();
      if (active.isEmpty) {
        return SolverResult(
          solvable: true,
          solutionDepth: d,
          exploredStates: explored,
          maxBranching: maxBranch,
          initialMoves: initialMoves,
          occupancyRatio: occupancy,
          intersections: intersections,
          avgPathLength: avgLen,
        );
      }

      final valid = _validMoves(cur, level.gridSize);
      if (valid.length > maxBranch) maxBranch = valid.length;
      if (valid.isEmpty) continue; // dead end

      for (final vm in valid) {
        final next = cur.map((p) => p.copyWith()).toList();
        final idx = next.indexWhere((p) => p.id == vm.id);
        if (idx != -1) {
          next[idx] = next[idx].copyWith(state: PathState.removed);
        }
        final h = hash(next);
        if (!visited.contains(h)) {
          visited.add(h);
          queue.add(next);
          depths.add(d + 1);
          // Early exit if found minimal solution? BFS guarantees minimal.
          // We continue until we pop solved state (which will be minimal depth)
        }
      }

      // Safety cap to avoid explosion for pathological large levels
      if (explored > 80000) {
        // Assume unsolvable / too complex
        break;
      }
    }

    return SolverResult(
      solvable: false,
      exploredStates: explored,
      maxBranching: maxBranch,
      initialMoves: initialMoves,
      occupancyRatio: occupancy,
      intersections: intersections,
      avgPathLength: avgLen,
    );
  }

  /// Estimates difficulty score 1..10 based on multiple dimensions.
  static int estimateDifficulty(Level level) {
    final res = solve(level);
    if (!res.solvable) return 10;
    // Dimensions per spec:
    // 1) arrow count (pathCount)
    // 2) intersections
    // 3) blocking dependencies (implicit via maxBranching & initialMoves)
    // 4) tightness (occupancy)
    // 5) longer paths (avgLen)
    // 6) solution depth (==pathCount)
    final n = level.puzzlePaths.length;
    double score = 0;
    score += n * 0.55; // 1
    score += res.intersections * 0.35; //2
    score += res.occupancyRatio * 6; //4
    score += res.avgPathLength * 0.45; //5
    // fewer initial moves => harder (more constrained)
    score += (7 - res.initialMoves.clamp(0, 6)) * 0.6; //8,9
    score += res.maxBranching * 0.2;
    // Normalize: world1 should be ~1-2, world7 ~9-10
    if (score < 6) return 1;
    if (score < 9) return 2;
    if (score < 12) return 3;
    if (score < 15) return 4;
    if (score < 18) return 5;
    if (score < 21) return 6;
    if (score < 24) return 7;
    if (score < 27) return 8;
    if (score < 30) return 9;
    return 10;
  }

  /// Solver for larger boards (more than 12 arrows).
  ///
  /// Removing an arrow only frees cells, so an arrow that can escape stays
  /// escapable whatever else is removed first. Repeatedly removing every
  /// currently escapable arrow therefore clears the board exactly when the
  /// level is solvable, with no search or backtracking. Uses the same
  /// collision rule ([PathCollisionService.corridorIsClear]) against an
  /// incrementally maintained occupancy set, so 200+ arrow boards validate
  /// in milliseconds. [SolverResult.exploredStates] is the number of peel
  /// rounds, i.e. the dependency depth.
  static SolverResult _solveLarge(
    List<PuzzlePath> paths,
    int boardSize, {
    required double occupancy,
    required double avgLen,
    required int intersections,
    required int initialMoves,
  }) {
    final rounds = peelRounds(paths, boardSize);
    final removed = rounds.fold<int>(0, (s, r) => s + r.length);
    final active = paths.where((p) => p.state == PathState.active).length;
    return SolverResult(
      solvable: removed == active,
      solutionDepth: removed == active ? removed : null,
      exploredStates: rounds.length,
      maxBranching: rounds.fold<int>(0, (m, r) => r.length > m ? r.length : m),
      initialMoves: initialMoves,
      occupancyRatio: occupancy,
      intersections: intersections,
      avgPathLength: avgLen,
    );
  }

  /// Peels [paths] in rounds: each round removes every arrow that can
  /// escape at that moment. Round k holds the arrows whose longest chain of
  /// blockers has length k-1. Stops early if the board deadlocks.
  static List<List<PuzzlePath>> peelRounds(
      List<PuzzlePath> paths, int boardSize) {
    final active = paths.where((p) => p.state == PathState.active).toList();
    final occupied = <GridPoint>{};
    for (final p in active) {
      occupied.addAll(p.occupiedCells);
    }
    final rounds = <List<PuzzlePath>>[];
    while (active.isNotEmpty) {
      final free = [
        for (final p in active)
          if (PathCollisionService.corridorIsClear(
              p.points, p.direction, occupied, boardSize))
            p,
      ];
      if (free.isEmpty) break;
      for (final p in free) {
        active.remove(p);
        occupied.removeAll(p.occupiedCells);
      }
      rounds.add(free);
    }
    return rounds;
  }

  /// Longest dependency chain: the number of peel rounds needed to clear
  /// [level] (0 if it cannot be cleared).
  static int dependencyDepth(Level level) {
    final paths = level.createPuzzlePaths();
    final rounds = peelRounds(paths, level.gridSize);
    final removed = rounds.fold<int>(0, (s, r) => s + r.length);
    return removed == paths.length ? rounds.length : 0;
  }

  static List<PuzzlePath> _validMoves(List<PuzzlePath> state, int boardSize) {
    final active = state.where((p) => p.state == PathState.active).toList();
    final res = <PuzzlePath>[];
    for (final p in active) {
      if (PathCollisionService.canPathEscape(p, state, boardSize)) {
        res.add(p);
      }
    }
    return res;
  }

  static double _occupancyRatio(List<PuzzlePath> paths, int gridSize) {
    final cells = <GridPoint>{};
    for (final p in paths) {
      cells.addAll(p.occupiedCells);
    }
    final total = gridSize * gridSize;
    return cells.length / total;
  }

  static double _avgPathLength(List<PuzzlePath> paths) {
    if (paths.isEmpty) return 0;
    final totalCells = paths.fold<int>(0, (s, p) => s + p.occupiedCells.length);
    return totalCells / paths.length;
  }

  static int _estimateIntersections(List<PuzzlePath> paths) {
    int count = 0;
    final allCells = paths.map((p) => p.occupiedCells).toList();
    for (int i = 0; i < allCells.length; i++) {
      for (int j = i + 1; j < allCells.length; j++) {
        bool close = false;
        for (final a in allCells[i]) {
          for (final b in allCells[j]) {
            final d = (a.x - b.x).abs() + (a.y - b.y).abs();
            if (d <= 2) {
              close = true;
              break;
            }
          }
          if (close) break;
        }
        if (close) count++;
      }
    }
    return count;
  }

  /// Validates curated level: checks Level.isValid + solvable + difficulty reasonable.
  static bool validate(
    Level level, {
    int? expectedMinDifficulty,
    int? expectedMaxDifficulty,
  }) {
    if (!level.isValid) return false;
    final res = solve(level);
    if (!res.solvable) return false;
    if (expectedMinDifficulty != null &&
        estimateDifficulty(level) < expectedMinDifficulty)
      return false;
    if (expectedMaxDifficulty != null &&
        estimateDifficulty(level) > expectedMaxDifficulty)
      return false;
    // Avoid trivial: need at least 2 initial moves? allow 1 for very early tutorial but not for hard
    if (level.puzzlePaths.length > 8 && res.initialMoves < 2) return false;
    // Avoid too dense
    if (res.occupancyRatio > 0.78) return false;
    return true;
  }
}
