import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/models/arrow.dart';
import 'package:arrow_escape/models/level.dart';
import 'package:arrow_escape/models/puzzle_path.dart';
import 'package:arrow_escape/models/reward_purpose.dart';
import 'package:arrow_escape/screens/game/game_screen.dart';
import 'package:arrow_escape/screens/home/home_screen.dart';
import 'package:arrow_escape/screens/level_select/level_select_screen.dart';
import 'package:arrow_escape/screens/settings/settings_screen.dart';
import 'package:arrow_escape/services/admob_service.dart';
import 'package:arrow_escape/services/economy/economy_service.dart';
import 'package:arrow_escape/widgets/banner_ad_widget.dart';
import 'package:arrow_escape/game/widgets/puzzle_board.dart';
import 'package:arrow_escape/widgets/lives_display.dart';

PuzzlePath _p(String id, List<List<int>> pts, ArrowDirection dir) {
  return PuzzlePath(
    id: id,
    points: [for (final p in pts) GridPoint(p[0], p[1])],
    direction: dir,
  );
}

Level _blockedLevel() {
  return Level(
    levelId: 99,
    gridSize: 5,
    puzzlePaths: [
      _p('1', [
        [0, 2],
        [2, 2],
      ], ArrowDirection.right),
      _p('2', [
        [1, 0],
        [1, 1],
      ], ArrowDirection.down),
    ],
  );
}

Level _twoFreeLevel() {
  return Level(
    levelId: 42,
    gridSize: 5,
    puzzlePaths: [
      _p('1', [
        [0, 2],
        [2, 2],
      ], ArrowDirection.right),
      _p('2', [
        [4, 4],
        [4, 3],
      ], ArrowDirection.up),
    ],
  );
}

int _livesOf(WidgetTester tester) {
  final widget = tester.widget<LivesDisplay>(find.byType(LivesDisplay));
  return widget.lives;
}

Future<void> _pumpGameWithLevel(
    WidgetTester tester, Level level, int levelNumber) async {
  await tester.pumpWidget(MaterialApp(
    home: GameScreen(levelNumber: levelNumber, level: level),
  ));
  await tester.pumpAndSettle();
}

