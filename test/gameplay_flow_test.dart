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
        [1, 0],
        [1, 1],
      ], ArrowDirection.down),
    ],
  );
}

PuzzlePainter? _painterOf(WidgetTester tester) {
  final candidates =
      tester.renderObjectList<RenderCustomPaint>(find.byType(CustomPaint));
  for (final renderObject in candidates) {
    if (renderObject.painter is PuzzlePainter) {
      return renderObject.painter as PuzzlePainter;
    }
  }
  return null;
}

Offset _cellCenter(WidgetTester tester, int x, int y) {
  final box = tester.renderObjectList<RenderCustomPaint>(
    find.byWidgetPredicate((w) => w is CustomPaint && w.painter is PuzzlePainter),
  ).first;
  final size = box.size;
  final cell = size.width / 5;
  return box.localToGlobal(Offset(x * cell + cell / 2, y * cell + cell / 2));
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('free path exits fully, blocked path flashes and stays',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: GameScreen(levelNumber: 42, level: _level())));
    await tester.pumpAndSettle();

    var painter = _painterOf(tester);
    expect(painter, isNotNull);

    final initialStates = {for (final p in painter!.paths) p.id: p.state};
    expect(initialStates['1'], PathState.active);
    expect(initialStates['2'], PathState.active);

    // Tap path 2 (blocked by path 1 crossing its downward corridor).
    await tester.tapAt(_cellCenter(tester, 1, 1));
    await tester.pump(const Duration(milliseconds: 60));
    painter = _painterOf(tester);
    expect(painter!.blockedPathId, '2',
        reason: 'blocked path should be highlighted red');
    await tester.pumpAndSettle();
    painter = _painterOf(tester);
    expect(painter!.paths.firstWhere((p) => p.id == '2').state,
        PathState.active,
        reason: 'blocked path must not move');
    expect(find.textContaining('0 MOVES'), findsOneWidget);

    // Tap path 1 (free to the right).
    await tester.tapAt(_cellCenter(tester, 1, 2));
    await tester.pump(const Duration(milliseconds: 100));
    painter = _painterOf(tester);
    expect(painter!.movingPathId, '1',
        reason: 'free path should start moving');

    await tester.pumpAndSettle();
    painter = _painterOf(tester);
    expect(painter!.paths.firstWhere((p) => p.id == '1').state,
        PathState.removed,
        reason: 'path should have exited completely');
    expect(find.textContaining('1 MOVES'), findsOneWidget);

    // With path 1 gone, path 2 is now free.
    await tester.tapAt(_cellCenter(tester, 1, 1));
    await tester.pump(const Duration(milliseconds: 80));
    painter = _painterOf(tester);
    expect(painter!.movingPathId, '2');

    await tester.pumpAndSettle();
    painter = _painterOf(tester);
    expect(
      painter!.paths.every((p) => p.state == PathState.removed),
      isTrue,
      reason: 'level should be complete',
    );
  });
}
