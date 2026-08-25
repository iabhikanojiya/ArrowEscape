import 'dart:math' as math;

import '../../models/arrow.dart';
import '../../models/level.dart';
import '../../models/puzzle_path.dart';
import '../path/path_collision_service.dart';

class _Rng {
  int _state;

  _Rng(int seed) : _state = (seed.abs() & 0x7FFFFFFF) | 1;

  int nextInt(int max) {
    if (max <= 0) return 0;
    _state = (_state * 48271) % 0x7FFFFFFF;
    return _state % max;
  }

  bool nextBool() => nextInt(2) == 0;
}

class _LevelConfig {
  final int gridSize;
  final int pathCount;
  final int minSegments;
  final int maxSegments;
  final int maxSegmentLength;
  final int minInitialMoves;
  final int maxInitialMoves;
  final double maxOccupancyRatio;

  const _LevelConfig({
    required this.gridSize,
    required this.pathCount,
    required this.minSegments,
    required this.maxSegments,
    required this.maxSegmentLength,
    required this.minInitialMoves,
    required this.maxInitialMoves,
    required this.maxOccupancyRatio,
  });
}

class LevelGenerator {
  static const List<int> _dirX = [1, 0, -1, 0];
  static const List<int> _dirY = [0, 1, 0, -1];

  static _LevelConfig _configFor(int levelId) {
    final int gridSize;
    if (levelId <= 10) {
      gridSize = 9;
    } else if (levelId <= 30) {
      gridSize = 10;
    } else {
      gridSize = 12;
    }
    final pathCount = math.min(16, 8 + levelId ~/ 5);

    int minSegments = 2;
    int maxSegments = 3;
    if (levelId <= 10) {
      minSegments = 2;
      maxSegments = 4;
    } else if (levelId <= 30) {
      minSegments = 3;
      maxSegments = 5;
    } else if (levelId <= 60) {
      minSegments = 3;
      maxSegments = 5;
    } else {
      minSegments = 3;
      maxSegments = 6;
    }

    return _LevelConfig(
      gridSize: gridSize,
      pathCount: pathCount,
      minSegments: minSegments,
      maxSegments: maxSegments,
      maxSegmentLength: levelId <= 20 ? 5 : 4,
      minInitialMoves: levelId <= 3 ? 3 : 2,
      maxInitialMoves: levelId <= 3 ? 4 : 7,
      maxOccupancyRatio: 0.72,
    );
  }

  static int difficultyFor(int levelId) {
    if (levelId <= 10) return 1;
    if (levelId <= 30) return 2;
    if (levelId <= 60) return 3;
    if (levelId <= 120) return 4;
    return 5;
  }

