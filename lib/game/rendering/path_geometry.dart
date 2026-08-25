import 'dart:math' as math;
import 'dart:ui';

import 'package:arrow_escape/models/arrow.dart';
import 'package:arrow_escape/models/puzzle_path.dart';

/// Immutable geometry for one arrow: pixel-space polyline plus its
/// PathMetric so distance/tangent queries never rebuild anything.
class TracedPath {
  final Path polyline;
  final List<Offset> vertices;

  /// Metric of [polyline]. For escaping arrows the polyline is extended
  /// beyond the board, so length covers both the visible track and the
  /// off-screen runway.
  final PathMetric metric;
  final double length;

  const TracedPath({
    required this.polyline,
    required this.vertices,
    required this.metric,
    required this.length,
  });
}

class PathGeometry {
  static double cellSizeFor(double dimension, int gridSize) =>
      dimension / gridSize;

  static Offset toPixel(GridPoint p, double cell, Offset offset) {
    return Offset(
      p.x * cell + cell / 2 + offset.dx,
      p.y * cell + cell / 2 + offset.dy,
    );
  }

  /// Builds the traced geometry for [path]. When [exitExtension] > 0 the
  /// polyline continues past its head along the final segment direction,
  /// creating the runway the arrowhead uses to leave the board.
  ///
  /// This is the ONLY place arrow geometry is created; results are cached
  /// by the caller and reused across animation frames.
  static TracedPath buildTracedPath(
      PuzzlePath path, double cell,
      {double exitExtension = 0}) {
    final points = path.points;
    if (points.isEmpty) {
      final empty = Path();
      return TracedPath(
        polyline: empty,
        vertices: const [],
        metric: empty.computeMetrics().first,
        length: 0,
      );
    }

    final vertices = <Offset>[];
    if (points.length == 1) {
      final dir = path.direction.vector;
      final c = toPixel(points.first, cell, Offset.zero);
      final len = cell * 0.7;
      vertices.add(Offset(c.dx - dir.dx * len * 0.5, c.dy - dir.dy * len * 0.5));
      vertices.add(Offset(c.dx + dir.dx * len * 0.5, c.dy + dir.dy * len * 0.5));
    } else {
      for (final p in points) {
        vertices.add(toPixel(p, cell, Offset.zero));
      }
    }

    if (exitExtension > 0 && vertices.isNotEmpty) {
      final dir = path.direction.vector;
      final last = vertices.last;
      vertices.add(Offset(
        last.dx + dir.dx * exitExtension,
        last.dy + dir.dy * exitExtension,
      ));
    }

    final polyline = Path();
    polyline.moveTo(vertices.first.dx, vertices.first.dy);
    for (int i = 1; i < vertices.length; i++) {
      polyline.lineTo(vertices[i].dx, vertices[i].dy);
    }

    final metric = polyline.computeMetrics().first;
    return TracedPath(
      polyline: polyline,
      vertices: vertices,
      metric: metric,
      length: metric.length,
    );
  }

  /// Distance the ARROWHEAD must travel past its final endpoint, along its
  /// own direction, until it is fully outside the board area.
  static double headExitExtension(
      PuzzlePath path, double cell, double dimension, double margin) {
    final head = toPixel(path.head, cell, Offset.zero);
    switch (path.direction) {
      case ArrowDirection.right:
        return math.max(0, dimension - head.dx) + margin;
      case ArrowDirection.left:
        return math.max(0, head.dx) + margin;
      case ArrowDirection.down:
        return math.max(0, dimension - head.dy) + margin;
      case ArrowDirection.up:
        return math.max(0, head.dy) + margin;
    }
  }

  /// Duration for the full journey (track + runway). Scales with total
  /// travelled length so speed feels consistent: short paths ~350ms,
  /// long paths up to ~700ms.
  static Duration escapeDuration(double totalLengthPx, double cell) {
    final cellsTravelled = totalLengthPx / math.max(cell, 1);
    final ms = 190 + cellsTravelled * 34;
    return Duration(milliseconds: ms.clamp(340, 700).toInt());
  }

  static double distanceToPolyline(Offset point, List<Offset> vertices) {
    if (vertices.isEmpty) return double.infinity;
    if (vertices.length == 1) return (point - vertices.first).distance;
    var best = double.infinity;
    for (int i = 0; i < vertices.length - 1; i++) {
      best =
          math.min(best, _distanceToSegment(point, vertices[i], vertices[i + 1]));
    }
    return best;
  }

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final squaredLen = ab.distanceSquared;
    if (squaredLen == 0) return (p - a).distance;
    final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / squaredLen).clamp(0.0, 1.0);
    final projected = a + ab * t;
    return (p - projected).distance;
  }

  /// Subtle blocked shake: 0 -> -4 -> +4 -> -2 -> 0
  static double blockedShakeDx(double t) {
    const keys = [0.0, -4.0, 4.0, -2.0, 0.0];
    final x = (t.clamp(0.0, 1.0)) * (keys.length - 1);
    final i = x.floor();
    if (i >= keys.length - 1) return keys.last;
    final f = x - i;
    return keys[i] + (keys[i + 1] - keys[i]) * f;
  }
}
