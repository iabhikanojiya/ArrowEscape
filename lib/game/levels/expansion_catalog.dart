import 'dart:math' as math;

import 'dense_tiler.dart';

/// One silhouette placed on an expansion board.
class ExpansionPiece {
  /// Shape name (a [ShapeArt] design or an [ExpansionShapes] geometry).
  final String name;

  /// Box position and size as fractions of the board's inner area.
  final double x, y, size;

  /// Mirror left-right.
  final bool mirror;

  /// Quarter turns clockwise (geometry and patterns only).
  final int turns;

  /// Nested copies: each scale cuts a one-cell channel along a smaller
  /// copy of the shape, splitting it into concentric bands.
  final List<double> rings;

  const ExpansionPiece(
    this.name,
    this.x,
    this.y,
    this.size, {
    this.mirror = false,
    this.turns = 0,
    this.rings = const [],
  });
}

/// Content plan for Levels 1001-2000 (Levels 1-1000 never reach here).
///
/// Ten bands of 100 levels, each with its own theme. Everything is a pure
/// function of the level id, so a level is identical on every run and
/// platform. Within a band the composition grows from pairs to trios to
/// four-shape scenes, and boards, arrow lengths, bends and dependency
/// depth keep rising from where Level 1000 ends.
class ExpansionCatalog {
  static const int first = 1001;
  static const int last = 2000;

  static bool covers(int levelId) => levelId >= first && levelId <= last;

  /// 0..1 progress through the expansion.
  static double progress(int levelId) =>
      ((levelId - first) / (last - first)).clamp(0.0, 1.0);

  /// Band index 0..9 (Master Shapes .. Ultimate Challenges).
  static int band(int levelId) => (levelId - first) ~/ 100;

  /// Board size: 43x43 at Level 1001 (one larger than Level 1000) up to
  /// 48x48 at Level 2000.
  static int gridSizeFor(int levelId) => 43 + (5 * progress(levelId)).round();

  /// Tiler settings continuing the Level 21-1000 curve past its end point:
  /// fewer short arrows, longer and more bent ones, stronger preference for
  /// deep dependency chains and against free opening moves.
  ///
  /// Solid geometry (Master Shapes) lets arrows snake much further than
  /// thin strokes do, so that band uses shorter arrows: more, tighter-packed
  /// arrows instead of a few huge ones. Other bands scale arrow length a
  /// little ([_lengthBias]) so arrow counts rise steadily across themes.
  static TilerParams paramsFor(int levelId) {
    final u = math.pow(progress(levelId), 0.8).toDouble();
    final b = band(levelId);
    if (b == 0) {
      return TilerParams(
        shortChance: 0.15,
        longChance: 0.15,
        mediumMean: 5.5,
        longMin: 10,
        maxSize: 16,
        bendWeight: 36 + 8 * u,
        turnChance: 0.8 + 0.06 * u,
        depthWeight: 18 + 10 * u,
        freePenalty: 250 + 130 * u,
        freeLengthBonus: 6 + 2 * u,
        blockedBias: 0.9 + 0.06 * u,
      );
    }
    final k = _lengthBias[b];
    return TilerParams(
      shortChance: 0.15 - 0.03 * u,
      longChance: (0.35 + 0.03 * u) * k,
      mediumMean: (7 + 0.2 * u) * k,
      longMin: (10 + 1 * u).round(),
      maxSize: (24 + 2 * u).round(),
      bendWeight: 36 + 8 * u,
      turnChance: 0.8 + 0.06 * u,
      depthWeight: 18 + 10 * u,
      freePenalty: 250 + 130 * u,
      freeLengthBonus: 6 + 2 * u,
      blockedBias: 0.9 + 0.06 * u,
    );
  }

  /// Deeper-biased settings for the rescue seeds the generator tries when
  /// no regular candidate is deeper than Level 1000: longer arrows and a
  /// stronger pull towards long dependency chains.
  static TilerParams rescueParamsFor(int levelId) {
    final p = paramsFor(levelId);
    return TilerParams(
      shortChance: p.shortChance * 0.6,
      longChance: math.min(0.6, p.longChance + 0.15),
      mediumMean: p.mediumMean + 1.5,
      longMin: p.longMin,
      maxSize: p.maxSize + 8,
      bendWeight: p.bendWeight,
      turnChance: p.turnChance,
      depthWeight: p.depthWeight * 1.8,
      freePenalty: p.freePenalty * 1.5,
      freeLengthBonus: p.freeLengthBonus,
      blockedBias: 0.98,
    );
  }

