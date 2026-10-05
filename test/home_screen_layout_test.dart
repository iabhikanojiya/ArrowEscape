import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/screens/home/home_screen.dart';
import 'package:arrow_escape/services/admob_service.dart';
import 'package:arrow_escape/services/economy/economy_service.dart';
import 'package:arrow_escape/widgets/economy_chips.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    EconomyProvider.setInstance(createEconomyService(useInMemory: true));
    await EconomyProvider.instance.init();
    AdmobService.instance.debugReset();
  });

  tearDown(() => AdmobService.instance.debugReset());

  Future<void> pumpHome(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: const HomeScreen(),
      routes: {'/settings': (_) => const Scaffold(body: Text('settings'))},
    ));
    await tester.pumpAndSettle();
  }

  for (final size in const [Size(320, 568), Size(411, 891), Size(800, 1280)]) {
    testWidgets('top row and actions lay out at ${size.width}x${size.height}',
        (tester) async {
      await pumpHome(tester, size);

      expect(tester.takeException(), isNull);
      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.byIcon(Icons.leaderboard_rounded), findsOneWidget);
      expect(find.text('Levels'), findsOneWidget);

      final settings = tester.getCenter(find.byTooltip('Settings'));
      final coins = tester.getCenter(find.byType(CoinChip));
      expect(settings.dx, lessThan(size.width / 2));
      expect(coins.dx, greaterThan(size.width / 2));
      expect((settings.dy - coins.dy).abs(), lessThan(1));
    });
  }

  testWidgets('top-left Settings button opens settings', (tester) async {
    await pumpHome(tester, const Size(411, 891));
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('settings'), findsOneWidget);
  });
}
