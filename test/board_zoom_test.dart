import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/game/rendering/puzzle_painter.dart';
import 'package:arrow_escape/models/arrow.dart';
import 'package:arrow_escape/models/level.dart';
import 'package:arrow_escape/models/puzzle_path.dart';
import 'package:arrow_escape/screens/game/game_screen.dart';

PuzzlePath _path(String id, List<List<int>> pts, ArrowDirection dir) {
  return PuzzlePath(
    id: id,
    points: [for (final p in pts) GridPoint(p[0], p[1])],
    direction: dir,
  );
}

Level _level() {
  return Level(
    levelId: 42,
    gridSize: 5,
    puzzlePaths: [
      _path('1', [
        [0, 2],
        [2, 2],
      ], ArrowDirection.right),
      _path('2', [
        [4, 4],
        [4, 3],
      ], ArrowDirection.up),
    ],
  );
}

double _currentScale(WidgetTester tester) {
  return tester
      .widget<InteractiveViewer>(find.byType(InteractiveViewer))
      .transformationController!
      .value
      .getMaxScaleOnAxis();
}

RenderCustomPaint _boardRenderObject(WidgetTester tester) {
  return tester.renderObjectList<RenderCustomPaint>(
    find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is PuzzlePainter),
  ).first;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('pinch zoom works and keeps taps accurate',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester
        .pumpWidget(MaterialApp(home: GameScreen(levelNumber: 42, level: _level())));
    await tester.pumpAndSettle();

    expect(_currentScale(tester), 1.0);

    final box = _boardRenderObject(tester);
    final topLeft = box.localToGlobal(Offset.zero);
    final side = box.size.width;
    final center = topLeft + Offset(side / 2, side / 2);

    // Pinch outwards around the board centre.
    final g1 = await tester.startGesture(center - const Offset(30, 0));
    final g2 = await tester.startGesture(center + const Offset(30, 0));
    await tester.pump();
    await g1.moveBy(const Offset(-70, 0),
        timeStamp: const Duration(milliseconds: 120));
    await g2.moveBy(const Offset(70, 0),
        timeStamp: const Duration(milliseconds: 120));
    await tester.pump();
    await g1.up();
    await g2.up();
    await tester.pump();

    await tester.pumpAndSettle();

    final viewer =
        tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
    final matrix = viewer.transformationController!.value;
    final scale = matrix.getMaxScaleOnAxis();
    expect(scale, greaterThan(1.5), reason: 'pinch should zoom in');
    final t = matrix.getTranslation();

    // Map board-local point (centre of cell (1,2) on path 1) through the
    // zoom transform and tap there.
    final cell = side / 5;
    final lx = 1 * cell + cell / 2;
    final ly = 2 * cell + cell / 2;
    final screenPoint =
        topLeft + Offset(lx * scale + t.x, ly * scale + t.y);

    await tester.tapAt(screenPoint);
    await tester.pump(const Duration(milliseconds: 90));

    final painter = _boardRenderObject(tester).painter as PuzzlePainter;
    expect(painter.movingPathId, '1',
        reason: 'taps must stay accurate while the canvas is zoomed');
  });

  testWidgets('restart resets zoom back to fit', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester
        .pumpWidget(MaterialApp(home: GameScreen(levelNumber: 42, level: _level())));
    await tester.pumpAndSettle();

    final box = _boardRenderObject(tester);
    final center = box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));

    final g1 = await tester.startGesture(center - const Offset(30, 0));
    final g2 = await tester.startGesture(center + const Offset(30, 0));
    await tester.pump();
    await g1.moveBy(const Offset(-70, 0),
        timeStamp: const Duration(milliseconds: 120));
    await g2.moveBy(const Offset(70, 0),
        timeStamp: const Duration(milliseconds: 120));
    await tester.pump();
    await g1.up();
    await g2.up();
    await tester.pumpAndSettle();

    final before = tester
        .widget<InteractiveViewer>(find.byType(InteractiveViewer))
        .transformationController!
        .value
        .getMaxScaleOnAxis();
    expect(before, greaterThan(1.5));

    await tester.tap(find.byTooltip('Restart'));
    await tester.pumpAndSettle();

    final after = tester
        .widget<InteractiveViewer>(find.byType(InteractiveViewer))
        .transformationController!
        .value
        .getMaxScaleOnAxis();
    expect(after, 1.0, reason: 'restart should restore fit-to-screen zoom');
  });
}