  static String difficultyNameFor(int levelId) {
    switch (difficultyFor(levelId)) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      case 4:
        return 'Expert';
      default:
        return 'Master';
    }
  }

  static Level generate(int levelId) {
    final baseSeed = (levelId * 2654435761) & 0x7FFFFFFF;
    Level? best;
    int bestScore = -(1 << 30);

    for (int attempt = 0; attempt < 12; attempt++) {
      final rng = _Rng(baseSeed + attempt * 7919);
      final config = _configFor(levelId);
      final level = _attemptGenerate(levelId, config, rng);
      if (level == null) continue;

      final freeMoves = _countValidMoves(level);
      int score = level.puzzlePaths.length * 1000 + _totalCells(level);
      if (freeMoves < config.minInitialMoves) {
        score -= 100000;
      } else if (freeMoves > config.maxInitialMoves) {
        score -= (freeMoves - config.maxInitialMoves) * 300;
      }
      if (score > bestScore) {
        bestScore = score;
        best = level;
      }
      final acceptableCount =
          level.puzzlePaths.length >= math.max(4, config.pathCount * 3 ~/ 4);
      if (acceptableCount &&
          freeMoves >= config.minInitialMoves &&
          freeMoves <= config.maxInitialMoves) {
        return best!;
      }
    }
    return best ?? _fallbackLevel(levelId);
  }

  static Level? _attemptGenerate(int levelId, _LevelConfig config, _Rng rng) {
    final grid = config.gridSize;
    final occupied = <GridPoint>{};
    final freeList = <GridPoint>[];
    final freeIndex = <GridPoint, int>{};
    for (int x = 0; x < grid; x++) {
      for (int y = 0; y < grid; y++) {
        final pt = GridPoint(x, y);
        freeIndex[pt] = freeList.length;
        freeList.add(pt);
      }
    }
    final placed = <PuzzlePath>[];
    final cellCapacity = (grid * grid * config.maxOccupancyRatio).toInt();

    int attempts = 0;
    while (placed.length < config.pathCount &&
        attempts < config.pathCount * 80 &&
        freeList.isNotEmpty) {
      attempts++;
      if (occupied.length >= cellCapacity) break;

      final pathsRemaining = config.pathCount - placed.length;
      final cellsRemaining = cellCapacity - occupied.length;
      final budgetPerPath = cellsRemaining ~/ math.max(1, pathsRemaining);
      var segLenCap = config.maxSegmentLength;
      if (budgetPerPath < config.minSegments * 2 + 2) {
        segLenCap = math.max(2, budgetPerPath ~/ math.max(1, config.minSegments));
      }

      final start = freeList[rng.nextInt(freeList.length)];
      final path =
          _tryPlaceFrom(rng, grid, occupied, config, segLenCap.clamp(2, config.maxSegmentLength), start);
      if (path == null) continue;
      placed.add(path);
      occupied.addAll(path.occupiedCells);
      _consumeFreeCells(freeList, freeIndex, path);
    }

    const relaxedConfig = _LevelConfig(
      gridSize: 0,
      pathCount: 0,
      minSegments: 2,
      maxSegments: 3,
      maxSegmentLength: 3,
      minInitialMoves: 0,
      maxInitialMoves: 99,
      maxOccupancyRatio: 1.0,
    );
    int topUp = 0;
    while (topUp < 160 && freeList.isNotEmpty) {
      topUp++;
      if (occupied.length >= cellCapacity) break;
      final start = freeList[rng.nextInt(freeList.length)];
      final path = _tryPlaceFrom(rng, grid, occupied, relaxedConfig, 3, start);
      if (path == null) continue;
      placed.add(path);
      occupied.addAll(path.occupiedCells);
      _consumeFreeCells(freeList, freeIndex, path);
    }

    if (placed.length < math.max(6, config.pathCount * 2 ~/ 3)) return null;

    final paths = <PuzzlePath>[];
    for (int i = 0; i < placed.length; i++) {
      paths.add(PuzzlePath(
        id: '${i + 1}',
        points: placed[i].points,
        direction: placed[i].direction,
      ));
    }
    return Level(
      levelId: levelId,
      gridSize: grid,
      puzzlePaths: paths,
      difficulty: difficultyFor(levelId),
      difficultyName: difficultyNameFor(levelId),
    );
  }

  static void _consumeFreeCells(
      List<GridPoint> freeList, Map<GridPoint, int> freeIndex, PuzzlePath path) {
    for (final cell in path.occupiedCells) {
      final idx = freeIndex[cell];
      if (idx != null && idx < freeList.length && freeList[idx] == cell) {
        final last = freeList.removeLast();
        if (idx < freeList.length) {
          freeList[idx] = last;
          freeIndex[last] = idx;
        }
        freeIndex.remove(cell);
      }
    }
  }

  static PuzzlePath? _tryPlaceFrom(_Rng rng, int grid, Set<GridPoint> occupied,
      _LevelConfig config, int segmentLengthCap, GridPoint start) {
    var position = start;
    final visited = <GridPoint>{position};
    final points = <GridPoint>[position];

    var d = rng.nextInt(4);
    final segments = config.minSegments +
        rng.nextInt(config.maxSegments - config.minSegments + 1);

    for (int s = 0; s < segments; s++) {
      if (s > 0) {
        d = (d + (rng.nextBool() ? 1 : 3)) % 4;
      }
      final desiredLength = 2 +
          rng.nextInt(math.max(1, segmentLengthCap - 1));

      var steps =
          _feasibleSteps(position, d, desiredLength, grid, occupied, visited);
      if (steps < 2 && s > 0) {
        d = (d + 2) % 4;
        steps =
            _feasibleSteps(position, d, desiredLength, grid, occupied, visited);
      }
      if (steps == 0) break;
      if (steps < 2 && s == 0) {
        d = (d + 2) % 4;
        steps =
            _feasibleSteps(position, d, desiredLength, grid, occupied, visited);
        if (steps < 2) break;
      }

      for (int i = 0; i < steps; i++) {
        position = GridPoint(position.x + _dirX[d], position.y + _dirY[d]);
        visited.add(position);
      }
      points.add(position);
    }

    if (points.length < 3) return null;
    if (!_hasTurn(points)) return null;

    final direction = _lastSegmentDirection(points);
    if (!PathCollisionService.corridorIsClear(points, direction, occupied, grid)) {
      return null;
    }

    return PuzzlePath(id: 'tmp', points: points, direction: direction);
  }

  static bool _hasTurn(List<GridPoint> points) {
    for (int i = 2; i < points.length; i++) {
      final a = points[i - 2];
      final b = points[i - 1];
      final c = points[i];
      if ((a.x != b.x || b.x != c.x) && (a.y != b.y || b.y != c.y)) {
        return true;
      }
    }
    return false;
  }

  static ArrowDirection _lastSegmentDirection(List<GridPoint> points) {
    final a = points[points.length - 2];
    final b = points[points.length - 1];
    if (b.x > a.x) return ArrowDirection.right;
    if (b.x < a.x) return ArrowDirection.left;
    if (b.y > a.y) return ArrowDirection.down;
    return ArrowDirection.up;
  }

  static int _feasibleSteps(GridPoint from, int d, int maxSteps, int grid,
      Set<GridPoint> occupied, Set<GridPoint> visited) {
    var x = from.x;
    var y = from.y;
    int steps = 0;
    while (steps < maxSteps) {
      final nx = x + _dirX[d];
      final ny = y + _dirY[d];
      if (nx < 0 || nx >= grid || ny < 0 || ny >= grid) break;
      final pt = GridPoint(nx, ny);
      if (occupied.contains(pt) || visited.contains(pt)) break;
      x = nx;
      y = ny;
      steps++;
    }
    return steps;
  }

  static int _countValidMoves(Level level) {
    int count = 0;
    for (final p in level.puzzlePaths) {
      if (PathCollisionService.corridorIsClear(p.points, p.direction,
          _allOtherCells(p, level.puzzlePaths), level.gridSize)) {
        count++;
      }
    }
    return count;
  }

  static Set<GridPoint> _allOtherCells(PuzzlePath exclude, List<PuzzlePath> all) {
    final set = <GridPoint>{};
    for (final p in all) {
      if (p.id == exclude.id) continue;
      set.addAll(p.occupiedCells);
    }
    return set;
  }

  static int _totalCells(Level level) {
    return level.puzzlePaths.fold(0, (sum, p) => sum + p.occupiedCells.length);
  }

  static Level _fallbackLevel(int levelId) {
    final grid = _configFor(levelId).gridSize;
    final paths = <PuzzlePath>[
      PuzzlePath(id: '1', points: [
        const GridPoint(0, 1),
        const GridPoint(0, 3),
        const GridPoint(2, 3),
      ], direction: ArrowDirection.right),
      PuzzlePath(id: '2', points: [
        GridPoint(grid - 1, 2),
        GridPoint(grid - 1, 0),
        GridPoint(grid - 3, 0),
      ], direction: ArrowDirection.left),
      PuzzlePath(id: '3', points: [
        GridPoint(1, grid - 1),
        GridPoint(1, grid - 3),
        GridPoint(3, grid - 3),
      ], direction: ArrowDirection.right),
      PuzzlePath(id: '4', points: [
        GridPoint(grid - 2, grid - 2),
        GridPoint(grid - 2, grid - 1),
        GridPoint(grid - 4, grid - 1),
      ], direction: ArrowDirection.left),
    ];
    return Level(
      levelId: levelId,
      gridSize: grid,
      puzzlePaths: paths,
      difficulty: difficultyFor(levelId),
      difficultyName: difficultyNameFor(levelId),
    );
  }
}
