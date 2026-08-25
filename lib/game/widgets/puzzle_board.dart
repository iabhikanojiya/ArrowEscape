import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/puzzle_path.dart';
import '../../services/audio/audio_service.dart';
import '../../services/haptics/haptic_service.dart';
import '../engine/puzzle_engine.dart';
import '../rendering/path_geometry.dart';
import '../rendering/puzzle_painter.dart';

class PuzzleBoard extends StatefulWidget {
  final PuzzleEngine engine;
  final int restartToken;
  final String? hintPathId;
  final void Function(PuzzlePath path)? onTapPath;
  final void Function(PuzzlePath path)? onBlockedTap;
  final ValueChanged<bool>? onMoveCompleted;

  const PuzzleBoard({
    super.key,
    required this.engine,
    this.restartToken = 0,
    this.hintPathId,
    this.onTapPath,
    this.onMoveCompleted,
    this.onBlockedTap,
  });

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard>
    with TickerProviderStateMixin {
  static const double _minScale = 0.75;
  static const double _maxScale = 3.0;

  late final AnimationController _moveController;
  late final AnimationController _shakeController;
  late final AnimationController _hintController;
  final TransformationController _transform = TransformationController();

  Timer? _blockedTimer;
  String? _blockedPathId;
  double _side = 0;

  final Map<String, TracedPath> _shapeCache = {};
  TracedPath? _activeTrace;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..addStatusListener(_onMoveStatus);
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  void _onMoveStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    final id = widget.engine.animatingPathId;
    if (id == null) return;
    final levelCompleted = widget.engine.completeMove(id);
    _shapeCache.removeWhere((key, _) => key.startsWith('$id|'));
    if (mounted) setState(() => _activeTrace = null);
    widget.onMoveCompleted?.call(levelCompleted);
  }

  @override
  void didUpdateWidget(covariant PuzzleBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.restartToken != oldWidget.restartToken) {
      _resetAnimations();
    }
    if (widget.hintPathId != null &&
        widget.hintPathId != oldWidget.hintPathId) {
      _hintController.repeat();
    } else if (widget.hintPathId == null && _hintController.isAnimating) {
      _hintController.stop();
      _hintController.value = 0;
    }
  }

  void _resetAnimations() {
    _moveController.reset();
    _shakeController.reset();
    _hintController.stop();
    _hintController.value = 0;
    _blockedTimer?.cancel();
    _blockedTimer = null;
    _blockedPathId = null;
    _transform.value = Matrix4.identity();
    _shapeCache.clear();
    _activeTrace = null;
  }

  @override
  void dispose() {
    _blockedTimer?.cancel();
    _transform.dispose();
    _moveController.dispose();
    _shakeController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  void _handleTapUp(TapUpDetails details) {
    final engine = widget.engine;
    if (engine.isAnimating || engine.isLevelComplete || !engine.hasPaths) {
      return;
    }
    if (_shakeController.isAnimating || _moveController.isAnimating) return;

    if (_side <= 0) return;
    final path = _hitTest(details.localPosition, _side);
    if (path == null) return;

    widget.onTapPath?.call(path);

    if (engine.canPathMove(path)) {
      HapticService.selectionClick();
      AudioService.instance.play(GameSound.move);
      if (engine.beginMove(path)) {
        final cell = PathGeometry.cellSizeFor(_side, engine.boardSize);
        final stroke = (cell * 0.20).clamp(7.0, 12.0).toDouble();
        final runway = PathGeometry.headExitExtension(
            path, cell, _side, stroke * 4);
        _activeTrace =
            PathGeometry.buildTracedPath(path, cell, exitExtension: runway);
        _moveController.duration =
            PathGeometry.escapeDuration(_activeTrace!.length, cell);
        setState(() {});
        _moveController.forward(from: 0);
      }
    } else {
      HapticService.lightImpact();
      AudioService.instance.play(GameSound.blocked);
      widget.onBlockedTap?.call(path);
      setState(() => _blockedPathId = path.id);
      _shakeController.forward(from: 0).whenCompleteOrCancel(() {
        _blockedTimer?.cancel();
        _blockedTimer = Timer(const Duration(milliseconds: 350), () {
          if (mounted && _blockedPathId == path.id) {
            setState(() => _blockedPathId = null);
          }
        });
      });
    }
  }

  PuzzlePath? _hitTest(Offset local, double side) {
    final engine = widget.engine;
    final cell = PathGeometry.cellSizeFor(side, engine.boardSize);
    var tolerance = (cell * 0.55).clamp(16.0, 26.0).toDouble();

    PuzzlePath? best;
    var bestDistance = tolerance;
    for (final path in engine.activePaths) {
      double d;
      if (path.points.length <= 1) {
        final center =
            PathGeometry.toPixel(path.head, cell, Offset.zero);
        d = (local - center).distance - cell * 0.3;
      } else {
        final vertices = path.points
            .map((pt) => PathGeometry.toPixel(pt, cell, Offset.zero))
            .toList();
        d = PathGeometry.distanceToPolyline(local, vertices);
      }
      if (d < bestDistance) {
        bestDistance = d;
        best = path;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;

    return AnimatedBuilder(
      animation: Listenable.merge(
          [_moveController, _shakeController, _hintController]),
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 320.0;
            final height = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 320.0;
            final side = math.min(width, height);
            _side = side;
            return Center(
              child: SizedBox(
                width: side,
                height: side,
                child: InteractiveViewer(
                  transformationController: _transform,
                  minScale: _minScale,
                  maxScale: _maxScale,
                  panEnabled: true,
                  scaleEnabled: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapUp: _handleTapUp,
                    child: CustomPaint(
                      size: Size(side, side),
                      painter: PuzzlePainter(
                        paths: engine.paths,
                        gridSize: engine.boardSize,
                        movingPathId: engine.animatingPathId,
                        moveProgress: _moveController.value,
                        activeTrace: _activeTrace,
                        blockedPathId: _blockedPathId,
                        shakeProgress: _shakeController.value,
                        hintPathId: widget.hintPathId,
                        hintPhase: _hintController.value,
                        showDotGrid: true,
                        shapeCache: _shapeCache,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