  static const List<double> _lengthBias = [
    1.0, 1.0, 0.84, 1.0, 0.84, 0.98, 0.98, 0.95, 0.95, 1.0, //
  ];

  /// Candidate tilings compared per level (see [targetDepthFor]).
  static int candidatesFor(int levelId) =>
      4 + (2 * progress(levelId)).round();

  static int attemptsPerPieceFor(int levelId) =>
      72 + (24 * progress(levelId)).round();

  /// Level 1000 has dependency depth 32. While no candidate is deeper than
  /// that, the generator tries extra seeds with [rescueParamsFor].
  static const int depthFloor = 33;

  /// Floor for [levelId]: Complex Patterns levels must also reach the
  /// Level 1001 target depth, so the pattern band is not easier than the
  /// Master Shapes band before it.
  static int depthFloorFor(int levelId) =>
      band(levelId) == 1 ? targetDepthFor(first) : depthFloor;

  /// One-cell arrows allowed in a rescue candidate. Thin designs (labyrinth
  /// passages, sun rays, rings) only reach deep chains with a few more
  /// one-cell arrows; they render with a clear head along their direction.
  static const double rescueSingleShare = 0.12;

  /// Target dependency depth (peel rounds): 42 at Level 1001, rising
  /// linearly to 66 at Level 2000. The generator keeps a candidate close
  /// above it with few opening moves, so difficulty climbs steadily instead
  /// of jumping with each theme; if no seed reaches it, the deepest is kept.
  static int targetDepthFor(int levelId) =>
      42 + (24 * progress(levelId)).round();

  // ---------------------------------------------------------------- pools

  static const List<String> geometry = [
    'Circle', 'Triangle', 'Square', 'Pentagon', 'Hexagon', 'Star', //
    'Heart', 'Diamond', 'Spiral', 'Cross', 'Crescent', 'Infinity',
    'Gear', 'Crown', 'Octagon', 'Shield', 'Clock',
  ];

  /// Solid geometry that reads well with a nested inner copy.
  static const Set<String> _nestable = {
    'Circle', 'Triangle', 'Square', 'Pentagon', 'Hexagon', 'Star', //
    'Heart', 'Diamond', 'Cross', 'Octagon', 'Crown', 'Shield',
  };

  /// Nestable shapes with narrow points: one nested copy at most.
  static const Set<String> _thin = {'Star', 'Cross', 'Crown'};

  /// Shapes that may be rotated without looking wrong.
  static const Set<String> _turnable = {
    'Triangle', 'Square', 'Pentagon', 'Hexagon', 'Diamond', 'Cross', //
    'Crescent', 'Octagon', 'Clock',
    ...patterns,
  };

  /// Nesting per repeat of a single geometric shape: plain, then one, two
  /// or three concentric copies.
  static const List<List<double>> _ringSets = [
    [],
    [0.55],
    [0.7, 0.4],
    [0.6],
    [0.76, 0.52, 0.28],
    [0.5],
  ];

  static const List<String> patterns = [
    'Spiral', 'Double Spiral', 'Ring', 'Mechanical Gear', 'Infinity', //
    'Interlock Labyrinth', 'Mandala', 'Wave', 'Zigzag', 'Honeycomb',
    'Checkerboard', 'Concentric Circles', 'Concentric Squares', 'Gear',
    'Dream Catcher', 'Kaleidoscope', 'Concentric Diamonds', 'Sunburst',
    'Woven Lattice',
  ];

  static const List<String> _objects = [
    'House', 'Car', 'Rocket', 'Boat', 'Airplane', 'Camera', 'Gift', //
    'Key', 'Lock', 'Trophy', 'Umbrella', 'Bell', 'Chair', 'Lamp',
    'Bicycle', 'Guitar', 'Cup', 'Castle', 'Lighthouse', 'Windmill',
    'Tower', 'Temple', 'Pyramid', 'Pagoda', 'Church', 'Palace',
    'Cat', 'Dog', 'Rabbit', 'Elephant', 'Turtle', 'Owl', 'Fox', 'Bear',
    'Penguin', 'Whale', 'Lion', 'Giraffe', 'Dinosaur', 'Octopus',
    'Flower', 'Tree', 'Butterfly', 'Mushroom', 'Palm', 'Cactus',
  ];

