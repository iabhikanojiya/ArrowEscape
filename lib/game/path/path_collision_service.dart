import 'dart:math' as math;

import '../../models/arrow.dart';
import '../../models/puzzle_path.dart';

class PathCollisionService {
  static bool canPathEscape(PuzzlePath path, List<PuzzlePath> allPaths, int boardSize) {
    if (path.state != PathState.active) return false;
    final occupied = _occupiedCellsExcluding(allPaths, path.id);
    return _corridorIsClear(
        _expand(path.points), path.direction, occupied, boardSize);
  }

  static PuzzlePath? getBlockingPath(PuzzlePath path, List<PuzzlePath> allPaths, int boardSize) {
    final owners = <GridPoint, PuzzlePath>{};
    for (final p in allPaths) {
      if (p.id == path.id) continue;
      if (p.state != PathState.active) continue;
      for (final cell in p.occupiedCells) {
        owners[cell] = p;
      }
    }
    final vec = path.direction.vector;
    final stepX = vec.dx.toInt();
    final stepY = vec.dy.toInt();
    final own = path.occupiedCells;
    for (final cell in own) {
      var x = cell.x + stepX;
      var y = cell.y + stepY;
      while (x >= 0 && x < boardSize && y >= 0 && y < boardSize) {
        final blocker = owners[GridPoint(x, y)];
        if (blocker != null) return blocker;
        x += stepX;
        y += stepY;
      }
    }
    return null;
  }

  static bool corridorIsClear(
    List<GridPoint> cells,
    ArrowDirection direction,
    Set<GridPoint> occupied,
    int boardSize,
  ) {
    return _corridorIsClear(
        _expand(cells), direction, occupied, boardSize);
  }

  static bool _corridorIsClear(
    Set<GridPoint> own,
    ArrowDirection direction,
    Set<GridPoint> occupied,
    int boardSize,
  ) {
    final vec = direction.vector;
    final stepX = vec.dx.toInt();
    final stepY = vec.dy.toInt();
    for (final cell in own) {
      var x = cell.x + stepX;
      var y = cell.y + stepY;
      while (x >= 0 && x < boardSize && y >= 0 && y < boardSize) {
        final pt = GridPoint(x, y);
        if (!own.contains(pt) && occupied.contains(pt)) return false;
        x += stepX;
        y += stepY;
      }
    }
    return true;
  }

  static Set<GridPoint> _expand(List<GridPoint> points) {
    final set = <GridPoint>{};
    if (points.length == 1) {
      set.add(points.first);
      return set;
    }
    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      if (a.x == b.x) {
        final yStart = math.min(a.y, b.y);
        final yEnd = math.max(a.y, b.y);
        for (int y = yStart; y <= yEnd; y++) {
          set.add(GridPoint(a.x, y));
        }
      } else if (a.y == b.y) {
        final xStart = math.min(a.x, b.x);
        final xEnd = math.max(a.x, b.x);
        for (int x = xStart; x <= xEnd; x++) {
          set.add(GridPoint(x, a.y));
        }
      }
    }
    return set;
  }

  static bool canPathMoveInState(PuzzlePath path, List<PuzzlePath> snapshot, int boardSize) {
    if (path.state != PathState.active) return false;
    return canPathEscape(path, snapshot, boardSize);
  }

  static Set<GridPoint> _occupiedCellsExcluding(List<PuzzlePath> paths, String excludeId) {
    final set = <GridPoint>{};
    for (final p in paths) {
      if (p.id == excludeId) continue;
      if (p.state != PathState.active) continue;
      set.addAll(p.occupiedCells);
    }
    return set;
  }
}
