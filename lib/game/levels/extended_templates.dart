import '../../models/puzzle_path.dart';
import 'level_world.dart';
import 'shape_art.dart';
import 'shape_masks.dart';

/// Mask composition for Levels 21-1000 (Levels 1-20 are curated and untouched).
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
