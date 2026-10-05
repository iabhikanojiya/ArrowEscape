import '../../models/puzzle_path.dart';
import 'expansion_catalog.dart';
import 'expansion_shapes.dart';
import 'level_world.dart';
import 'shape_art.dart';
import 'shape_masks.dart';

/// Mask composition for Levels 21-2000 (Levels 1-20 are curated and untouched).
/// Levels 1001-2000 take a separate path ([ExpansionCatalog]) so Levels
/// 21-1000 keep exactly their original masks.
///
/// Template *selection* (components, layout, display name) lives in
/// [LevelWorlds] so metadata and tile labels share one source of truth.
/// This file only turns a template into a concrete target mask from the
/// hand-drawn [ShapeArt] silhouettes.
class ExtendedTemplate {
  /// Component mask names in composition order.
  final List<String> components;

  /// 'single', 'sideH' (left/right) or 'sideV' (top/bottom).
  final String layout;

  /// Human-readable name, e.g. 'Flower + Butterfly'.
  final String displayName;

  const ExtendedTemplate({
    required this.components,
    required this.layout,
    required this.displayName,
  });
}

class ExtendedTemplates {
  /// Deterministic template for any level >= 21. Levels 1-20 never reach here.
  static ExtendedTemplate templateFor(int levelId) {
    return ExtendedTemplate(
      components: LevelWorlds.extendedComponents(levelId),
      layout: LevelWorlds.extendedLayout(levelId),
      displayName: LevelWorlds.extendedDisplayName(levelId),
    );
  }

  /// Display name shared by level metadata and level-select tile labels.
  static String displayName(int levelId) =>
      LevelWorlds.extendedDisplayName(levelId);

  /// Target silhouette cells for [levelId] on a [grid] board.
  static Set<GridPoint> buildMask(int levelId, int grid) =>
      buildRegions(levelId, grid).keys.toSet();

  /// Target silhouette for [levelId] on a [grid] board, as cell -> colour
  /// region (0 primary, 1 secondary, 2 accent).
  ///
  /// Single-shape levels scale the design to fill the board (1-cell
  /// margin, proportions kept), coloured by the design's own regions (e.g.
  /// petals / centre / stem). Combination levels stagger two large shapes
  /// (each 60% of the board) diagonally ('diagonal': top-left/bottom-right,
  /// 'antiDiagonal': top-right/bottom-left) so they interlock into one
  /// composition; the first shape keeps a one-cell gap from the second.
  /// The first shape is primary with accent details, the second secondary.
  static Map<GridPoint, int> buildRegions(int levelId, int grid) {
    if (ExpansionCatalog.covers(levelId)) return _buildExpansion(levelId, grid);
    final t = templateFor(levelId);
    const margin = 1;
    final passes = thickeningFor(grid);
    if (t.components.length == 1 || t.layout == 'single') {
      return _thicken(
          _placed(_art(t.components.first, grid - 2 * margin), margin,
              margin, (r) => r),
          grid,
          passes);
    }
    final size = componentSize(grid);
    final far = grid - margin - size;
    final anti = t.layout == 'antiDiagonal';
    final first = _placed(_art(t.components[0], size),
        anti ? far : margin, margin, (r) => r == 0 ? 0 : 2);
    final second = _placed(_art(t.components[1], size),
        anti ? margin : far, far, (_) => 1);
    bool nearSecond(GridPoint p) =>
        second.containsKey(p) ||
        second.containsKey(GridPoint(p.x + 1, p.y)) ||
        second.containsKey(GridPoint(p.x - 1, p.y)) ||
        second.containsKey(GridPoint(p.x, p.y + 1)) ||
        second.containsKey(GridPoint(p.x, p.y - 1));
    first.removeWhere((p, _) => nearSecond(p));
    return _thicken({...first, ...second}, grid, passes);
  }

  /// Expansion board (Levels 1001-2000): each [ExpansionPiece] is drawn in
  /// its box (mirrored / turned / nested as planned). The first piece is
  /// the main shape; each later piece gives up any cell touching an earlier
  /// one, so every shape stays separated by at least one empty cell.
  static Map<GridPoint, int> _buildExpansion(int levelId, int grid) {
    const margin = 1;
    final inner = grid - 2 * margin;
    final out = <GridPoint, int>{};
    final pieces = ExpansionCatalog.piecesFor(levelId);
    for (int k = 0; k < pieces.length; k++) {
      final pc = pieces[k];
      final size = (pc.size * inner).round().clamp(4, inner);
      final ox = margin + (pc.x * inner).round().clamp(0, inner - size);
      final oy = margin + (pc.y * inner).round().clamp(0, inner - size);
      final base = _expansionArt(pc.name, size);
      var art = base;
      for (final s in pc.rings) {
        art = _cutRing(art, base, s);
      }
      art = _orient(art, size, pc.mirror, pc.turns);
      final tone = k == 0 ? 0 : (k == 1 ? 1 : 2);
      final earlier = Set<GridPoint>.of(out.keys);
      for (final c in art.keys) {
        final p = GridPoint(c.x + ox, c.y + oy);
        if (earlier.contains(p) ||
            earlier.contains(GridPoint(p.x + 1, p.y)) ||
            earlier.contains(GridPoint(p.x - 1, p.y)) ||
            earlier.contains(GridPoint(p.x, p.y + 1)) ||
            earlier.contains(GridPoint(p.x, p.y - 1))) {
          continue;
        }
        out[p] = tone;
      }
    }
    return _thicken(out, grid, thickeningFor(grid));
  }

