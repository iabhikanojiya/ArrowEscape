import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/core/constants/app_constants.dart';
import 'package:arrow_escape/game/levels/level_world.dart';
import 'package:arrow_escape/models/arrow.dart';
import 'package:arrow_escape/models/level.dart';
import 'package:arrow_escape/models/puzzle_path.dart';
import 'package:arrow_escape/screens/game/game_screen.dart';
import 'package:arrow_escape/screens/level_select/level_select_screen.dart';
import 'package:arrow_escape/services/achievements/achievement_service.dart';
import 'package:arrow_escape/services/admob_service.dart';
import 'package:arrow_escape/services/economy/economy_service.dart';
import 'package:arrow_escape/services/storage/storage_service.dart';

const _firstStep = 'first_step';

String _categoryId(int world) => 'category_world_$world';

Future<void> _complete(Iterable<int> levels) async {
  final storage = createStorageService();
  await storage.init();
  for (final l in levels) {
    await storage.addCompletedLevel(l);
  }
}

AchievementState _stateOf(List<AchievementStatus> all, String id) =>
    all.firstWhere((a) => a.def.id == id).state;

Future<int> _coins() => EconomyProvider.instance.getCoins();

/// Level screen with looping reward animations off, so pumpAndSettle settles.
Widget _levelScreen() => MaterialApp(
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child!,
  ),
  home: const LevelSelectScreen(),
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'tip_blocked_arrow_seen': true});
    EconomyProvider.setInstance(createEconomyService());
    await EconomyProvider.instance.init();
    AchievementService.setInstance(null);
    AdmobService.instance.debugReset();
  });

  tearDown(() {
    AchievementService.setInstance(null);
    AdmobService.instance.debugReset();
  });

  group('Definitions', () {
    test('one individual level achievement (Level 1) plus one per world', () {
      final defs = AchievementService.definitions;
      final individual = defs
          .where((d) => d.kind == AchievementKind.firstLevel)
          .toList();
      expect(individual, hasLength(1));
      expect(individual.single.startLevel, 1);
      expect(individual.single.endLevel, 1);
      expect(individual.single.reward, 20);

      final categories = defs
          .where((d) => d.kind == AchievementKind.category)
          .toList();
      expect(categories, hasLength(LevelWorlds.all.length));
      for (var i = 0; i < categories.length; i++) {
        final w = LevelWorlds.all[i];
        expect(categories[i].title, w.title);
        expect(categories[i].startLevel, w.startId);
        expect(categories[i].endLevel, w.endId);
        expect(categories[i].reward, 50);
      }
      expect(defs.map((d) => d.id).toSet(), hasLength(defs.length));
    });
  });

  group('First Step', () {
    test('Level 1 completion unlocks First Step without paying +20', () async {
      await _complete([1]);
      final all = await AchievementService.instance.load();
      expect(_stateOf(all, _firstStep), AchievementState.claimable);
      expect(await _coins(), AppConstants.initialCoins);
    });

    test('claiming gives exactly +20, and only once', () async {
      await _complete([1]);
      final service = AchievementService.instance;
      expect(await service.claim(_firstStep), 20);
      expect(await _coins(), AppConstants.initialCoins + 20);

      expect(await service.claim(_firstStep), isNull);
      await service.load();
      expect(await service.claim(_firstStep), isNull);
      expect(await _coins(), AppConstants.initialCoins + 20);
      expect(
        _stateOf(await service.load(), _firstStep),
        AchievementState.claimed,
      );
    });

    test('rapid repeated claims pay once', () async {
      await _complete([1]);
      final service = AchievementService.instance;
      final results = await Future.wait([
        for (var i = 0; i < 5; i++) service.claim(_firstStep),
      ]);
      expect(results.whereType<int>(), [20]);
      expect(await _coins(), AppConstants.initialCoins + 20);
    });

    test('cannot claim while locked', () async {
      expect(await AchievementService.instance.claim(_firstStep), isNull);
      expect(await _coins(), AppConstants.initialCoins);
    });

    test('replaying Level 1 or resetting progress never pays again', () async {
      await _complete([1]);
      final service = AchievementService.instance;
      expect(await service.claim(_firstStep), 20);

      await _complete([1]);
      final storage = createStorageService();
      await storage.init();
      await storage.resetProgress();
      await _complete([1]);

      expect(await service.claim(_firstStep), isNull);
      expect(
        _stateOf(await service.load(), _firstStep),
        AchievementState.claimed,
      );
    });

    test('Level 2 does not create an individual achievement', () async {
      await _complete([2]);
      final all = await AchievementService.instance.load();
      expect(all.where((a) => a.state != AchievementState.locked), isEmpty);
      expect(AchievementService.definitionFor('level_2'), isNull);
    });
  });

  group('Category mastery', () {
    final patterns = LevelWorlds.world2;
    final patternLevels = [
      for (var l = patterns.startId; l <= patterns.endId; l++) l,
    ];

    test('stays locked until every level in the category is done', () async {
      await _complete(patternLevels.take(patternLevels.length - 1));
      final all = await AchievementService.instance.load();
      final status = all.firstWhere(
        (a) => a.def.id == _categoryId(patterns.world),
      );
      expect(status.state, AchievementState.locked);
      expect(status.completedLevels, patternLevels.length - 1);
      expect(await AchievementService.instance.claim(status.def.id), isNull);
    });

    test('completing all levels unlocks it without paying +50', () async {
      await _complete(patternLevels);
      final all = await AchievementService.instance.load();
      expect(
        _stateOf(all, _categoryId(patterns.world)),
        AchievementState.claimable,
      );
      expect(_stateOf(all, _categoryId(1)), AchievementState.locked);
      expect(await _coins(), AppConstants.initialCoins);
    });

    test('claiming gives exactly +50, and only once', () async {
      await _complete(patternLevels);
      final service = AchievementService.instance;
      final id = _categoryId(patterns.world);
      expect(await service.claim(id), 50);
      expect(await service.claim(id), isNull);
      await _complete(patternLevels);
      expect(await service.claim(id), isNull);
      expect(await _coins(), AppConstants.initialCoins + 50);
    });

    test('works for every world, including expansion worlds', () async {
      final last = LevelWorlds.all.last;
      await _complete([for (var l = last.startId; l <= last.endId; l++) l]);
      final all = await AchievementService.instance.load();
      expect(
        _stateOf(all, _categoryId(last.world)),
        AchievementState.claimable,
      );
    });
  });

  group('Persistence', () {
    test('state survives a restart and is stored apart from coins', () async {
      await _complete([1, ...List.generate(10, (i) => i + 1)]);
      await AchievementService.instance.claim(_firstStep);

      // Simulate a cold start: fresh service + economy over the same prefs.
      AchievementService.setInstance(null);
      EconomyProvider.setInstance(createEconomyService());
      await EconomyProvider.instance.init();

      final all = await AchievementService.instance.load();
      expect(_stateOf(all, _firstStep), AchievementState.claimed);
      expect(_stateOf(all, _categoryId(1)), AchievementState.claimable);
      expect(await AchievementService.instance.claim(_firstStep), isNull);
      expect(await _coins(), AppConstants.initialCoins + 20);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getInt(AppConstants.storageKeyCoins),
        AppConstants.initialCoins + 20,
      );
      final stored =
          jsonDecode(prefs.getString(AchievementService.storageKey)!)
              as Map<String, dynamic>;
      expect(stored['claimed'], [_firstStep]);
      expect(stored['unlocked'], containsAll([_firstStep, _categoryId(1)]));
    });
  });

  group('Economy and leaderboard', () {
    test('rewards flow through the EconomyProvider coin listener', () async {
      // PlayGamesService submits from this same listenable, keeping only the
      // highest balance; achievements need no leaderboard code of their own.
      final economy = EconomyProvider.instance;
      await economy.setCoins(100);
      final seen = <int>[];
      void listener() => seen.add(economy.coinsListenable.value);
      economy.coinsListenable.addListener(listener);
      addTearDown(() => economy.coinsListenable.removeListener(listener));

      await _complete([for (var l = 1; l <= LevelWorlds.world1.endId; l++) l]);
      await economy.addCoins(3); // the existing level-complete reward
      final service = AchievementService.instance;
      await service.load();
      expect(await economy.getCoins(), 103);

      await service.claim(_firstStep);
      expect(await economy.getCoins(), 123);
      await service.claim(_categoryId(1));
      expect(await economy.getCoins(), 173);

      expect(seen, [103, 123, 173]);
      expect(seen.reduce((a, b) => a > b ? a : b), 173);
    });
  });

  group('In game', () {
    Level twoArrowLevel(int id) => Level(
      levelId: id,
      gridSize: 5,
      puzzlePaths: [
        PuzzlePath(
          id: '1',
          points: const [GridPoint(0, 2), GridPoint(2, 2)],
          direction: ArrowDirection.right,
        ),
        PuzzlePath(
          id: '2',
          points: const [GridPoint(4, 4), GridPoint(4, 3)],
          direction: ArrowDirection.up,
        ),
      ],
    );

    Future<void> playAndClear(WidgetTester tester, int levelNumber) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            levelNumber: levelNumber,
            level: twoArrowLevel(levelNumber),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final board = tester
          .renderObjectList<RenderBox>(
            find.byWidgetPredicate(
              (w) => w is CustomPaint && w.size.width > 50,
            ),
          )
          .reduce((a, b) => a.size.width > b.size.width ? a : b);
      final cell = board.size.width / 5;
      await tester.tapAt(board.localToGlobal(Offset(1.5 * cell, 2.5 * cell)));
      await tester.pumpAndSettle(const Duration(milliseconds: 900));
      await tester.tapAt(board.localToGlobal(Offset(4.5 * cell, 3.5 * cell)));
      await tester.pumpAndSettle(const Duration(milliseconds: 1200));
    }

    /// Unlocked ids as persisted, read without going through load() (which
    /// would itself unlock), to prove completion unlocked them.
    Future<List<dynamic>> storedUnlocked() async {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AchievementService.storageKey);
      if (raw == null) return const [];
      return (jsonDecode(raw) as Map<String, dynamic>)['unlocked'] as List;
    }

    testWidgets('Level 1 pays +3 and unlocks First Step immediately', (
      tester,
    ) async {
      await playAndClear(tester, 1);

      expect(await _coins(), AppConstants.initialCoins + 3);
      expect(await storedUnlocked(), [_firstStep]);

      final all = await tester.runAsync(
        () => AchievementService.instance.load(),
      );
      expect(_stateOf(all!, _firstStep), AchievementState.claimable);
      expect(await _coins(), AppConstants.initialCoins + 3);
    });

    testWidgets('final level of a world unlocks it immediately, no +50', (
      tester,
    ) async {
      final world = LevelWorlds.world1;
      await _complete([for (var l = world.startId; l < world.endId; l++) l]);
      expect(await storedUnlocked(), isEmpty);

      await playAndClear(tester, world.endId);

      expect(
        await storedUnlocked(),
        containsAll([_firstStep, _categoryId(world.world)]),
      );
      expect(await _coins(), AppConstants.initialCoins + 3);
    });
  });

  group('Level screen', () {
    testWidgets('Levels tab is default; Achievements tab claims once', (
      tester,
    ) async {
      await _complete([1]);
      await tester.pumpWidget(_levelScreen());
      await tester.pumpAndSettle();

      expect(find.text('LEVELS'), findsOneWidget);
      expect(find.text('ACHIEVEMENTS'), findsOneWidget);
      expect(find.text('Basic Shapes'), findsOneWidget);
      expect(find.text('First Step'), findsNothing);

      await tester.tap(find.text('ACHIEVEMENTS'));
      await tester.pumpAndSettle();

      expect(find.text('First Step'), findsOneWidget);
      expect(find.text('CLAIM'), findsOneWidget);
      expect(find.text('20 coins ready to claim'), findsOneWidget);

      // Double tap: the second tap lands while the first claim is pending
      // (or after the button is gone) and must not pay again.
      final claim = tester.getCenter(find.text('CLAIM'));
      await tester.tapAt(claim);
      await tester.tapAt(claim);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('ACHIEVEMENT CLAIMED'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('CLAIM'), findsNothing);
      expect(await _coins(), AppConstants.initialCoins + 20);

      // Let the toast finish and remove itself.
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('ACHIEVEMENT CLAIMED'), findsNothing);

      // Claimed achievements move to the Completed section at the bottom.
      await tester.scrollUntilVisible(
        find.text('CLAIMED'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('CLAIMED'), findsOneWidget);

      await tester.tap(find.text('LEVELS'));
      await tester.pumpAndSettle();
      expect(find.text('Basic Shapes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('groups achievements: ready, in progress, locked, completed', (
      tester,
    ) async {
      // World 1 done and claimed, World 2 done, World 3 partly done.
      await _complete([for (var l = 1; l <= 24; l++) l]);
      await AchievementService.instance.claim(_categoryId(1));

      await tester.pumpWidget(_levelScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('ACHIEVEMENTS'));
      await tester.pumpAndSettle();

      double y(String text) => tester.getTopLeft(find.text(text)).dy;
      expect(y('READY TO CLAIM'), lessThan(y('IN PROGRESS')));
      expect(find.text('CLAIM'), findsNWidgets(2)); // First Step + Patterns
      expect(find.text('4 / 15'), findsOneWidget); // Nature in progress

      // Only the next 3 locked worlds show until expanded.
      final lockedCount = AchievementService.definitions.length - 4;
      final showMore = find.text('Show ${lockedCount - 3} more');
      await tester.scrollUntilVisible(
        showMore,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Ultimate Challenges'), findsNothing);
      await tester.tap(showMore);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Ultimate Challenges'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.scrollUntilVisible(
        find.text('COMPLETED'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('CLAIMED'), findsOneWidget);
      // Flush staggered entrance delays of cards built while scrolling.
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Achievements tab fits a small phone', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _complete([for (var l = 1; l <= 20; l++) l]);

      await tester.pumpWidget(_levelScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('ACHIEVEMENTS'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('CLAIM'), findsWidgets);
    });
  });
}