  // Themed combinations per band: pairs (first half), trios (second half).
  static const List<List<String>> _naturePairs = [
    ['Flower', 'Butterfly'], ['Tree', 'Sun'], ['Mountain', 'Cloud'], //
    ['Cactus', 'Sun'], ['Palm', 'Fish'], ['Mushroom', 'Leaf'],
    ['Apple', 'Leaf'], ['Cherry', 'Flower'], ['Rainbow', 'Cloud'],
    ['Tree', 'Bird'], ['Flower', 'Leaf'], ['Sun', 'Mountain'],
    ['Palm', 'Sun'], ['Mushroom', 'Flower'], ['Butterfly', 'Leaf'],
    ['Cloud', 'Bird'],
  ];
  static const List<List<String>> _natureTrios = [
    ['Tree', 'Sun', 'Cloud'], ['Flower', 'Butterfly', 'Leaf'], //
    ['Mountain', 'Sun', 'Cloud'], ['Palm', 'Fish', 'Sun'],
    ['Cactus', 'Sun', 'Bird'], ['Mushroom', 'Flower', 'Leaf'],
    ['Rainbow', 'Cloud', 'Sun'], ['Apple', 'Leaf', 'Butterfly'],
    ['Tree', 'Flower', 'Bird'], ['Cherry', 'Leaf', 'Butterfly'],
  ];

  static const List<List<String>> _animalPairs = [
    ['Cat', 'Fish'], ['Dog', 'Cat'], ['Owl', 'Tree'], ['Penguin', 'Whale'], //
    ['Fox', 'Rabbit'], ['Bear', 'Fish'], ['Elephant', 'Giraffe'],
    ['Turtle', 'Fish'], ['Frog', 'Leaf'], ['Monkey', 'Palm'],
    ['Lion', 'Zebra'], ['Dolphin', 'Whale'], ['Kangaroo', 'Bird'],
    ['Dinosaur', 'Palm'], ['Crab', 'Octopus'], ['Rabbit', 'Flower'],
  ];
  static const List<List<String>> _animalTrios = [
    ['Elephant', 'Giraffe', 'Lion'], ['Penguin', 'Whale', 'Fish'], //
    ['Cat', 'Dog', 'Rabbit'], ['Owl', 'Tree', 'Bird'],
    ['Dinosaur', 'Palm', 'Mountain'], ['Frog', 'Fish', 'Leaf'],
    ['Bear', 'Tree', 'Fish'], ['Monkey', 'Palm', 'Bird'],
    ['Turtle', 'Dolphin', 'Crab'], ['Fox', 'Tree', 'Rabbit'],
  ];

  static const List<List<String>> _objectPairs = [
    ['House', 'Car'], ['Rocket', 'Star'], ['Airplane', 'Cloud'], //
    ['Boat', 'Lighthouse'], ['Camera', 'Lamp'], ['Key', 'Lock'],
    ['Gift', 'Bell'], ['Trophy', 'Star Trophy'], ['Guitar', 'Chair'],
    ['Cup', 'Lamp'], ['Bicycle', 'House'], ['Umbrella', 'Cloud'],
    ['Castle Toy', 'Gift'], ['Diamond Gem', 'Key'], ['Car', 'Tree'],
    ['Clock', 'Lamp'],
  ];
  static const List<List<String>> _objectTrios = [
    ['House', 'Car', 'Tree'], ['Rocket', 'Star', 'Moon'], //
    ['Airplane', 'Cloud', 'Sun'], ['Boat', 'Lighthouse', 'Fish'],
    ['Gift', 'Bell', 'Star'], ['Key', 'Lock', 'Diamond Gem'],
    ['Camera', 'Lamp', 'Chair'], ['Trophy', 'Star Trophy', 'Star'],
    ['Bicycle', 'House', 'Tree'], ['Clock', 'Guitar', 'Lamp'],
  ];

