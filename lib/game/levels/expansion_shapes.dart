import 'dart:math' as math;

import '../../models/puzzle_path.dart';

/// Clean geometric silhouettes for the Level 1001-2000 expansion.
///
/// Each shape is an exact inside test on the unit square (x right, y down),
/// rasterised at any box size by 4x4 supersampling, so large boards get
/// crisp outlines instead of an upscaled low-resolution mask. Levels 1-1000
/// never use this file.
class ExpansionShapes {
  static bool has(String name) => _shapes.containsKey(name.toLowerCase());

  /// [name] filled into a [box] x [box] square (tight bounds scaled to fit,
  /// proportions kept, centred). Null when [name] is not an analytic shape.
  static Set<GridPoint>? fit(String name, int box) {
    final inside = _shapes[name.toLowerCase()];
    if (inside == null || box <= 0) return null;

    // Tight bounds of the shape, sampled finely.
    const probe = 256;
    var x0 = 1.0, y0 = 1.0, x1 = 0.0, y1 = 0.0;
    for (int j = 0; j < probe; j++) {
      for (int i = 0; i < probe; i++) {
        final x = (i + 0.5) / probe, y = (j + 0.5) / probe;
        if (!inside(x, y)) continue;
        x0 = math.min(x0, x);
        x1 = math.max(x1, x);
        y0 = math.min(y0, y);
        y1 = math.max(y1, y);
      }
    }
    if (x1 < x0) return {};
    final w = x1 - x0, h = y1 - y0;
    final span = math.max(w, h);
    final tw = (box * w / span).round().clamp(1, box);
    final th = (box * h / span).round().clamp(1, box);
    final ox = (box - tw) ~/ 2, oy = (box - th) ~/ 2;

    const ss = 4;
    final out = <GridPoint>{};
    for (int j = 0; j < th; j++) {
      for (int i = 0; i < tw; i++) {
        var hits = 0;
        for (int sy = 0; sy < ss; sy++) {
          for (int sx = 0; sx < ss; sx++) {
            final x = x0 + w * (i + (sx + 0.5) / ss) / tw;
            final y = y0 + h * (j + (sy + 0.5) / ss) / th;
            if (inside(x, y)) hits++;
          }
        }
        if (hits * 2 >= ss * ss) out.add(GridPoint(ox + i, oy + j));
      }
    }
    return out;
  }

  static final Map<String, bool Function(double, double)> _shapes = {
    'triangle': (x, y) => _inPoly(x, y, const [0.5, 0.0, 1.0, 0.88, 0.0, 0.88]),
    'circle': (x, y) => _sq(x - 0.5) + _sq(y - 0.5) <= 0.25,
    'square': (x, y) => true,
    'pentagon': (x, y) => _inRegular(x, y, 5, -math.pi / 2),
    'hexagon': (x, y) => _inRegular(x, y, 6, 0),
    'octagon': (x, y) => _inRegular(x, y, 8, math.pi / 8),
    'star': (x, y) => _inStar(x, y, 5, 0.5, 0.25),
    'heart': _heart,
    'diamond': (x, y) => (x - 0.5).abs() / 0.36 + (y - 0.5).abs() / 0.5 <= 1,
    'cross': (x, y) => (x - 0.5).abs() <= 0.17 || (y - 0.5).abs() <= 0.17,
    'crescent': (x, y) =>
        _sq(x - 0.5) + _sq(y - 0.5) <= 0.25 &&
        _sq(x - 0.7) + _sq(y - 0.38) > 0.16,
    'crown': (x, y) => _inPoly(x, y, const [
      0.0, 1.0, 0.0, 0.15, 0.25, 0.5, 0.5, 0.05, //
      0.75, 0.5, 1.0, 0.15, 1.0, 1.0,
    ]),
    'clock': _clock,
    'shield': (x, y) => _inPoly(x, y, const [
      0.0, 0.08, 0.5, 0.0, 1.0, 0.08, 1.0, 0.5, 0.9, 0.7, //
      0.72, 0.87, 0.5, 1.0, 0.28, 0.87, 0.1, 0.7, 0.0, 0.5,
    ]),
    'moon': (x, y) =>
        _sq(x - 0.5) + _sq(y - 0.5) <= 0.25 &&
        _sq(x - 0.78) + _sq(y - 0.5) > 0.12,
    'concentric diamonds': (x, y) {
      final d = (x - 0.5).abs() + (y - 0.5).abs();
      return d <= 0.5 && (d / 0.0835).floor().isEven;
    },
    'sunburst': (x, y) {
      final dx = x - 0.5, dy = y - 0.5;
      final r = math.sqrt(dx * dx + dy * dy);
      if (r <= 0.15) return true;
      if (r < 0.2 || r > 0.5) return false;
      final a = (math.atan2(dy, dx) + math.pi) / (2 * math.pi) * 12;
      return a - a.floor() < 0.5;
    },
    'woven lattice': (x, y) {
      // Over/under bands: horizontal bands break where vertical bands pass
      // over them and vice versa, alternating like a weave.
      const n = 6;
      final cx = (x * n).floor(), cy = (y * n).floor();
      final fx = x * n - cx, fy = y * n - cy;
      final inH = fy > 0.18 && fy < 0.82;
      final inV = fx > 0.18 && fx < 0.82;
      if (inH && inV) return true;
      final vOver = (cx + cy).isEven;
      if (inH) return !vOver || fx < 0.06 || fx > 0.94;
      if (inV) return vOver || fy < 0.06 || fy > 0.94;
      return false;
    },
  };

