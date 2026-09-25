import 'dart:math' as math;

import '../../models/level.dart';
import '../../models/puzzle_path.dart';

/// World / Stage definitions for shape-driven progression.
/// Each world has a clear visual theme and increasing difficulty.
class WorldInfo {
  final int world;
  final String title;
  final String category;
  final List<String> shapes;
  final int startId;
  final int endId;
  final int gridSize;

  const WorldInfo({
    required this.world,
    required this.title,
    required this.category,
    required this.shapes,
    required this.startId,
    required this.endId,
    required this.gridSize,
  });

  bool contains(int levelId) => levelId >= startId && levelId <= endId;
}

class LevelWorlds {
  // W1: Basic geometric - curated dense 20x20 boards
  static const WorldInfo world1 = WorldInfo(
    world: 1,
    title: 'Basic Shapes',
    category: 'Geometry',
    startId: 1,
    endId: 10,
    gridSize: 20,
    shapes: [
      'Square', // 1 (curated Dense Maze board: square tile label)
      'Triangle', // 2 (curated Triangle board, unchanged)
      'Hexagon', // 3
      'Circle', // 4
      'Pentagon', // 5
      'Star', // 6
      'Heart', // 7
      'Diamond', // 8
      'Octagon', // 9
      'Cross', // 10
    ],
  );

  // W2: More complex geometry - curated dense 20x20 boards
  static const WorldInfo world2 = WorldInfo(
    world: 2,
    title: 'Patterns',
    category: 'Complex Geometry',
    startId: 11,
    endId: 20,
    gridSize: 20,
    shapes: [
      'Concentric Squares', // 11
      'Spiral', // 12
      'Wave', // 13
      'Checker Grid', // 14
      'Infinity', // 15
      'Radial Pattern', // 16
      'Labyrinth', // 17
      'Diamond Grid', // 18
      'Interlocking Loops', // 19
      'Master Pattern', // 20
    ],
  );

  // W3: Nature - one dense silhouette per level, boards ~24-26
  static const WorldInfo world3 = WorldInfo(
    world: 3,
    title: 'Nature',
    category: 'Nature',
    startId: 21,
    endId: 35,
    gridSize: 20,
    shapes: [
      'Flower', //21
      'Leaf', //22
      'Tree', //23
      'Sun', //24
      'Cloud', //25
      'Mushroom', //26
      'Butterfly', //27
      'Fish', //28
      'Bird', //29
      'Apple', //30
      'Cherry', //31
      'Cactus', //32
      'Palm', //33
      'Rainbow', //34
      'Mountain', //35
    ],
  );

  // W4: Animals - one dense silhouette per level, boards ~26-28
  static const WorldInfo world4 = WorldInfo(
    world: 4,
    title: 'Animals',
    category: 'Animals',
    startId: 36,
    endId: 55,
    gridSize: 20,
    shapes: [
      'Cat',
      'Dog',
      'Rabbit',
      'Elephant',
      'Turtle',
      'Owl',
      'Fox',
      'Bear',
      'Penguin',
      'Whale',
      'Crab',
      'Frog',
      'Monkey',
      'Lion',
      'Giraffe',
      'Zebra',
      'Kangaroo',
      'Dolphin',
      'Octopus',
      'Dinosaur',
    ],
  );

  // W5: Objects - one dense silhouette per level, boards ~27-28
  static const WorldInfo world5 = WorldInfo(
    world: 5,
    title: 'Objects',
    category: 'Objects',
    startId: 56,
    endId: 75,
    gridSize: 20,
    shapes: [
      'House',
      'Car',
      'Rocket',
      'Boat',
      'Airplane',
      'Camera',
      'Gift',
      'Key',
      'Lock',
      'Trophy',
      'Umbrella',
      'Bell',
      'Star Trophy',
      'Chair',
      'Lamp',
      'Bicycle',
      'Guitar',
      'Cup',
      'Diamond Gem',
      'Castle Toy',
    ],
  );

  // W6: Buildings / Landmarks - one dense silhouette per level, ~28-29
  static const WorldInfo world6 = WorldInfo(
    world: 6,
    title: 'Landmarks',
    category: 'Buildings',
    startId: 76,
    endId: 95,
    gridSize: 20,
    shapes: [
      'Small House',
      'Lighthouse',
      'Windmill',
      'Castle',
      'Tower',
      'Bridge',
      'Temple',
      'Skyline',
      'Pyramid',
      'Pagoda',
      'Church',
      'Factory',
      'Stadium',
      'Fort',
      'Gate',
      'Well',
      'Mill',
      'Mansion',
      'Cottage',
      'Palace',
    ],
  );