  static const List<List<String>> _landmarkPairs = [
    ['Castle', 'Tower'], ['Lighthouse', 'Boat'], ['Pyramid', 'Sun'], //
    ['Windmill', 'Cloud'], ['Temple', 'Pagoda'], ['Bridge', 'Skyline'],
    ['Church', 'Tree'], ['Palace', 'Gate'], ['Fort', 'Tower'],
    ['Factory', 'Skyline'], ['Stadium', 'Skyline'], ['Mansion', 'Cottage'],
    ['Well', 'Cottage'], ['Lighthouse', 'Mountain'], ['Pyramid', 'Palm'],
    ['Mill', 'Tree'],
  ];
  static const List<List<String>> _landmarkTrios = [
    ['Castle', 'Tower', 'Moon'], ['Lighthouse', 'Boat', 'Cloud'], //
    ['Pyramid', 'Palm', 'Sun'], ['Windmill', 'Cottage', 'Cloud'],
    ['Temple', 'Pagoda', 'Mountain'], ['Bridge', 'Skyline', 'Sun'],
    ['Church', 'Cottage', 'Tree'], ['Palace', 'Gate', 'Tower'],
    ['Fort', 'Castle', 'Mountain'], ['Skyline', 'Bridge', 'Boat'],
  ];

  static const List<List<String>> _multiTrios = [
    ['Triangle', 'Circle', 'Square'], ['Heart', 'Star', 'Diamond'], //
    ['House', 'Tree', 'Sun'], ['Castle', 'Tower', 'Moon'],
    ['Mountain', 'Sun', 'Cloud'], ['Cat', 'House', 'Tree'],
    ['Flower', 'Leaf', 'Butterfly'], ['Rocket', 'Star', 'Moon'],
    ['Boat', 'Fish', 'Sun'], ['Owl', 'Tree', 'Moon'],
  ];
  static const List<List<String>> _multiQuads = [
    ['House', 'Tree', 'Sun', 'Cloud'], ['Castle', 'Tower', 'Moon', 'Star'], //
    ['Mountain', 'Tree', 'Sun', 'Bird'],
    ['Lighthouse', 'Boat', 'Cloud', 'Fish'],
    ['Flower', 'Butterfly', 'Leaf', 'Sun'], ['Pyramid', 'Palm', 'Sun', 'Cloud'],
    ['Windmill', 'Cottage', 'Tree', 'Sun'], ['Whale', 'Boat', 'Fish', 'Sun'],
    ['Dog', 'House', 'Tree', 'Cloud'], ['Heart', 'Star', 'Circle', 'Triangle'],
  ];

  // --------------------------------------------------------------- layout

  /// Shape boxes (x, y, size as fractions of the inner area). The first
  /// shape is the main one; later shapes give way where they meet it.
  static List<List<double>> _boxes(int count, int layout, double grow) {
    double s(double v) => math.min(0.92, v * grow);
    switch (count) {
      case 1:
        final a = math.min(1.0, 0.86 * grow);
        return [
          [(1 - a) / 2, (1 - a) / 2, a],
        ];
      case 2:
        final a = s(0.68);
        // layout 0: main top-left; 1: main top-right.
        return layout.isEven
            ? [
                [0, 0, a],
                [1 - a, 1 - a, a],
              ]
            : [
                [1 - a, 0, a],
                [0, 1 - a, a],
              ];
      case 3:
        final a = s(0.62), b = s(0.48), c = s(0.44);
        return [
          [0, 1 - a, a],
          [1 - b, 1 - b, b],
          [1 - c, 0, c],
        ];
      default:
        final a = s(0.58), b = s(0.46), c = s(0.42), d = s(0.42);
        return [
          [0, 1 - a, a],
          [1 - b, 1 - b, b],
          [1 - c, 0, c],
          [0, 0, d],
        ];
    }
  }

  /// Size multiplier at the start of each band; shapes then grow a further
  /// 8% through the band, so boards fill up steadily.
  static const List<double> _bandGrow = [
    1.0, 0.98, 1.1, 1.12, 1.12, 1.1, 1.05, 1.07, 1.08, 1.08, //
  ];

