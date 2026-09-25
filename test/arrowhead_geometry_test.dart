import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_escape/game/levels/curated_levels.dart';
import 'package:arrow_escape/game/rendering/path_geometry.dart';

Offset o(double x, double y) => Offset(x, y);

void main() {
  group('arrowHead follows the final segment only', () {
    test('straight arrows in all four directions share one geometry', () {
      const stroke = 3.0;
      final right = PathGeometry.arrowHead(
        vertices: [o(0, 0), o(100, 0)],
        stroke: stroke,
        cornerRadius: 4,
        fallbackAngle: 0,
      );
      final left = PathGeometry.arrowHead(
        vertices: [o(100, 0), o(0, 0)],
        stroke: stroke,
        cornerRadius: 4,
        fallbackAngle: 0,
      );
      final down = PathGeometry.arrowHead(
        vertices: [o(0, 0), o(0, 100)],
        stroke: stroke,
        cornerRadius: 4,
        fallbackAngle: 0,
      );
      final up = PathGeometry.arrowHead(
        vertices: [o(0, 100), o(0, 0)],
        stroke: stroke,
        cornerRadius: 4,
        fallbackAngle: 0,
      );
      // Identical visual weight after rotation.
      for (final h in [right, left, down, up]) {
        expect(h.length, closeTo(9.0, 1e-6));
        expect(h.width, closeTo(7.8, 1e-6));
      }
      expect(right.angle, closeTo(0, 1e-9));
      expect(left.angle.abs(), closeTo(3.141592653589793, 1e-9));
      expect(down.angle, closeTo(3.141592653589793 / 2, 1e-9));
      expect(up.angle, closeTo(-3.141592653589793 / 2, 1e-9));
      // Tip exactly at endpoint; wings trail behind symmetrically.
      expect(right.tip, o(100, 0));
      expect(right.wing1.dx, closeTo(91.0, 1e-6));
      expect(right.wing2.dx, closeTo(91.0, 1e-6));
      expect(right.wing1.dy, closeTo(3.9, 1e-6));
      expect(right.wing2.dy, closeTo(-3.9, 1e-6));
      expect(left.tip, o(0, 0));
      expect(down.tip, o(0, 100));
      expect(up.tip, o(0, 0));
    });

    test('L/U/S bends use the final tangent, not the first segment', () {
      const stroke = 3.0;
      // L ending RIGHT (first segment goes down).
      final lShape = PathGeometry.arrowHead(
        vertices: [o(0, 0), o(0, 40), o(60, 40)],
        stroke: stroke,
        cornerRadius: 4,
        fallbackAngle: 0,
      );
      expect(lShape.angle, closeTo(0, 1e-9));
      expect(lShape.tip, o(60, 40));

      // U ending DOWN.
      final uShape = PathGeometry.arrowHead(
        vertices: [o(0, 40), o(0, 0), o(40, 0), o(40, 40)],
        stroke: stroke,
        cornerRadius: 4,
        fallbackAngle: 0,
      );
      expect(uShape.angle, closeTo(3.141592653589793 / 2, 1e-9));
      expect(uShape.tip, o(40, 40));

      // S ending DOWN (first segment goes right).
      final sShape = PathGeometry.arrowHead(
        vertices: [o(0, 0), o(40, 0), o(40, 20), o(0, 20), o(0, 40)],
        stroke: stroke,
        cornerRadius: 4,
        fallbackAngle: 0,
      );
      expect(sShape.angle, closeTo(3.141592653589793 / 2, 1e-9));
      expect(sShape.tip, o(0, 40));
    });

    test('short final segment shrinks proportionally, never vanishes', () {
      const stroke = 3.0;
      // Final leg only 8px: ──────┐└──> style hook.
      final short = PathGeometry.arrowHead(
        vertices: [o(0, 0), o(50, 0), o(50, 8)],
        stroke: stroke,
        cornerRadius: 4,
        fallbackAngle: 0,
      );
      expect(short.tip, o(50, 8));
      expect(short.angle, closeTo(3.141592653589793 / 2, 1e-9));
      // Shrunk below normal 9px but above the 0.45 floor.
      expect(short.length, lessThan(9.0));
      expect(short.length, greaterThanOrEqualTo(9.0 * 0.45 - 1e-9));
      // Proportional: same aspect as normal head.
      expect(short.length / short.width, closeTo(9.0 / 7.8, 1e-9));
      // Structural guarantee: the wings' backward extent never passes the
      // previous corner point (50,0) — head stays on the final leg.
      expect(8.0 - short.length, greaterThanOrEqualTo(0.0 - 1e-9));
      expect(short.wing1.dy, greaterThanOrEqualTo(0.0 - 1e-9));
      expect(short.wing2.dy, greaterThanOrEqualTo(0.0 - 1e-9));
    });
  });

  group('Level 1 heads (layout untouched)', () {
    test('every Level 1 arrow gets exactly one valid head at its endpoint',
        () {
      final level = buildCuratedLevel1();
      const cell = 17.5; // ~350px board / 20
      const stroke = 2.6; // _strokeWidth clamps 17.5*0.095 up to 2.6
      final radius = PathGeometry.cornerRadiusFor(cell);
      final tangentDirs = <String>{};
      for (final path in level.puzzlePaths) {
        final traced = PathGeometry.buildTracedPath(
          path,
          cell,
          roundedCorners: true,
          cornerRadius: radius,
          endTrim: stroke / 2,
        );
        final head = PathGeometry.arrowHead(
          vertices: traced.vertices,
          stroke: stroke,
          cornerRadius: radius,
          fallbackAngle: 0,
        );
        // Tip is exactly the logical endpoint.
        expect(head.tip, traced.vertices.last);
        // Wings are real, distinct, behind the tip along the final segment.
        expect(head.wing1, isNot(head.wing2));
        expect(head.wing1, isNot(head.tip));
        // Head follows the FINAL SEGMENT tangent (spec), verified here
        // independently from the last two logical points: the wing
        // midpoint must lie exactly opposite the tangent (cosine == -1).
        final a = path.points[path.points.length - 2];
        final b = path.points.last;
        final tdx = (b.x - a.x).toDouble();
        final tdy = (b.y - a.y).toDouble();
        final mdx = (head.wing1.dx + head.wing2.dx) / 2 - head.tip.dx;
        final mdy = (head.wing1.dy + head.wing2.dy) / 2 - head.tip.dy;
        final mLen2 = mdx * mdx + mdy * mdy;
        final tLen2 = tdx * tdx + tdy * tdy;
        expect(mLen2, greaterThan(1e-12));
        expect(tLen2, greaterThan(0));
        final cosine = (mdx * -tdx + mdy * -tdy) /
            (math.sqrt(mLen2) * math.sqrt(tLen2));
        // Midpoint lies exactly opposite the tangent: dot with the
        // negated tangent is +|m||t| (cosine == +1).
        expect(cosine, closeTo(1.0, 1e-6));
        final String tdir;
        if (b.x > a.x) {
          tdir = 'right';
        } else if (b.x < a.x) {
          tdir = 'left';
        } else if (b.y > a.y) {
          tdir = 'down';
        } else {
          tdir = 'up';
        }
        tangentDirs.add(tdir);
        // Backward extent never passes the previous corner.
        final f = (head.tip - traced.vertices[traced.vertices.length - 2])
            .distance;
        expect(head.length, lessThanOrEqualTo(f + 1e-6));
      }
      // All four tangent directions appear across the board.
      expect(tangentDirs, {'right', 'left', 'down', 'up'});
    });
  });

  group('dense boards', () {
    const vertices = [Offset(0, 0), Offset(40, 0)];
    ArrowHead headFor(double cell) => PathGeometry.arrowHead(
          vertices: vertices,
          stroke: 2.6,
          cornerRadius: 2,
          fallbackAngle: 0,
          cell: cell,
        );

    test('head shrinks to fit a small cell (42x42 board)', () {
      final h = headFor(8.6);
      expect(h.length, closeTo(8.6 * 0.55, 1e-9));
      expect(h.width, closeTo(8.6 * 0.5, 1e-9));
      expect(h.width, lessThan(8.6)); // stays inside its own lane
    });

    test('regular cells keep the standard head (Levels 1-20 size)', () {
      final h = headFor(18);
      expect(h.length, closeTo(2.6 * 3.0, 1e-9));
      expect(h.width, closeTo(2.6 * 2.6, 1e-9));
    });
  });
}
