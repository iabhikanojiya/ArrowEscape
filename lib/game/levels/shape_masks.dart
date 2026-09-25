import 'dart:math' as math;

import '../../models/puzzle_path.dart';

/// Provides filled silhouette masks for each recognizable shape.
/// Mask is a set of grid cells that should ideally be occupied by puzzle paths
/// to form the visual shape. Generator will constrain placements to this mask
/// to ensure shape recognizability while still allowing difficulty via
/// blocking relationships.
class ShapeMasks {
  static Set<GridPoint> maskForShape(String shapeName, int gridSize) {
    final norm = shapeName.toLowerCase().trim();
    switch (norm) {
      // W1 Basic
      case 'triangle':
        return _triangleMask(gridSize);
      case 'square':
        return _squareMask(gridSize);
      case 'rectangle':
        return _rectangleMask(gridSize);
      case 'circle':
        return _circleMask(gridSize, radiusFactor: 0.35);
      case 'diamond':
        return _diamondMask(gridSize, radius: (gridSize * 0.35).toInt());
      case 'octagon':
        return _regularPolygonMask(gridSize, sides: 8);
      case 'pentagon':
        return _regularPolygonMask(gridSize, sides: 5);
      case 'hexagon':
        return _regularPolygonMask(gridSize, sides: 6);
      case 'star':
        return _starMask(gridSize);
      case 'heart':
        return _heartMask(gridSize);
      case 'cross':
        return _crossMask(gridSize);
      case 'spiral':
        return _spiralMask(gridSize);
      case 'wave':
        return _waveMask(gridSize);
      case 'zigzag':
        return _zigzagMask(gridSize);
      case 'honeycomb':
        return _honeycombMask(gridSize);
      case 'checkerboard':
        return _checkerboardMask(gridSize);
      case 'concentric circles':
        return _concentricCirclesMask(gridSize);
      case 'concentric squares':
        return _concentricSquaresMask(gridSize);
      // W2 Complex
      case 'crescent':
        return _crescentMask(gridSize);
      case 'ring':
        return _ringMask(gridSize);
      case 'plus':
        return _plusMask(gridSize);
      case 'arrow':
        return _arrowMask(gridSize);
      case 'lightning':
        return _lightningMask(gridSize);
      case 'crown':
        return _crownMask(gridSize);
      case 'parallelogram':
        return _parallelogramMask(gridSize);
      case 'trapezoid':
        return _trapezoidMask(gridSize);
      case 'gear':
        return _gearMask(gridSize);
      case 'infinity':
        return _infinityMask(gridSize);
      // W3 Nature
      case 'flower':
        return _flowerMask(gridSize);
      case 'leaf':
        return _leafMask(gridSize);
      case 'tree':
        return _treeMask(gridSize);
      case 'sun':
        return _sunMask(gridSize);
      case 'cloud':
        return _cloudMask(gridSize);
      case 'mushroom':
        return _mushroomMask(gridSize);
      case 'butterfly':
        return _butterflyMask(gridSize);
      case 'fish':
        return _fishMask(gridSize);
      case 'bird':
        return _birdMask(gridSize);
      case 'apple':
        return _appleMask(gridSize);
      case 'cherry':
        return _cherryMask(gridSize);
      case 'cactus':
        return _cactusMask(gridSize);
      case 'palm':
        return _palmMask(gridSize);
      case 'rainbow':
        return _rainbowMask(gridSize);
      case 'mountain':
        return _mountainMask(gridSize);
      // W4 Animals
      case 'cat':
        return _catMask(gridSize);
      case 'dog':
        return _dogMask(gridSize);
      case 'rabbit':
        return _rabbitMask(gridSize);
      case 'elephant':
        return _elephantMask(gridSize);
      case 'turtle':
        return _turtleMask(gridSize);
      case 'owl':
        return _owlMask(gridSize);
      case 'fox':
        return _foxMask(gridSize);
      case 'bear':
        return _bearMask(gridSize);
      case 'penguin':
        return _penguinMask(gridSize);
      case 'whale':
        return _whaleMask(gridSize);
      case 'crab':
        return _crabMask(gridSize);
      case 'frog':
        return _frogMask(gridSize);
      case 'monkey':
        return _monkeyMask(gridSize);
      case 'lion':
        return _lionMask(gridSize);
      case 'giraffe':
        return _giraffeMask(gridSize);
      case 'zebra':
        return _zebraMask(gridSize);
      case 'kangaroo':
        return _kangarooMask(gridSize);
      case 'dolphin':
        return _dolphinMask(gridSize);
      case 'octopus':
        return _octopusMask(gridSize);
      case 'dinosaur':
        return _dinosaurMask(gridSize);
      // W5 Objects
      case 'house':
      case 'small house':
        return _houseMask(gridSize);
      case 'car':
        return _carMask(gridSize);
      case 'rocket':
        return _rocketMask(gridSize);
      case 'boat':
        return _boatMask(gridSize);
      case 'airplane':
        return _airplaneMask(gridSize);
      case 'camera':
        return _cameraMask(gridSize);
      case 'gift':
      case 'gift box':
        return _giftMask(gridSize);
      case 'key':
        return _keyMask(gridSize);
      case 'lock':
        return _lockMask(gridSize);
      case 'trophy':
      case 'star trophy':
        return _trophyMask(gridSize);
      case 'umbrella':
        return _umbrellaMask(gridSize);
      case 'bell':
        return _bellMask(gridSize);
      case 'chair':
        return _chairMask(gridSize);
      case 'lamp':
        return _lampMask(gridSize);
      case 'bicycle':
        return _bicycleMask(gridSize);
      case 'guitar':
        return _guitarMask(gridSize);
      case 'cup':
        return _cupMask(gridSize);
      case 'diamond gem':
        return _diamondMask(gridSize, radius: (gridSize * 0.30).toInt());
      case 'castle toy':
        return _castleMask(gridSize, small: true);
      // W6 Buildings
      case 'lighthouse':
        return _lighthouseMask(gridSize);
      case 'windmill':
        return _windmillMask(gridSize);
      case 'castle':
        return _castleMask(gridSize);
      case 'tower':
        return _towerMask(gridSize);
      case 'bridge':
        return _bridgeMask(gridSize);
      case 'temple':
        return _templeMask(gridSize);
      case 'skyline':
      case 'city skyline':
        return _skylineMask(gridSize);
      case 'pyramid':
        return _pyramidMask(gridSize);
      case 'pagoda':
        return _pagodaMask(gridSize);
      case 'church':
        return _churchMask(gridSize);
      case 'factory':
        return _factoryMask(gridSize);
      case 'stadium':
        return _stadiumMask(gridSize);
      case 'fort':
        return _fortMask(gridSize);
      case 'gate':
        return _gateMask(gridSize);
      case 'well':
        return _wellMask(gridSize);
      case 'mill':
        return _millMask(gridSize);
      case 'mansion':
        return _mansionMask(gridSize);
      case 'cottage':
        return _cottageMask(gridSize);
      case 'palace':
        return _palaceMask(gridSize);
      // W7 Expert
      case 'flower garden':
        return _flowerGardenMask(gridSize);
      case 'animal parade':
        return _animalParadeMask(gridSize);
      case 'city complex':
        return _cityComplexMask(gridSize);
      case 'mechanical gear':
        return _gearMask(gridSize);
      case 'interlock labyrinth':
        return _labyrinthMask(gridSize);
      case 'double spiral':
        return _doubleSpiralMask(gridSize);
      case 'mandala':
        return _mandalaMask(gridSize);
      case 'constellation':
        return _constellationMask(gridSize);
      case 'dragon':
        return _dragonMask(gridSize);
      case 'phoenix':
        return _phoenixMask(gridSize);
      case 'galaxy':
        return _galaxyMask(gridSize);
      case 'crystal palace':
        return _crystalPalaceMask(gridSize);
      case 'jungle':
        return _jungleMask(gridSize);
      case 'ocean world':
        return _oceanMask(gridSize);
      case 'space station':
        return _spaceStationMask(gridSize);
      case 'ancient temple':
        return _templeMask(gridSize);
      case 'futuristic city':
        return _futuristicCityMask(gridSize);
      case 'dream catcher':
        return _dreamCatcherMask(gridSize);
      case 'kaleidoscope':
        return _kaleidoscopeMask(gridSize);
      case 'infinity maze':
        return _infinityMask(gridSize);
      default:
        // Fallback hash-based blob for unknown shapes - deterministic per name
        return _hashBlobMask(shapeName, gridSize);
    }
  }

  // ============ Primitive helpers ============

