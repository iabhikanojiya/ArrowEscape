import 'dart:math' as math;

import 'arrow.dart';

/// Minimal logical coordinate, integer grid.
class GridPoint {
  final int x;
  final int y;
  const GridPoint(this.x, this.y);

  @override
  bool operator ==(Object other) => other is GridPoint && other.x == x && other.y == y;
  @override
  int get hashCode => Object.hash(x, y);
  @override
  String toString() => '($x,$y)';
}

enum PathState { active, moving, removed }

class PuzzlePath {
  final String id;
  final List<GridPoint> points; // polyline points, at least 2 for shaped path, 1 for straight single-cell legacy
  /// Stored direction; only used when the path has no final segment to
  /// derive it from (single-point or degenerate paths).
  final ArrowDirection _declaredDirection;
  PathState state;
  final int colorIndex;

  PuzzlePath({
    required this.id,
    required this.points,
    required ArrowDirection direction,
    this.state = PathState.active,
    this.colorIndex = 0,
  }) : _declaredDirection = direction;

  /// Canonical escape direction: the direction the arrowhead visibly points,
  /// i.e. the final segment (`points.last - points[length - 2]`), exactly as
  /// `PathGeometry.arrowHead` draws it. Rendering, tap/move, collision and
  /// the solver all read this, so the arrow always moves where it points.
  ArrowDirection get direction {
    if (points.length < 2) return _declaredDirection;
    final a = points[points.length - 2];
    final b = points.last;
    if (a.y == b.y && b.x > a.x) return ArrowDirection.right;
    if (a.y == b.y && b.x < a.x) return ArrowDirection.left;
    if (a.x == b.x && b.y > a.y) return ArrowDirection.down;
    if (a.x == b.x && b.y < a.y) return ArrowDirection.up;
    return _declaredDirection;
  }

  /// Head is the arrow tip location (last point)
  GridPoint get head => points.isNotEmpty ? points.last : const GridPoint(0, 0);
  GridPoint get tail => points.isNotEmpty ? points.first : const GridPoint(0, 0);

  int get minX => points.map((p) => p.x).reduce(math.min);
  int get maxX => points.map((p) => p.x).reduce(math.max);
  int get minY => points.map((p) => p.y).reduce(math.min);
  int get maxY => points.map((p) => p.y).reduce(math.max);

  int get segmentCount => points.isEmpty ? 0 : points.length - 1;

  /// All grid cells occupied by this path, including interpolated cells between
  /// segment endpoints ( Manhattan straight segments only ).
  Set<GridPoint> get occupiedCells {
    final set = <GridPoint>{};
    if (points.isEmpty) return set;
    if (points.length == 1) {
      set.add(points.first);
      return set;
    }
    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      if (a.x == b.x) {
        // vertical
        final yStart = a.y < b.y ? a.y : b.y;
        final yEnd = a.y < b.y ? b.y : a.y;
        for (int y = yStart; y <= yEnd; y++) {
          set.add(GridPoint(a.x, y));
        }
      } else if (a.y == b.y) {
        // horizontal
        final xStart = a.x < b.x ? a.x : b.x;
        final xEnd = a.x < b.x ? b.x : a.x;
        for (int x = xStart; x <= xEnd; x++) {
          set.add(GridPoint(x, a.y));
        }
      } else {
        // diagonal fallback (should not happen for 90deg design) - add endpoints
        set.add(a);
        set.add(b);
      }
    }
    return set;
  }

  PuzzlePath copyWith({
    String? id,
    List<GridPoint>? points,
    ArrowDirection? direction,
    PathState? state,
    int? colorIndex,
  }) {
    return PuzzlePath(
      id: id ?? this.id,
      points: points ?? List<GridPoint>.from(this.points),
      direction: direction ?? _declaredDirection,
      state: state ?? this.state,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  @override
  bool operator ==(Object other) => other is PuzzlePath && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