// First-time "blocked" tip already seen (covered in blocked_tip_test), so
// these lives/economy flows aren't interrupted by it.
const Map<String, Object> _prefs = {'tip_blocked_arrow_seen': true};

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(_prefs);
    EconomyProvider.setInstance(createEconomyService(useInMemory: true));
    await EconomyProvider.instance.init();
    AdmobService.debugShowRewardedHandler = null;
    AdmobService.instance.debugReset();
  });

  tearDown(() {
    AdmobService.debugShowRewardedHandler = null;
    AdmobService.instance.debugReset();
  });

  group('Lives', () {
    testWidgets('new level starts at 3 lives', (tester) async {
      SharedPreferences.setMockInitialValues(_prefs);
      await _pumpGameWithLevel(tester, _blockedLevel(), 1);
      expect(_livesOf(tester), 3);
    });

    testWidgets('blocked arrow removes exactly 1 life', (tester) async {
      await _pumpGameWithLevel(tester, _blockedLevel(), 1);
      expect(_livesOf(tester), 3);

      final boardFinder = find.byType(GameScreen);
      expect(boardFinder, findsOneWidget);

      // Tap blocked path 2 at cell (1,1) center. Need to find board coordinates.
      // Use the puzzle board's tap: we can tap via engine logic by directly
      // finding the CustomPaint and tapping at estimated position is fragile.
      // Instead we tap the path via the GameScreen's puzzle board hit test
      // by tapping at the center of the board offset for cell (1,1).
      // For simplicity we tap at (1,1) board position computed via CustomPaint.
      // We'll use tester.tapAt with board's center offset.
      // Alternative: directly call onBlockedTap via widget? Easiest: fire a tap
      // at the board's rendered position for cell (1,1).
      // Let's compute board position via RenderBox.
      final renderBoxes = tester.renderObjectList<RenderBox>(find.byWidgetPredicate(
          (w) => w is CustomPaint && w.size.width > 50));
      // Find the largest CustomPaint which is the board.
      RenderBox? boardBox;
      double maxArea = 0;
      for (final box in renderBoxes) {
        final area = box.size.width * box.size.height;
        if (area > maxArea) {
          maxArea = area;
          boardBox = box;
        }
      }
      expect(boardBox, isNotNull);
      final side = boardBox!.size.width;
      final cell = side / 5;
      // Cell (1,1) center in board local coords
      final local = Offset(1 * cell + cell / 2, 1 * cell + cell / 2);
      final global = boardBox.localToGlobal(local);

      await tester.tapAt(global);
      await tester.pump(const Duration(milliseconds: 100));
      expect(_livesOf(tester), 2);

      // Tap again quickly while shake still running should not deduct again.
      await tester.tapAt(global);
      await tester.pump(const Duration(milliseconds: 100));
      expect(_livesOf(tester), 2);

      await tester.pumpAndSettle(const Duration(milliseconds: 800));
      expect(_livesOf(tester), 2);
    });

    testWidgets('3 blocked taps show out-of-lives popup', (tester) async {
      await _pumpGameWithLevel(tester, _blockedLevel(), 1);

      final boardBox = tester.renderObjectList<RenderBox>(find.byWidgetPredicate(
              (w) => w is CustomPaint && w.size.width > 50))
          .reduce((a, b) => a.size.width > b.size.width ? a : b);
      final side = boardBox.size.width;
      final cell = side / 5;
      final blockedCenter =
          boardBox.localToGlobal(Offset(1 * cell + cell / 2, 1 * cell + cell / 2));

      for (int i = 0; i < 3; i++) {
        await tester.tapAt(blockedCenter);
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pumpAndSettle(const Duration(milliseconds: 800));
      }

      expect(_livesOf(tester), 0);
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('Out of Lives'), findsOneWidget);
      expect(find.text('Watch Ad  +1 Life'), findsOneWidget);
      expect(find.text('Restart Level'), findsOneWidget);
    });

    testWidgets('watch ad for life gives +1', (tester) async {
      AdmobService.debugShowRewardedHandler = (purpose) async {
        expect(purpose, RewardPurpose.extraLife);
        return true;
      };
      await _pumpGameWithLevel(tester, _blockedLevel(), 1);

      final boardBox = tester.renderObjectList<RenderBox>(find.byWidgetPredicate(
              (w) => w is CustomPaint && w.size.width > 50))
          .reduce((a, b) => a.size.width > b.size.width ? a : b);
      final side = boardBox.size.width;
      final cell = side / 5;
      final blockedCenter =
          boardBox.localToGlobal(Offset(1 * cell + cell / 2, 1 * cell + cell / 2));

      for (int i = 0; i < 3; i++) {
        await tester.tapAt(blockedCenter);
        await tester.pumpAndSettle(const Duration(milliseconds: 900));
      }
      expect(find.text('Out of Lives'), findsOneWidget);

      await tester.tap(find.text('Watch Ad  +1 Life'));
      await tester.pumpAndSettle();

      expect(_livesOf(tester), 1);
      expect(find.text('Out of Lives'), findsNothing);

      // Verify the cycle repeats: one more blocked tap brings back to 0 and shows popup again
      await tester.tapAt(blockedCenter);
      await tester.pumpAndSettle(const Duration(milliseconds: 900));
      expect(_livesOf(tester), 0);
      expect(find.text('Out of Lives'), findsOneWidget);
      expect(find.text('Watch Ad  +1 Life'), findsOneWidget);
    });

    testWidgets('watch ad failure shows message and keeps popup', (tester) async {
      AdmobService.debugShowRewardedHandler = (purpose) async => false;
      await _pumpGameWithLevel(tester, _blockedLevel(), 1);

      final boardBox = tester.renderObjectList<RenderBox>(find.byWidgetPredicate(
              (w) => w is CustomPaint && w.size.width > 50))
          .reduce((a, b) => a.size.width > b.size.width ? a : b);
      final side = boardBox.size.width;
      final cell = side / 5;
      final blockedCenter =
          boardBox.localToGlobal(Offset(1 * cell + cell / 2, 1 * cell + cell / 2));

      for (int i = 0; i < 3; i++) {
        await tester.tapAt(blockedCenter);
        await tester.pumpAndSettle(const Duration(milliseconds: 900));
      }
      await tester.tap(find.text('Watch Ad  +1 Life'));
      await tester.pumpAndSettle();

      expect(find.text('Ad Not Available'), findsOneWidget);
      expect(find.text('Restart Level'), findsOneWidget);
      expect(_livesOf(tester), 0);
    });

    testWidgets('restart from popup gives 3 lives', (tester) async {
      await _pumpGameWithLevel(tester, _blockedLevel(), 1);

      final boardBox = tester.renderObjectList<RenderBox>(find.byWidgetPredicate(
              (w) => w is CustomPaint && w.size.width > 50))
          .reduce((a, b) => a.size.width > b.size.width ? a : b);
      final side = boardBox.size.width;
      final cell = side / 5;
      final blockedCenter =
          boardBox.localToGlobal(Offset(1 * cell + cell / 2, 1 * cell + cell / 2));

      for (int i = 0; i < 3; i++) {
        await tester.tapAt(blockedCenter);
        await tester.pumpAndSettle(const Duration(milliseconds: 900));
      }
      await tester.tap(find.text('Restart Level'));
      await tester.pumpAndSettle();

      expect(_livesOf(tester), 3);
      expect(find.text('Out of Lives'), findsNothing);
    });
  });

  group('Coins', () {
    testWidgets('level completion awards exactly +3 coins once', (tester) async {
      SharedPreferences.setMockInitialValues(_prefs);
      EconomyProvider.setInstance(createEconomyService(useInMemory: true));
      await EconomyProvider.instance.init();
      await EconomyProvider.instance.setCoins(20);

      await _pumpGameWithLevel(tester, _twoFreeLevel(), 42);
      final economy = EconomyProvider.instance;

      final boardBox = tester.renderObjectList<RenderBox>(find.byWidgetPredicate(
              (w) => w is CustomPaint && w.size.width > 50))
          .reduce((a, b) => a.size.width > b.size.width ? a : b);
      final side = boardBox.size.width;
      final cell = side / 5;

      // Tap path 1 (0,2)-(2,2) free at center (1,2)
      final p1Center = boardBox.localToGlobal(Offset(1 * cell + cell / 2, 2 * cell + cell / 2));
      await tester.tapAt(p1Center);
      await tester.pumpAndSettle(const Duration(milliseconds: 900));

      // Tap path 2 (4,4)-(4,3) free at (4,3.5)
      final p2Center = boardBox.localToGlobal(Offset(4 * cell + cell / 2, 3.5 * cell));
      await tester.tapAt(p2Center);
      await tester.pumpAndSettle(const Duration(milliseconds: 1200));

      expect(await economy.getCoins(), 23);

      // Pump a bit more to ensure no duplicate reward
      await tester.pump(const Duration(milliseconds: 500));
      expect(await economy.getCoins(), 23);
      expect(find.textContaining('+3'), findsWidgets);
    });

    testWidgets('coins persist after restart', (tester) async {
      SharedPreferences.setMockInitialValues(_prefs);
      EconomyProvider.setInstance(createEconomyService(useInMemory: true));
      await EconomyProvider.instance.init();
      await EconomyProvider.instance.setCoins(10);

      await _pumpGameWithLevel(tester, _twoFreeLevel(), 42);
      final boardBox = tester.renderObjectList<RenderBox>(find.byWidgetPredicate(
              (w) => w is CustomPaint && w.size.width > 50))
          .reduce((a, b) => a.size.width > b.size.width ? a : b);
      final side = boardBox.size.width;
      final cell = side / 5;
      final p1Center = boardBox.localToGlobal(Offset(1 * cell + cell / 2, 2 * cell + cell / 2));
      await tester.tapAt(p1Center);
      await tester.pumpAndSettle(const Duration(milliseconds: 900));
      final p2Center = boardBox.localToGlobal(Offset(4 * cell + cell / 2, 3.5 * cell));
      await tester.tapAt(p2Center);
      await tester.pumpAndSettle(const Duration(milliseconds: 1200));

      expect(await EconomyProvider.instance.getCoins(), 13);

      // Tap restart from completion dialog's Replay is not directly testable here
      // Instead tap the top-bar restart button
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pumpAndSettle();
      expect(await EconomyProvider.instance.getCoins(), 13);
    });
  });

  group('Hints', () {
    testWidgets('10+ coins deducts 10 and shows hint', (tester) async {
      EconomyProvider.setInstance(createEconomyService(useInMemory: true));
      await EconomyProvider.instance.init();
      await EconomyProvider.instance.setCoins(20);

      await _pumpGameWithLevel(tester, _blockedLevel(), 1);
      await tester.tap(find.byTooltip('Hint'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(await EconomyProvider.instance.getCoins(), 10);
      expect(tester.widget<PuzzleBoard>(find.byType(PuzzleBoard)).hintPathId,
          isNotNull);
      await tester.pump(const Duration(milliseconds: 2500));
    });

    testWidgets('less than 10 coins shows not-enough popup', (tester) async {
      EconomyProvider.setInstance(createEconomyService(useInMemory: true));
      await EconomyProvider.instance.init();
      await EconomyProvider.instance.setCoins(5);

      await _pumpGameWithLevel(tester, _blockedLevel(), 1);
      await tester.tap(find.byTooltip('Hint'));
      await tester.pumpAndSettle();

      expect(find.text('Not Enough Coins'), findsOneWidget);
      expect(find.text('Watch Ad for Hint'), findsOneWidget);
      expect(await EconomyProvider.instance.getCoins(), 5);
    });

    testWidgets('watch ad for hint grants hint without deducting coins',
        (tester) async {
      AdmobService.debugShowRewardedHandler = (purpose) async {
        expect(purpose, RewardPurpose.hint);
        return true;
      };
      EconomyProvider.setInstance(createEconomyService(useInMemory: true));
      await EconomyProvider.instance.init();
      await EconomyProvider.instance.setCoins(5);

      await _pumpGameWithLevel(tester, _blockedLevel(), 1);
      await tester.tap(find.byTooltip('Hint'));
      await tester.pumpAndSettle();
      // Before watching ad, hint must NOT be visible yet
      expect(tester.widget<PuzzleBoard>(find.byType(PuzzleBoard)).hintPathId,
          isNull);
      await tester.tap(find.text('Watch Ad for Hint'));
      await tester.pump(Duration(milliseconds: 100));
      await tester.pump(Duration(milliseconds: 400));

      expect(await EconomyProvider.instance.getCoins(), 5);
      expect(find.text('Not Enough Coins'), findsNothing);
      // After watching, the arrow hint must be highlighted on the board
      expect(tester.widget<PuzzleBoard>(find.byType(PuzzleBoard)).hintPathId,
          isNotNull);
      await tester.pump(const Duration(milliseconds: 2500));
    });

    testWidgets('hint button updates live with coin balance', (tester) async {
      EconomyProvider.setInstance(createEconomyService(useInMemory: true));
      await EconomyProvider.instance.init();
      await EconomyProvider.instance.setCoins(5);

      await _pumpGameWithLevel(tester, _blockedLevel(), 1);
      expect(find.text('Watch Ad'), findsOneWidget);
      expect(find.text('10'), findsNothing);

      await EconomyProvider.instance.setCoins(15);
      await tester.pumpAndSettle();
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Watch Ad'), findsNothing);

      await EconomyProvider.instance.setCoins(2);
      await tester.pumpAndSettle();
      expect(find.text('Watch Ad'), findsOneWidget);
    });

    testWidgets('rapid hint taps only deduct once', (tester) async {
      EconomyProvider.setInstance(createEconomyService(useInMemory: true));
      await EconomyProvider.instance.init();
      await EconomyProvider.instance.setCoins(20);

      await _pumpGameWithLevel(tester, _blockedLevel(), 1);
      // Tap hint rapidly 3 times
      await tester.tap(find.byTooltip('Hint'));
      await tester.tap(find.byTooltip('Hint'));
      await tester.tap(find.byTooltip('Hint'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      expect(await EconomyProvider.instance.getCoins(), 10);
      await tester.pump(const Duration(milliseconds: 2500));
    });
  });

  group('Banners', () {
    testWidgets('banner appears on Home', (tester) async {
      SharedPreferences.setMockInitialValues(_prefs);
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(BannerAdWidget), findsOneWidget);
    });

    testWidgets('banner appears on Level Selection', (tester) async {
      SharedPreferences.setMockInitialValues(_prefs);
      await tester.pumpWidget(const MaterialApp(home: LevelSelectScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(BannerAdWidget), findsOneWidget);
    });

    testWidgets('banner appears on Settings', (tester) async {
      SharedPreferences.setMockInitialValues(_prefs);
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(BannerAdWidget), findsOneWidget);
    });

    testWidgets('banner appears during gameplay', (tester) async {
      await _pumpGameWithLevel(tester, _blockedLevel(), 1);
      expect(find.byType(BannerAdWidget), findsOneWidget);
    });
  });

  group('Earn Coins', () {
    testWidgets('settings has Earn Coins section and watch ad gives +3',
        (tester) async {
      AdmobService.debugShowRewardedHandler = (purpose) async {
        expect(purpose, RewardPurpose.coins);
        return true;
      };
      EconomyProvider.setInstance(createEconomyService(useInMemory: true));
      await EconomyProvider.instance.init();
      await EconomyProvider.instance.setCoins(20);

      SharedPreferences.setMockInitialValues(_prefs);
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('EARN COINS'), findsOneWidget);
      await tester.ensureVisible(find.text('Watch Ad'));
      await tester.pumpAndSettle();
      expect(find.text('Watch Ad'), findsOneWidget);

      await tester.tap(find.text('Watch Ad'));
      await tester.pumpAndSettle();

      expect(await EconomyProvider.instance.getCoins(), 23);
      expect(find.text('+3 Coins'), findsOneWidget);
    });
  });
}
