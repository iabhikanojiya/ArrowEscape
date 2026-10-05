import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/main.dart';
import 'package:arrow_escape/screens/game/game_screen.dart';
import 'package:arrow_escape/models/level.dart';
import 'package:arrow_escape/models/arrow.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ArrowEscapeApp());

    expect(find.text('Arrow Escape'), findsOneWidget);
    expect(find.text('A relaxing arrow logic puzzle'), findsOneWidget);
  });

  testWidgets('Splash screen navigates to home after delay', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ArrowEscapeApp());

    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Arrow Escape'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Levels'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
  });

  testWidgets('Game screen minimal controls fit on small screen without overflow',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: GameScreen(levelNumber: 1),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.undo_rounded), findsOneWidget);
    expect(find.byIcon(Icons.lightbulb_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsWidgets);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Game board handles restart, undo and back without errors',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final level = Level(
      levelId: 99,
      gridSize: 5,
      name: 'Test',
      arrows: [
        LevelArrow(id: 1, row: 0, column: 2, direction: ArrowDirection.down),
        LevelArrow(id: 2, row: 4, column: 2, direction: ArrowDirection.up),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(levelNumber: 99, level: level),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Restart'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
