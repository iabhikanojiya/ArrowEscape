import 'dart:math' as math;
import 'dart:ui';

import 'package:arrow_escape/models/arrow.dart';
import 'package:arrow_escape/models/puzzle_path.dart';

/// Open-arrowhead geometry: tip plus two wing endpoints, all derived from
/// the final path segment (see [PathGeometry.arrowHead]).
class ArrowHead {
  final Offset tip;
  final Offset wing1;
  final Offset wing2;
  final double length;
  final double width;
  final double angle;

  const ArrowHead({
    required this.tip,
    required this.wing1,
    required this.wing2,
    required this.length,
    required this.width,
    required this.angle,
  });
}

/// Immutable geometry for one arrow: pixel-space polyline plus its
/// PathMetric so distance/tangent queries never rebuild anything.
class TracedPath {
  final Path polyline;
  final List<Offset> vertices;

  /// Metric of [polyline]. For escaping arrows the polyline is extended
  /// beyond the head along the arrowhead direction (the exit runway).
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

  /// Subtle visual corner radius for rounded bends (display only).
  /// Logical points, collision, and hit-testing stay sharp; only the drawn
  /// polyline is filleted. ~2-5px across board scales.
  static double cornerRadiusFor(double cell) =>
      (cell * 0.18).clamp(2.0, 5.0).toDouble();

  static Offset toPixel(GridPoint p, double cell, Offset offset) {
    return Offset(
      p.x * cell + cell / 2 + offset.dx,
      p.y * cell + cell / 2 + offset.dy,
    );
  }

  /// Builds the traced geometry for [path]. When [exitExtension] > 0 the
  /// polyline continues past its head along the canonical escape (arrowhead)
  /// direction, creating the runway the arrow slithers out on.
  ///
  /// When [roundedCorners] is true, interior 90-degree bends are filleted
  /// with [cornerRadius] for display (logical [vertices] stay sharp so head
  /// placement, collision, and hit-testing are unchanged). Defaults are off
  /// so existing callers and geometry tests keep exact sharp behavior.
  ///
  /// [endTrim] shortens only the drawn endpoint (along the final segment)
  /// so the shaft's round cap never pokes past the arrowhead tip. The stored
  /// [TracedPath.vertices] remain untrimmed.
  ///
  /// This is the ONLY place arrow geometry is created; results are cached
  /// by the caller and reused across animation frames.
  static TracedPath buildTracedPath(
      PuzzlePath path, double cell,
      {double exitExtension = 0,
      bool roundedCorners = false,
      double cornerRadius = 0,
      double endTrim = 0}) {
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

    // Display-only endpoint trim (see [endTrim]); sharp vertices preserved.
    var drawn = vertices;
    if (endTrim > 0 && vertices.length >= 2) {
      final a = vertices[vertices.length - 2];
      final b = vertices.last;
      final dx = b.dx - a.dx;
      final dy = b.dy - a.dy;
      final segLen = math.sqrt(dx * dx + dy * dy);
      if (segLen > 1e-6) {
        final trim = math.min(endTrim, segLen * 0.4);
        drawn = List<Offset>.of(vertices);
        drawn[drawn.length - 1] =
            Offset(b.dx - dx / segLen * trim, b.dy - dy / segLen * trim);
      }
    }

    final polyline = Path();
    polyline.moveTo(drawn.first.dx, drawn.first.dy);
    if (!roundedCorners || cornerRadius <= 0 || drawn.length < 3) {
      for (int i = 1; i < drawn.length; i++) {
        polyline.lineTo(drawn[i].dx, drawn[i].dy);
      }
    } else {
      // Fillet each interior 90-degree bend: cut the corner with a
      // quadratic bezier (control at the sharp corner) so predominantly
      // horizontal/vertical paths keep their shape with softly rounded bends.
      for (int i = 1; i < drawn.length - 1; i++) {
        final prev = drawn[i - 1];
        final cur = drawn[i];
        final next = drawn[i + 1];
        final inDx = cur.dx - prev.dx;
        final inDy = cur.dy - prev.dy;
        final outDx = next.dx - cur.dx;
        final outDy = next.dy - cur.dy;
        final inLen = math.sqrt(inDx * inDx + inDy * inDy);
        final outLen = math.sqrt(outDx * outDx + outDy * outDy);
        final straight =
            (inLen == 0 || outLen == 0) ||
            (inDx / inLen == outDx / outLen &&
                inDy / inLen == outDy / outLen);
        if (straight) {
          polyline.lineTo(cur.dx, cur.dy);
          continue;
        }
        final rr = math.min(
          cornerRadius,
          math.min(inLen, outLen) * 0.5,
        );
        final ax = cur.dx - (inDx / inLen) * rr;
        final ay = cur.dy - (inDy / inLen) * rr;
        final bx = cur.dx + (outDx / outLen) * rr;
        final by = cur.dy + (outDy / outLen) * rr;
        polyline.lineTo(ax, ay);
        polyline.quadraticBezierTo(cur.dx, cur.dy, bx, by);
      }
      polyline.lineTo(drawn.last.dx, drawn.last.dy);
    }

    final metric = polyline.computeMetrics().first;
    return TracedPath(
      polyline: polyline,
      vertices: vertices,
      metric: metric,
      length: metric.length,
    );
  }

