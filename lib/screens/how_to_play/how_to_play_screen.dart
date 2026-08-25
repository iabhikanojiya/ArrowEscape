import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../game/rendering/path_geometry.dart';
import '../../game/rendering/puzzle_painter.dart' show PuzzlePalette;
import '../../models/arrow.dart';
import '../../models/puzzle_path.dart';
import '../../services/audio/audio_service.dart';
import '../../services/haptics/haptic_service.dart';
import '../../widgets/circle_button.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 8),
              child: Row(
                children: [
                  CircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    iconSize: 18,
                    tooltip: 'Back',
                    onTap: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'How to Play',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.3, end: 0, curve: Curves.easeOut),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  const Text(
                    'Every arrow is a track. Set them free.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.subtleText,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 22),
                  _Step(
                    index: 0,
                    title: 'Spot the paths',
                    description:
                        'Each line with an arrowhead is one arrow. Bent lines are a single arrow too - corners included.',
                    variant: 0,
                  ),
                  _Step(
                    index: 1,
                    title: 'Tap to escape',
                    description:
                        'With a clear runway the track lights up blue and is pulled away toward the exit, corner by corner.',
                    variant: 1,
                  ),
                  _Step(
                    index: 2,
                    title: 'Blocked? No luck yet',
                    description:
                        'If another arrow blocks the exit the whole path flashes red and shakes. Clear the blocker first.',
                    variant: 2,
                  ),
                  _Step(
                    index: 3,
                    title: 'Clear the board',
                    description:
                        'Free every arrow to complete the level, earn coins and unlock the next challenge.',
                    variant: 3,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.chipFill,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_rounded,
                            size: 20, color: AppTheme.coinGold),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Stuck? Use a Hint to highlight a safe move, or Undo to take a step back.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.ink.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(delay: 420.ms)
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 22),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () {
                    HapticService.lightImpact();
                    AudioService.instance.play(GameSound.button);
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Text(
                    'Start playing',
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
                  ),
                ),
              )
                  .animate(delay: 480.ms)
                  .fadeIn(duration: 320.ms)
                  .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final int variant;

  const _Step({
    required this.index,
    required this.title,
    required this.description,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppTheme.chipFill,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: CustomPaint(painter: _DemoPainter(variant)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP ${index + 1}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.subtleText,
                  ),
                ),
              ],
            ),
          ),
        ],
      )
          .animate(delay: (90 * index + 60).ms)
          .fadeIn(duration: 340.ms)
          .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
    );
  }
}

class _DemoPainter extends CustomPainter {
  final int variant;

  _DemoPainter(this.variant);

  @override
  void paint(Canvas canvas, Size size) {
    const grid = 5;
    final cell = size.width / grid;
    final stroke = (cell * 0.22).clamp(4.0, 7.0);

    _drawDots(canvas, size, cell, grid);

    switch (variant) {
      case 0:
        _drawStatic(canvas, cell, stroke,
            const [GridPoint(0, 1), GridPoint(2, 1), GridPoint(2, 3), GridPoint(4, 3)],
            ArrowDirection.right, PuzzlePalette.ink);
        _drawStatic(canvas, cell, stroke,
            const [GridPoint(4, 4), GridPoint(4, 0)],
            ArrowDirection.up, PuzzlePalette.ink);
        break;
      case 1:
        _drawTracingSnapshot(canvas, cell, stroke);
        break;
      case 2:
        canvas.save();
        canvas.translate(2, 0);
        _drawStatic(canvas, cell, stroke,
            const [GridPoint(0, 2), GridPoint(2, 2), GridPoint(2, 4)],
            ArrowDirection.right, PuzzlePalette.blocked);
        canvas.restore();
        break;
      case 3:
        _drawStatic(canvas, cell, stroke,
            const [GridPoint(1, 2), GridPoint(3, 2)],
            ArrowDirection.right, PuzzlePalette.ink.withValues(alpha: 0.85));
        final center = Offset(cell * 4, cell * 1);
        final r = cell * 0.42;
        canvas.drawCircle(center, r, Paint()..color = AppTheme.accent);
        final checkPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke * 0.55
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        final checkPath = Path()
          ..moveTo(center.dx - r * 0.45, center.dy + r * 0.05)
          ..lineTo(center.dx - r * 0.08, center.dy + r * 0.4)
          ..lineTo(center.dx + r * 0.48, center.dy - r * 0.32);
        canvas.drawPath(checkPath, checkPaint);
        break;
    }
  }

  void _drawDots(Canvas canvas, Size size, double cell, int grid) {
    final paint = Paint()
      ..color = PuzzlePalette.dot.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;
    final r = math.max(0.8, cell * 0.032);
    for (int i = 0; i <= grid; i++) {
      for (int j = 0; j <= grid; j++) {
        canvas.drawCircle(Offset(i * cell, j * cell), r, paint);
      }
    }
  }

  void _drawStatic(Canvas canvas, double cell, double stroke,
      List<GridPoint> points, ArrowDirection direction, Color color) {
    final traced = PathGeometry.buildTracedPath(
      PuzzlePath(id: 'demo', points: points, direction: direction),
      cell,
    );
    canvas.drawPath(traced.polyline, _stroke(color, stroke));
    _drawHead(canvas, traced.vertices[points.length - 1],
        _angle(direction), stroke, color);
  }

  void _drawTracingSnapshot(Canvas canvas, double cell, double stroke) {
    final path = PuzzlePath(
      id: 'demo',
      points: const [
        GridPoint(0, 1),
        GridPoint(2, 1),
        GridPoint(2, 3),
        GridPoint(4, 3),
      ],
      direction: ArrowDirection.right,
    );
    final trace = PathGeometry.buildTracedPath(path, cell);
    final d = trace.length * 0.58;

    final trail = math.min(cell * 1.3, d);
    if (trail > 0) {
      canvas.drawPath(
        trace.metric.extractPath(d - trail, d),
        _stroke(PuzzlePalette.accent.withValues(alpha: 0.18), stroke),
      );
    }
    canvas.drawPath(
      trace.metric.extractPath(d, trace.length),
      _stroke(PuzzlePalette.accent, stroke),
    );
  }

  Paint _stroke(Color color, double width) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  double _angle(ArrowDirection direction) {
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

  void _drawHead(Canvas canvas, Offset position, double angle,
      double stroke, Color color) {
    final len = stroke * 2.7;
    final half = stroke * 1.35;
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    final head = Path()
      ..moveTo(len * 0.58, 0)
      ..lineTo(-len * 0.42, -half)
      ..lineTo(-len * 0.42, half)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DemoPainter oldDelegate) =>
      oldDelegate.variant != variant;
}