  /// The silhouettes making up [levelId], in priority order.
  static List<ExpansionPiece> piecesFor(int levelId) {
    final b = band(levelId);
    final i = (levelId - first) % 100;
    final names = _namesFor(b, i);
    // Shapes grow within each band so later levels interlock more tightly.
    final grow =
        _bandGrow[b] +
        0.08 * (i / 99) +
        (names.length == 1 ? 0.06 * (i / 99) : 0);
    final layout = i ~/ 2;
    final flip = (i ~/ 3).isOdd; // mirror the whole composition
    final boxes = _boxes(names.length, layout, grow);
    final variant = names.length == 1 ? i ~/ geometryCountFor(b) : i;
    return [
      for (int k = 0; k < names.length; k++)
        _piece(
          names[k],
          boxes[k],
          flip,
          variant + k,
          single: names.length == 1,
        ),
    ];
  }

  static int geometryCountFor(int b) =>
      b == 0 ? geometry.length : patterns.length;

  static ExpansionPiece _piece(
    String name,
    List<double> box,
    bool flip,
    int variant, {
    required bool single,
  }) {
    final x = flip ? 1 - box[0] - box[2] : box[0];
    final turnable = _turnable.contains(name);
    final nestable = _nestable.contains(name);
    // Repeats of a shape differ in nesting (solid geometry), rotation and
    // mirroring, so no two look the same.
    var rings = nestable && single
        ? _ringSets[variant % _ringSets.length]
        : const <double>[];
    // Pointed shapes would break into specks with several channels.
    if (rings.length > 1 && _thin.contains(name)) rings = [rings.last];
    return ExpansionPiece(
      name,
      x,
      box[1],
      box[2],
      mirror: flip != variant.isOdd,
      turns: turnable ? (variant ~/ 2) % 4 : 0,
      rings: rings,
    );
  }

  static List<String> _namesFor(int b, int i) {
    List<String> pick(List<List<String>> list, int stride) =>
        list[(i * stride + b) % list.length];
    switch (b) {
      case 0: // Master Shapes
        return [geometry[i % geometry.length]];
      case 1: // Complex Patterns
        return [patterns[(i * 5) % patterns.length]];
      case 2:
        return i < 34 ? pick(_naturePairs, 7) : pick(_natureTrios, 3);
      case 3:
        return i < 25 ? pick(_animalPairs, 7) : pick(_animalTrios, 3);
      case 4:
        return i < 25 ? pick(_objectPairs, 7) : pick(_objectTrios, 3);
      case 5:
        return i < 20 ? pick(_landmarkPairs, 7) : pick(_landmarkTrios, 3);
      case 6: // Multi-Shape Puzzles
        return i < 40 ? pick(_multiTrios, 3) : pick(_multiQuads, 3);
      case 7: // Expert: object + geometry + pattern, pairs and trios
        final a = _objects[(i * 7 + 3) % _objects.length];
        final p = patterns[(i * 5 + 2) % patterns.length];
        if (i % 3 == 0) return _distinct([a, p], i);
        return _distinct([a, geometry[(i * 3 + 1) % geometry.length], p], i);
      case 8: // Master: trios and four-shape boards
        final a = _objects[(i * 11 + 5) % _objects.length];
        final c = _objects[(i * 13 + 17) % _objects.length];
        final g = geometry[(i * 5 + 4) % geometry.length];
        if (i.isEven) return _distinct([a, c, g], i);
        return _distinct([a, c, g, patterns[(i * 7 + 1) % patterns.length]], i);
      default: // Ultimate: four-shape boards
        final a = _objects[(i * 17 + 9) % _objects.length];
        final c = _objects[(i * 19 + 23) % _objects.length];
        final g = geometry[(i * 7 + 2) % geometry.length];
        final p = patterns[(i * 3 + 6) % patterns.length];
        return _distinct([a, p, c, g], i);
    }
  }

  /// Replaces repeated names with the next unused object.
  static List<String> _distinct(List<String> names, int i) {
    final out = <String>[];
    var k = i;
    for (final n in names) {
      var name = n;
      while (out.any((o) => o.toLowerCase() == name.toLowerCase())) {
        name = _objects[k++ % _objects.length];
      }
      out.add(name);
    }
    return out;
  }
}