  /// Open-arrowhead geometry derived SOLELY from the final segment.
  ///
  /// - [tip] is exactly the logical endpoint (`vertices.last`).
  /// - Direction is the final-segment tangent (`last - secondLast`),
  ///   never the first/longest segment or bounding box. [fallbackAngle] is
  ///   used only for degenerate (zero-length) input.
  /// - Wings extend backward from the tip and shrink proportionally when the
  ///   final straight segment is too short to clear the preceding corner:
  ///   normal length `(3.0×stroke)∈[6,10]`, normal width `(2.6×stroke)∈[5,9]`,
  ///   scaled down to a 0.45 floor so the head never vanishes or overlaps
  ///   the corner. Logical paths are never modified.
  /// - When [cell] is given, the head is also capped relative to the cell
  ///   (length <= 0.55 cell, width <= 0.5 cell) so it stays inside its own
  ///   lane on dense boards. On regular boards the caps never bind.
  static ArrowHead arrowHead({
    required List<Offset> vertices,
    required double stroke,
    required double cornerRadius,
    required double fallbackAngle,
    double? cell,
  }) {
    Offset tip;
    Offset dir;
    double available = 0;
    if (vertices.length >= 2) {
      final a = vertices[vertices.length - 2];
      final b = vertices.last;
      tip = b;
      final dx = b.dx - a.dx;
      final dy = b.dy - a.dy;
      final len = math.sqrt(dx * dx + dy * dy);
      if (len > 1e-6) {
        dir = Offset(dx / len, dy / len);
        available = len;
      } else {
        dir = Offset(
          math.cos(fallbackAngle),
          math.sin(fallbackAngle),
        );
      }
    } else if (vertices.length == 1) {
      tip = vertices.first;
      dir = Offset(math.cos(fallbackAngle), math.sin(fallbackAngle));
    } else {
      tip = Offset.zero;
      dir = Offset(math.cos(fallbackAngle), math.sin(fallbackAngle));
    }

    var normalLen = (stroke * 3.0).clamp(6.0, 10.0).toDouble();
    var normalWidth = (stroke * 2.6).clamp(5.0, 9.0).toDouble();
    if (cell != null) {
      normalLen = math.min(normalLen, math.max(3.5, cell * 0.55));
      normalWidth = math.min(normalWidth, math.max(3.0, cell * 0.5));
    }
    final reserve = math.min(cornerRadius, available * 0.3);
    final usable = available - reserve - stroke * 0.5;
    double scale = 1.0;
    if (usable < normalLen) {
      scale = usable <= 0 ? 0.45 : (usable / normalLen).clamp(0.45, 1.0).toDouble();
    }
    final length = normalLen * scale;
    final width = normalWidth * scale;
    final perp = Offset(-dir.dy, dir.dx);
    return ArrowHead(
      tip: tip,
      wing1: Offset(
        tip.dx - dir.dx * length + perp.dx * width / 2,
        tip.dy - dir.dy * length + perp.dy * width / 2,
      ),
      wing2: Offset(
        tip.dx - dir.dx * length - perp.dx * width / 2,
        tip.dy - dir.dy * length - perp.dy * width / 2,
      ),
      length: length,
      width: width,
      angle: math.atan2(dir.dy, dir.dx),
    );
  }

  /// Runway length past the head for the slither escape: the arrowhead
  /// leaves the board along its own direction and the full body (of pixel
  /// length [bodyLength]) follows it out, so the tail ends off-board too.
  static double slitherRunway(PuzzlePath path, double cell, double dimension,
      double margin, double bodyLength) {
    final head = toPixel(path.head, cell, Offset.zero);
    final double headExit;
    switch (path.direction) {
      case ArrowDirection.right:
        headExit = math.max(0, dimension - head.dx);
      case ArrowDirection.left:
        headExit = math.max(0, head.dx);
      case ArrowDirection.down:
        headExit = math.max(0, dimension - head.dy);
      case ArrowDirection.up:
        headExit = math.max(0, head.dy);
    }
    return headExit + bodyLength + margin;
  }

  /// Duration for the full escape journey. Scales with total travelled
  /// length so speed feels consistent: short trips ~350ms, long trips up to
  /// ~700ms.
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
