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
  // Tapped arrows slither: the arrowhead leads, the body keeps its full
  // length and flows through its own bends, then everything leaves the board
  // along the arrowhead (final segment) direction.
  group('slither escape follows the arrowhead direction', () {
    final cases = <ArrowDirection, PuzzlePath>{
      ArrowDirection.up: _path('u', [
        [1, 8],
        [1, 5],
        [5, 5],
        [5, 2],
      ], ArrowDirection.up),
      ArrowDirection.down: _path('d', [
        [0, 0],
        [3, 0],
        [3, 7],
      ], ArrowDirection.down),
      ArrowDirection.left: _path('l', [
        [8, 1],
        [5, 1],
        [5, 3],
        [2, 3],
      ], ArrowDirection.left),
      ArrowDirection.right: _path('r', [
        [0, 4],
        [2, 4],
        [2, 1],
        [6, 1],
        [6, 3],
        [7, 3],
      ], ArrowDirection.right),
    };

    cases.forEach((dir, path) {
      final body = PathGeometry.buildTracedPath(path, _cell).length;
      final runway = PathGeometry.slitherRunway(
        path,
        _cell,
        _dimension,
        _margin,
        body,
      );
      final trace = PathGeometry.buildTracedPath(
        path,
        _cell,
        exitExtension: runway,
      );
      final travel = trace.length - body;
      Offset headAt(double p) =>
          trace.metric.getTangentForOffset(p * travel + body)!.position;
      Offset headDirAt(double p) => trace.metric
          .getTangentForOffset(
            math.min(p * travel + body, trace.length - 0.01),
          )!
          .vector;

      test('${dir.name}: exit runway points ${dir.name}', () {
        expect(path.direction, dir);
        final v = trace.vertices;
        final run = (v.last - v[v.length - 2]) / runway;
        expect(run.dx, closeTo(dir.vector.dx, 1e-9));
        expect(run.dy, closeTo(dir.vector.dy, 1e-9));
      });

      test('${dir.name}: starts exactly where the arrow is drawn', () {
        final headPx = PathGeometry.toPixel(path.head, _cell, Offset.zero);
        expect((headAt(0) - headPx).distance, lessThan(1e-6));
      });

      test('${dir.name}: body keeps its full length while slithering', () {
        for (final p in const [0.0, 0.2, 0.5, 0.8, 1.0]) {
          final start = p * travel;
          final window = trace.metric.extractPath(start, start + body);
          final len = window.computeMetrics().fold<double>(
            0,
            (sum, m) => sum + m.length,
          );
          expect(len, closeTo(body, 1e-2), reason: 'p=$p');
        }
      });

      test('${dir.name}: arrowhead follows every bend of its own path', () {
        final segs = <Offset>[];
        for (int i = 1; i < path.points.length; i++) {
          final a = PathGeometry.toPixel(
            path.points[i - 1],
            _cell,
            Offset.zero,
          );
          final b = PathGeometry.toPixel(path.points[i], _cell, Offset.zero);
          segs.add((b - a) / (b - a).distance);
        }
        // Sample the tail's track: the head later passes over it too.
        var along = 0.0;
        for (int i = 0; i < segs.length; i++) {
          final a = PathGeometry.toPixel(path.points[i], _cell, Offset.zero);
          final b = PathGeometry.toPixel(
            path.points[i + 1],
            _cell,
            Offset.zero,
          );
          final mid = along + (b - a).distance / 2;
          final t = trace.metric.getTangentForOffset(mid)!.vector;
          expect(t.dx, closeTo(segs[i].dx, 1e-6));
          expect(t.dy, closeTo(segs[i].dy, 1e-6));
          along += (b - a).distance;
        }
        // Once past its original head, the arrowhead travels in `dir`.
        final t = headDirAt(0.5);
        expect(t.dx, closeTo(dir.vector.dx, 1e-6));
        expect(t.dy, closeTo(dir.vector.dy, 1e-6));
      });

      test('${dir.name}: whole arrow ends completely outside the board', () {
        final window = trace.metric
            .extractPath(travel, trace.length)
            .computeMetrics()
            .first;
        for (double d = 0; d <= window.length; d += 2) {
          final pt = window.getTangentForOffset(d)!.position;
          final outside =
              pt.dx <= 0 ||
              pt.dy <= 0 ||
              pt.dx >= _dimension ||
              pt.dy >= _dimension;
          expect(outside, isTrue, reason: 'body point $pt still on board');
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