  static bool _insidePolygon(GridPoint p, List<math.Point<double>> poly) {
    // Ray casting
    final x = p.x + 0.5;
    final y = p.y + 0.5;
    bool inside = false;
    for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final xi = poly[i].x, yi = poly[i].y;
      final xj = poly[j].x, yj = poly[j].y;
      final intersect =
          ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  static Set<GridPoint> _polygonMask(
    int gridSize,
    List<math.Point<double>> vertices,
  ) {
    final set = <GridPoint>{};
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (_insidePolygon(GridPoint(x, y), vertices)) set.add(GridPoint(x, y));
      }
    }
    return set;
  }

  static Set<GridPoint> _circleMask(
    int gridSize, {
    required double radiusFactor,
    math.Point<double>? center,
  }) {
    final c = center ?? math.Point(gridSize / 2, gridSize / 2);
    final r = gridSize * radiusFactor;
    final set = <GridPoint>{};
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final dx = x + 0.5 - c.x;
        final dy = y + 0.5 - c.y;
        if (dx * dx + dy * dy <= r * r) set.add(GridPoint(x, y));
      }
    }
    return set;
  }

  // ============ Basic geometric ============

  static Set<GridPoint> _triangleMask(int n) {
    final cx = n / 2;
    final vertices = [
      math.Point(cx, 1.0),
      math.Point(1.0, n - 1.5),
      math.Point(n - 1.0, n - 1.5),
    ];
    return _polygonMask(n, vertices);
  }

  static Set<GridPoint> _squareMask(int n) {
    final pad = (n * 0.18).floor();
    final vertices = [
      math.Point(pad.toDouble(), pad.toDouble()),
      math.Point((n - pad).toDouble(), pad.toDouble()),
      math.Point((n - pad).toDouble(), (n - pad).toDouble()),
      math.Point(pad.toDouble(), (n - pad).toDouble()),
    ];
    return _polygonMask(n, vertices);
  }

  static Set<GridPoint> _rectangleMask(int n) {
    final padx = (n * 0.15).floor();
    final pady = (n * 0.28).floor();
    final vertices = [
      math.Point(padx.toDouble(), pady.toDouble()),
      math.Point((n - padx).toDouble(), pady.toDouble()),
      math.Point((n - padx).toDouble(), (n - pady).toDouble()),
      math.Point(padx.toDouble(), (n - pady).toDouble()),
    ];
    return _polygonMask(n, vertices);
  }

  static Set<GridPoint> _diamondMask(int n, {required int radius}) {
    final cx = n ~/ 2;
    final cy = n ~/ 2;
    final set = <GridPoint>{};
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        if ((x - cx).abs() + (y - cy).abs() <= radius) set.add(GridPoint(x, y));
      }
    }
    return set;
  }

  static Set<GridPoint> _regularPolygonMask(int n, {required int sides}) {
    final cx = n / 2;
    final cy = n / 2;
    final r = n * 0.36;
    final vertices = <math.Point<double>>[];
    for (int i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / sides;
      vertices.add(
        math.Point(cx + r * math.cos(angle), cy + r * math.sin(angle)),
      );
    }
    return _polygonMask(n, vertices);
  }

  static Set<GridPoint> _starMask(int n) {
    final cx = n / 2;
    final cy = n / 2;
    final outer = n * 0.42;
    final inner = n * 0.18;
    final vertices = <math.Point<double>>[];
    for (int i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final rad = i.isEven ? outer : inner;
      vertices.add(
        math.Point(cx + rad * math.cos(angle), cy + rad * math.sin(angle)),
      );
    }
    return _polygonMask(n, vertices);
  }

  static Set<GridPoint> _heartMask(int n) {
    final cx = n / 2;
    final cy = n / 2 + 0.8;
    final r = n * 0.28;
    final set = <GridPoint>{};
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        final nx = (x + 0.5 - cx) / r;
        final ny = (cy - (y + 0.5)) / r; // flip y so heart upright
        // heart equation
        final a = nx * nx + ny * ny - 1;
        final v = a * a * a - nx * nx * ny * ny * ny;
        if (v <= 0.08) set.add(GridPoint(x, y));
      }
    }
    if (set.isEmpty) return _circleMask(n, radiusFactor: 0.3);
    return set;
  }

  static Set<GridPoint> _crossMask(int n) {
    final set = <GridPoint>{};
    final w = (n * 0.28).floor().clamp(2, 4);
    final cx = n ~/ 2;
    final cy = n ~/ 2;
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        if ((x - cx).abs() <= w ~/ 2 || (y - cy).abs() <= w ~/ 2) {
          // limit to cross length 70%
          if ((x - cx).abs() <= n * 0.35 || (y - cy).abs() <= n * 0.35) {
            set.add(GridPoint(x, y));
          }
        }
      }
    }
    return set;
  }

  static Set<GridPoint> _spiralMask(int n) {
    // Spiral as thick path winding: approximate by filling grid then carving spiral corridor 2 cells wide
    final set = <GridPoint>{};
    // Create spiral corridor using walk
    int x = n ~/ 2, y = n ~/ 2;
    int dx = 1, dy = 0;
    int steps = 1, stepCount = 0, turnCount = 0;
    for (int i = 0; i < n * n * 2; i++) {
      if (x >= 0 && x < n && y >= 0 && y < n) set.add(GridPoint(x, y));
      // also add width
      if (x + 1 >= 0 && x + 1 < n) set.add(GridPoint(x + 1, y));
      x += dx;
      y += dy;
      stepCount++;
      if (stepCount == steps) {
        stepCount = 0;
        final tmp = dx;
        dx = -dy;
        dy = tmp;
        turnCount++;
        if (turnCount % 2 == 0) steps++;
        if (steps > n) break;
      }
      if (x < -1 || x > n || y < -1 || y > n) break;
    }
    // Ensure at least central area
    if (set.length < n * 2) return _circleMask(n, radiusFactor: 0.32);
    return set;
  }

  static Set<GridPoint> _waveMask(int n) {
    // Repeating horizontal sine bands (orthogonal stepped waves).
    final set = <GridPoint>{};
    const periods = 2.0;
    for (int x = 1; x < n - 1; x++) {
      final wave =
          (n * 0.16) * math.sin(periods * 2 * math.pi * (x - 1) / (n - 2));
      for (final band in [-1, 0, 1]) {
        final cy = (n / 2 + band * n * 0.26 + wave).round();
        for (int dy = -1; dy <= 1; dy++) {
          final y = cy + dy;
          if (x >= 1 && x < n - 1 && y >= 1 && y < n - 1) {
            set.add(GridPoint(x, y));
          }
        }
      }
    }
    if (set.length < n * 4) return _circleMask(n, radiusFactor: 0.32);
    return set;
  }

  static Set<GridPoint> _zigzagMask(int n) {
    // Repeating chevron (zigzag) bands.
    final set = <GridPoint>{};
    const teeth = 3;
    for (int x = 1; x < n - 1; x++) {
      final tri = ((x - 1) * teeth * 2 / (n - 2)) % 2;
      final zag = tri < 1 ? tri : 2 - tri; // 0..1..0
      for (final band in [-1, 0, 1]) {
        final cy = (n / 2 + band * n * 0.26 + (zag - 0.5) * n * 0.22).round();
        for (int dy = -1; dy <= 1; dy++) {
          final y = cy + dy;
          if (x >= 1 && x < n - 1 && y >= 1 && y < n - 1) {
            set.add(GridPoint(x, y));
          }
        }
      }
    }
    if (set.length < n * 4) return _circleMask(n, radiusFactor: 0.32);
    return set;
  }

  static Set<GridPoint> _honeycombMask(int n) {
    // Cluster of small filled hexagons with 1px gaps (4-connected).
    final set = <GridPoint>{};
    final r = math.max(2, (n * 0.14).round());
    final stepX = (r * 2) + 1;
    final stepY = (r * 2);
    int row = 0;
    for (int cy = 2 + r; cy < n - 1; cy += stepY, row++) {
      for (int cx = 2 + r + (row.isOdd ? stepX ~/ 2 : 0);
          cx < n - 1;
          cx += stepX) {
        for (int y = 0; y < n; y++) {
          for (int x = 0; x < n; x++) {
            final dx = (x - cx).abs();
            final dy = (y - cy).abs();
            // Pointy-top filled hexagon approximation (4-connected).
            if (dx + (dy ~/ 2) <= r && dy <= r + 1) {
              if (x >= 1 && x < n - 1 && y >= 1 && y < n - 1) {
                set.add(GridPoint(x, y));
              }
            }
          }
        }
      }
    }
    if (set.length < n * 3) return _circleMask(n, radiusFactor: 0.32);
    return set;
  }

  static Set<GridPoint> _checkerboardMask(int n) {
    // Woven checkerboard of filled blocks with 1px gaps.
    final set = <GridPoint>{};
    const blocks = 3;
    final usable = n - 2;
    final pitch = usable ~/ blocks;
    final size = pitch - 1;
    for (int by = 0; by < blocks; by++) {
      for (int bx = 0; bx < blocks; bx++) {
        for (int dy = 0; dy < size; dy++) {
          for (int dx = 0; dx < size; dx++) {
            final x = 1 + bx * pitch + dx;
            final y = 1 + by * pitch + dy;
            if (x < n - 1 && y < n - 1) set.add(GridPoint(x, y));
          }
        }
      }
    }
    if (set.isEmpty) return _circleMask(n, radiusFactor: 0.32);
    return set;
  }

  static Set<GridPoint> _concentricCirclesMask(int n) {
    final set = <GridPoint>{};
    final c = n / 2;
    final radii = [n * 0.40, n * 0.26, n * 0.10];
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        final d = math.sqrt(
          (x + 0.5 - c) * (x + 0.5 - c) + (y + 0.5 - c) * (y + 0.5 - c),
        );
        for (final r in radii) {
          if ((d - r).abs() <= 1.0) {
            if (x >= 1 && x < n - 1 && y >= 1 && y < n - 1) {
              set.add(GridPoint(x, y));
            }
          }
        }
      }
    }
    if (set.length < n * 3) return _circleMask(n, radiusFactor: 0.32);
    return set;
  }

  static Set<GridPoint> _concentricSquaresMask(int n) {
    final set = <GridPoint>{};
    final bounds = [
      [1, n - 2],
      [3, n - 4],
    ];
    for (final b in bounds) {
      final x0 = b[0], x1 = b[1];
      for (int x = x0; x <= x1; x++) {
        for (int y = x0; y <= x1; y++) {
          if (x - x0 < 2 || x1 - x < 2 || y - x0 < 2 || x1 - y < 2) {
            set.add(GridPoint(x, y));
          }
        }
      }
    }
    // Center block.
    final c0 = n ~/ 2 - 1;
    for (int y = c0; y <= c0 + 2; y++) {
      for (int x = c0; x <= c0 + 2; x++) {
        set.add(GridPoint(x, y));
      }
    }
    if (set.length < n * 3) return _circleMask(n, radiusFactor: 0.32);
    return set;
  }

  // ============ Complex geometric ============

  static Set<GridPoint> _crescentMask(int n) {
    final outer = _circleMask(
      n,
      radiusFactor: 0.38,
      center: math.Point(n / 2 - 0.6, n / 2),
    );
    final inner = _circleMask(
      n,
      radiusFactor: 0.32,
      center: math.Point(n / 2 + 1.2, n / 2),
    );
    outer.removeAll(inner);
    return outer;
  }

  static Set<GridPoint> _ringMask(int n) {
    final outer = _circleMask(n, radiusFactor: 0.40);
    final inner = _circleMask(n, radiusFactor: 0.22);
    outer.removeAll(inner);
    if (outer.isEmpty) return _circleMask(n, radiusFactor: 0.35);
    return outer;
  }

  static Set<GridPoint> _plusMask(int n) => _crossMask(n);

  static Set<GridPoint> _arrowMask(int n) {
    final set = <GridPoint>{};
    final cx = n ~/ 2;
    // shaft vertical
    for (int y = 1; y < n - 2; y++) {
      for (int x = cx - 1; x <= cx + 1; x++) {
        if (x >= 0 && x < n) set.add(GridPoint(x, y));
      }
    }
    // head triangle at top
    for (int y = 0; y < 3; y++) {
      final w = y;
      for (int x = cx - w; x <= cx + w; x++) {
        if (x >= 0 && x < n && y < n) set.add(GridPoint(x, y));
      }
    }
    return set;
  }

  static Set<GridPoint> _lightningMask(int n) {
    final vertices = [
      math.Point(n * 0.55, 0.5),
      math.Point(n * 0.35, n * 0.45),
      math.Point(n * 0.55, n * 0.50),
      math.Point(n * 0.30, n - 0.5),
      math.Point(n * 0.70, n * 0.55),
      math.Point(n * 0.45, n * 0.50),
      math.Point(n * 0.65, 2.0),
    ];
    return _polygonMask(n, vertices);
  }

  static Set<GridPoint> _crownMask(int n) {
    final set = <GridPoint>{};
    // base rectangle
    for (int y = (n * 0.62).floor(); y < n - 1; y++) {
      for (int x = 1; x < n - 1; x++) {
        set.add(GridPoint(x, y));
      }
    }
    // three peaks
    final peaks = [
      [n * 0.18, n * 0.30, n * 0.35, n * 0.60],
      [n * 0.42, n * 0.15, n * 0.58, n * 0.60],
      [n * 0.65, n * 0.30, n * 0.82, n * 0.60],
    ];
    for (final p in peaks) {
      final poly = [
        math.Point(p[0], p[1]),
        math.Point((p[0] + p[2]) / 2, p[3]),
        math.Point(p[2], p[1]),
      ];
      for (int y = 0; y < n; y++) {
        for (int x = 0; x < n; x++) {
          if (_insidePolygon(GridPoint(x, y), poly)) set.add(GridPoint(x, y));
        }
      }
    }
    return set;
  }

  static Set<GridPoint> _parallelogramMask(int n) {
    final dx = (n * 0.18).floor();
    final vertices = [
      math.Point(1.0 + dx, 2.0),
      math.Point(n - 1.0, 2.0),
      math.Point(n - 1.0 - dx, n - 2.0),
      math.Point(1.0, n - 2.0),
    ];
    return _polygonMask(n, vertices);
  }

  static Set<GridPoint> _trapezoidMask(int n) {
    final vertices = [
      math.Point(n * 0.25, 2.0),
      math.Point(n * 0.75, 2.0),
      math.Point(n - 1.0, n - 2.0),
      math.Point(1.0, n - 2.0),
    ];
    return _polygonMask(n, vertices);
  }

  static Set<GridPoint> _gearMask(int n) {
    final base = _circleMask(n, radiusFactor: 0.32);
    // add teeth as small squares at cardinal + diagonal
    final teeth = [
      GridPoint(n ~/ 2, 1),
      GridPoint(n ~/ 2, n - 2),
      GridPoint(1, n ~/ 2),
      GridPoint(n - 2, n ~/ 2),
      GridPoint(2, 2),
      GridPoint(n - 3, 2),
      GridPoint(2, n - 3),
      GridPoint(n - 3, n - 3),
    ];
    for (final t in teeth) {
      for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
          final x = t.x + dx, y = t.y + dy;
          if (x >= 0 && x < n && y >= 0 && y < n) base.add(GridPoint(x, y));
        }
      }
    }
    // hole
    final inner = _circleMask(n, radiusFactor: 0.12);
    base.removeAll(inner);
    return base;
  }

  static Set<GridPoint> _infinityMask(int n) {
    final left = _circleMask(
      n,
      radiusFactor: 0.22,
      center: math.Point(n * 0.32, n / 2),
    );
    final right = _circleMask(
      n,
      radiusFactor: 0.22,
      center: math.Point(n * 0.68, n / 2),
    );
    final set = {...left, ...right};
    // remove inner holes to make outline
    final leftHole = _circleMask(
      n,
      radiusFactor: 0.10,
      center: math.Point(n * 0.32, n / 2),
    );
    final rightHole = _circleMask(
      n,
      radiusFactor: 0.10,
      center: math.Point(n * 0.68, n / 2),
    );
    set.removeAll(leftHole);
    set.removeAll(rightHole);
    // bridge
    for (int x = (n * 0.32).floor(); x <= (n * 0.68).floor(); x++) {
      set.add(GridPoint(x, n ~/ 2));
      set.add(GridPoint(x, n ~/ 2 + 1));
    }
    return set;
  }

  // ============ Nature ============

  static Set<GridPoint> _flowerMask(int n) {
    final center = _circleMask(
      n,
      radiusFactor: 0.12,
      center: math.Point(n / 2, n / 2 - 0.5),
    );
    final petals = <GridPoint>{};
    final petalCenters = [
      math.Point(n / 2, n * 0.22),
      math.Point(n * 0.78, n * 0.35),
      math.Point(n * 0.74, n * 0.64),
      math.Point(n * 0.26, n * 0.64),
      math.Point(n * 0.22, n * 0.35),
    ];
    for (final c in petalCenters) {
      petals.addAll(_circleMask(n, radiusFactor: 0.16, center: c));
    }
    final stem = <GridPoint>{};
    for (int y = (n * 0.58).floor(); y < n - 1; y++) {
      stem.add(GridPoint(n ~/ 2, y));
      stem.add(GridPoint(n ~/ 2 + 1, y));
    }
    final leaves =
        _circleMask(
          n,
          radiusFactor: 0.11,
          center: math.Point(n * 0.34, n * 0.70),
        )..addAll(
          _circleMask(
            n,
            radiusFactor: 0.11,
            center: math.Point(n * 0.66, n * 0.72),
          ),
        );
    return {...center, ...petals, ...stem, ...leaves};
  }

  static Set<GridPoint> _leafMask(int n) {
    final vertices = [
      math.Point(n * 0.50, 0.8),
      math.Point(n * 0.78, n * 0.35),
      math.Point(n * 0.68, n * 0.78),
      math.Point(n * 0.50, n - 0.8),
      math.Point(n * 0.32, n * 0.78),
      math.Point(n * 0.22, n * 0.35),
    ];
    return _polygonMask(n, vertices);
  }

  static Set<GridPoint> _treeMask(int n) {
    final crown = _circleMask(
      n,
      radiusFactor: 0.34,
      center: math.Point(n / 2, n * 0.38),
    );
    final trunk = <GridPoint>{};
    for (int y = (n * 0.60).floor(); y < n - 1; y++) {
      trunk.add(GridPoint(n ~/ 2, y));
      trunk.add(GridPoint(n ~/ 2 + 1, y));
      trunk.add(GridPoint(n ~/ 2 - 1, y));
    }
    return {...crown, ...trunk};
  }

  static Set<GridPoint> _sunMask(int n) {
    final core = _circleMask(n, radiusFactor: 0.24);
    final rays = <GridPoint>{};
    final angles = [0, 45, 90, 135, 180, 225, 270, 315];
    for (final a in angles) {
      final rad = a * math.pi / 180;
      for (int r = (n * 0.30).floor(); r < (n * 0.48).floor(); r++) {
        final x = (n / 2 + r * math.cos(rad)).round();
        final y = (n / 2 + r * math.sin(rad)).round();
        if (x >= 0 && x < n && y >= 0 && y < n) {
          rays.add(GridPoint(x, y));
          if (x + 1 < n) rays.add(GridPoint(x + 1, y));
          if (y + 1 < n) rays.add(GridPoint(x, y + 1));
        }
      }
    }
    return {...core, ...rays};
  }

  static Set<GridPoint> _cloudMask(int n) {
    final c1 = _circleMask(
      n,
      radiusFactor: 0.18,
      center: math.Point(n * 0.30, n * 0.50),
    );
    final c2 = _circleMask(
      n,
      radiusFactor: 0.22,
      center: math.Point(n * 0.50, n * 0.42),
    );
    final c3 = _circleMask(
      n,
      radiusFactor: 0.20,
      center: math.Point(n * 0.68, n * 0.50),
    );
    final c4 = _circleMask(
      n,
      radiusFactor: 0.16,
      center: math.Point(n * 0.42, n * 0.62),
    );
    return {...c1, ...c2, ...c3, ...c4};
  }

  static Set<GridPoint> _mushroomMask(int n) {
    final cap = <GridPoint>{};
    final cx = n / 2;
    final cy = n * 0.42;
    final r = n * 0.34;
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        final dx = x + 0.5 - cx;
        final dy = y + 0.5 - cy;
        if (dx * dx + dy * dy <= r * r && y <= cy) cap.add(GridPoint(x, y));
      }
    }
    final stem = <GridPoint>{};
    for (int y = (n * 0.45).floor(); y < n - 1; y++) {
      for (int x = (n * 0.40).floor(); x <= (n * 0.60).floor(); x++) {
        stem.add(GridPoint(x, y));
      }
    }
    return {...cap, ...stem};
  }

  static Set<GridPoint> _butterflyMask(int n) {
    final leftWing = _diamondMask(n, radius: (n * 0.28).toInt());
    final rightWing = _diamondMask(n, radius: (n * 0.28).toInt());
    // shift wings
    final set = <GridPoint>{};
    for (final p in leftWing) {
      final nx = p.x - (n * 0.18).floor();
      if (nx >= 0) set.add(GridPoint(nx, p.y));
    }
    for (final p in rightWing) {
      final nx = p.x + (n * 0.18).floor();
      if (nx < n) set.add(GridPoint(nx, p.y));
    }
    // body
    for (int y = 1; y < n - 1; y++) {
      set.add(GridPoint(n ~/ 2, y));
      set.add(GridPoint(n ~/ 2 + 1, y));
    }
    // remove gap at center? keep
    return set;
  }

  static Set<GridPoint> _fishMask(int n) {
    final body = _circleMask(
      n,
      radiusFactor: 0.22,
      center: math.Point(n * 0.45, n / 2),
    );
    final tailPoly = [
      math.Point(n * 0.78, n * 0.28),
      math.Point(n * 0.68, n / 2),
      math.Point(n * 0.78, n * 0.72),
      math.Point(n * 0.92, n * 0.58),
      math.Point(n * 0.92, n * 0.42),
    ];
    final tail = _polygonMask(n, tailPoly);
    return {...body, ...tail};
  }

  static Set<GridPoint> _birdMask(int n) {
    final body = _circleMask(
      n,
      radiusFactor: 0.18,
      center: math.Point(n * 0.45, n * 0.55),
    );
    final wing = _polygonMask(n, [
      math.Point(n * 0.30, n * 0.32),
      math.Point(n * 0.70, n * 0.38),
      math.Point(n * 0.55, n * 0.60),
      math.Point(n * 0.25, n * 0.48),
    ]);
    final beak = _polygonMask(n, [
      math.Point(n * 0.65, n * 0.50),
      math.Point(n * 0.85, n * 0.55),
      math.Point(n * 0.65, n * 0.60),
    ]);
    return {...body, ...wing, ...beak};
  }

  static Set<GridPoint> _appleMask(int n) {
    final body = _circleMask(n, radiusFactor: 0.30);
    final stem = <GridPoint>{};
    for (int y = 1; y < 3; y++) {
      stem.add(GridPoint(n ~/ 2, y));
      stem.add(GridPoint(n ~/ 2 + 1, y));
    }
    final leaf = _circleMask(
      n,
      radiusFactor: 0.11,
      center: math.Point(n * 0.62, n * 0.28),
    );
    final set = {...body, ...stem, ...leaf};
    // bite
    final bite = _circleMask(
      n,
      radiusFactor: 0.12,
      center: math.Point(n * 0.72, n * 0.40),
    );
    set.removeAll(bite);
    return set;
  }

  static Set<GridPoint> _cherryMask(int n) {
    final c1 = _circleMask(
      n,
      radiusFactor: 0.18,
      center: math.Point(n * 0.35, n * 0.60),
    );
    final c2 = _circleMask(
      n,
      radiusFactor: 0.18,
      center: math.Point(n * 0.65, n * 0.60),
    );
    final stem = _polygonMask(n, [
      math.Point(n * 0.35, n * 0.42),
      math.Point(n * 0.50, 1.0),
      math.Point(n * 0.65, n * 0.42),
    ]);
    return {...c1, ...c2, ...stem};
  }

  static Set<GridPoint> _cactusMask(int n) {
    final main = <GridPoint>{};
    for (int y = (n * 0.25).floor(); y < n - 1; y++) {
      for (int x = (n * 0.42).floor(); x <= (n * 0.58).floor(); x++) {
        main.add(GridPoint(x, y));
      }
    }
    final leftArm = _polygonMask(n, [
      math.Point(n * 0.42, n * 0.40),
      math.Point(n * 0.22, n * 0.38),
      math.Point(n * 0.22, n * 0.62),
      math.Point(n * 0.42, n * 0.60),
    ]);
    final rightArm = _polygonMask(n, [
      math.Point(n * 0.58, n * 0.45),
      math.Point(n * 0.78, n * 0.43),
      math.Point(n * 0.78, n * 0.67),
      math.Point(n * 0.58, n * 0.65),
    ]);
    return {...main, ...leftArm, ...rightArm};
  }

  static Set<GridPoint> _palmMask(int n) {
    final trunk = <GridPoint>{};
    for (int y = (n * 0.45).floor(); y < n - 1; y++) {
      trunk.add(GridPoint(n ~/ 2, y));
      trunk.add(GridPoint(n ~/ 2 + 1, y));
    }
    final leaves = <GridPoint>{};
    final leafCenters = [
      math.Point(n * 0.50, n * 0.18),
      math.Point(n * 0.28, n * 0.30),
      math.Point(n * 0.72, n * 0.30),
      math.Point(n * 0.20, n * 0.42),
      math.Point(n * 0.80, n * 0.42),
    ];
    for (final c in leafCenters) {
      leaves.addAll(_circleMask(n, radiusFactor: 0.14, center: c));
    }
    return {...trunk, ...leaves};
  }

  static Set<GridPoint> _rainbowMask(int n) {
    final set = <GridPoint>{};
    final cx = n / 2;
    final cy = n * 0.78;
    for (int r = (n * 0.22).floor(); r < (n * 0.42).floor(); r += 2) {
      for (int angle = 180; angle <= 360; angle += 4) {
        final rad = angle * math.pi / 180;
        final x = (cx + r * math.cos(rad)).round();
        final y = (cy + r * math.sin(rad)).round();
        if (x >= 0 && x < n && y >= 0 && y < n) set.add(GridPoint(x, y));
      }
    }
    // thicken
    final thick = <GridPoint>{};
    for (final p in set) {
      for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
          final x = p.x + dx, y = p.y + dy;
          if (x >= 0 && x < n && y >= 0 && y < n) thick.add(GridPoint(x, y));
        }
      }
    }
    return thick;
  }

  static Set<GridPoint> _mountainMask(int n) {
    final vertices = [
      math.Point(n * 0.50, 1.0),
      math.Point(n - 1.0, n - 1.0),
      math.Point(1.0, n - 1.0),
    ];
    final main = _polygonMask(n, vertices);
    // second peak
    final peak2 = [
      math.Point(n * 0.28, n * 0.35),
      math.Point(n * 0.70, n * 0.48),
      math.Point(n * 0.15, n - 1.0),
    ];
    main.addAll(_polygonMask(n, peak2));
    return main;
  }

  // ============ Animals ============

  static Set<GridPoint> _catMask(int n) {
    // head triangle + ears
    final head = _circleMask(
      n,
      radiusFactor: 0.18,
      center: math.Point(n * 0.50, n * 0.32),
    );
    final earL = _polygonMask(n, [
      math.Point(n * 0.32, n * 0.22),
      math.Point(n * 0.40, n * 0.08),
      math.Point(n * 0.44, n * 0.22),
    ]);
    final earR = _polygonMask(n, [
      math.Point(n * 0.56, n * 0.22),
      math.Point(n * 0.60, n * 0.08),
      math.Point(n * 0.68, n * 0.22),
    ]);
    final body = _polygonMask(n, [
      math.Point(n * 0.32, n * 0.45),
      math.Point(n * 0.68, n * 0.45),
      math.Point(n * 0.62, n * 0.85),
      math.Point(n * 0.38, n * 0.85),
    ]);
    final tail = <GridPoint>{};
    for (int y = (n * 0.50).floor(); y < (n * 0.82).floor(); y++) {
      tail.add(GridPoint((n * 0.78).floor(), y));
      tail.add(GridPoint((n * 0.78).floor() + 1, y));
    }
    // curve tail top
    tail.addAll(
      _circleMask(
        n,
        radiusFactor: 0.08,
        center: math.Point(n * 0.78, n * 0.48),
      ),
    );
    return {...head, ...earL, ...earR, ...body, ...tail};
  }

  static Set<GridPoint> _dogMask(int n) {
    final head = _circleMask(
      n,
      radiusFactor: 0.17,
      center: math.Point(n * 0.42, n * 0.32),
    );
    final earL = _circleMask(
      n,
      radiusFactor: 0.09,
      center: math.Point(n * 0.26, n * 0.34),
    );
    final earR = _circleMask(
      n,
      radiusFactor: 0.09,
      center: math.Point(n * 0.58, n * 0.34),
    );
    final body = _polygonMask(n, [
      math.Point(n * 0.32, n * 0.48),
      math.Point(n * 0.68, n * 0.48),
      math.Point(n * 0.62, n * 0.86),
      math.Point(n * 0.38, n * 0.86),
    ]);
    final tail = _circleMask(
      n,
      radiusFactor: 0.07,
      center: math.Point(n * 0.72, n * 0.50),
    );
    return {...head, ...earL, ...earR, ...body, ...tail};
  }

  static Set<GridPoint> _rabbitMask(int n) {
    final head = _circleMask(
      n,
      radiusFactor: 0.16,
      center: math.Point(n * 0.50, n * 0.45),
    );
    final earL = <GridPoint>{};
    for (int y = 1; y < (n * 0.42).floor(); y++) {
      earL.add(GridPoint((n * 0.40).floor(), y));
      earL.add(GridPoint((n * 0.40).floor() + 1, y));
    }
    final earR = <GridPoint>{};
    for (int y = 1; y < (n * 0.42).floor(); y++) {
      earR.add(GridPoint((n * 0.60).floor(), y));
      earR.add(GridPoint((n * 0.60).floor() + 1, y));
    }
    final body = _circleMask(
      n,
      radiusFactor: 0.22,
      center: math.Point(n * 0.50, n * 0.72),
    );
    return {...head, ...earL, ...earR, ...body};
  }

  static Set<GridPoint> _elephantMask(int n) {
    final body = _circleMask(
      n,
      radiusFactor: 0.26,
      center: math.Point(n * 0.50, n * 0.62),
    );
    final head = _circleMask(
      n,
      radiusFactor: 0.16,
      center: math.Point(n * 0.34, n * 0.38),
    );
    final ear = _circleMask(
      n,
      radiusFactor: 0.14,
      center: math.Point(n * 0.26, n * 0.42),
    );
    final trunk = <GridPoint>{};
    for (int y = (n * 0.45).floor(); y < (n * 0.78).floor(); y++) {
      trunk.add(GridPoint((n * 0.30).floor(), y));
      trunk.add(GridPoint((n * 0.30).floor() + 1, y));
    }
    return {...body, ...head, ...ear, ...trunk};
  }

  static Set<GridPoint> _turtleMask(int n) {
    final shell = _circleMask(
      n,
      radiusFactor: 0.30,
      center: math.Point(n * 0.50, n * 0.58),
    );
    final head = _circleMask(
      n,
      radiusFactor: 0.11,
      center: math.Point(n * 0.50, n * 0.22),
    );
    final leg1 = _circleMask(
      n,
      radiusFactor: 0.09,
      center: math.Point(n * 0.28, n * 0.68),
    );
    final leg2 = _circleMask(
      n,
      radiusFactor: 0.09,
      center: math.Point(n * 0.72, n * 0.68),
    );
    final leg3 = _circleMask(
      n,
      radiusFactor: 0.09,
      center: math.Point(n * 0.30, n * 0.82),
    );
    final leg4 = _circleMask(
      n,
      radiusFactor: 0.09,
      center: math.Point(n * 0.70, n * 0.82),
    );
    return {...shell, ...head, ...leg1, ...leg2, ...leg3, ...leg4};
  }

  static Set<GridPoint> _owlMask(int n) {
    final body = _circleMask(
      n,
      radiusFactor: 0.28,
      center: math.Point(n * 0.50, n * 0.58),
    );
    final earL = _polygonMask(n, [
      math.Point(n * 0.28, n * 0.22),
      math.Point(n * 0.34, n * 0.08),
      math.Point(n * 0.40, n * 0.22),
    ]);
    final earR = _polygonMask(n, [
      math.Point(n * 0.60, n * 0.22),
      math.Point(n * 0.66, n * 0.08),
      math.Point(n * 0.72, n * 0.22),
    ]);
    final eyes =
        _circleMask(
          n,
          radiusFactor: 0.08,
          center: math.Point(n * 0.40, n * 0.38),
        )..addAll(
          _circleMask(
            n,
            radiusFactor: 0.08,
            center: math.Point(n * 0.60, n * 0.38),
          ),
        );
    return {...body, ...earL, ...earR, ...eyes};
  }

  static Set<GridPoint> _foxMask(int n) => _catMask(n); // reuse cat with tweak
  static Set<GridPoint> _bearMask(int n) => _dogMask(n);
  static Set<GridPoint> _penguinMask(int n) {
    final body = _circleMask(
      n,
      radiusFactor: 0.24,
      center: math.Point(n * 0.50, n * 0.60),
    );
    final head = _circleMask(
      n,
      radiusFactor: 0.14,
      center: math.Point(n * 0.50, n * 0.30),
    );
    return {...body, ...head};
  }

  static Set<GridPoint> _whaleMask(int n) => _fishMask(n);
  static Set<GridPoint> _crabMask(int n) {
    final body = _circleMask(
      n,
      radiusFactor: 0.20,
      center: math.Point(n * 0.50, n * 0.58),
    );
    final clawL = _circleMask(
      n,
      radiusFactor: 0.10,
      center: math.Point(n * 0.22, n * 0.40),
    );
    final clawR = _circleMask(
      n,
      radiusFactor: 0.10,
      center: math.Point(n * 0.78, n * 0.40),
    );
    return {...body, ...clawL, ...clawR};
  }

  static Set<GridPoint> _frogMask(int n) {
    final body = _circleMask(
      n,
      radiusFactor: 0.24,
      center: math.Point(n * 0.50, n * 0.62),
    );
    final eyeL = _circleMask(
      n,
      radiusFactor: 0.08,
      center: math.Point(n * 0.36, n * 0.38),
    );
    final eyeR = _circleMask(
      n,
      radiusFactor: 0.08,
      center: math.Point(n * 0.64, n * 0.38),
    );
    final leg =
        _circleMask(
          n,
          radiusFactor: 0.10,
          center: math.Point(n * 0.30, n * 0.78),
        )..addAll(
          _circleMask(
            n,
            radiusFactor: 0.10,
            center: math.Point(n * 0.70, n * 0.78),
          ),
        );
    return {...body, ...eyeL, ...eyeR, ...leg};
  }

  static Set<GridPoint> _monkeyMask(int n) {
    final head = _circleMask(
      n,
      radiusFactor: 0.16,
      center: math.Point(n * 0.50, n * 0.34),
    );
    final earL = _circleMask(
      n,
      radiusFactor: 0.08,
      center: math.Point(n * 0.32, n * 0.36),
    );
    final earR = _circleMask(
      n,
      radiusFactor: 0.08,
      center: math.Point(n * 0.68, n * 0.36),
    );
    final body = _circleMask(
      n,
      radiusFactor: 0.20,
      center: math.Point(n * 0.50, n * 0.66),
    );
    final tail = _circleMask(
      n,
      radiusFactor: 0.07,
      center: math.Point(n * 0.74, n * 0.70),
    );
    return {...head, ...earL, ...earR, ...body, ...tail};
  }

  static Set<GridPoint> _lionMask(int n) {
    final head = _circleMask(
      n,
      radiusFactor: 0.18,
      center: math.Point(n * 0.50, n * 0.36),
    );
    final mane = _circleMask(
      n,
      radiusFactor: 0.26,
      center: math.Point(n * 0.50, n * 0.36),
    );
    mane.removeAll(head);
    final body = _circleMask(
      n,
      radiusFactor: 0.20,
      center: math.Point(n * 0.50, n * 0.68),
    );
    return {...mane, ...head, ...body};
  }

  static Set<GridPoint> _giraffeMask(int n) {
    final body = _circleMask(
      n,
      radiusFactor: 0.18,
      center: math.Point(n * 0.50, n * 0.72),
    );
    final neck = <GridPoint>{};
    for (int y = (n * 0.28).floor(); y < (n * 0.60).floor(); y++) {
      neck.add(GridPoint(n ~/ 2, y));
      neck.add(GridPoint(n ~/ 2 + 1, y));
    }
    final head = _circleMask(
      n,
      radiusFactor: 0.11,
      center: math.Point(n * 0.50, n * 0.22),
    );
    return {...body, ...neck, ...head};
  }

  static Set<GridPoint> _zebraMask(int n) => _giraffeMask(n);
  static Set<GridPoint> _kangarooMask(int n) {
    final body = _circleMask(
      n,
      radiusFactor: 0.20,
      center: math.Point(n * 0.50, n * 0.65),
    );
    final head = _circleMask(
      n,
      radiusFactor: 0.12,
      center: math.Point(n * 0.50, n * 0.34),
    );
    final tail = _polygonMask(n, [
      math.Point(n * 0.65, n * 0.65),
      math.Point(n * 0.88, n * 0.72),
      math.Point(n * 0.70, n * 0.80),
    ]);
    return {...body, ...head, ...tail};
  }

  static Set<GridPoint> _dolphinMask(int n) => _fishMask(n);
  static Set<GridPoint> _octopusMask(int n) {
    final head = _circleMask(
      n,
      radiusFactor: 0.20,
      center: math.Point(n * 0.50, n * 0.34),
    );
    final tentacles = <GridPoint>{};
    for (int x = 2; x < n - 2; x += 2) {
      for (int y = (n * 0.52).floor(); y < n - 1; y++) {
        if ((x - n ~/ 2).abs() < n * 0.30) tentacles.add(GridPoint(x, y));
      }
    }
    return {...head, ...tentacles};
  }

  static Set<GridPoint> _dinosaurMask(int n) {
    final body = _circleMask(
      n,
      radiusFactor: 0.22,
      center: math.Point(n * 0.52, n * 0.62),
    );
    final neck = <GridPoint>{};
    for (int y = (n * 0.30).floor(); y < (n * 0.60).floor(); y++) {
      neck.add(GridPoint((n * 0.32).floor(), y));
      neck.add(GridPoint((n * 0.32).floor() + 1, y));
    }
    final head = _circleMask(
      n,
      radiusFactor: 0.12,
      center: math.Point(n * 0.32, n * 0.24),
    );
    final tail = _polygonMask(n, [
      math.Point(n * 0.70, n * 0.58),
      math.Point(n * 0.92, n * 0.48),
      math.Point(n * 0.90, n * 0.70),
    ]);
    return {...body, ...neck, ...head, ...tail};
  }

  // ============ Objects ============

  static Set<GridPoint> _houseMask(int n) {
    final walls = <GridPoint>{};
    for (int y = (n * 0.42).floor(); y < n - 2; y++) {
      for (int x = 2; x < n - 2; x++) {
        walls.add(GridPoint(x, y));
      }
    }
    final roof = _polygonMask(n, [
      math.Point(1.0, n * 0.42),
      math.Point(n / 2, 0.5),
      math.Point(n - 1.0, n * 0.42),
    ]);
    final door = _polygonMask(n, [
      math.Point(n * 0.42, n * 0.62),
      math.Point(n * 0.58, n * 0.62),
      math.Point(n * 0.58, n - 2.0),
      math.Point(n * 0.42, n - 2.0),
    ]);
    walls.removeAll(door);
    return {...walls, ...roof};
  }

  static Set<GridPoint> _carMask(int n) {
    final body = <GridPoint>{};
    for (int y = (n * 0.42).floor(); y < (n * 0.78).floor(); y++) {
      for (int x = 1; x < n - 1; x++) {
        body.add(GridPoint(x, y));
      }
    }
    final cabin = _polygonMask(n, [
      math.Point(n * 0.28, n * 0.42),
      math.Point(n * 0.68, n * 0.42),
      math.Point(n * 0.62, n * 0.28),
      math.Point(n * 0.34, n * 0.28),
    ]);
    final wheel1 = _circleMask(
      n,
      radiusFactor: 0.11,
      center: math.Point(n * 0.30, n * 0.78),
    );
    final wheel2 = _circleMask(
      n,
      radiusFactor: 0.11,
      center: math.Point(n * 0.70, n * 0.78),
    );
    return {...body, ...cabin, ...wheel1, ...wheel2};
  }

  static Set<GridPoint> _rocketMask(int n) {
    final body = <GridPoint>{};
    for (int y = (n * 0.22).floor(); y < (n * 0.78).floor(); y++) {
      for (int x = (n * 0.38).floor(); x <= (n * 0.62).floor(); x++) {
        body.add(GridPoint(x, y));
      }
    }
    final nose = _polygonMask(n, [
      math.Point(n * 0.38, n * 0.22),
      math.Point(n * 0.50, 0.5),
      math.Point(n * 0.62, n * 0.22),
    ]);
    final finL = _polygonMask(n, [
      math.Point(n * 0.38, n * 0.60),
      math.Point(n * 0.22, n * 0.85),
      math.Point(n * 0.38, n * 0.78),
    ]);
    final finR = _polygonMask(n, [
      math.Point(n * 0.62, n * 0.60),
      math.Point(n * 0.78, n * 0.85),
      math.Point(n * 0.62, n * 0.78),
    ]);
    return {...body, ...nose, ...finL, ...finR};
  }

  static Set<GridPoint> _boatMask(int n) {
    final hull = _polygonMask(n, [
      math.Point(1.0, n * 0.55),
      math.Point(n - 1.0, n * 0.55),
      math.Point(n * 0.78, n - 1.0),
      math.Point(n * 0.22, n - 1.0),
    ]);
    final mast = <GridPoint>{};
    for (int y = 1; y < (n * 0.55).floor(); y++) {
      mast.add(GridPoint(n ~/ 2, y));
      mast.add(GridPoint(n ~/ 2 + 1, y));
    }
    final sail = _polygonMask(n, [
      math.Point(n * 0.52, 1.0),
      math.Point(n * 0.78, n * 0.50),
      math.Point(n * 0.52, n * 0.50),
    ]);
    return {...hull, ...mast, ...sail};
  }

  static Set<GridPoint> _airplaneMask(int n) {
    final fuselage = <GridPoint>{};
    for (int x = 1; x < n - 1; x++) {
      for (int y = (n * 0.48).floor(); y <= (n * 0.52).floor(); y++) {
        fuselage.add(GridPoint(x, y));
      }
    }
    final wing = _polygonMask(n, [
      math.Point(n * 0.30, n * 0.48),
      math.Point(n * 0.60, n * 0.32),
      math.Point(n * 0.65, n * 0.48),
    ]);
    final tail = _polygonMask(n, [
      math.Point(n * 0.18, n * 0.30),
      math.Point(n * 0.24, n * 0.48),
      math.Point(n * 0.18, n * 0.70),
    ]);
    return {...fuselage, ...wing, ...tail};
  }

  static Set<GridPoint> _cameraMask(int n) {
    final body = <GridPoint>{};
    for (int y = (n * 0.32).floor(); y < (n * 0.78).floor(); y++) {
      for (int x = 1; x < n - 1; x++) {
        body.add(GridPoint(x, y));
      }
    }
    final lens = _circleMask(
      n,
      radiusFactor: 0.18,
      center: math.Point(n * 0.50, n * 0.55),
    );
    return {...body, ...lens};
  }

  static Set<GridPoint> _giftMask(int n) {
    final box = _squareMask(n);
    // ribbon vertical/horizontal
    for (int y = 1; y < n - 1; y++) {
      box.add(GridPoint(n ~/ 2, y));
      box.add(GridPoint(n ~/ 2 + 1, y));
    }
    for (int x = 1; x < n - 1; x++) {
      box.add(GridPoint(x, n ~/ 2));
      box.add(GridPoint(x, n ~/ 2 + 1));
    }
    return box;
  }

  static Set<GridPoint> _keyMask(int n) {
    final head = _circleMask(
      n,
      radiusFactor: 0.16,
      center: math.Point(n * 0.28, n / 2),
    );
    final shaft = <GridPoint>{};
    for (int x = (n * 0.40).floor(); x < n - 2; x++) {
      shaft.add(GridPoint(x, n ~/ 2));
      shaft.add(GridPoint(x, n ~/ 2 + 1));
    }
    final teeth = <GridPoint>{};
    for (int x = (n * 0.62).floor(); x < (n * 0.78).floor(); x += 2) {
      teeth.add(GridPoint(x, n ~/ 2 + 2));
    }
    return {...head, ...shaft, ...teeth};
  }

  static Set<GridPoint> _lockMask(int n) {
    final body = <GridPoint>{};
    for (int y = (n * 0.42).floor(); y < n - 1; y++) {
      for (int x = 2; x < n - 2; x++) {
        body.add(GridPoint(x, y));
      }
    }
    final shackle = _ringMask(n);
    // keep only top half of ring
    shackle.removeWhere((p) => p.y > n * 0.42);
    return {...body, ...shackle};
  }

  static Set<GridPoint> _trophyMask(int n) {
    final cup = _polygonMask(n, [
      math.Point(n * 0.28, n * 0.18),
      math.Point(n * 0.72, n * 0.18),
      math.Point(n * 0.62, n * 0.52),
      math.Point(n * 0.38, n * 0.52),
    ]);
    final stem = <GridPoint>{};
    for (int y = (n * 0.52).floor(); y < (n * 0.72).floor(); y++) {
      stem.add(GridPoint(n ~/ 2, y));
      stem.add(GridPoint(n ~/ 2 + 1, y));
    }
    final base = <GridPoint>{};
    for (int x = (n * 0.32).floor(); x <= (n * 0.68).floor(); x++) {
      base.add(GridPoint(x, n - 2));
      base.add(GridPoint(x, n - 3));
    }
    return {...cup, ...stem, ...base};
  }

  static Set<GridPoint> _umbrellaMask(int n) {
    final canopy = _circleMask(
      n,
      radiusFactor: 0.30,
      center: math.Point(n / 2, n * 0.38),
    );
    // only top half
    canopy.removeWhere((p) => p.y > n * 0.45);
    final handle = <GridPoint>{};
    for (int y = (n * 0.45).floor(); y < n - 1; y++) {
      handle.add(GridPoint(n ~/ 2, y));
    }
    handle.addAll(
      _circleMask(n, radiusFactor: 0.07, center: math.Point(n * 0.50, n - 1.0)),
    );
    return {...canopy, ...handle};
  }

  static Set<GridPoint> _bellMask(int n) {
    final top = _circleMask(
      n,
      radiusFactor: 0.18,
      center: math.Point(n / 2, n * 0.30),
    );
    final body = _polygonMask(n, [
      math.Point(n * 0.30, n * 0.38),
      math.Point(n * 0.70, n * 0.38),
      math.Point(n * 0.78, n * 0.82),
      math.Point(n * 0.22, n * 0.82),
    ]);
    return {...top, ...body};
  }

  static Set<GridPoint> _chairMask(int n) {
    final seat = <GridPoint>{};
    for (int y = (n * 0.48).floor(); y < (n * 0.58).floor(); y++) {
      for (int x = 2; x < n - 2; x++) {
        seat.add(GridPoint(x, y));
      }
    }
    final back = <GridPoint>{};
    for (int y = 1; y < (n * 0.48).floor(); y++) {
      for (int x = 2; x < 4; x++) {
        back.add(GridPoint(x, y));
      }
    }
    final leg1 = <GridPoint>{GridPoint(2, n - 2), GridPoint(3, n - 2)};
    final leg2 = <GridPoint>{GridPoint(n - 3, n - 2), GridPoint(n - 4, n - 2)};
    for (int y = (n * 0.58).floor(); y < n - 1; y++) {
      leg1.add(GridPoint(2, y));
      leg1.add(GridPoint(3, y));
      leg2.add(GridPoint(n - 3, y));
      leg2.add(GridPoint(n - 4, y));
    }
    return {...seat, ...back, ...leg1, ...leg2};
  }

  static Set<GridPoint> _lampMask(int n) {
    final shade = _polygonMask(n, [
      math.Point(n * 0.22, n * 0.18),
      math.Point(n * 0.78, n * 0.18),
      math.Point(n * 0.68, n * 0.42),
      math.Point(n * 0.32, n * 0.42),
    ]);
    final stand = <GridPoint>{};
    for (int y = (n * 0.42).floor(); y < n - 1; y++) {
      stand.add(GridPoint(n ~/ 2, y));
      stand.add(GridPoint(n ~/ 2 + 1, y));
    }
    return {...shade, ...stand};
  }

  static Set<GridPoint> _bicycleMask(int n) {
    // Simplify as two circles
    final w1 = _circleMask(
      n,
      radiusFactor: 0.20,
      center: math.Point(n * 0.28, n * 0.68),
    );
    w1.removeAll(
      _circleMask(
        n,
        radiusFactor: 0.12,
        center: math.Point(n * 0.28, n * 0.68),
      ),
    );
    final w2 = _circleMask(
      n,
      radiusFactor: 0.20,
      center: math.Point(n * 0.72, n * 0.68),
    );
    w2.removeAll(
      _circleMask(
        n,
        radiusFactor: 0.12,
        center: math.Point(n * 0.72, n * 0.68),
      ),
    );
    final frame = _polygonMask(n, [
      math.Point(n * 0.28, n * 0.68),
      math.Point(n * 0.50, n * 0.32),
      math.Point(n * 0.72, n * 0.68),
    ]);
    return {...w1, ...w2, ...frame};
  }

  static Set<GridPoint> _guitarMask(int n) {
    final body = _circleMask(
      n,
      radiusFactor: 0.22,
      center: math.Point(n * 0.50, n * 0.68),
    );
    final neck = <GridPoint>{};
    for (int y = 1; y < (n * 0.55).floor(); y++) {
      neck.add(GridPoint(n ~/ 2, y));
      neck.add(GridPoint(n ~/ 2 + 1, y));
    }
    return {...body, ...neck};
  }

  static Set<GridPoint> _cupMask(int n) {
    final body = _polygonMask(n, [
      math.Point(n * 0.22, n * 0.28),
      math.Point(n * 0.78, n * 0.28),
      math.Point(n * 0.70, n * 0.82),
      math.Point(n * 0.30, n * 0.82),
    ]);
    final handle = _ringMask(n).where((p) => p.x > n * 0.70).toSet();
    return {...body, ...handle};
  }

  // ============ Buildings ============

  static Set<GridPoint> _lighthouseMask(int n) {
    final tower = <GridPoint>{};
    for (int y = (n * 0.28).floor(); y < n - 1; y++) {
      final w = 2 + ((n - 1 - y) * 0.08).floor();
      for (int x = n ~/ 2 - w; x <= n ~/ 2 + w; x++) {
        if (x >= 0 && x < n) tower.add(GridPoint(x, y));
      }
    }
    final light = _circleMask(
      n,
      radiusFactor: 0.12,
      center: math.Point(n / 2, n * 0.22),
    );
    return {...tower, ...light};
  }

  static Set<GridPoint> _windmillMask(int n) {
    final tower = <GridPoint>{};
    for (int y = (n * 0.38).floor(); y < n - 1; y++) {
      tower.add(GridPoint(n ~/ 2, y));
      tower.add(GridPoint(n ~/ 2 + 1, y));
    }
    final blades = _starMask(n).where((p) => p.y < n * 0.42).toSet();
    return {...tower, ...blades};
  }

  static Set<GridPoint> _castleMask(int n, {bool small = false}) {
    final base = <GridPoint>{};
    for (int y = (n * 0.42).floor(); y < n - 1; y++) {
      for (int x = 1; x < n - 1; x++) {
        base.add(GridPoint(x, y));
      }
    }
    // towers
    for (int x in [2, n - 3]) {
      for (int y = (n * 0.22).floor(); y < (n * 0.42).floor(); y++) {
        for (int dx = -1; dx <= 1; dx++) {
          base.add(GridPoint(x + dx, y));
        }
      }
    }
    final gate = _polygonMask(n, [
      math.Point(n * 0.42, n * 0.62),
      math.Point(n * 0.58, n * 0.62),
      math.Point(n * 0.58, n - 1.0),
      math.Point(n * 0.42, n - 1.0),
    ]);
    base.removeAll(gate);
    return base;
  }

  static Set<GridPoint> _towerMask(int n) {
    final set = <GridPoint>{};
    for (int y = 1; y < n - 1; y++) {
      final w = 2 + (y > n * 0.6 ? 1 : 0);
      for (int x = n ~/ 2 - w; x <= n ~/ 2 + w; x++) {
        set.add(GridPoint(x, y));
      }
    }
    return set;
  }

  static Set<GridPoint> _bridgeMask(int n) {
    final arch = _circleMask(
      n,
      radiusFactor: 0.30,
      center: math.Point(n / 2, n * 0.85),
    );
    arch.removeWhere((p) => p.y < n * 0.55);
    final deck = <GridPoint>{};
    for (int x = 1; x < n - 1; x++) {
      deck.add(GridPoint(x, (n * 0.55).floor()));
      deck.add(GridPoint(x, (n * 0.55).floor() + 1));
    }
    final pillarL = <GridPoint>{};
    for (int y = (n * 0.55).floor(); y < n - 1; y++) {
      pillarL.add(GridPoint(2, y));
      pillarL.add(GridPoint(3, y));
      pillarL.add(GridPoint(n - 3, y));
      pillarL.add(GridPoint(n - 4, y));
    }
    return {...deck, ...pillarL, ...arch};
  }

  static Set<GridPoint> _templeMask(int n) {
    final base = <GridPoint>{};
    for (int y = (n * 0.72).floor(); y < n - 1; y++) {
      for (int x = 1; x < n - 1; x++) {
        base.add(GridPoint(x, y));
      }
    }
    final columns = <GridPoint>{};
    for (int c = 2; c < n - 2; c += 2) {
      for (int y = (n * 0.32).floor(); y < (n * 0.72).floor(); y++) {
        columns.add(GridPoint(c, y));
      }
    }
    final roof = _polygonMask(n, [
      math.Point(0.5, n * 0.32),
      math.Point(n / 2, 1.0),
      math.Point(n - 0.5, n * 0.32),
    ]);
    return {...base, ...columns, ...roof};
  }

  static Set<GridPoint> _skylineMask(int n) {
    final set = <GridPoint>{};
    final heights = [n * 0.38, n * 0.22, n * 0.48, n * 0.30, n * 0.42];
    int x = 1;
    for (int i = 0; i < heights.length && x < n - 1; i++) {
      final h = heights[i];
      final w = (n * 0.18).floor();
      for (int yy = h.floor(); yy < n - 1; yy++) {
        for (int xx = x; xx < x + w && xx < n - 1; xx++) {
          set.add(GridPoint(xx, yy));
        }
      }
      x += w + 1;
    }
    return set;
  }

  static Set<GridPoint> _pyramidMask(int n) => _triangleMask(n);
  static Set<GridPoint> _pagodaMask(int n) => _templeMask(n);
  static Set<GridPoint> _churchMask(int n) => _houseMask(n);
  static Set<GridPoint> _factoryMask(int n) => _skylineMask(n);
  static Set<GridPoint> _stadiumMask(int n) =>
      _circleMask(n, radiusFactor: 0.38);
  static Set<GridPoint> _fortMask(int n) => _castleMask(n);
  static Set<GridPoint> _gateMask(int n) => _bridgeMask(n);
  static Set<GridPoint> _wellMask(int n) => _circleMask(n, radiusFactor: 0.30);
  static Set<GridPoint> _millMask(int n) => _windmillMask(n);
  static Set<GridPoint> _mansionMask(int n) => _castleMask(n);
  static Set<GridPoint> _cottageMask(int n) => _houseMask(n);
  static Set<GridPoint> _palaceMask(int n) => _templeMask(n);

  // ============ Expert ============

  static Set<GridPoint> _flowerGardenMask(int n) {
    final f1 = _flowerMask(n);
    // spread
    return f1;
  }

  static Set<GridPoint> _animalParadeMask(int n) {
    final cat = _catMask(n);
    // duplicate shifted? just return cat for now
    return cat;
  }

  static Set<GridPoint> _cityComplexMask(int n) => _skylineMask(n);
  static Set<GridPoint> _labyrinthMask(int n) {
    final set = <GridPoint>{};
    for (int y = 1; y < n - 1; y += 2) {
      for (int x = 1; x < n - 1; x++) {
        set.add(GridPoint(x, y));
      }
    }
    for (int x = 1; x < n - 1; x += 2) {
      for (int y = 1; y < n - 1; y++) {
        set.add(GridPoint(x, y));
      }
    }
    return set;
  }

  static Set<GridPoint> _doubleSpiralMask(int n) => _spiralMask(n);
  static Set<GridPoint> _mandalaMask(int n) => _gearMask(n);
  static Set<GridPoint> _constellationMask(int n) {
    final set = <GridPoint>{};
    for (int i = 0; i < n; i++) {
      set.add(GridPoint(i, i));
      set.add(GridPoint(n - 1 - i, i));
    }
    return set;
  }

  static Set<GridPoint> _dragonMask(int n) => _dinosaurMask(n);
  static Set<GridPoint> _phoenixMask(int n) => _birdMask(n);
  static Set<GridPoint> _galaxyMask(int n) => _spiralMask(n);
  static Set<GridPoint> _crystalPalaceMask(int n) => _castleMask(n);
  static Set<GridPoint> _jungleMask(int n) => _treeMask(n);
  static Set<GridPoint> _oceanMask(int n) => _fishMask(n);
  static Set<GridPoint> _spaceStationMask(int n) => _rocketMask(n);
  static Set<GridPoint> _futuristicCityMask(int n) => _skylineMask(n);
  static Set<GridPoint> _dreamCatcherMask(int n) => _ringMask(n);
  static Set<GridPoint> _kaleidoscopeMask(int n) => _starMask(n);

  static Set<GridPoint> _hashBlobMask(String name, int n) {
    final seed = name.hashCode.abs();
    final rng = math.Random(seed);
    final set = <GridPoint>{};
    final cx = n / 2, cy = n / 2;
    final count = (n * n * 0.42).floor();
    for (int i = 0; i < count; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final rad = rng.nextDouble() * n * 0.38;
      final x = (cx + rad * math.cos(angle)).round().clamp(0, n - 1);
      final y = (cy + rad * math.sin(angle)).round().clamp(0, n - 1);
      set.add(GridPoint(x, y));
    }
    return set;
  }
}
