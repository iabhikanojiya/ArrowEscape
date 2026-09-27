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
  final candidates = tester.renderObjectList<RenderCustomPaint>(
    find.byType(CustomPaint),
  );
  for (final renderObject in candidates) {
    if (renderObject.painter is PuzzlePainter) {
      return renderObject.painter as PuzzlePainter;
    }
  }
  return null;
}

Offset _cellCenter(WidgetTester tester, int x, int y) {
  final box = tester
      .renderObjectList<RenderCustomPaint>(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is PuzzlePainter,
        ),
      )
      .first;
  final size = box.size;
  final cell = size.width / 5;
  return box.localToGlobal(Offset(x * cell + cell / 2, y * cell + cell / 2));
}

Future<void> _openLevel(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(home: GameScreen(levelNumber: 42, level: _level())),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapBlocked(WidgetTester tester) async {
  // Path 2 points down into path 1, so it can't escape.
  await tester.tapAt(_cellCenter(tester, 1, 1));
  await tester.pump(const Duration(milliseconds: 60));
  expect(_painterOf(tester)!.blockedPathId, '2');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first blocked tap ever explains the rule once', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _openLevel(tester);

    await _tapBlocked(tester);
    expect(find.text('Blocked!'), findsOneWidget);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.text('Blocked!'), findsNothing);

    // Further blocked taps (same session) don't show it again.
    await _tapBlocked(tester);
    expect(find.text('Blocked!'), findsNothing);

    // Nor after reopening the game (flag persisted for the install).
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('tip_blocked_arrow_seen'), isTrue);
    await tester.pumpWidget(const SizedBox());
    await _openLevel(tester);
    await _tapBlocked(tester);
    expect(find.text('Blocked!'), findsNothing);
  });

  testWidgets('tip is not shown when it was already seen', (tester) async {
    SharedPreferences.setMockInitialValues({'tip_blocked_arrow_seen': true});
    await _openLevel(tester);
    await _tapBlocked(tester);
    expect(find.text('Blocked!'), findsNothing);
  });
}
