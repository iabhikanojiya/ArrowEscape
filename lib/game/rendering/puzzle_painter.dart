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

  /// 0..1 progress of the escape. Linear so speed stays constant through
  /// corners.
  final double moveProgress;

  /// Traced geometry for [movingPathId]: its own track plus the exit runway
  /// along the arrowhead direction. Null while no escape is animating.
  final TracedPath? activeTrace;

  /// Pixel length of the moving arrow's body; the slithering window keeps
  /// exactly this length the whole way out.
  final double moveBodyLength;

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
    this.moveBodyLength = 0,
    this.blockedPathId,
    this.shakeProgress = 0,
    this.hintPathId,
    this.hintPhase = 0,
    this.showDotGrid = true,
    this.shapeCache,
  });

  // Thinner shafts for dense labyrinth levels (small gaps, clean 90° turns)
  double _strokeWidth(double cell) => (cell * 0.095).clamp(2.6, 5.0);

  TracedPath _shapeFor(PuzzlePath path, double cell) {
    // Display traces use subtly rounded bends and a shaft trimmed back by
    // half a stroke so the round cap never pokes past the arrowhead tip.
    // Logical vertices stay sharp for head placement and hit-testing.
    // Radius/trim derive from cell size, so the existing cache key remains
    // unique.
    final stroke = _strokeWidth(cell);
    final cache = shapeCache;
    if (cache == null) {
      return PathGeometry.buildTracedPath(
        path,
        cell,
        roundedCorners: true,
        cornerRadius: PathGeometry.cornerRadiusFor(cell),
        endTrim: stroke / 2,
      );
    }
    final key = '${path.id}|${cell.toStringAsFixed(2)}';
    return cache.putIfAbsent(
      key,
      () => PathGeometry.buildTracedPath(
        path,
        cell,
        roundedCorners: true,
        cornerRadius: PathGeometry.cornerRadiusFor(cell),
        endTrim: stroke / 2,
      ),
    );
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
      _drawSlitheringArrow(canvas, cell, stroke);
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
      // One pen for the whole piece: shaft and open-arrowhead wings share
      // the exact same stroke so the head reads as the natural end of the
      // line rather than an icon placed on top of it.
      final pen = _strokePaint(color, stroke);
      canvas.drawPath(shape.polyline, pen);
      // Single head at the final endpoint, aligned purely with the final
      // segment tangent (never the first/longest segment or bounding box).
      final head = PathGeometry.arrowHead(
        vertices: shape.vertices,
        stroke: stroke,
        cornerRadius: PathGeometry.cornerRadiusFor(cell),
        fallbackAngle: _angleFor(path.direction),
        cell: cell,
      );
      final wings = Path()
        ..moveTo(head.tip.dx, head.tip.dy)
        ..lineTo(head.wing1.dx, head.wing1.dy)
        ..moveTo(head.tip.dx, head.tip.dy)
        ..lineTo(head.wing2.dx, head.wing2.dy);
      canvas.drawPath(wings, pen);
      canvas.restore();
    }
  }

  /// The escaping arrow slithers: a window of the body's full length slides
  /// along its own track (through every bend) and then out along the exit
  /// runway, which points in the arrowhead direction. The arrowhead leads,
  /// turning with the track at each corner.
  void _drawSlitheringArrow(Canvas canvas, double cell, double stroke) {
    final trace = activeTrace!;
    final total = trace.length;
    if (total <= 0) return;
    final body = moveBodyLength.clamp(0.0, total);
    final travel = total - body;
    final start =
        Curves.linear.transform(moveProgress.clamp(0.0, 1.0)) * travel;
    final end = start + body;

    final tangent = trace.metric.getTangentForOffset(math.min(end, total));
    if (tangent == null) return;
    final pen = _strokePaint(PuzzlePalette.accent, stroke);
    // Trim the shaft half a stroke so its round cap never pokes past the tip.
    final shaftEnd = math.max(start, end - stroke / 2);
    if (shaftEnd > start) {
      canvas.drawPath(trace.metric.extractPath(start, shaftEnd), pen);
    }
    final tip = tangent.position;
    final head = PathGeometry.arrowHead(
      vertices: [tip - tangent.vector * cell, tip],
      stroke: stroke,
      cornerRadius: PathGeometry.cornerRadiusFor(cell),
      fallbackAngle: math.atan2(tangent.vector.dy, tangent.vector.dx),
      cell: cell,
    );
    canvas.drawPath(
      Path()
        ..moveTo(head.tip.dx, head.tip.dy)
        ..lineTo(head.wing1.dx, head.wing1.dy)
        ..moveTo(head.tip.dx, head.tip.dy)
        ..lineTo(head.wing2.dx, head.wing2.dy),
      pen,
    );
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
        oldDelegate.moveBodyLength != moveBodyLength ||
        oldDelegate.blockedPathId != blockedPathId ||
        oldDelegate.shakeProgress != shakeProgress ||
        oldDelegate.hintPathId != hintPathId ||
        oldDelegate.hintPhase != hintPhase ||
        oldDelegate.showDotGrid != showDotGrid;
  }
}
