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

  /// Builds the target silhouette for [levelId] on a [grid] board.
  ///
  /// Single-shape levels use the art for their name at full board size.
  /// Combination levels stagger two large shapes (each ~66% of the board)
  /// diagonally: the first in one corner, the second in the opposite one
  /// ('diagonal': top-left/bottom-right, 'antiDiagonal': top-right/
  /// bottom-left). Where they meet, the first shape keeps a one-cell gap
  /// from the second so both silhouettes stay distinct while their arrows
  /// interlock.
  static Set<GridPoint> buildMask(int levelId, int grid) {
    final t = templateFor(levelId);
    if (t.components.length == 1 || t.layout == 'single') {
      return _art(t.components.first, grid);
    }
    final size = componentSize(grid);
    final off = grid - size;
    final anti = t.layout == 'antiDiagonal';
    final first = {
      for (final p in _art(t.components[0], size))
        GridPoint(p.x + (anti ? off : 0), p.y),
    };
    final second = {
      for (final p in _art(t.components[1], size))
        GridPoint(p.x + (anti ? 0 : off), p.y + off),
    };
    bool nearSecond(GridPoint p) =>
        second.contains(p) ||
        second.contains(GridPoint(p.x + 1, p.y)) ||
        second.contains(GridPoint(p.x - 1, p.y)) ||
        second.contains(GridPoint(p.x, p.y + 1)) ||
        second.contains(GridPoint(p.x, p.y - 1));
    return {...first.where((p) => !nearSecond(p)), ...second};
  }

  /// Size of each shape on a combination board of [grid] cells.
  static int componentSize(int grid) => (grid * 0.66).round();

  /// [name]'s silhouette at [size], falling back to the procedural mask
  /// when no hand-drawn art exists for that size.
  static Set<GridPoint> _art(String name, int size) {
    final art = ShapeArt.cells(name, size);
    if (art != null) return art;
    return ShapeMasks.maskForShape(name, size)
        .where((p) => p.x >= 0 && p.x < size && p.y >= 0 && p.y < size)
        .toSet();
  }
}
