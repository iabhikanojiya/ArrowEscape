import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/screens/how_to_play/how_to_play_screen.dart';
import 'package:arrow_escape/screens/settings/settings_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('settings opens the how-to-play page', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(MaterialApp(
      routes: {
        '/how_to_play': (context) => const HowToPlayScreen(),
      },
      home: const SettingsScreen(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('How to play'), findsOneWidget);

    await tester.tap(find.text('How to play'));
    await tester.pumpAndSettle();

    expect(find.byType(HowToPlayScreen), findsOneWidget);
    expect(find.text('Spot the arrows'), findsOneWidget);
    expect(find.text('The arrowhead shows the way'), findsOneWidget);
    expect(find.text('Tap a free arrow'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Clear the board'), 200);
    expect(find.text('Blocked costs a heart'), findsOneWidget);
    expect(find.text('Clear the board'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('start playing returns from how-to-play', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(MaterialApp(
      routes: {
        '/how_to_play': (context) => const HowToPlayScreen(),
      },
      home: const SettingsScreen(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('How to play'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start playing'));
    await tester.pumpAndSettle();

    expect(find.byType(HowToPlayScreen), findsNothing);
    expect(find.text('Sound'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('how-to-play fits on a small screen without overflow',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320 * 3, 560 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HowToPlayScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Every arrow is a track. Set them free.'), findsOneWidget);
    expect(find.text('Start playing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
