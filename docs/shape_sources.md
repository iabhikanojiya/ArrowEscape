# Shape Sources — Arrow Escape

This document records the origin and license of every silhouette template used to generate puzzle levels. Arrow Escape is commercially distributed on Google Play, so only shapes compatible with commercial use are permitted.

## Level 1 — Triangle (Basic Shapes)

- **Source:** Original vector geometry generated in code — not copied from an external asset.
- **Original URL:** N/A (procedurally generated)
- **Shape name:** Triangle
- **License:** Original work, owned by Arrow Escape project (no external attribution required)
- **Attribution:** None required
- **Modifications:** N/A
- **Implementation:** Exact triangle defined by vertices `A(4.5,2.5) B(1.5,5.5) C(7.5,5.5)` in grid space for `gridSize=9`. Rasterized via `ShapeRasterizer.rasterizeTriangle()` which tests each cell center `(x+0.5, y+0.5)` with barycentric point-in-triangle. Result is deterministic filled occupancy: 16 cells (rows 1,3,5,7). Occupancy validated via `ShapeRasterizer.validateTriangle()` (centered, symmetric, straight edges, contiguous rows, no outside cells, no holes). Every occupied cell becomes one playable single-point arrow; directions assigned afterwards and validated with `PuzzleSolver` (shape fixed, only directions regenerated if unsolvable).

### Why not external SVG for Level 1
Level 1 triangle is a pure geometric primitive. Using an external SVG would add unnecessary dependency and licensing overhead for a shape that is trivial to define mathematically and guarantees a clean, symmetric, filled silhouette on a low-resolution grid.

## Future Shapes (Template Pipeline)

The same pipeline will be reused for:

- Level 2 → Square, Level 3 → Circle, Level 4 → Diamond, Level 5 → Pentagon, etc.
- Later: Flower, Leaf, Butterfly, Cat, Dog, etc.

Each future shape will be either:

1. **Procedurally generated** from exact vector math (for geometric shapes), or
2. **Rasterized from an SVG** that is verified to be public-domain / CC0 / MIT / Apache-2.0 with commercial-use permission.

Before any external SVG is imported, the following must be recorded in this file:

- Source name and URL
- License type and link
- Whether attribution is required (and where it is provided)
- Any modifications (simplification, hole preservation, thin-detail expansion)

No shape will be imported if its license prohibits commercial use or requires share-alike that conflicts with the game's distribution.

## Reference Inspiration (Not Copied)

The dense-silhouette concept (27×27 to 40×40 grids, reverse-placement, solver verification) was studied from the public repository `https://github.com/gtxPrime/arrow-escape` (MIT licensed). No code, assets, or shapes were copied verbatim; only the high-level pipeline (dense mask → fill → reverse placement → solver) informed the clean-room implementation in `lib/game/levels/shape_level_generator.dart` and `lib/game/solver/puzzle_solver.dart`.

## Verification for Level 1

- Grid size: 9
- Occupied cells: 16 (1+3+5+7)
- Bounding box: width 7, height 4, centered at (4.5, ~3.8)
- Occupancy ratio: 16/81 = 19.7%
- Silhouette coverage: 100% of triangle interior (no holes, no outside noise)
- Arrow count: 16 (one per cell, thin shaft)
- Solver: solvable=true, initialMoves=6, solutionDepth=16
- Visual: `ShapeRasterizer.debugBoard()` shows perfect filled triangle before arrows, identical after arrows.


## Levels 21–1000 — Shape Art

- **Source:** Original pixel art designed for this project from simple geometric primitives (circles, ellipses, polygons, thick lines) — no external SVGs, images or third-party assets.
- **License:** Original work, owned by the Arrow Escape project (no attribution required).
- **Implementation:** `lib/game/levels/shape_art.dart` stores one silhouette per level name (91 names: the Nature, Animals, Objects and Landmarks shapes plus 16 patterns) once at 64×64, cropped to the design's own outline, with up to three colour regions per shape (e.g. petals / centre / stem). `ShapeArt.fit` scales it to any board size by area coverage. Boards grow from 24×24 (Level 21) to 42×42 (Level 1000); combination levels stagger two shapes diagonally. Larger boards get one gap-preserving thickening pass, and thin diagonal strokes are bridged so every filled cell has an edge neighbour.
- **Level construction:** `ExtendedTemplates.buildRegions` places the art on the board and `DenseTiler` fills 100% of the silhouette with arrows in removal order (solvable by construction), never crossing colour regions. `LevelQuality` measures shape coverage, outside noise, occupancy, arrow length/bends, one-cell arrows, dependency depth and free opening moves; `PuzzleSolver` validates every generated level.