  // W7: Combination Levels (96-200) - two staggered silhouettes, ~29-32.
  // Display names cycle here for documentation; runtime labels and masks
  // come from ExtendedTemplates so combos stay in sync.
  static const WorldInfo world7 = WorldInfo(
    world: 7,
    title: 'Combination',
    category: 'Combination',
    startId: 96,
    endId: 200,
    gridSize: 24,
    shapes: [
      'Flower + Butterfly',
      'House + Tree',
      'Sun + Mountain',
      'Cat + Heart',
      'Castle + Moon',
      'Rocket + Stars',
    ],
  );

  // W8: Advanced Patterns (201-400) - one dense pattern, boards ~32-35.
  static const WorldInfo world8 = WorldInfo(
    world: 8,
    title: 'Advanced Patterns',
    category: 'Advanced Patterns',
    startId: 201,
    endId: 400,
    gridSize: 20,
    shapes: [
      'Spiral',
      'Double Spiral',
      'Ring',
      'Wave',
      'Zigzag',
      'Honeycomb',
      'Checkerboard',
      'Concentric Circles',
      'Concentric Squares',
      'Infinity',
      'Mandala',
      'Interlock Labyrinth',
    ],
  );

  // W9: Expert Combinations (401-700) - two staggered silhouettes, ~35-39.
  static const WorldInfo world9 = WorldInfo(
    world: 9,
    title: 'Expert',
    category: 'Expert',
    startId: 401,
    endId: 700,
    gridSize: 24,
    shapes: [
      'Flower + Spiral',
      'Castle + Maze',
      'Butterfly + Wave',
      'House + Labyrinth',
      'Tree + Zigzag',
      'Rocket + Starburst',
    ],
  );

  // W10: Master Challenges (701-900) - two staggered silhouettes, ~39-41.
  static const WorldInfo world10 = WorldInfo(
    world: 10,
    title: 'Master',
    category: 'Master',
    startId: 701,
    endId: 900,
    gridSize: 24,
    shapes: [
      'Spiral + Infinity',
      'Mandala + Wave',
      'Castle + Spiral',
      'Dragon + Maze',
    ],
  );

  // W11: Ultimate Challenges (901-1000) - two staggered silhouettes, 41-42.
  static const WorldInfo world11 = WorldInfo(
    world: 11,
    title: 'Ultimate',
    category: 'Ultimate',
    startId: 901,
    endId: 1000,
    gridSize: 24,
    shapes: [
      'Dragon + Infinity',
      'Castle + Kaleidoscope',
      'Phoenix + Spiral',
      'Galaxy + Wave',
    ],
  );

  static const List<WorldInfo> all = [
    world1,
    world2,
    world3,
    world4,
    world5,
    world6,
    world7,
    world8,
    world9,
    world10,
    world11,
  ];

  static WorldInfo worldFor(int levelId) {
    for (final w in all) {
      if (w.contains(levelId)) return w;
    }
    return world7;
  }

  static String shapeFor(int levelId) {
    // Bands 96+ use deterministic template names so tile labels always match
    // generated level metadata (single source of truth, no extra dependency).
    if (levelId >= 96) return extendedDisplayName(levelId);
    final w = worldFor(levelId);
    final idx = (levelId - w.startId) % w.shapes.length;
    return w.shapes[idx];
  }

  static String categoryFor(int levelId) => worldFor(levelId).category;

  static String worldNameFor(int levelId) => worldFor(levelId).title;

  /// Board size for [levelId]. Levels 1-20 are the curated 20x20 boards.
  /// From Level 21 boards grow continuously from 24x24 to 42x42 (fast
  /// early, then steady), giving finer, denser arrow constructions;
  /// combination levels start at 28 so both shapes stay large.
  static int gridSizeFor(int levelId) {
    if (levelId <= 20) return worldFor(levelId).gridSize;
    final t = ((levelId - 21) / (1000 - 21)).clamp(0.0, 1.0);
    final size = 24 + (18 * math.sqrt(t)).round();
    if (extendedComponents(levelId).length >= 2) return math.max(28, size);
    return size;
  }