  /// Analytic geometry first, then the designed art / procedural masks.
  static Map<GridPoint, int> _expansionArt(String name, int size) {
    final geo = ExpansionShapes.fit(name, size);
    if (geo != null) return {for (final c in geo) c: 0};
    return _art(name, size);
  }

  /// Cuts a one-cell channel along the outline of a copy of [base] scaled
  /// by [scale] about its centre: the shape becomes an outer band around a
  /// smaller version of itself.
  static Map<GridPoint, int> _cutRing(
    Map<GridPoint, int> art,
    Map<GridPoint, int> base,
    double scale,
  ) {
    if (base.isEmpty) return art;
    var sx = 0.0, sy = 0.0;
    for (final c in base.keys) {
      sx += c.x;
      sy += c.y;
    }
    final cx = sx / base.length, cy = sy / base.length;
    bool inCopy(int x, int y) => base.containsKey(
      GridPoint(
        (cx + (x - cx) / scale).round(),
        (cy + (y - cy) / scale).round(),
      ),
    );
    return {
      for (final e in art.entries)
        if (inCopy(e.key.x, e.key.y) ||
            !(inCopy(e.key.x + 1, e.key.y) ||
                inCopy(e.key.x - 1, e.key.y) ||
                inCopy(e.key.x, e.key.y + 1) ||
                inCopy(e.key.x, e.key.y - 1)))
          e.key: e.value,
    };
  }

  /// Mirrors (left-right) and turns (quarter turns clockwise) [art] within
  /// its [size] box.
  static Map<GridPoint, int> _orient(
    Map<GridPoint, int> art,
    int size,
    bool mirror,
    int turns,
  ) {
    if (!mirror && turns % 4 == 0) return art;
    final m = size - 1;
    return {
      for (final e in art.entries)
        () {
          var x = mirror ? m - e.key.x : e.key.x, y = e.key.y;
          for (int t = 0; t < turns % 4; t++) {
            final nx = m - y;
            y = x;
            x = nx;
          }
          return GridPoint(x, y);
        }(): e.value,
    };
  }

  /// Size of each shape on a combination board of [grid] cells.
  static int componentSize(int grid) => ((grid - 2) * 0.64).round();

  /// Stroke-thickening passes for a [grid] board: bigger boards get bolder
  /// shapes (denser, fewer thin one-cell strokes).
  static int thickeningFor(int grid) => grid >= 32 ? 1 : 0;

  /// Thickens strokes by growing the shape one cell outward per pass,
  /// without ever closing a gap: a cell is only added if, opposite each
  /// filled neighbour, the next two cells are empty (so every gap keeps at
  /// least one empty cell). New cells take their neighbour's colour region.
  static Map<GridPoint, int> _thicken(
      Map<GridPoint, int> cells, int grid, int passes) {
    const dirs = [[1, 0], [-1, 0], [0, 1], [0, -1]];
    for (int pass = 0; pass < passes; pass++) {
      final add = <GridPoint, int>{};
      for (int y = 1; y < grid - 1; y++) {
        for (int x = 1; x < grid - 1; x++) {
          final c = GridPoint(x, y);
          if (cells.containsKey(c)) continue;
          int? tone;
          var ok = true;
          for (final d in dirs) {
            final n = cells[GridPoint(x + d[0], y + d[1])];
            if (n == null) continue;
            tone ??= n;
            if (cells.containsKey(GridPoint(x - d[0], y - d[1])) ||
                cells.containsKey(GridPoint(x - 2 * d[0], y - 2 * d[1]))) {
              ok = false;
              break;
            }
          }
          if (ok && tone != null) add[c] = tone;
        }
      }
      cells.addAll(add);
    }
    return cells;
  }

  static Map<GridPoint, int> _placed(
      Map<GridPoint, int> art, int ox, int oy, int Function(int) tone) {
    return {
      for (final e in art.entries)
        GridPoint(e.key.x + ox, e.key.y + oy): tone(e.value),
    };
  }

  /// [name]'s silhouette fitted to a [size] box, falling back to the
  /// procedural mask when no designed art exists for the name.
  static Map<GridPoint, int> _art(String name, int size) {
    final art = ShapeArt.fit(name, size);
    if (art != null) return art;
    return {
      for (final p in ShapeMasks.maskForShape(name, size))
        if (p.x >= 0 && p.x < size && p.y >= 0 && p.y < size) p: 0,
    };
  }
}
