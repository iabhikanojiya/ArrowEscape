import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/arrow.dart';
import '../../models/puzzle_path.dart';
import 'path_geometry.dart';

class PuzzlePalette {
  static const Color ink = Color(0xFF111735);
  static const Color accent = Color(0xFF5B6FF5);
  static const Color blocked = Color(0xFFEF4444);
  static const Color dot = Color(0xFF8A93C4);
}

class PuzzlePainter extends CustomPainter {
  final List<PuzzlePath> paths;
  final int gridSize;
  final String? movingPathId;

  /// 0..1 progress mapped linearly onto the traced path length
  /// (track + exit runway). Linear easing keeps speed constant through
  /// corners.
  final double moveProgress;

  /// Pre-built traced geometry for [movingPathId] including its off-board
  /// runway. Null while no escape is animating.
  final TracedPath? activeTrace;

  final String? blockedPathId;
  final double shakeProgress;
  final String? hintPathId;
  final double hintPhase;
  final bool showDotGrid;
  final Map<String, TracedPath>? shapeCache;

  PuzzlePainter({
    required this.paths,
    required this.gridSize,
    this.movingPathId,
    this.moveProgress = 0,
    this.activeTrace,
    this.blockedPathId,
    this.shakeProgress = 0,
    this.hintPathId,
    this.hintPhase = 0,
    this.showDotGrid = true,
    this.shapeCache,
  });

  double _strokeWidth(double cell) => (cell * 0.20).clamp(7.0, 12.0);

  TracedPath _shapeFor(PuzzlePath path, double cell) {
    final cache = shapeCache;
    if (cache == null) {
      return PathGeometry.buildTracedPath(path, cell);
    }
    final key = '${path.id}|${cell.toStringAsFixed(2)}';
    return cache.putIfAbsent(key, () => PathGeometry.buildTracedPath(path, cell));
  }

  Paint _strokePaint(Color color, double width) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cell = PathGeometry.cellSizeFor(size.width, gridSize);
    final stroke = _strokeWidth(cell);

    if (showDotGrid && cell >= 26) {
      _paintDots(canvas, size, cell);
    }

    if (movingPathId != null && activeTrace != null) {
      _drawTracingArrow(canvas, size, cell, stroke);
    }

    for (final path in paths) {
      if (path.state == PathState.removed) continue;
      if (movingPathId != null && path.id == movingPathId) continue;

      Offset offset = Offset.zero;
      Color color = PuzzlePalette.ink;

      final isBlocked = path.id == blockedPathId;
      if (isBlocked) {
        color = PuzzlePalette.blocked;
        offset = Offset(PathGeometry.blockedShakeDx(shakeProgress), 0);
      }

      final shape = _shapeFor(path, cell);

      if (path.id == hintPathId &&
          path.state == PathState.active &&
          !isBlocked) {
        final pulse = 0.5 + 0.5 * math.sin(hintPhase * 2 * math.pi);
        final glowAlpha = 0.28 + 0.22 * pulse;
        canvas.drawPath(
          shape.polyline,
          _strokePaint(
            PuzzlePalette.accent.withValues(alpha: glowAlpha),
            stroke * 3.0,
          ),
        );
        canvas.drawPath(
          shape.polyline,
          _strokePaint(
            Colors.white.withValues(alpha: 0.55 * pulse),
            stroke * 1.15,
          ),
        );
      }

      canvas.save();
      if (offset != Offset.zero) {
        canvas.translate(offset.dx, offset.dy);
      }
      canvas.drawPath(shape.polyline, _strokePaint(color, stroke));
      _drawHeadAt(
        canvas,
        shape.vertices.last,
        _angleFor(path.direction),
        stroke,
        color,
      );
      canvas.restore();
    }
  }

  /// The escaping arrow: the visible track is the unconsumed remainder of
  /// the path, shrinking toward the exit. No travelling arrowhead is drawn.
  void _drawTracingArrow(
      Canvas canvas, Size size, double cell, double stroke) {
    final trace = activeTrace!;
    final total = trace.length;
    if (total <= 0) return;

    final d = Curves.linear.transform(moveProgress.clamp(0.0, 1.0)) * total;

    final consumedTrail = math.min(cell * 1.4, d);
    if (consumedTrail > 0) {
      canvas.drawPath(
        trace.metric.extractPath(d - consumedTrail, d),
        _strokePaint(PuzzlePalette.accent.withValues(alpha: 0.16), stroke),
      );
    }

    if (d < total) {
      canvas.drawPath(
        trace.metric.extractPath(d, total),
        _strokePaint(PuzzlePalette.accent, stroke),
      );
    }
  }

  double _angleFor(ArrowDirection direction) {
    switch (direction) {
      case ArrowDirection.up:
        return -math.pi / 2;
      case ArrowDirection.down:
        return math.pi / 2;
      case ArrowDirection.left:
        return math.pi;
      case ArrowDirection.right:
        return 0;
    }
  }

  void _drawHeadAt(
      Canvas canvas, Offset position, double angle, double stroke, Color color) {
    final len = stroke * 2.7;
    final halfWidth = stroke * 1.35;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    final head = Path()
      ..moveTo(len * 0.58, 0)
      ..lineTo(-len * 0.42, -halfWidth)
      ..lineTo(-len * 0.42, halfWidth)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    canvas.restore();
  }

  void _paintDots(Canvas canvas, Size size, double cell) {
    final paint = Paint()
      ..color = PuzzlePalette.dot.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;
    final r = math.max(1.0, cell * 0.032);
    for (int i = 0; i <= gridSize; i++) {
      for (int j = 0; j <= gridSize; j++) {
        canvas.drawCircle(Offset(i * cell, j * cell), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PuzzlePainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.gridSize != gridSize ||
        oldDelegate.movingPathId != movingPathId ||
        oldDelegate.moveProgress != moveProgress ||
        oldDelegate.activeTrace != activeTrace ||
        oldDelegate.blockedPathId != blockedPathId ||
        oldDelegate.shakeProgress != shakeProgress ||
        oldDelegate.hintPathId != hintPathId ||
        oldDelegate.hintPhase != hintPhase ||
        oldDelegate.showDotGrid != showDotGrid;
  }
}
