import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/core/constants/app_constants.dart';
import 'package:arrow_escape/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('reset progress sends the player back to level 1',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.storageKeyUnlockedLevel: 3,
      AppConstants.storageKeyCompletedLevels: '[1,2]',
      AppConstants.storageKeyCoins: 120,
      AppConstants.storageKeyHearts: 5,
    });

    await tester.pumpWidget(const ArrowEscapeApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Level 3'), findsOneWidget);
    expect(find.text('2 / ${AppConstants.maxLevels}'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Reset progress'), 200,
        scrollable: find.byType(Scrollable).last);
    expect(find.text('Reset coins'), findsNothing);
    expect(find.text('Reset progress'), findsOneWidget);

    await tester.tap(find.text('Reset progress'));
    await tester.pumpAndSettle();

    expect(find.text('Reset progress?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
    await tester.pumpAndSettle();

    expect(find.textContaining('back to level 1'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(AppConstants.storageKeyUnlockedLevel) ?? 1, 1);
    expect(prefs.getString(AppConstants.storageKeyCompletedLevels), isNull);
    expect(prefs.getInt(AppConstants.storageKeyCoins),
        AppConstants.initialCoins);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('0 / ${AppConstants.maxLevels}'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
