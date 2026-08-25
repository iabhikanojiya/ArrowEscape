import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_escape/game/rendering/path_geometry.dart';
import 'package:arrow_escape/models/arrow.dart';
import 'package:arrow_escape/models/puzzle_path.dart';

PuzzlePath _path(String id, List<List<int>> pts, ArrowDirection dir) {
  return PuzzlePath(
    id: id,
    points: [for (final p in pts) GridPoint(p[0], p[1])],
    direction: dir,
  );
}

const double _cell = 40;
const double _dimension = 360;
const double _margin = 48;

void main() {
  group('Test shape from spec #24 - multi-turn right', () {
    final path = _path('mt', [
      [0, 4],
      [2, 4],
      [2, 1],
      [6, 1],
      [6, 3],
      [8, 3],
    ], ArrowDirection.right);

    final runway = PathGeometry.headExitExtension(
        path, _cell, _dimension, _margin);
    final trace =
        PathGeometry.buildTracedPath(path, _cell, exitExtension: runway);

    test('runway extends the head beyond the board along final tangent', () {
      final headPx =
          PathGeometry.toPixel(path.head, _cell, Offset.zero);
      expect(runway, closeTo(_dimension - headPx.dx + _margin, 1e-6));
      final last = trace.vertices.last;
      final head = trace.vertices[trace.vertices.length - 2];
      expect(last.dx, closeTo(head.dx + runway, 1e-6));
      expect(last.dy, closeTo(head.dy, 1e-6));
      expect(last.dx, greaterThanOrEqualTo(_dimension + _margin - 0.01));
    });

    test('total length equals track plus runway', () {
      var trackPx = 0.0;
      for (int i = 1; i < trace.vertices.length; i++) {
        trackPx += (trace.vertices[i] - trace.vertices[i - 1]).distance;
      }
      expect(trace.length, closeTo(trackPx, 1e-6));
    });

    test('path is consumed behind the moving arrowhead', () {
      for (final p in const [0.15, 0.35, 0.55, 0.8]) {
        final d = p * trace.length;
        final visible = trace.metric.extractPath(d, trace.length);
        final visibleMetrics = visible.computeMetrics().toList();
        final visibleLength = visibleMetrics.fold<double>(
            0, (sum, m) => sum + m.length);
        expect(visibleLength, closeTo(trace.length - d, 1e-2),
            reason: 'consumed length must equal travelled length at p=$p');
      }
    });

    test('nothing remains once the arrowhead has exited', () {
      final visible = trace.metric.extractPath(trace.length, trace.length);
      expect(visible.computeMetrics().isEmpty, isTrue);
    });

    test('arrowhead follows the exact geometry through every corner', () {
      final cumulative = <double>[0];
      for (int i = 1; i < trace.vertices.length; i++) {
        cumulative.add(cumulative.last +
            (trace.vertices[i] - trace.vertices[i - 1]).distance);
      }

      for (int i = 0; i < trace.vertices.length - 1; i++) {
        for (final eps in const [0.5, 4.0]) {
          final probe = math.min(cumulative[i] + eps, trace.length - 0.01);
          final tangent = trace.metric.getTangentForOffset(probe);
          if (tangent == null) continue;

          final expectedDir =
              (trace.vertices[i + 1] - trace.vertices[i]) /
                  (trace.vertices[i + 1] - trace.vertices[i]).distance;
          expect(tangent.vector.dx, closeTo(expectedDir.dx, 1e-6),
              reason: 'tangent x after vertex $i must match segment');
          expect(tangent.vector.dy, closeTo(expectedDir.dy, 1e-6),
              reason: 'tangent y after vertex $i must match segment');
        }
      }
    });

    test('no teleportation between segments (positions continuous)', () {
      final corners = <double>[0];
      for (int i = 1; i < trace.vertices.length - 1; i++) {
        corners.add(corners.last +
            (trace.vertices[i] - trace.vertices[i - 1]).distance);
      }

      for (final c in corners.skip(1)) {
        final before = trace.metric.getTangentForOffset(c - 0.01)!.position;
        final at = trace.metric.getTangentForOffset(math.min(c + 0.01,
            trace.length - 0.01))!.position;
        expect((at - before).distance, lessThan(0.5),
            reason: 'arrowhead jumped across a corner');
        final vertexPos = trace.metric
            .getTangentForOffset(math.min(c, trace.length - 0.01))!
            .position;
        expect((vertexPos - before).distance, lessThan(0.5));
      }
    });

    test('head orientation rotates with the tangent at each turn', () {
      final cumulative = <double>[0];
      for (int i = 1; i < trace.vertices.length; i++) {
        cumulative.add(cumulative.last +
            (trace.vertices[i] - trace.vertices[i - 1]).distance);
      }

      double angleAt(double dist) {
        final t = trace.metric
            .getTangentForOffset(math.min(dist, trace.length - 0.01))!;
        return math.atan2(t.vector.dy, t.vector.dx) * 180 / math.pi;
      }

      double mid(int leg) =>
          (cumulative[leg] + cumulative[leg + 1]) / 2;

      expect(angleAt(mid(0)), closeTo(0, 1e-6),
          reason: 'segment 1 heads RIGHT');
      expect(angleAt(mid(1)), closeTo(-90, 1e-6),
          reason: 'segment 2 heads UP after corner 1');
      expect(angleAt(mid(2)), closeTo(0, 1e-6),
          reason: 'segment 3 heads DOWN after corner 2');
      expect(angleAt(mid(3)), closeTo(90, 1e-6),
          reason: 'segment 4 heads DOWN after corner 3');
      expect(angleAt(mid(4)), closeTo(0, 1e-6),
          reason: 'final segment heads RIGHT');
    });
  });

  group('other directions fully exit the board', () {
    final cases = <String, PuzzlePath>{
      'left': _path('l', [
        [8, 1],
        [5, 1],
        [5, 3],
        [2, 3],
      ], ArrowDirection.left),
      'down': _path('d', [
        [0, 0],
        [3, 0],
        [3, 7],
      ], ArrowDirection.down),
      'up': _path('u', [
        [1, 8],
        [1, 5],
        [5, 5],
        [5, 0],
      ], ArrowDirection.up),
      'straight right': _path('r', [
        [0, 4],
        [3, 4],
      ], ArrowDirection.right),
    };

    cases.forEach((name, path) {
      test('$name arrow ends completely outside the board', () {
        final runway =
            PathGeometry.headExitExtension(path, _cell, _dimension, _margin);
        final trace = PathGeometry.buildTracedPath(path, _cell,
            exitExtension: runway);

        final end = trace.vertices.last;
        switch (path.direction) {
          case ArrowDirection.right:
            expect(end.dx, greaterThanOrEqualTo(_dimension + _margin - 0.01));
          case ArrowDirection.left:
            expect(end.dx, lessThanOrEqualTo(-_margin + 0.01));
          case ArrowDirection.down:
            expect(end.dy, greaterThanOrEqualTo(_dimension + _margin - 0.01));
          case ArrowDirection.up:
            expect(end.dy, lessThanOrEqualTo(-_margin + 0.01));
        }
      });
    });
  });

  group('escape duration scales with path length', () {
    test('longer journeys take longer but stay within bounds', () {
      Duration durationFor(int cells) =>
          PathGeometry.escapeDuration(cells * _cell, _cell);

      final short = durationFor(6);
      final medium = durationFor(12);
      final long = durationFor(24);
      final huge = durationFor(200);

      expect(short < medium, isTrue);
      expect(medium < long, isTrue);
      expect(long.inMilliseconds, lessThanOrEqualTo(700));
      expect(huge.inMilliseconds, lessThanOrEqualTo(700));
      expect(short.inMilliseconds, greaterThanOrEqualTo(340));
      expect(short.inMilliseconds, lessThan(500));
    });
  });
}
