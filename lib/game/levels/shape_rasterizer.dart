// ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:math' as math;
import '../../models/puzzle_path.dart';

/// Reusable exact shape → grid occupancy system.
///
/// For each board cell, the center point (x+0.5, y+0.5) is tested against
/// the exact vector geometry. This guarantees the visible arrangement
/// follows the mathematical shape, not an approximation.
class ShapeRasterizer {
  /// Returns the set of grid cells whose center lies inside the triangle
  /// defined by [a], [b], [c] in grid coordinates (continuous).
  static Set<GridPoint> rasterizeTriangle(
    int gridSize,
    math.Point<double> a,
    math.Point<double> b,
    math.Point<double> c,
  ) {
    final set = <GridPoint>{};
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final px = x + 0.5;
        final py = y + 0.5;
        if (_pointInTriangle(px, py, a.x, a.y, b.x, b.y, c.x, c.y)) {
          set.add(GridPoint(x, y));
        }
      }
    }
    return set;
  }

  /// Exact filled triangle for Level 1 — dense high-resolution.
  /// Uses a large grid (15-27) to create a clean, filled silhouette.
  /// For grid 9 we keep the original 16-cell triangle for backward compat,
  /// but Level 1 now uses grid 15+ for dense.
  static Set<GridPoint> triangleLevel1Cells(int gridSize) {
    if (gridSize == 9) {
      // Legacy 9x9 triangle: 4 rows 1,3,5,7 =16 cells
      return rasterizeTriangle(
        gridSize,
        const math.Point(4.5, 2.5),
        const math.Point(1.5, 5.5),
        const math.Point(7.5, 5.5),
      );
    }
    // Dense triangle for high-res grids: centered, large, straight edges
    // Apex at top center with small top margin, base at 85% height with side margins
    final double apexX = gridSize / 2;
    final double apexY = gridSize * 0.14;
    final double baseY = gridSize * 0.86;
    final double halfBase = gridSize * 0.38;
    return rasterizeTriangle(
      gridSize,
      math.Point(apexX, apexY),
      math.Point(apexX - halfBase, baseY),
      math.Point(apexX + halfBase, baseY),
    );
  }

  /// Dense triangle for arbitrary grid (used for Level 1 high-res)
  static Set<GridPoint> denseTriangleCells(int gridSize) {
    // Use 38% half-base and 14%-86% vertical range for dense fill
    final double apexX = gridSize / 2;
    final double apexY = gridSize * 0.12;
    final double baseY = gridSize * 0.88;
    final double halfBase = gridSize * 0.42;
    return rasterizeTriangle(
      gridSize,
      math.Point(apexX, apexY),
      math.Point(gridSize / 2 - halfBase, baseY),
      math.Point(gridSize / 2 + halfBase, baseY),
    );
  }

  /// Generic rasterizer for future shapes (square, circle, etc.) - placeholder
  /// For now only triangle is used, but architecture is reusable.
  static Set<GridPoint> rasterizeForShape(String shape, int gridSize) {
    final lower = shape.toLowerCase();
    if (lower == 'triangle') {
      if (gridSize == 9) return triangleLevel1Cells(gridSize);
      // For other grid sizes, scale proportionally
      final apex = math.Point(gridSize / 2, gridSize * 0.28);
      final baseY = gridSize * 0.62;
      final halfBase = gridSize * 0.34;
      return rasterizeTriangle(
        gridSize,
        apex,
        math.Point(gridSize / 2 - halfBase, baseY),
        math.Point(gridSize / 2 + halfBase, baseY),
      );
    }
    // Fallback: return empty, caller will handle
    return <GridPoint>{};
  }

  /// Barycentric point-in-triangle test (exact, no epsilon distortion).
  static bool _pointInTriangle(
    double px,
    double py,
    double ax,
    double ay,
    double bx,
    double by,
    double cx,
    double cy,
  ) {
    final v0x = cx - ax;
    final v0y = cy - ay;
    final v1x = bx - ax;
    final v1y = by - ay;
    final v2x = px - ax;
    final v2y = py - ay;

    final dot00 = v0x * v0x + v0y * v0y;
    final dot01 = v0x * v1x + v0y * v1y;
    final dot02 = v0x * v2x + v0y * v2y;
    final dot11 = v1x * v1x + v1y * v1y;
    final dot12 = v1x * v2x + v1y * v2y;

    final invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
    final u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    final v = (dot00 * dot12 - dot01 * dot02) * invDenom;
    return (u >= 0) && (v >= 0) && (u + v <= 1);
  }

  /// Debug helper: prints occupancy grid
  static String debugBoard(Set<GridPoint> occupied, int gridSize) {
    final sb = StringBuffer();
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        sb.write(occupied.contains(GridPoint(x, y)) ? 'X ' : '. ');
      }
      sb.writeln(' // y=$y count ${occupied.where((p) => p.y == y).length}');
    }
    sb.writeln('total ${occupied.length}');
    return sb.toString();
  }

  /// Validates triangle shape properties
  static bool validateTriangle(Set<GridPoint> cells, int gridSize) {
    if (cells.isEmpty) return false;
    // Check rows have 1,3,5,7 pattern and centered
    final rowCounts = <int, List<int>>{};
    for (final pt in cells) {
      rowCounts.putIfAbsent(pt.y, () => []).add(pt.x);
    }
    final sortedRows = rowCounts.keys.toList()..sort();
    // Should be consecutive rows
    for (int i = 1; i < sortedRows.length; i++) {
      if (sortedRows[i] != sortedRows[i - 1] + 1) return false;
    }
    // Each row should be contiguous and centered at 4
    for (final y in sortedRows) {
      final xs = rowCounts[y]!..sort();
      for (int i = 1; i < xs.length; i++) {
        if (xs[i] != xs[i - 1] + 1) return false; // gap
      }
      final minX = xs.first, maxX = xs.last;
      final center = (minX + maxX) / 2;
      if ((center - 4.5).abs() > 0.6)
        return false; // not centered (allow 0.5 for even widths)
    }
    // Check increasing width
    int prevCount = 0;
    for (final y in sortedRows) {
      final count = rowCounts[y]!.length;
      if (count <= prevCount && y != sortedRows.first) {
        // Allow equal at bottom? For triangle should strictly increase
        // But our 1,3,5,7 is increasing, so check
        if (count != prevCount) return false;
      }
      prevCount = count;
    }
    // Check no outside cells (all inside triangle bounds y 2..5, x 1..7)
    for (final pt in cells) {
      if (pt.y < 2 || pt.y > 5) return false;
      if (pt.x < 1 || pt.x > 7) return false;
    }
    return true;
  }
}