  static int difficultyFor(int levelId) {
    final w = worldFor(levelId).world;
    // Map world 1..7 to difficulty 1..5 with smooth within-world ramp
    if (w == 1) return 1;
    if (w == 2) return 2;
    if (w == 3) return levelId <= 28 ? 2 : 3;
    if (w == 4) return levelId <= 45 ? 3 : 4;
    if (w == 5) return 4;
    if (w == 6) return 4;
    if (w == 7) return 3;
    if (w == 8) return 4;
    if (w == 9) return 4;
    return 5;
  }

  static String difficultyNameFor(int levelId) {
    switch (difficultyFor(levelId)) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      case 4:
        return 'Expert';
      default:
        return 'Master';
    }
  }

  // ============ Extended bands (96-1000) template tables ============
  // Single source of truth for deterministic template selection. Both the
  // generator (masks) and shapeFor (labels) derive from these, so the tile
  // label always matches the generated level content.

  /// Recognizable object/shape pool (Worlds 3-6 shapes).
  static List<String> get objectPool => [
    ...world3.shapes,
    ...world4.shapes,
    ...world5.shapes,
    ...world6.shapes,
  ];

  /// Abstract pattern pool (every entry is a ShapeMasks case).
  static const List<String> patternPool = [
    'Spiral',
    'Double Spiral',
    'Ring',
    'Mechanical Gear',
    'Infinity',
    'Interlock Labyrinth',
    'Mandala',
    'Wave',
    'Zigzag',
    'Honeycomb',
    'Checkerboard',
    'Concentric Circles',
    'Concentric Squares',
    'Gear',
    'Dream Catcher',
    'Kaleidoscope',
  ];

  /// Component mask names for [levelId] (1 for single-template levels).
  static List<String> extendedComponents(int levelId) {
    final pool = objectPool;
    if (levelId >= 96 && levelId <= 200) {
      final a = pool[(levelId * 7 + 3) % pool.length];
      var b = pool[(levelId * 13 + 11) % pool.length];
      if (b == a) b = pool[(levelId * 13 + 12) % pool.length];
      return [a, b];
    }
    if (levelId >= 201 && levelId <= 400) {
      return [patternPool[levelId % patternPool.length]];
    }
    if (levelId >= 401 && levelId <= 700) {
      final a = pool[(levelId * 7 + 3) % pool.length];
      final p = patternPool[(levelId * 5 + 1) % patternPool.length];
      return [a, p];
    }
    if (levelId >= 701 && levelId <= 900) {
      if (levelId.isEven) {
        final a = patternPool[(levelId * 3 + 2) % patternPool.length];
        var b = patternPool[(levelId * 11 + 7) % patternPool.length];
        if (b == a) b = patternPool[(levelId * 11 + 8) % patternPool.length];
        return [a, b];
      }
      final a = pool[(levelId * 7 + 5) % pool.length];
      final p = patternPool[(levelId * 13 + 4) % patternPool.length];
      return [a, p];
    }
    if (levelId >= 901 && levelId <= 1000) {
      final a = pool[(levelId * 17 + 9) % pool.length];
      var p = patternPool[(levelId * 19 + 6) % patternPool.length];
      if (p.toLowerCase() == a.toLowerCase()) {
        p = patternPool[(levelId * 19 + 7) % patternPool.length];
      }
      return [a, p];
    }
    return [shapeFor(levelId)];
  }

  /// Composition layout for [levelId]: the two shapes staggered along the
  /// main diagonal ('diagonal') or the other one ('antiDiagonal').
  static String extendedLayout(int levelId) {
    if (extendedComponents(levelId).length < 2) return 'single';
    return levelId.isEven ? 'diagonal' : 'antiDiagonal';
  }

  /// Display name shared by level metadata and tile labels.
  static String extendedDisplayName(int levelId) {
    final comps = extendedComponents(levelId);
    if (comps.length == 1) return comps.first;
    return '${comps[0]} + ${comps[1]}';
  }
}

/// Helper to build Level with world metadata consistently.
Level buildLevelWithMeta({
  required int levelId,
  required int gridSize,
  required List<PuzzlePath> puzzlePaths,
  int? difficulty,
  String? difficultyName,
}) {
  final worldInfo = LevelWorlds.worldFor(levelId);
  final shape = LevelWorlds.shapeFor(levelId);
  return Level(
    levelId: levelId,
    gridSize: gridSize,
    puzzlePaths: puzzlePaths,
    name: shape,
    shapeName: shape,
    category: worldInfo.category,
    world: worldInfo.world,
    worldName: worldInfo.title,
    difficulty: difficulty ?? LevelWorlds.difficultyFor(levelId),
    difficultyName: difficultyName ?? LevelWorlds.difficultyNameFor(levelId),
  );
}