  static double _sq(double v) => v * v;

  /// Two round lobes over a pointed base, with a clear notch on top.
  static bool _heart(double x, double y) {
    if (_sq(x - 0.27) + _sq(y - 0.3) <= 0.0729) return true;
    if (_sq(x - 0.73) + _sq(y - 0.3) <= 0.0729) return true;
    return _inPoly(x, y, const [0.02, 0.38, 0.98, 0.38, 0.5, 0.98]);
  }

  static bool _clock(double x, double y) {
    final dx = x - 0.5, dy = y - 0.5;
    final r2 = dx * dx + dy * dy;
    if (r2 > 0.25) return false;
    if (r2 >= 0.37 * 0.37) return true; // rim
    if (r2 <= 0.07 * 0.07) return true; // hub
    // Hands: hour hand up, minute hand towards four o'clock.
    if (dx.abs() <= 0.04 && dy <= 0 && dy >= -0.26) return true;
    final along = dx * 0.866 + dy * 0.5, across = -dx * 0.5 + dy * 0.866;
    if (across.abs() <= 0.04 && along >= 0 && along <= 0.31) return true;
    // Hour ticks at 12, 3, 6, 9.
    final r = math.sqrt(r2);
    return r >= 0.3 && (dx.abs() <= 0.035 || dy.abs() <= 0.035);
  }

  /// Point-in-polygon (even-odd) for flat [x0, y0, x1, y1, ...] vertices.
  static bool _inPoly(double x, double y, List<double> v) {
    var inside = false;
    final n = v.length ~/ 2;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      final xi = v[2 * i], yi = v[2 * i + 1];
      final xj = v[2 * j], yj = v[2 * j + 1];
      if ((yi > y) != (yj > y) && x < (xj - xi) * (y - yi) / (yj - yi) + xi) {
        inside = !inside;
      }
    }
    return inside;
  }

  static bool _inRegular(double x, double y, int sides, double rot) {
    final v = <double>[];
    for (int k = 0; k < sides; k++) {
      final a = rot + 2 * math.pi * k / sides;
      v
        ..add(0.5 + 0.5 * math.cos(a))
        ..add(0.5 + 0.5 * math.sin(a));
    }
    return _inPoly(x, y, v);
  }

  static bool _inStar(
    double x,
    double y,
    int points,
    double outer,
    double inner,
  ) {
    final v = <double>[];
    for (int k = 0; k < points * 2; k++) {
      final r = k.isEven ? outer : inner;
      final a = -math.pi / 2 + math.pi * k / points;
      v
        ..add(0.5 + r * math.cos(a))
        ..add(0.5 + r * math.sin(a));
    }
    return _inPoly(x, y, v);
  }
}
