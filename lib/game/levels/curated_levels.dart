// ignore_for_file: curly_braces_in_flow_control_structures
import '../../models/arrow.dart';
import '../../models/level.dart';
import '../../models/puzzle_path.dart';
import 'level_world.dart';

/// Level 1 ONLY — dense classic Arrow-Escape board (many individual pieces).
/// Levels 2-10 are curated dense shape boards on 20x20 (same tiling craft as L1).
/// L1 pipeline: dedicated deterministic layout, NO shape mask, NO giant lanes:
/// 20x20 board, 1-cell outer margin, inner 18x18 (324 cells) tiled with small
/// snake polyominoes (4-8 cells each) grown deterministically (seed 1).
/// Each tile is one playable arrow piece with its own L/U/C/S/Z/hook/stair/
/// spiral geometry and own bends. Each piece's escape direction is its
/// arrowhead (final segment) direction; pieces are tiled in removal order so
/// every level is solvable (outer pieces free first, inner unlock as outer
/// clears) while keeping each level's original silhouette cell-for-cell.
/// Arrows are thin shafts with small sharp heads (PuzzlePainter 0.095*cell).

Level buildCuratedLevel1() {
  const gridSize = 20;
  // Same silhouette as before (300 occupied cells), re-tiled into 73 pieces
  // (27 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(7, 12), GridPoint(7, 11)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(8, 12), GridPoint(8, 11)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(7, 17), GridPoint(7, 18)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(6, 18), GridPoint(6, 17)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(16, 18), GridPoint(17, 18)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(16, 17), GridPoint(17, 17)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(16, 10), GridPoint(17, 10)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(16, 11), GridPoint(17, 11)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(3, 18), GridPoint(3, 17)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(4, 18), GridPoint(4, 17)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(16, 8), GridPoint(17, 8)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(16, 7), GridPoint(17, 7)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(4, 11), GridPoint(4, 8)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(5, 7), GridPoint(4, 7)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(2, 7), GridPoint(1, 7), GridPoint(1, 9)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(2, 10), GridPoint(1, 10)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(5, 9), GridPoint(5, 10)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(5, 6), GridPoint(4, 6)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(5, 12), GridPoint(4, 12)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(2, 17), GridPoint(2, 18)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(5, 17), GridPoint(5, 18)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(2, 6), GridPoint(1, 6)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(3, 9), GridPoint(3, 8)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(16, 16), GridPoint(17, 16)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(16, 9), GridPoint(17, 9)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(8, 10), GridPoint(7, 10), GridPoint(7, 9), GridPoint(8, 9), GridPoint(8, 8), GridPoint(7, 8), GridPoint(7, 7)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(7, 6), GridPoint(8, 6)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(16, 15), GridPoint(17, 15)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(12, 6), GridPoint(13, 6), GridPoint(13, 7)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(12, 7), GridPoint(12, 9), GridPoint(13, 9), GridPoint(13, 10), GridPoint(12, 10), GridPoint(12, 11)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(9, 12), GridPoint(13, 12)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(16, 12), GridPoint(17, 12)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(16, 4), GridPoint(17, 4), GridPoint(17, 3)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(16, 3), GridPoint(13, 3)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '35', points: [GridPoint(8, 15), GridPoint(8, 18)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '36', points: [GridPoint(9, 15), GridPoint(9, 18)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '37', points: [GridPoint(7, 3), GridPoint(8, 3), GridPoint(8, 2)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '38', points: [GridPoint(10, 15), GridPoint(10, 18)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '39', points: [GridPoint(18, 15), GridPoint(18, 18)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '40', points: [GridPoint(6, 16), GridPoint(2, 16)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '41', points: [GridPoint(7, 15), GridPoint(2, 15)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '42', points: [GridPoint(1, 15), GridPoint(1, 18)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '43', points: [GridPoint(6, 11), GridPoint(6, 7)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '44', points: [GridPoint(6, 2), GridPoint(6, 3), GridPoint(4, 3), GridPoint(4, 2), GridPoint(3, 2)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '45', points: [GridPoint(11, 15), GridPoint(11, 18)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '46', points: [GridPoint(1, 3), GridPoint(2, 3), GridPoint(2, 2), GridPoint(1, 2), GridPoint(1, 1)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '47', points: [GridPoint(9, 11), GridPoint(9, 6)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '48', points: [GridPoint(2, 1), GridPoint(8, 1)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '49', points: [GridPoint(13, 2), GridPoint(17, 2)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '50', points: [GridPoint(11, 11), GridPoint(11, 6)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '51', points: [GridPoint(10, 11), GridPoint(10, 6)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '52', points: [GridPoint(10, 3), GridPoint(9, 3), GridPoint(9, 1)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '53', points: [GridPoint(12, 3), GridPoint(12, 2), GridPoint(10, 2), GridPoint(10, 1)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '54', points: [GridPoint(11, 1), GridPoint(17, 1)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '55', points: [GridPoint(10, 13), GridPoint(10, 14), GridPoint(11, 14), GridPoint(11, 13), GridPoint(12, 13)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '56', points: [GridPoint(16, 14), GridPoint(16, 13), GridPoint(17, 13), GridPoint(17, 14), GridPoint(18, 14)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '57', points: [GridPoint(18, 13), GridPoint(18, 7)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '58', points: [GridPoint(15, 7), GridPoint(14, 7), GridPoint(14, 8), GridPoint(15, 8), GridPoint(15, 10)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '59', points: [GridPoint(14, 6), GridPoint(16, 6), GridPoint(16, 5), GridPoint(17, 5)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '60', points: [GridPoint(18, 6), GridPoint(18, 1)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '61', points: [GridPoint(13, 13), GridPoint(13, 14), GridPoint(12, 14), GridPoint(12, 18)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '62', points: [GridPoint(15, 5), GridPoint(15, 4), GridPoint(14, 4), GridPoint(14, 5), GridPoint(13, 5), GridPoint(13, 4), GridPoint(12, 4)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '63', points: [GridPoint(12, 5), GridPoint(11, 5), GridPoint(11, 4), GridPoint(10, 4), GridPoint(10, 5), GridPoint(9, 5)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '64', points: [GridPoint(9, 4), GridPoint(8, 4), GridPoint(8, 5), GridPoint(7, 5), GridPoint(7, 4), GridPoint(6, 4)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '65', points: [GridPoint(9, 14), GridPoint(9, 13), GridPoint(8, 13), GridPoint(8, 14), GridPoint(7, 14)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '66', points: [GridPoint(7, 13), GridPoint(6, 13), GridPoint(6, 14), GridPoint(5, 14), GridPoint(5, 13), GridPoint(4, 13)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '67', points: [GridPoint(15, 11), GridPoint(14, 11), GridPoint(14, 12), GridPoint(15, 12), GridPoint(15, 13), GridPoint(14, 13), GridPoint(14, 14)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '68', points: [GridPoint(15, 14), GridPoint(15, 15), GridPoint(13, 15), GridPoint(13, 18)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '69', points: [GridPoint(3, 11), GridPoint(3, 12), GridPoint(2, 12), GridPoint(2, 11), GridPoint(1, 11)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '70', points: [GridPoint(6, 5), GridPoint(5, 5), GridPoint(5, 4), GridPoint(4, 4)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '71', points: [GridPoint(4, 5), GridPoint(3, 5), GridPoint(3, 4), GridPoint(2, 4), GridPoint(2, 5), GridPoint(1, 5)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '72', points: [GridPoint(4, 14), GridPoint(3, 14), GridPoint(3, 13), GridPoint(2, 13), GridPoint(2, 14), GridPoint(1, 14)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '73', points: [GridPoint(14, 16), GridPoint(15, 16), GridPoint(15, 17), GridPoint(14, 17), GridPoint(14, 18)], direction: ArrowDirection.down, colorIndex: 1),
  ];
  return Level(
    levelId: 1,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Dense Maze',
    shapeName: 'Dense Maze',
    category: 'Geometry',
    world: 1,
    worldName: LevelWorlds.world1.title,
    difficulty: 2,
    difficultyName: 'Hard',
  );
}

Level buildCuratedLevel2() {
  const gridSize = 20;
  // Same silhouette as before (129 occupied cells), re-tiled into 22 pieces
  // (19 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(2, 17), GridPoint(3, 17)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(10, 9), GridPoint(9, 9)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(5, 17), GridPoint(6, 17), GridPoint(6, 15)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(7, 15), GridPoint(7, 17)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(11, 10), GridPoint(10, 10), GridPoint(10, 11), GridPoint(11, 11), GridPoint(11, 12)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(9, 10), GridPoint(8, 10), GridPoint(8, 11), GridPoint(9, 11), GridPoint(9, 12)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(10, 14), GridPoint(10, 15), GridPoint(8, 15), GridPoint(8, 17)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(9, 17), GridPoint(9, 16), GridPoint(10, 16), GridPoint(10, 17), GridPoint(11, 17)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(7, 11), GridPoint(6, 11), GridPoint(6, 10), GridPoint(7, 10), GridPoint(7, 9)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(11, 15), GridPoint(12, 15), GridPoint(12, 16), GridPoint(13, 16), GridPoint(13, 15), GridPoint(14, 15)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(13, 12), GridPoint(12, 12), GridPoint(12, 11), GridPoint(13, 11), GridPoint(13, 10)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(10, 6), GridPoint(10, 5), GridPoint(9, 5), GridPoint(9, 7), GridPoint(8, 7)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(8, 8), GridPoint(10, 8), GridPoint(10, 7), GridPoint(11, 7), GridPoint(11, 9), GridPoint(12, 9)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(6, 9), GridPoint(6, 8), GridPoint(7, 8), GridPoint(7, 6), GridPoint(8, 6), GridPoint(8, 5)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(10, 13), GridPoint(9, 13), GridPoint(9, 14), GridPoint(8, 14), GridPoint(8, 12), GridPoint(6, 12)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(12, 17), GridPoint(14, 17), GridPoint(14, 16), GridPoint(15, 16), GridPoint(15, 17), GridPoint(17, 17)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(13, 9), GridPoint(13, 8), GridPoint(12, 8), GridPoint(12, 6), GridPoint(11, 6), GridPoint(11, 5)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(11, 13), GridPoint(11, 14), GridPoint(12, 14), GridPoint(12, 13), GridPoint(13, 13), GridPoint(13, 14), GridPoint(14, 14)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(8, 4), GridPoint(9, 4), GridPoint(9, 2), GridPoint(10, 2), GridPoint(10, 4), GridPoint(11, 4)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(7, 13), GridPoint(6, 13), GridPoint(6, 14), GridPoint(5, 14), GridPoint(5, 16), GridPoint(4, 16)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(3, 16), GridPoint(3, 15), GridPoint(4, 15), GridPoint(4, 13), GridPoint(5, 13), GridPoint(5, 12)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(16, 16), GridPoint(16, 15), GridPoint(15, 15), GridPoint(15, 13), GridPoint(14, 13), GridPoint(14, 11)], direction: ArrowDirection.up, colorIndex: 4),
  ];
  return Level(
    levelId: 2,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Triangle',
    shapeName: 'Triangle',
    category: 'Geometry',
    world: 1,
    worldName: LevelWorlds.world1.title,
    difficulty: 2,
    difficultyName: 'Hard',
  );
}

Level buildCuratedLevel3() {
  const gridSize = 20;
  // Same silhouette as before (195 occupied cells), re-tiled into 42 pieces
  // (27 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(12, 14), GridPoint(13, 14)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(12, 13), GridPoint(13, 13)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(13, 9), GridPoint(13, 8)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(14, 9), GridPoint(14, 8)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(7, 8), GridPoint(7, 9)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(6, 9), GridPoint(6, 8)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(14, 7), GridPoint(13, 7)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(8, 2), GridPoint(8, 3)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(7, 7), GridPoint(6, 7)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(6, 6), GridPoint(7, 6)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(7, 14), GridPoint(7, 15), GridPoint(6, 15)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(6, 16), GridPoint(7, 16)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(13, 12), GridPoint(12, 12)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(5, 6), GridPoint(5, 9)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(16, 9), GridPoint(17, 9), GridPoint(17, 8)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(8, 6), GridPoint(8, 10)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(10, 10), GridPoint(9, 10), GridPoint(9, 6)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(11, 9), GridPoint(12, 9), GridPoint(12, 7)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(7, 13), GridPoint(7, 10), GridPoint(5, 10)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(10, 12), GridPoint(11, 12), GridPoint(11, 14)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(8, 11), GridPoint(9, 11), GridPoint(9, 12), GridPoint(8, 12), GridPoint(8, 13)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(6, 14), GridPoint(6, 11), GridPoint(5, 11)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(9, 13), GridPoint(10, 13), GridPoint(10, 14), GridPoint(8, 14), GridPoint(8, 16)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(5, 12), GridPoint(5, 16)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(9, 16), GridPoint(9, 15), GridPoint(10, 15), GridPoint(10, 16), GridPoint(11, 16)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(2, 11), GridPoint(3, 11), GridPoint(3, 10), GridPoint(2, 10), GridPoint(2, 9)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(10, 9), GridPoint(10, 8), GridPoint(11, 8), GridPoint(11, 7), GridPoint(10, 7), GridPoint(10, 6)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(10, 11), GridPoint(11, 11), GridPoint(11, 10), GridPoint(12, 10), GridPoint(12, 11), GridPoint(13, 11)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(4, 10), GridPoint(4, 9), GridPoint(3, 9), GridPoint(3, 8), GridPoint(4, 8), GridPoint(4, 6)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(7, 2), GridPoint(7, 3), GridPoint(6, 3), GridPoint(6, 2), GridPoint(5, 2)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(13, 10), GridPoint(15, 10), GridPoint(15, 11), GridPoint(16, 11), GridPoint(16, 10), GridPoint(17, 10)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(9, 2), GridPoint(9, 3), GridPoint(10, 3), GridPoint(10, 2), GridPoint(11, 2), GridPoint(11, 3), GridPoint(12, 3)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(11, 6), GridPoint(12, 6), GridPoint(12, 5), GridPoint(13, 5), GridPoint(13, 6), GridPoint(14, 6)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(13, 4), GridPoint(11, 4), GridPoint(11, 5), GridPoint(10, 5), GridPoint(10, 4), GridPoint(9, 4)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '35', points: [GridPoint(14, 11), GridPoint(14, 12), GridPoint(15, 12), GridPoint(15, 13), GridPoint(14, 13), GridPoint(14, 14)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '36', points: [GridPoint(9, 5), GridPoint(8, 5), GridPoint(8, 4), GridPoint(7, 4), GridPoint(7, 5), GridPoint(5, 5)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '37', points: [GridPoint(15, 9), GridPoint(15, 8), GridPoint(16, 8), GridPoint(16, 7), GridPoint(15, 7), GridPoint(15, 6)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '38', points: [GridPoint(4, 11), GridPoint(4, 12), GridPoint(3, 12), GridPoint(3, 13), GridPoint(4, 13), GridPoint(4, 15)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '39', points: [GridPoint(1, 10), GridPoint(1, 8), GridPoint(2, 8), GridPoint(2, 7), GridPoint(3, 7), GridPoint(3, 6)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '40', points: [GridPoint(12, 2), GridPoint(13, 2), GridPoint(13, 3), GridPoint(14, 3), GridPoint(14, 5), GridPoint(15, 5)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '41', points: [GridPoint(11, 15), GridPoint(12, 15), GridPoint(12, 16), GridPoint(13, 16), GridPoint(13, 15), GridPoint(14, 15)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '42', points: [GridPoint(6, 4), GridPoint(5, 4), GridPoint(5, 3), GridPoint(4, 3), GridPoint(4, 5), GridPoint(3, 5)], direction: ArrowDirection.left, colorIndex: 0),
  ];
  return Level(
    levelId: 3,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Hexagon',
    shapeName: 'Hexagon',
    category: 'Geometry',
    world: 1,
    worldName: LevelWorlds.world1.title,
    difficulty: 3,
    difficultyName: 'Hard',
  );
}

Level buildCuratedLevel4() {
  const gridSize = 20;
  // Same silhouette as before (213 occupied cells), re-tiled into 39 pieces
  // (31 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(5, 3), GridPoint(6, 3)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(5, 2), GridPoint(6, 2)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(9, 15), GridPoint(8, 15), GridPoint(8, 14), GridPoint(9, 14), GridPoint(9, 13)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(3, 11), GridPoint(3, 12), GridPoint(4, 12), GridPoint(4, 11), GridPoint(6, 11)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(9, 11), GridPoint(9, 9)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(9, 16), GridPoint(9, 17), GridPoint(8, 17)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(14, 11), GridPoint(15, 11), GridPoint(15, 9)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(16, 5), GridPoint(16, 6), GridPoint(15, 6)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(5, 12), GridPoint(9, 12)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(12, 9), GridPoint(12, 13)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(12, 15), GridPoint(12, 16), GridPoint(13, 16)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(9, 8), GridPoint(9, 3)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(12, 8), GridPoint(12, 3)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(6, 9), GridPoint(6, 10), GridPoint(3, 10)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(11, 3), GridPoint(10, 3), GridPoint(10, 5)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(6, 8), GridPoint(6, 7), GridPoint(5, 7), GridPoint(5, 9), GridPoint(3, 9)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(8, 11), GridPoint(7, 11), GridPoint(7, 7)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(7, 6), GridPoint(7, 5), GridPoint(6, 5), GridPoint(6, 6), GridPoint(5, 6)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(8, 10), GridPoint(8, 5)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(13, 12), GridPoint(13, 10), GridPoint(14, 10), GridPoint(14, 9), GridPoint(13, 9), GridPoint(13, 8)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(16, 9), GridPoint(17, 9), GridPoint(17, 10), GridPoint(16, 10), GridPoint(16, 11)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(9, 2), GridPoint(9, 1), GridPoint(10, 1), GridPoint(10, 2), GridPoint(12, 2)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(11, 4), GridPoint(11, 6), GridPoint(10, 6), GridPoint(10, 7), GridPoint(11, 7), GridPoint(11, 8)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(4, 8), GridPoint(4, 7), GridPoint(3, 7), GridPoint(3, 8), GridPoint(1, 8)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(2, 9), GridPoint(1, 9), GridPoint(1, 10), GridPoint(2, 10), GridPoint(2, 12)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(6, 4), GridPoint(5, 4), GridPoint(5, 5), GridPoint(4, 5), GridPoint(4, 6), GridPoint(3, 6)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(13, 7), GridPoint(13, 6), GridPoint(14, 6), GridPoint(14, 5), GridPoint(13, 5), GridPoint(13, 4)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(10, 8), GridPoint(10, 9), GridPoint(11, 9), GridPoint(11, 10), GridPoint(10, 10), GridPoint(10, 11)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(11, 11), GridPoint(11, 12), GridPoint(10, 12), GridPoint(10, 13), GridPoint(11, 13), GridPoint(11, 14)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(15, 5), GridPoint(15, 4), GridPoint(14, 4), GridPoint(14, 3), GridPoint(13, 3), GridPoint(13, 2)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(8, 16), GridPoint(7, 16), GridPoint(7, 15), GridPoint(6, 15), GridPoint(6, 16), GridPoint(5, 16)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(14, 7), GridPoint(14, 8), GridPoint(15, 8), GridPoint(15, 7), GridPoint(16, 7), GridPoint(16, 8), GridPoint(17, 8)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(8, 13), GridPoint(7, 13), GridPoint(7, 14), GridPoint(6, 14), GridPoint(6, 13), GridPoint(4, 13)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(12, 14), GridPoint(13, 14), GridPoint(13, 13), GridPoint(14, 13), GridPoint(14, 12), GridPoint(16, 12)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '35', points: [GridPoint(2, 7), GridPoint(2, 5), GridPoint(3, 5), GridPoint(3, 4), GridPoint(4, 4), GridPoint(4, 3)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '36', points: [GridPoint(7, 4), GridPoint(8, 4), GridPoint(8, 3), GridPoint(7, 3), GridPoint(7, 2), GridPoint(8, 2), GridPoint(8, 1)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '37', points: [GridPoint(10, 14), GridPoint(10, 15), GridPoint(11, 15), GridPoint(11, 16), GridPoint(10, 16), GridPoint(10, 17)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '38', points: [GridPoint(5, 14), GridPoint(5, 15), GridPoint(4, 15), GridPoint(4, 14), GridPoint(3, 14), GridPoint(3, 13), GridPoint(2, 13)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '39', points: [GridPoint(13, 15), GridPoint(14, 15), GridPoint(14, 14), GridPoint(15, 14), GridPoint(15, 13), GridPoint(16, 13)], direction: ArrowDirection.right, colorIndex: 3),
  ];
  return Level(
    levelId: 4,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Circle',
    shapeName: 'Circle',
    category: 'Geometry',
    world: 1,
    worldName: LevelWorlds.world1.title,
    difficulty: 3,
    difficultyName: 'Hard',
  );
}

Level buildCuratedLevel5() {
  const gridSize = 20;
  // Same silhouette as before (188 occupied cells), re-tiled into 42 pieces
  // (30 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(13, 15), GridPoint(12, 15)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(13, 16), GridPoint(12, 16)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(5, 15), GridPoint(5, 14)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(6, 14), GridPoint(6, 15)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(13, 12), GridPoint(13, 11)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(14, 11), GridPoint(14, 12)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(10, 4), GridPoint(10, 5)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(11, 5), GridPoint(11, 4)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(14, 15), GridPoint(14, 16)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(12, 12), GridPoint(12, 11)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(9, 4), GridPoint(9, 5)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(9, 2), GridPoint(9, 1), GridPoint(10, 1)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(5, 5), GridPoint(5, 4), GridPoint(4, 4)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(3, 8), GridPoint(2, 8), GridPoint(2, 9)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(11, 11), GridPoint(11, 12), GridPoint(7, 12)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(3, 9), GridPoint(4, 9), GridPoint(4, 8), GridPoint(5, 8), GridPoint(5, 9), GridPoint(6, 9)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(9, 8), GridPoint(9, 6), GridPoint(11, 6)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(9, 9), GridPoint(10, 9), GridPoint(10, 7), GridPoint(11, 7)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(7, 15), GridPoint(11, 15), GridPoint(11, 16)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(10, 16), GridPoint(5, 16)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(6, 12), GridPoint(6, 13), GridPoint(5, 13), GridPoint(5, 12), GridPoint(3, 12)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(11, 9), GridPoint(11, 8), GridPoint(13, 8)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(3, 13), GridPoint(4, 13), GridPoint(4, 16)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(17, 7), GridPoint(16, 7), GridPoint(16, 8)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(10, 10), GridPoint(10, 11), GridPoint(9, 11), GridPoint(9, 10), GridPoint(8, 10)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(7, 13), GridPoint(7, 14), GridPoint(8, 14), GridPoint(8, 13), GridPoint(9, 13)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(5, 7), GridPoint(5, 6), GridPoint(4, 6), GridPoint(4, 5), GridPoint(3, 5)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(11, 10), GridPoint(12, 10), GridPoint(12, 9), GridPoint(13, 9), GridPoint(13, 10), GridPoint(14, 10)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(8, 9), GridPoint(7, 9), GridPoint(7, 8), GridPoint(8, 8), GridPoint(8, 7)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(6, 8), GridPoint(6, 7), GridPoint(7, 7), GridPoint(7, 6), GridPoint(8, 6), GridPoint(8, 5)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(13, 7), GridPoint(12, 7), GridPoint(12, 6), GridPoint(13, 6), GridPoint(13, 5), GridPoint(12, 5), GridPoint(12, 4)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(15, 9), GridPoint(16, 9), GridPoint(16, 10), GridPoint(15, 10), GridPoint(15, 12)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(9, 14), GridPoint(10, 14), GridPoint(10, 13), GridPoint(11, 13), GridPoint(11, 14), GridPoint(12, 14)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(4, 7), GridPoint(3, 7), GridPoint(3, 6), GridPoint(2, 6), GridPoint(2, 7), GridPoint(1, 7)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '35', points: [GridPoint(9, 3), GridPoint(10, 3), GridPoint(10, 2), GridPoint(11, 2), GridPoint(11, 3), GridPoint(12, 3)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '36', points: [GridPoint(14, 9), GridPoint(14, 8), GridPoint(15, 8), GridPoint(15, 7), GridPoint(14, 7), GridPoint(14, 6)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '37', points: [GridPoint(12, 13), GridPoint(13, 13), GridPoint(13, 14), GridPoint(14, 14), GridPoint(14, 13), GridPoint(15, 13)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '38', points: [GridPoint(8, 11), GridPoint(7, 11), GridPoint(7, 10), GridPoint(6, 10), GridPoint(6, 11), GridPoint(5, 11)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '39', points: [GridPoint(6, 6), GridPoint(6, 5), GridPoint(7, 5), GridPoint(7, 4), GridPoint(6, 4), GridPoint(6, 3)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '40', points: [GridPoint(13, 4), GridPoint(14, 4), GridPoint(14, 5), GridPoint(15, 5), GridPoint(15, 6), GridPoint(16, 6)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '41', points: [GridPoint(8, 4), GridPoint(8, 3), GridPoint(7, 3), GridPoint(7, 2), GridPoint(8, 2), GridPoint(8, 1)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '42', points: [GridPoint(5, 10), GridPoint(4, 10), GridPoint(4, 11), GridPoint(3, 11), GridPoint(3, 10), GridPoint(2, 10)], direction: ArrowDirection.left, colorIndex: 0),
  ];
  return Level(
    levelId: 5,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Pentagon',
    shapeName: 'Pentagon',
    category: 'Geometry',
    world: 1,
    worldName: LevelWorlds.world1.title,
    difficulty: 3,
    difficultyName: 'Hard',
  );
}

Level buildCuratedLevel6() {
  const gridSize = 20;
  // Same silhouette as before (111 occupied cells), re-tiled into 29 pieces
  // (19 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(9, 1), GridPoint(9, 2)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(5, 13), GridPoint(5, 12)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(6, 13), GridPoint(6, 12)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(6, 8), GridPoint(5, 8)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(9, 5), GridPoint(8, 5)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(5, 15), GridPoint(5, 14), GridPoint(6, 14)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(12, 11), GridPoint(13, 11), GridPoint(13, 15)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(9, 7), GridPoint(13, 7)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(7, 8), GridPoint(11, 8)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(13, 6), GridPoint(10, 6)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(9, 6), GridPoint(8, 6), GridPoint(8, 7), GridPoint(6, 7)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(3, 6), GridPoint(4, 6), GridPoint(4, 8)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(2, 7), GridPoint(3, 7), GridPoint(3, 8)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(4, 16)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(14, 16)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(12, 9), GridPoint(12, 8), GridPoint(13, 8), GridPoint(13, 9), GridPoint(14, 9)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(15, 8), GridPoint(14, 8), GridPoint(14, 6)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(16, 7), GridPoint(15, 7), GridPoint(15, 6)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(11, 11), GridPoint(9, 11), GridPoint(9, 12)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(10, 12), GridPoint(12, 12), GridPoint(12, 14)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(9, 13), GridPoint(11, 13), GridPoint(11, 14)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(8, 4), GridPoint(8, 3), GridPoint(10, 3)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(13, 10), GridPoint(11, 10), GridPoint(11, 9), GridPoint(10, 9)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(10, 10), GridPoint(9, 10), GridPoint(9, 9), GridPoint(7, 9)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(9, 4), GridPoint(10, 4), GridPoint(10, 5), GridPoint(11, 5)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(5, 7), GridPoint(5, 6), GridPoint(7, 6), GridPoint(7, 5)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(7, 12), GridPoint(8, 12), GridPoint(8, 13), GridPoint(7, 13), GridPoint(7, 14)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(8, 11), GridPoint(8, 10), GridPoint(7, 10), GridPoint(7, 11), GridPoint(5, 11)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(6, 9), GridPoint(6, 10), GridPoint(5, 10), GridPoint(5, 9), GridPoint(4, 9)], direction: ArrowDirection.left, colorIndex: 5),
  ];
  return Level(
    levelId: 6,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Star',
    shapeName: 'Star',
    category: 'Geometry',
    world: 1,
    worldName: LevelWorlds.world1.title,
    difficulty: 4,
    difficultyName: 'Expert',
  );
}

Level buildCuratedLevel7() {
  const gridSize = 20;
  // Same silhouette as before (177 occupied cells), re-tiled into 34 pieces
  // (26 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(10, 8), GridPoint(9, 8)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(10, 7), GridPoint(9, 7)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(7, 16), GridPoint(7, 15)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(10, 9), GridPoint(9, 9)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(4, 8), GridPoint(3, 8), GridPoint(3, 7)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(2, 7), GridPoint(2, 8)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(10, 6), GridPoint(9, 6)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(14, 9), GridPoint(15, 9), GridPoint(15, 6)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(16, 6), GridPoint(16, 9)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(11, 6), GridPoint(11, 9)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(8, 8), GridPoint(6, 8), GridPoint(6, 7)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(6, 11), GridPoint(4, 11), GridPoint(4, 12)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(5, 12), GridPoint(7, 12), GridPoint(7, 11), GridPoint(8, 11)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(7, 7), GridPoint(8, 7), GridPoint(8, 6), GridPoint(7, 6), GridPoint(7, 4)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(7, 3), GridPoint(8, 3), GridPoint(8, 5), GridPoint(11, 5)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(8, 17), GridPoint(8, 16), GridPoint(9, 16), GridPoint(9, 17), GridPoint(10, 17)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(8, 12), GridPoint(9, 12), GridPoint(9, 11), GridPoint(10, 11), GridPoint(10, 10), GridPoint(11, 10)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(5, 8), GridPoint(5, 7), GridPoint(4, 7), GridPoint(4, 6), GridPoint(6, 6), GridPoint(6, 5)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(12, 10), GridPoint(12, 9), GridPoint(13, 9), GridPoint(13, 8), GridPoint(14, 8), GridPoint(14, 6)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(9, 10), GridPoint(8, 10), GridPoint(8, 9), GridPoint(7, 9), GridPoint(7, 10), GridPoint(6, 10)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(10, 12), GridPoint(11, 12), GridPoint(11, 11), GridPoint(12, 11), GridPoint(12, 12), GridPoint(14, 12)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(12, 8), GridPoint(12, 7), GridPoint(13, 7), GridPoint(13, 6), GridPoint(12, 6), GridPoint(12, 5)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(11, 3), GridPoint(11, 4), GridPoint(12, 4), GridPoint(12, 3), GridPoint(14, 3)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(6, 4), GridPoint(6, 3), GridPoint(5, 3), GridPoint(5, 5), GridPoint(4, 5)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(13, 11), GridPoint(13, 10), GridPoint(14, 10), GridPoint(14, 11), GridPoint(15, 11), GridPoint(15, 10), GridPoint(16, 10)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(6, 9), GridPoint(5, 9), GridPoint(5, 10), GridPoint(4, 10), GridPoint(4, 9), GridPoint(3, 9)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(12, 13), GridPoint(12, 14), GridPoint(11, 14), GridPoint(11, 13), GridPoint(10, 13), GridPoint(10, 14), GridPoint(9, 14)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(2, 9), GridPoint(2, 10), GridPoint(3, 10), GridPoint(3, 11), GridPoint(2, 11), GridPoint(2, 12)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(13, 4), GridPoint(13, 5), GridPoint(14, 5), GridPoint(14, 4), GridPoint(15, 4), GridPoint(15, 5), GridPoint(16, 5)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(9, 13), GridPoint(8, 13), GridPoint(8, 14), GridPoint(7, 14), GridPoint(7, 13), GridPoint(6, 13)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(3, 12), GridPoint(3, 13), GridPoint(5, 13), GridPoint(5, 14), GridPoint(6, 14), GridPoint(6, 15)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(8, 15), GridPoint(10, 15), GridPoint(10, 16), GridPoint(11, 16), GridPoint(11, 15), GridPoint(12, 15)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(3, 6), GridPoint(2, 6), GridPoint(2, 5), GridPoint(3, 5), GridPoint(3, 4), GridPoint(4, 4), GridPoint(4, 3)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(16, 11), GridPoint(16, 12), GridPoint(15, 12), GridPoint(15, 13), GridPoint(13, 13), GridPoint(13, 14)], direction: ArrowDirection.down, colorIndex: 4),
  ];
  return Level(
    levelId: 7,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Heart',
    shapeName: 'Heart',
    category: 'Geometry',
    world: 1,
    worldName: LevelWorlds.world1.title,
    difficulty: 4,
    difficultyName: 'Expert',
  );
}

Level buildCuratedLevel8() {
  const gridSize = 20;
  // Same silhouette as before (145 occupied cells), re-tiled into 34 pieces
  // (27 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(1, 9), GridPoint(2, 9), GridPoint(2, 10)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(9, 14), GridPoint(10, 14)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(8, 10), GridPoint(8, 9)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(9, 10), GridPoint(9, 9)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(9, 13), GridPoint(10, 13)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(9, 6), GridPoint(8, 6)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(10, 15), GridPoint(9, 15)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(10, 10), GridPoint(10, 9)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(15, 9), GridPoint(15, 10), GridPoint(16, 10), GridPoint(16, 9), GridPoint(17, 9)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(3, 9), GridPoint(4, 9), GridPoint(4, 10)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(7, 13), GridPoint(6, 13), GridPoint(6, 14)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(9, 17), GridPoint(9, 16), GridPoint(10, 16)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(9, 3), GridPoint(10, 3), GridPoint(10, 2)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(8, 7), GridPoint(8, 8), GridPoint(10, 8)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(6, 10), GridPoint(7, 10), GridPoint(7, 6)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(9, 7), GridPoint(10, 7), GridPoint(10, 6), GridPoint(12, 6)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(12, 7), GridPoint(11, 7), GridPoint(11, 8), GridPoint(12, 8), GridPoint(12, 10)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(15, 7), GridPoint(15, 8), GridPoint(16, 8)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(5, 10), GridPoint(5, 9), GridPoint(6, 9), GridPoint(6, 6)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(8, 4), GridPoint(8, 5), GridPoint(7, 5), GridPoint(7, 4), GridPoint(6, 4)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(11, 9), GridPoint(11, 11), GridPoint(12, 11), GridPoint(12, 12)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(5, 7), GridPoint(5, 8), GridPoint(2, 8)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(13, 9), GridPoint(14, 9), GridPoint(14, 10), GridPoint(13, 10), GridPoint(13, 11)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(10, 12), GridPoint(10, 11), GridPoint(9, 11), GridPoint(9, 12), GridPoint(8, 12)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(13, 13), GridPoint(13, 12), GridPoint(14, 12), GridPoint(14, 11), GridPoint(15, 11)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(14, 8), GridPoint(13, 8), GridPoint(13, 7), GridPoint(14, 7), GridPoint(14, 6)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(9, 1), GridPoint(9, 2), GridPoint(8, 2), GridPoint(8, 3), GridPoint(7, 3)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(8, 11), GridPoint(7, 11), GridPoint(7, 12), GridPoint(6, 12), GridPoint(6, 11), GridPoint(5, 11)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(9, 5), GridPoint(9, 4), GridPoint(10, 4), GridPoint(10, 5), GridPoint(11, 5)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(3, 10), GridPoint(3, 11), GridPoint(4, 11), GridPoint(4, 12), GridPoint(5, 12), GridPoint(5, 13)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(11, 12), GridPoint(11, 13), GridPoint(12, 13), GridPoint(12, 14), GridPoint(11, 14), GridPoint(11, 15)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(6, 5), GridPoint(5, 5), GridPoint(5, 6), GridPoint(4, 6), GridPoint(4, 7), GridPoint(3, 7)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(8, 13), GridPoint(8, 14), GridPoint(7, 14), GridPoint(7, 15), GridPoint(8, 15), GridPoint(8, 16)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(13, 6), GridPoint(13, 5), GridPoint(12, 5), GridPoint(12, 4), GridPoint(11, 4), GridPoint(11, 3)], direction: ArrowDirection.up, colorIndex: 4),
  ];
  return Level(
    levelId: 8,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Diamond',
    shapeName: 'Diamond',
    category: 'Geometry',
    world: 1,
    worldName: LevelWorlds.world1.title,
    difficulty: 4,
    difficultyName: 'Expert',
  );
}

Level buildCuratedLevel9() {
  const gridSize = 20;
  // Same silhouette as before (229 occupied cells), re-tiled into 45 pieces
  // (35 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(15, 12), GridPoint(14, 12)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(14, 13), GridPoint(15, 13)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(4, 11), GridPoint(3, 11)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(3, 10), GridPoint(4, 10)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(3, 6), GridPoint(4, 6)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(3, 5), GridPoint(4, 5)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(2, 11), GridPoint(2, 10)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(17, 7), GridPoint(16, 7)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(9, 5), GridPoint(10, 5), GridPoint(10, 6)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(6, 5), GridPoint(7, 5), GridPoint(7, 6), GridPoint(6, 6), GridPoint(6, 7)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(5, 7), GridPoint(5, 5)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(10, 7), GridPoint(10, 13)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(8, 4), GridPoint(8, 3), GridPoint(9, 3)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(17, 8), GridPoint(16, 8), GridPoint(16, 9), GridPoint(17, 9), GridPoint(17, 10)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(15, 11), GridPoint(14, 11), GridPoint(14, 10), GridPoint(15, 10), GridPoint(15, 7)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(12, 13), GridPoint(11, 13), GridPoint(11, 11)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(13, 13), GridPoint(13, 12), GridPoint(12, 12), GridPoint(12, 11)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(13, 11), GridPoint(13, 10), GridPoint(11, 10), GridPoint(11, 9)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(12, 9), GridPoint(14, 9), GridPoint(14, 7)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(12, 8), GridPoint(11, 8), GridPoint(11, 5)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(13, 8), GridPoint(13, 7), GridPoint(12, 7), GridPoint(12, 5)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(13, 2), GridPoint(12, 2), GridPoint(12, 1), GridPoint(11, 1), GridPoint(11, 2), GridPoint(10, 2)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(6, 10), GridPoint(5, 10), GridPoint(5, 11), GridPoint(6, 11), GridPoint(6, 12)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(5, 12), GridPoint(5, 13), GridPoint(6, 13), GridPoint(6, 14), GridPoint(5, 14), GridPoint(5, 15)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(10, 1), GridPoint(9, 1), GridPoint(9, 2), GridPoint(8, 2), GridPoint(8, 1), GridPoint(6, 1)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(8, 5), GridPoint(8, 6), GridPoint(9, 6), GridPoint(9, 10)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(16, 10), GridPoint(16, 11), GridPoint(17, 11), GridPoint(17, 12), GridPoint(16, 12), GridPoint(16, 13)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(8, 7), GridPoint(7, 7), GridPoint(7, 8), GridPoint(8, 8), GridPoint(8, 9)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(7, 9), GridPoint(6, 9), GridPoint(6, 8), GridPoint(5, 8), GridPoint(5, 9), GridPoint(4, 9)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(7, 10), GridPoint(8, 10), GridPoint(8, 11), GridPoint(9, 11), GridPoint(9, 13)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(7, 2), GridPoint(7, 3), GridPoint(6, 3), GridPoint(6, 2), GridPoint(5, 2)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(7, 11), GridPoint(7, 12), GridPoint(8, 12), GridPoint(8, 13), GridPoint(7, 13), GridPoint(7, 14)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(13, 6), GridPoint(13, 5), GridPoint(14, 5), GridPoint(14, 6), GridPoint(17, 6)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(4, 8), GridPoint(4, 7), GridPoint(3, 7), GridPoint(3, 9), GridPoint(2, 9)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '35', points: [GridPoint(1, 9), GridPoint(1, 12), GridPoint(2, 12), GridPoint(2, 13)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '36', points: [GridPoint(9, 4), GridPoint(10, 4), GridPoint(10, 3), GridPoint(11, 3), GridPoint(11, 4), GridPoint(13, 4)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '37', points: [GridPoint(6, 15), GridPoint(8, 15), GridPoint(8, 14), GridPoint(9, 14), GridPoint(9, 15), GridPoint(10, 15)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '38', points: [GridPoint(11, 17), GridPoint(11, 16), GridPoint(10, 16), GridPoint(10, 17), GridPoint(8, 17)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '39', points: [GridPoint(7, 4), GridPoint(5, 4), GridPoint(5, 3), GridPoint(4, 3), GridPoint(4, 4), GridPoint(3, 4)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '40', points: [GridPoint(10, 14), GridPoint(11, 14), GridPoint(11, 15), GridPoint(12, 15), GridPoint(12, 14), GridPoint(13, 14)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '41', points: [GridPoint(3, 12), GridPoint(4, 12), GridPoint(4, 13), GridPoint(3, 13), GridPoint(3, 14), GridPoint(4, 14), GridPoint(4, 15)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '42', points: [GridPoint(15, 14), GridPoint(14, 14), GridPoint(14, 15), GridPoint(13, 15), GridPoint(13, 16), GridPoint(12, 16), GridPoint(12, 17)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '43', points: [GridPoint(12, 3), GridPoint(14, 3), GridPoint(14, 4), GridPoint(15, 4), GridPoint(15, 5), GridPoint(16, 5)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '44', points: [GridPoint(9, 16), GridPoint(7, 16), GridPoint(7, 17), GridPoint(6, 17), GridPoint(6, 16), GridPoint(5, 16)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '45', points: [GridPoint(1, 8), GridPoint(2, 8), GridPoint(2, 7), GridPoint(1, 7), GridPoint(1, 6), GridPoint(2, 6), GridPoint(2, 5)], direction: ArrowDirection.up, colorIndex: 3),
  ];
  return Level(
    levelId: 9,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Octagon',
    shapeName: 'Octagon',
    category: 'Geometry',
    world: 1,
    worldName: LevelWorlds.world1.title,
    difficulty: 5,
    difficultyName: 'Master',
  );
}

Level buildCuratedLevel10() {
  const gridSize = 20;
  // Same silhouette as before (288 occupied cells), re-tiled into 52 pieces
  // (39 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(2, 15), GridPoint(2, 14)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(1, 14), GridPoint(1, 15)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(12, 18), GridPoint(12, 17)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(13, 17), GridPoint(13, 18)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(14, 17), GridPoint(14, 18)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(15, 1), GridPoint(15, 2)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(15, 17), GridPoint(15, 18)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(16, 11), GridPoint(12, 11)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(14, 1), GridPoint(14, 2), GridPoint(13, 2), GridPoint(13, 1), GridPoint(11, 1)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(7, 17), GridPoint(6, 17), GridPoint(6, 14)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(12, 2), GridPoint(10, 2), GridPoint(10, 1), GridPoint(8, 1)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(9, 2), GridPoint(8, 2), GridPoint(8, 5)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(7, 15), GridPoint(7, 14), GridPoint(12, 14)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(11, 11), GridPoint(6, 11)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(7, 5), GridPoint(7, 1)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(6, 5), GridPoint(6, 1)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(16, 9), GridPoint(16, 10), GridPoint(13, 10)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(1, 13), GridPoint(1, 12), GridPoint(2, 12), GridPoint(2, 13), GridPoint(3, 13)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(5, 11), GridPoint(4, 11), GridPoint(4, 13)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(16, 8), GridPoint(15, 8), GridPoint(15, 9), GridPoint(14, 9), GridPoint(14, 8), GridPoint(13, 8)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(5, 13), GridPoint(5, 17)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(5, 12), GridPoint(6, 12), GridPoint(6, 13), GridPoint(7, 13), GridPoint(7, 12), GridPoint(8, 12)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(13, 9), GridPoint(12, 9), GridPoint(12, 8), GridPoint(8, 8)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(8, 13), GridPoint(9, 13), GridPoint(9, 12), GridPoint(10, 12), GridPoint(10, 13), GridPoint(11, 13)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(11, 12), GridPoint(12, 12), GridPoint(12, 13), GridPoint(13, 13), GridPoint(13, 12), GridPoint(14, 12)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(13, 14), GridPoint(14, 14), GridPoint(14, 13), GridPoint(15, 13), GridPoint(15, 14), GridPoint(16, 14)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(12, 10), GridPoint(11, 10), GridPoint(11, 9), GridPoint(10, 9), GridPoint(10, 10), GridPoint(9, 10)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(15, 12), GridPoint(16, 12), GridPoint(16, 13), GridPoint(17, 13), GridPoint(17, 14), GridPoint(18, 14)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(9, 9), GridPoint(8, 9), GridPoint(8, 10), GridPoint(4, 10)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(18, 13), GridPoint(18, 12), GridPoint(17, 12), GridPoint(17, 11), GridPoint(18, 11), GridPoint(18, 9)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(17, 10), GridPoint(17, 8), GridPoint(18, 8), GridPoint(18, 6)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(17, 7), GridPoint(17, 6), GridPoint(16, 6), GridPoint(16, 7), GridPoint(14, 7)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(7, 8), GridPoint(7, 9), GridPoint(4, 9)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(15, 6), GridPoint(13, 6), GridPoint(13, 7), GridPoint(12, 7), GridPoint(12, 6), GridPoint(11, 6)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '35', points: [GridPoint(11, 7), GridPoint(10, 7), GridPoint(10, 6), GridPoint(6, 6)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '36', points: [GridPoint(9, 7), GridPoint(6, 7), GridPoint(6, 8), GridPoint(4, 8)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '37', points: [GridPoint(8, 17), GridPoint(11, 17), GridPoint(11, 18)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '38', points: [GridPoint(10, 18), GridPoint(5, 18)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '39', points: [GridPoint(9, 3), GridPoint(9, 4), GridPoint(10, 4), GridPoint(10, 3), GridPoint(13, 3)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '40', points: [GridPoint(7, 16), GridPoint(8, 16), GridPoint(8, 15), GridPoint(9, 15), GridPoint(9, 16), GridPoint(10, 16)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '41', points: [GridPoint(10, 15), GridPoint(11, 15), GridPoint(11, 16), GridPoint(12, 16), GridPoint(12, 15), GridPoint(14, 15)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '42', points: [GridPoint(3, 12), GridPoint(3, 11), GridPoint(1, 11), GridPoint(1, 10), GridPoint(2, 10), GridPoint(2, 9)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '43', points: [GridPoint(1, 9), GridPoint(1, 8), GridPoint(2, 8), GridPoint(2, 7), GridPoint(1, 7), GridPoint(1, 6)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '44', points: [GridPoint(3, 10), GridPoint(3, 7), GridPoint(5, 7), GridPoint(5, 6)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '45', points: [GridPoint(2, 6), GridPoint(3, 6), GridPoint(3, 5), GridPoint(1, 5), GridPoint(1, 4)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '46', points: [GridPoint(4, 6), GridPoint(4, 5), GridPoint(5, 5), GridPoint(5, 1)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '47', points: [GridPoint(13, 16), GridPoint(15, 16), GridPoint(15, 15), GridPoint(18, 15)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '48', points: [GridPoint(2, 4), GridPoint(4, 4), GridPoint(4, 1)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '49', points: [GridPoint(9, 5), GridPoint(11, 5), GridPoint(11, 4), GridPoint(12, 4), GridPoint(12, 5), GridPoint(13, 5)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '50', points: [GridPoint(13, 4), GridPoint(14, 4), GridPoint(14, 5), GridPoint(18, 5)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '51', points: [GridPoint(14, 3), GridPoint(15, 3), GridPoint(15, 4), GridPoint(18, 4)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '52', points: [GridPoint(4, 14), GridPoint(3, 14), GridPoint(3, 15), GridPoint(4, 15), GridPoint(4, 18)], direction: ArrowDirection.down, colorIndex: 4),
  ];
  return Level(
    levelId: 10,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Cross',
    shapeName: 'Cross',
    category: 'Geometry',
    world: 1,
    worldName: LevelWorlds.world1.title,
    difficulty: 5,
    difficultyName: 'Master',
  );
}
Level buildCuratedLevel11() {
  const gridSize = 20;
  // Same silhouette as before (208 occupied cells), re-tiled into 46 pieces
  // (12 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(14, 11), GridPoint(13, 11)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(14, 12), GridPoint(13, 12)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(9, 1), GridPoint(9, 2)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(10, 1), GridPoint(10, 2)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(10, 9), GridPoint(9, 9)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(10, 10), GridPoint(9, 10)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(17, 9), GridPoint(17, 10)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(5, 6), GridPoint(5, 7), GridPoint(6, 7), GridPoint(6, 6), GridPoint(7, 6)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(8, 6), GridPoint(12, 6)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(17, 8), GridPoint(17, 3)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(16, 2), GridPoint(17, 2)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(18, 10), GridPoint(18, 9)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(11, 9), GridPoint(11, 10)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(9, 17), GridPoint(12, 17)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(3, 17), GridPoint(2, 17), GridPoint(2, 16)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(4, 2), GridPoint(3, 2)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(13, 17), GridPoint(16, 17)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(17, 16), GridPoint(17, 17)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(9, 18), GridPoint(10, 18)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(11, 8), GridPoint(9, 8)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(11, 11), GridPoint(9, 11)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(13, 10), GridPoint(13, 6)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(14, 10), GridPoint(14, 6)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(8, 8), GridPoint(8, 11)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(18, 8), GridPoint(18, 2)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(14, 5), GridPoint(10, 5)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(9, 5), GridPoint(5, 5)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(6, 8), GridPoint(5, 8), GridPoint(5, 9), GridPoint(6, 9), GridPoint(6, 10)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(5, 10), GridPoint(5, 11), GridPoint(6, 11), GridPoint(6, 12), GridPoint(5, 12), GridPoint(5, 14)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(6, 14), GridPoint(6, 13), GridPoint(7, 13), GridPoint(7, 14), GridPoint(8, 14)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(8, 13), GridPoint(14, 13)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(9, 14), GridPoint(14, 14)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(11, 18), GridPoint(17, 18)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(2, 15), GridPoint(2, 10), GridPoint(1, 10)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '35', points: [GridPoint(1, 11), GridPoint(1, 17)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '36', points: [GridPoint(2, 9), GridPoint(1, 9), GridPoint(1, 8), GridPoint(2, 8), GridPoint(2, 7)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '37', points: [GridPoint(4, 17), GridPoint(8, 17), GridPoint(8, 18)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '38', points: [GridPoint(15, 2), GridPoint(11, 2), GridPoint(11, 1)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '39', points: [GridPoint(7, 18), GridPoint(1, 18)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '40', points: [GridPoint(12, 1), GridPoint(18, 1)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '41', points: [GridPoint(1, 7), GridPoint(1, 6), GridPoint(2, 6), GridPoint(2, 2)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '42', points: [GridPoint(5, 2), GridPoint(8, 2), GridPoint(8, 1)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '43', points: [GridPoint(7, 1), GridPoint(2, 1)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '44', points: [GridPoint(1, 5), GridPoint(1, 1)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '45', points: [GridPoint(17, 15), GridPoint(17, 11), GridPoint(18, 11)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '46', points: [GridPoint(18, 12), GridPoint(18, 18)], direction: ArrowDirection.down, colorIndex: 4),
  ];
  return Level(
    levelId: 11,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Concentric Squares',
    shapeName: 'Concentric Squares',
    category: 'Complex Geometry',
    world: 2,
    worldName: LevelWorlds.world2.title,
    difficulty: 3,
    difficultyName: 'Hard',
  );
}

Level buildCuratedLevel12() {
  const gridSize = 20;
  // Same silhouette as before (200 occupied cells), re-tiled into 48 pieces
  // (16 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(10, 18), GridPoint(10, 17)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(9, 18), GridPoint(9, 17)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(6, 1), GridPoint(6, 2)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(5, 1), GridPoint(5, 2)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(9, 2), GridPoint(9, 1)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(10, 2), GridPoint(10, 1)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(9, 12), GridPoint(10, 12)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(9, 11), GridPoint(10, 11)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(3, 1), GridPoint(2, 1)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(3, 2), GridPoint(2, 2)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(2, 15), GridPoint(2, 16)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(1, 2), GridPoint(1, 1)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(1, 6), GridPoint(1, 8), GridPoint(2, 8)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(2, 9), GridPoint(1, 9)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(3, 17), GridPoint(2, 17)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(9, 10), GridPoint(10, 10)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(4, 2), GridPoint(4, 1)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(9, 9), GridPoint(10, 9)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(7, 2), GridPoint(7, 1)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(16, 2), GridPoint(17, 2), GridPoint(17, 3)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(17, 9), GridPoint(18, 9), GridPoint(18, 10)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(17, 10), GridPoint(17, 16)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(16, 17), GridPoint(17, 17)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(8, 2), GridPoint(8, 1)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(14, 13), GridPoint(14, 14), GridPoint(13, 14)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(6, 9), GridPoint(8, 9), GridPoint(8, 10)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(18, 11), GridPoint(18, 17)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(7, 10), GridPoint(6, 10), GridPoint(6, 12)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(11, 14), GridPoint(11, 13), GridPoint(6, 13)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(10, 14), GridPoint(6, 14)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(2, 7), GridPoint(2, 6), GridPoint(7, 6)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(12, 14), GridPoint(12, 13), GridPoint(13, 13), GridPoint(13, 12), GridPoint(14, 12), GridPoint(14, 11)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(8, 6), GridPoint(12, 6)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(13, 11), GridPoint(13, 10), GridPoint(14, 10), GridPoint(14, 9), GridPoint(13, 9), GridPoint(13, 8)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '35', points: [GridPoint(14, 8), GridPoint(14, 7), GridPoint(13, 7), GridPoint(13, 6), GridPoint(14, 6), GridPoint(14, 5)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '36', points: [GridPoint(15, 2), GridPoint(11, 2), GridPoint(11, 1)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '37', points: [GridPoint(2, 14), GridPoint(2, 10), GridPoint(1, 10)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '38', points: [GridPoint(1, 11), GridPoint(1, 17)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '39', points: [GridPoint(12, 1), GridPoint(17, 1)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '40', points: [GridPoint(13, 5), GridPoint(7, 5)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '41', points: [GridPoint(5, 9), GridPoint(5, 14)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '42', points: [GridPoint(6, 5), GridPoint(1, 5)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '43', points: [GridPoint(17, 4), GridPoint(17, 8), GridPoint(18, 8)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '44', points: [GridPoint(4, 17), GridPoint(8, 17), GridPoint(8, 18)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '45', points: [GridPoint(15, 17), GridPoint(11, 17), GridPoint(11, 18)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '46', points: [GridPoint(18, 7), GridPoint(18, 1)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '47', points: [GridPoint(12, 18), GridPoint(18, 18)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '48', points: [GridPoint(7, 18), GridPoint(1, 18)], direction: ArrowDirection.left, colorIndex: 0),
  ];
  return Level(
    levelId: 12,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Spiral',
    shapeName: 'Spiral',
    category: 'Complex Geometry',
    world: 2,
    worldName: LevelWorlds.world2.title,
    difficulty: 3,
    difficultyName: 'Hard',
  );
}

Level buildCuratedLevel13() {
  const gridSize = 20;
  // Same silhouette as before (142 occupied cells), re-tiled into 36 pieces
  // (24 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(14, 4), GridPoint(14, 6)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(14, 10), GridPoint(14, 12)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(14, 16), GridPoint(14, 18)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(15, 1), GridPoint(15, 3)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(15, 13), GridPoint(15, 15)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(10, 16), GridPoint(10, 14)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(10, 10), GridPoint(10, 9)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(6, 15), GridPoint(6, 13)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(6, 9), GridPoint(6, 7)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(9, 12), GridPoint(8, 12), GridPoint(8, 11)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(9, 6), GridPoint(8, 6), GridPoint(8, 5)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(10, 4), GridPoint(10, 2), GridPoint(9, 2)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(6, 3), GridPoint(6, 2)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(7, 5), GridPoint(7, 6)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(1, 3), GridPoint(1, 5), GridPoint(2, 5), GridPoint(2, 6)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(1, 9), GridPoint(1, 11), GridPoint(2, 11), GridPoint(2, 12)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(1, 15), GridPoint(1, 17), GridPoint(2, 17), GridPoint(2, 18)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(9, 1), GridPoint(6, 1)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(3, 18), GridPoint(5, 18), GridPoint(5, 16)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(3, 12), GridPoint(5, 12), GridPoint(5, 10)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(7, 7), GridPoint(9, 7), GridPoint(9, 8), GridPoint(10, 8)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(3, 6), GridPoint(5, 6), GridPoint(5, 4)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(16, 1), GridPoint(18, 1), GridPoint(18, 2)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(15, 9), GridPoint(15, 7), GridPoint(16, 7)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(17, 7), GridPoint(18, 7), GridPoint(18, 8)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(16, 13), GridPoint(18, 13), GridPoint(18, 14)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(13, 18), GridPoint(11, 18), GridPoint(11, 17)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(12, 14), GridPoint(13, 14), GridPoint(13, 12)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(7, 11), GridPoint(7, 13), GridPoint(9, 13), GridPoint(9, 14)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(11, 13), GridPoint(12, 13), GridPoint(12, 12), GridPoint(11, 12), GridPoint(11, 11)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(4, 7), GridPoint(4, 8), GridPoint(3, 8), GridPoint(3, 7), GridPoint(2, 7)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(16, 12), GridPoint(16, 11), GridPoint(17, 11), GridPoint(17, 12), GridPoint(18, 12)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(12, 8), GridPoint(13, 8), GridPoint(13, 6)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(4, 13), GridPoint(4, 14), GridPoint(3, 14), GridPoint(3, 13), GridPoint(2, 13)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '35', points: [GridPoint(16, 6), GridPoint(16, 5), GridPoint(17, 5), GridPoint(17, 6), GridPoint(18, 6)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '36', points: [GridPoint(11, 7), GridPoint(12, 7), GridPoint(12, 6), GridPoint(11, 6), GridPoint(11, 5)], direction: ArrowDirection.up, colorIndex: 0),
  ];
  return Level(
    levelId: 13,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Wave',
    shapeName: 'Wave',
    category: 'Complex Geometry',
    world: 2,
    worldName: LevelWorlds.world2.title,
    difficulty: 3,
    difficultyName: 'Hard',
  );
}

Level buildCuratedLevel14() {
  const gridSize = 20;
  // Same silhouette as before (144 occupied cells), re-tiled into 63 pieces
  // (1 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(8, 14), GridPoint(8, 15)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(7, 15), GridPoint(7, 14)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(4, 12), GridPoint(3, 12)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(7, 8), GridPoint(7, 7)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(4, 14), GridPoint(4, 15)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(7, 11), GridPoint(8, 11)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(4, 11), GridPoint(3, 11)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(3, 14), GridPoint(3, 15)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(8, 8), GridPoint(8, 7)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(14, 11), GridPoint(15, 11)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(15, 3), GridPoint(14, 3)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(3, 8), GridPoint(3, 7)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(14, 7), GridPoint(15, 7)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(8, 3), GridPoint(7, 3)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(6, 14), GridPoint(6, 15)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(7, 12), GridPoint(8, 12)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(11, 14), GridPoint(11, 15)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(4, 8), GridPoint(4, 7)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(8, 2), GridPoint(7, 2)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(11, 12), GridPoint(11, 11)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(12, 11), GridPoint(12, 12)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(11, 10), GridPoint(12, 10)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(8, 10), GridPoint(7, 10)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(15, 4), GridPoint(14, 4)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(14, 6), GridPoint(15, 6)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(12, 8), GridPoint(11, 8), GridPoint(11, 6)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(2, 11), GridPoint(2, 12)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(12, 7), GridPoint(12, 6)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(4, 3), GridPoint(3, 3)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(14, 10), GridPoint(15, 10)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(2, 14), GridPoint(2, 15)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(2, 8), GridPoint(2, 7)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(4, 2), GridPoint(3, 2)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(14, 14), GridPoint(15, 14)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '35', points: [GridPoint(16, 3), GridPoint(16, 4)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '36', points: [GridPoint(8, 6), GridPoint(7, 6)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '37', points: [GridPoint(14, 12), GridPoint(15, 12)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '38', points: [GridPoint(12, 4), GridPoint(12, 3)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '39', points: [GridPoint(12, 14), GridPoint(12, 15)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '40', points: [GridPoint(10, 4), GridPoint(10, 3)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '41', points: [GridPoint(14, 15), GridPoint(15, 15)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '42', points: [GridPoint(8, 4), GridPoint(7, 4)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '43', points: [GridPoint(11, 4), GridPoint(11, 3)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '44', points: [GridPoint(11, 16), GridPoint(12, 16)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '45', points: [GridPoint(4, 4), GridPoint(3, 4)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '46', points: [GridPoint(14, 16), GridPoint(15, 16)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '47', points: [GridPoint(10, 6), GridPoint(10, 8)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '48', points: [GridPoint(10, 10), GridPoint(10, 12)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '49', points: [GridPoint(14, 8), GridPoint(15, 8)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '50', points: [GridPoint(6, 12), GridPoint(6, 10)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '51', points: [GridPoint(10, 14), GridPoint(10, 16)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '52', points: [GridPoint(4, 6), GridPoint(2, 6)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '53', points: [GridPoint(16, 6), GridPoint(16, 8)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '54', points: [GridPoint(8, 16), GridPoint(6, 16)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '55', points: [GridPoint(6, 8), GridPoint(6, 6)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '56', points: [GridPoint(4, 16), GridPoint(2, 16)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '57', points: [GridPoint(6, 4), GridPoint(6, 2)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '58', points: [GridPoint(16, 10), GridPoint(16, 12)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '59', points: [GridPoint(10, 2), GridPoint(12, 2)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '60', points: [GridPoint(4, 10), GridPoint(2, 10)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '61', points: [GridPoint(16, 14), GridPoint(16, 16)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '62', points: [GridPoint(14, 2), GridPoint(16, 2)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '63', points: [GridPoint(2, 4), GridPoint(2, 2)], direction: ArrowDirection.up, colorIndex: 3),
  ];
  return Level(
    levelId: 14,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Checker Grid',
    shapeName: 'Checker Grid',
    category: 'Complex Geometry',
    world: 2,
    worldName: LevelWorlds.world2.title,
    difficulty: 4,
    difficultyName: 'Expert',
  );
}

Level buildCuratedLevel15() {
  const gridSize = 20;
  // Same silhouette as before (132 occupied cells), re-tiled into 30 pieces
  // (14 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(11, 4), GridPoint(12, 4)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(12, 3), GridPoint(11, 3)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(7, 16), GridPoint(8, 16)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(7, 15), GridPoint(8, 15)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(16, 15), GridPoint(17, 15), GridPoint(17, 14)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(18, 9), GridPoint(17, 9)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(8, 4), GridPoint(7, 4)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(8, 3), GridPoint(7, 3)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(9, 16), GridPoint(10, 16), GridPoint(10, 15), GridPoint(9, 15), GridPoint(9, 14)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(9, 13), GridPoint(9, 8)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(18, 8), GridPoint(17, 8), GridPoint(17, 7), GridPoint(18, 7), GridPoint(18, 6)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(9, 7), GridPoint(9, 3)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(2, 5), GridPoint(1, 5), GridPoint(1, 4)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(17, 6), GridPoint(17, 5), GridPoint(18, 5), GridPoint(18, 4)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(17, 4), GridPoint(13, 4), GridPoint(13, 3)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(14, 3), GridPoint(18, 3)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(15, 15), GridPoint(11, 15), GridPoint(11, 16)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(2, 4), GridPoint(6, 4), GridPoint(6, 3)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(5, 3), GridPoint(1, 3)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(1, 6), GridPoint(2, 6), GridPoint(2, 7), GridPoint(1, 7), GridPoint(1, 9)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(2, 8), GridPoint(2, 10), GridPoint(1, 10), GridPoint(1, 11)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(10, 14), GridPoint(10, 9)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(12, 16), GridPoint(17, 16)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(2, 11), GridPoint(2, 12), GridPoint(1, 12), GridPoint(1, 13)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(2, 13), GridPoint(2, 14), GridPoint(1, 14), GridPoint(1, 15)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(2, 15), GridPoint(6, 15), GridPoint(6, 16)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(5, 16), GridPoint(1, 16)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(10, 8), GridPoint(10, 3)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(17, 13), GridPoint(17, 10), GridPoint(18, 10)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(18, 11), GridPoint(18, 16)], direction: ArrowDirection.down, colorIndex: 0),
  ];
  return Level(
    levelId: 15,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Infinity',
    shapeName: 'Infinity',
    category: 'Complex Geometry',
    world: 2,
    worldName: LevelWorlds.world2.title,
    difficulty: 4,
    difficultyName: 'Expert',
  );
}

Level buildCuratedLevel16() {
  const gridSize = 20;
  // Same silhouette as before (144 occupied cells), re-tiled into 44 pieces
  // (21 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(10, 10), GridPoint(9, 10)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(3, 17), GridPoint(3, 15)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(3, 10), GridPoint(3, 9)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(3, 2), GridPoint(3, 3), GridPoint(4, 3)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(9, 2), GridPoint(10, 2)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(9, 9), GridPoint(10, 9)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(2, 10), GridPoint(2, 9)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(9, 3), GridPoint(10, 3)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(9, 16), GridPoint(10, 16)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(16, 2), GridPoint(16, 4)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(9, 17), GridPoint(10, 17)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(16, 9), GridPoint(16, 10)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(15, 16), GridPoint(16, 16), GridPoint(16, 17)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(17, 10), GridPoint(17, 9)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(9, 15), GridPoint(10, 15)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(4, 9), GridPoint(4, 10)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(5, 10), GridPoint(5, 9)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(11, 9), GridPoint(11, 10)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(9, 8), GridPoint(10, 8)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(8, 2), GridPoint(8, 3)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(9, 14), GridPoint(10, 14)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(16, 8), GridPoint(17, 8)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(9, 13), GridPoint(10, 13)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(7, 10), GridPoint(6, 10), GridPoint(6, 9), GridPoint(7, 9), GridPoint(7, 8)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(8, 8), GridPoint(8, 10)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(6, 8), GridPoint(2, 8)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(14, 10), GridPoint(15, 10), GridPoint(15, 8)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(10, 6), GridPoint(10, 4), GridPoint(8, 4)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(10, 7), GridPoint(9, 7), GridPoint(9, 5), GridPoint(8, 5)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(4, 5), GridPoint(4, 4), GridPoint(3, 4)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(13, 10), GridPoint(12, 10), GridPoint(12, 9), GridPoint(14, 9), GridPoint(14, 8)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(14, 4), GridPoint(15, 4), GridPoint(15, 3)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(15, 14), GridPoint(15, 15), GridPoint(16, 15)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(7, 13), GridPoint(8, 13), GridPoint(8, 17)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '35', points: [GridPoint(5, 13), GridPoint(6, 13), GridPoint(6, 14)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '36', points: [GridPoint(12, 13), GridPoint(12, 12), GridPoint(13, 12)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '37', points: [GridPoint(11, 11), GridPoint(10, 11), GridPoint(10, 12), GridPoint(9, 12)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '38', points: [GridPoint(9, 11), GridPoint(8, 11), GridPoint(8, 12), GridPoint(6, 12)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '39', points: [GridPoint(8, 7), GridPoint(8, 6), GridPoint(7, 6), GridPoint(7, 7), GridPoint(6, 7)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '40', points: [GridPoint(5, 6), GridPoint(6, 6), GridPoint(6, 5), GridPoint(5, 5), GridPoint(5, 4)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '41', points: [GridPoint(11, 8), GridPoint(13, 8), GridPoint(13, 7), GridPoint(12, 7), GridPoint(12, 6)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '42', points: [GridPoint(14, 13), GridPoint(13, 13), GridPoint(13, 14), GridPoint(14, 14), GridPoint(14, 15)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '43', points: [GridPoint(13, 5), GridPoint(13, 6), GridPoint(14, 6), GridPoint(14, 5), GridPoint(15, 5)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '44', points: [GridPoint(4, 14), GridPoint(5, 14), GridPoint(5, 15), GridPoint(4, 15), GridPoint(4, 16)], direction: ArrowDirection.down, colorIndex: 2),
  ];
  return Level(
    levelId: 16,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Radial Pattern',
    shapeName: 'Radial Pattern',
    category: 'Complex Geometry',
    world: 2,
    worldName: LevelWorlds.world2.title,
    difficulty: 4,
    difficultyName: 'Expert',
  );
}

Level buildCuratedLevel17() {
  const gridSize = 20;
  // Same silhouette as before (176 occupied cells), re-tiled into 46 pieces
  // (13 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(1, 12), GridPoint(2, 12)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(13, 12), GridPoint(14, 12)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(11, 17), GridPoint(10, 17)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(16, 17), GridPoint(17, 17), GridPoint(17, 16)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(15, 2), GridPoint(16, 2)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(14, 13), GridPoint(12, 13)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(7, 13), GridPoint(6, 13), GridPoint(6, 12)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(17, 11), GridPoint(17, 10)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(5, 8), GridPoint(6, 8)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(4, 17), GridPoint(3, 17)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(18, 10), GridPoint(18, 11)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(11, 10), GridPoint(9, 10), GridPoint(9, 9)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(10, 9), GridPoint(11, 9)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(11, 18), GridPoint(10, 18)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(8, 9), GridPoint(8, 10)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(1, 7), GridPoint(2, 7)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(7, 14), GridPoint(6, 14)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(5, 7), GridPoint(6, 7)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(9, 17), GridPoint(9, 18)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(12, 14), GridPoint(14, 14)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(13, 7), GridPoint(14, 7), GridPoint(14, 6)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(13, 6), GridPoint(10, 6)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(11, 11), GridPoint(8, 11)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(8, 8), GridPoint(11, 8)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(6, 11), GridPoint(6, 9), GridPoint(5, 9)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(5, 10), GridPoint(5, 14)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(1, 13), GridPoint(2, 13), GridPoint(2, 17)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(9, 6), GridPoint(5, 6)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(8, 5), GridPoint(5, 5)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(9, 5), GridPoint(14, 5)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(1, 6), GridPoint(2, 6), GridPoint(2, 2)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(15, 17), GridPoint(12, 17), GridPoint(12, 18)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(13, 18), GridPoint(17, 18)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(3, 2), GridPoint(7, 2), GridPoint(7, 1)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '35', points: [GridPoint(17, 9), GridPoint(18, 9), GridPoint(18, 8), GridPoint(17, 8), GridPoint(17, 7)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '36', points: [GridPoint(6, 1), GridPoint(2, 1)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '37', points: [GridPoint(17, 6), GridPoint(17, 2)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '38', points: [GridPoint(18, 7), GridPoint(18, 2)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '39', points: [GridPoint(5, 17), GridPoint(8, 17), GridPoint(8, 18)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '40', points: [GridPoint(14, 2), GridPoint(12, 2), GridPoint(12, 1)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '41', points: [GridPoint(17, 15), GridPoint(17, 12), GridPoint(18, 12)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '42', points: [GridPoint(18, 13), GridPoint(18, 18)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '43', points: [GridPoint(7, 18), GridPoint(2, 18)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '44', points: [GridPoint(13, 1), GridPoint(18, 1)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '45', points: [GridPoint(1, 14), GridPoint(1, 18)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '46', points: [GridPoint(1, 5), GridPoint(1, 1)], direction: ArrowDirection.up, colorIndex: 4),
  ];
  return Level(
    levelId: 17,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Labyrinth',
    shapeName: 'Labyrinth',
    category: 'Complex Geometry',
    world: 2,
    worldName: LevelWorlds.world2.title,
    difficulty: 5,
    difficultyName: 'Master',
  );
}

Level buildCuratedLevel18() {
  const gridSize = 20;
  // Same silhouette as before (118 occupied cells), re-tiled into 32 pieces
  // (20 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(9, 15), GridPoint(9, 14)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(13, 2), GridPoint(13, 4)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(14, 9), GridPoint(14, 10), GridPoint(13, 10)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(9, 10), GridPoint(9, 9)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(15, 9), GridPoint(15, 10)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(16, 13), GridPoint(14, 13)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(10, 15), GridPoint(10, 13)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(10, 10), GridPoint(10, 9)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(5, 9), GridPoint(5, 10)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(4, 9), GridPoint(4, 10)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(2, 13), GridPoint(3, 13), GridPoint(3, 12)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(3, 6), GridPoint(5, 6)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(12, 5), GridPoint(14, 5)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(6, 15), GridPoint(6, 13)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(6, 7), GridPoint(6, 6), GridPoint(7, 6)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(12, 7), GridPoint(12, 6), GridPoint(13, 6)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(5, 8), GridPoint(5, 7), GridPoint(4, 7)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(8, 13), GridPoint(7, 13), GridPoint(7, 14)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(4, 11), GridPoint(6, 11), GridPoint(6, 12), GridPoint(7, 12)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(13, 12), GridPoint(11, 12), GridPoint(11, 14)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(10, 5), GridPoint(10, 4), GridPoint(9, 4), GridPoint(9, 5), GridPoint(8, 5)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(12, 13), GridPoint(13, 13), GridPoint(13, 14), GridPoint(12, 14), GridPoint(12, 15)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(5, 2), GridPoint(5, 5), GridPoint(4, 5)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(12, 11), GridPoint(14, 11), GridPoint(14, 12), GridPoint(15, 12)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(11, 6), GridPoint(11, 4), GridPoint(12, 4), GridPoint(12, 3)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(5, 12), GridPoint(4, 12), GridPoint(4, 13), GridPoint(5, 13), GridPoint(5, 14)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(5, 16), GridPoint(5, 15), GridPoint(4, 15), GridPoint(4, 14), GridPoint(3, 14)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(16, 5), GridPoint(15, 5), GridPoint(15, 4), GridPoint(14, 4), GridPoint(14, 3)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(6, 5), GridPoint(7, 5), GridPoint(7, 4), GridPoint(6, 4), GridPoint(6, 3)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(13, 16), GridPoint(13, 15), GridPoint(14, 15), GridPoint(14, 14), GridPoint(15, 14)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(2, 5), GridPoint(3, 5), GridPoint(3, 4), GridPoint(4, 4), GridPoint(4, 3)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(13, 8), GridPoint(13, 7), GridPoint(14, 7), GridPoint(14, 6), GridPoint(15, 6)], direction: ArrowDirection.right, colorIndex: 2),
  ];
  return Level(
    levelId: 18,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Diamond Grid',
    shapeName: 'Diamond Grid',
    category: 'Complex Geometry',
    world: 2,
    worldName: LevelWorlds.world2.title,
    difficulty: 5,
    difficultyName: 'Master',
  );
}

Level buildCuratedLevel19() {
  const gridSize = 20;
  // Same silhouette as before (224 occupied cells), re-tiled into 47 pieces
  // (25 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(6, 17), GridPoint(7, 17)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(6, 18), GridPoint(7, 18)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(18, 12), GridPoint(18, 11)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(17, 2), GridPoint(17, 3)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(17, 12), GridPoint(17, 11), GridPoint(13, 11)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(7, 11), GridPoint(7, 9)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(2, 9), GridPoint(1, 9), GridPoint(1, 10), GridPoint(2, 10), GridPoint(2, 11)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(3, 11), GridPoint(3, 9)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(8, 9), GridPoint(8, 12)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(9, 12), GridPoint(9, 9)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(10, 12), GridPoint(10, 9)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(10, 3), GridPoint(10, 2), GridPoint(9, 2)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(9, 3), GridPoint(8, 3), GridPoint(8, 2), GridPoint(7, 2)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(7, 1), GridPoint(10, 1)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(8, 13), GridPoint(8, 18)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(17, 4), GridPoint(17, 7), GridPoint(18, 7)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(16, 2), GridPoint(12, 2), GridPoint(12, 1)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(18, 6), GridPoint(18, 2)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(13, 1), GridPoint(18, 1)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(10, 5), GridPoint(10, 4), GridPoint(8, 4)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(11, 6), GridPoint(10, 6), GridPoint(10, 8), GridPoint(9, 8)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(9, 7), GridPoint(9, 5), GridPoint(8, 5)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(1, 11), GridPoint(1, 12), GridPoint(2, 12), GridPoint(2, 13), GridPoint(1, 13), GridPoint(1, 14)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(13, 10), GridPoint(18, 10)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(2, 14), GridPoint(2, 15), GridPoint(1, 15), GridPoint(1, 17)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(8, 6), GridPoint(8, 8), GridPoint(7, 8)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(2, 16), GridPoint(2, 17), GridPoint(5, 17), GridPoint(5, 18)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(4, 18), GridPoint(1, 18)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(2, 7), GridPoint(1, 7), GridPoint(1, 6), GridPoint(2, 6), GridPoint(2, 5)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(11, 7), GridPoint(11, 8), GridPoint(12, 8), GridPoint(12, 9)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(1, 5), GridPoint(1, 4), GridPoint(2, 4), GridPoint(2, 3), GridPoint(1, 3), GridPoint(1, 2)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(11, 9), GridPoint(11, 10), GridPoint(12, 10), GridPoint(12, 11), GridPoint(11, 11), GridPoint(11, 12)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(12, 17), GridPoint(12, 18), GridPoint(13, 18), GridPoint(13, 17), GridPoint(14, 17)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(14, 18), GridPoint(15, 18), GridPoint(15, 17), GridPoint(16, 17), GridPoint(16, 18), GridPoint(17, 18)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '35', points: [GridPoint(9, 13), GridPoint(9, 18)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '36', points: [GridPoint(5, 11), GridPoint(4, 11), GridPoint(4, 9)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '37', points: [GridPoint(11, 13), GridPoint(10, 13), GridPoint(10, 18)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '38', points: [GridPoint(17, 17), GridPoint(17, 13), GridPoint(18, 13)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '39', points: [GridPoint(18, 14), GridPoint(18, 18)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '40', points: [GridPoint(13, 8), GridPoint(13, 9), GridPoint(18, 9)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '41', points: [GridPoint(6, 11), GridPoint(6, 10), GridPoint(5, 10), GridPoint(5, 9), GridPoint(6, 9), GridPoint(6, 8)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '42', points: [GridPoint(2, 2), GridPoint(6, 2), GridPoint(6, 1)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '43', points: [GridPoint(5, 1), GridPoint(1, 1)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '44', points: [GridPoint(11, 14), GridPoint(11, 18)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '45', points: [GridPoint(5, 8), GridPoint(1, 8)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '46', points: [GridPoint(14, 8), GridPoint(18, 8)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '47', points: [GridPoint(11, 5), GridPoint(11, 1)], direction: ArrowDirection.up, colorIndex: 5),
  ];
  return Level(
    levelId: 19,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Interlocking Loops',
    shapeName: 'Interlocking Loops',
    category: 'Complex Geometry',
    world: 2,
    worldName: LevelWorlds.world2.title,
    difficulty: 5,
    difficultyName: 'Master',
  );
}

Level buildCuratedLevel20() {
  const gridSize = 20;
  // Same silhouette as before (226 occupied cells), re-tiled into 61 pieces
  // (25 bent) so every arrow escapes along its own arrowhead (final segment).
  // Built in removal order, so the level is solvable by construction.
  final paths = <PuzzlePath>[
    PuzzlePath(id: '1', points: [GridPoint(10, 7), GridPoint(10, 8)], direction: ArrowDirection.down, colorIndex: 1),
    PuzzlePath(id: '2', points: [GridPoint(11, 8), GridPoint(11, 7)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '3', points: [GridPoint(17, 1), GridPoint(16, 1)], direction: ArrowDirection.left, colorIndex: 3),
    PuzzlePath(id: '4', points: [GridPoint(17, 2), GridPoint(16, 2)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '5', points: [GridPoint(17, 12), GridPoint(17, 13)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '6', points: [GridPoint(18, 13), GridPoint(18, 12)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '7', points: [GridPoint(17, 8), GridPoint(18, 8)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '8', points: [GridPoint(17, 7), GridPoint(18, 7)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '9', points: [GridPoint(18, 16), GridPoint(18, 17)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '10', points: [GridPoint(17, 16), GridPoint(17, 17)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '11', points: [GridPoint(4, 16), GridPoint(3, 16)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '12', points: [GridPoint(4, 15), GridPoint(3, 15)], direction: ArrowDirection.left, colorIndex: 0),
    PuzzlePath(id: '13', points: [GridPoint(10, 2), GridPoint(10, 1)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '14', points: [GridPoint(11, 2), GridPoint(11, 1)], direction: ArrowDirection.up, colorIndex: 2),
    PuzzlePath(id: '15', points: [GridPoint(4, 4), GridPoint(4, 3)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '16', points: [GridPoint(3, 4), GridPoint(3, 3)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '17', points: [GridPoint(16, 3), GridPoint(17, 3)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '18', points: [GridPoint(11, 11), GridPoint(11, 13)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '19', points: [GridPoint(11, 18), GridPoint(10, 18)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '20', points: [GridPoint(9, 15), GridPoint(9, 14), GridPoint(10, 14)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '21', points: [GridPoint(17, 14), GridPoint(18, 14)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '22', points: [GridPoint(17, 15), GridPoint(18, 15)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '23', points: [GridPoint(10, 9), GridPoint(11, 9)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '24', points: [GridPoint(12, 2), GridPoint(12, 1)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '25', points: [GridPoint(13, 2), GridPoint(13, 1)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '26', points: [GridPoint(17, 9), GridPoint(18, 9)], direction: ArrowDirection.right, colorIndex: 2),
    PuzzlePath(id: '27', points: [GridPoint(2, 4), GridPoint(2, 2)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '28', points: [GridPoint(1, 2), GridPoint(1, 4)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '29', points: [GridPoint(1, 5), GridPoint(2, 5)], direction: ArrowDirection.right, colorIndex: 5),
    PuzzlePath(id: '30', points: [GridPoint(17, 11), GridPoint(18, 11)], direction: ArrowDirection.right, colorIndex: 0),
    PuzzlePath(id: '31', points: [GridPoint(17, 10), GridPoint(18, 10)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '32', points: [GridPoint(4, 8), GridPoint(4, 9), GridPoint(3, 9)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '33', points: [GridPoint(13, 7), GridPoint(12, 7), GridPoint(12, 8)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '34', points: [GridPoint(10, 12), GridPoint(10, 13), GridPoint(9, 13)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '35', points: [GridPoint(11, 17), GridPoint(9, 17), GridPoint(9, 18), GridPoint(7, 18)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '36', points: [GridPoint(8, 9), GridPoint(9, 9), GridPoint(9, 7)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '37', points: [GridPoint(7, 9), GridPoint(7, 8), GridPoint(8, 8), GridPoint(8, 7)], direction: ArrowDirection.up, colorIndex: 1),
    PuzzlePath(id: '38', points: [GridPoint(11, 10), GridPoint(10, 10), GridPoint(10, 11), GridPoint(9, 11), GridPoint(9, 10), GridPoint(8, 10)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '39', points: [GridPoint(7, 6), GridPoint(7, 5), GridPoint(8, 5), GridPoint(8, 6), GridPoint(10, 6)], direction: ArrowDirection.right, colorIndex: 3),
    PuzzlePath(id: '40', points: [GridPoint(8, 17), GridPoint(3, 17)], direction: ArrowDirection.left, colorIndex: 4),
    PuzzlePath(id: '41', points: [GridPoint(9, 12), GridPoint(8, 12), GridPoint(8, 11), GridPoint(7, 11), GridPoint(7, 10), GridPoint(6, 10)], direction: ArrowDirection.left, colorIndex: 5),
    PuzzlePath(id: '42', points: [GridPoint(2, 6), GridPoint(1, 6), GridPoint(1, 7), GridPoint(2, 7), GridPoint(2, 8), GridPoint(1, 8), GridPoint(1, 9)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '43', points: [GridPoint(6, 11), GridPoint(5, 11), GridPoint(5, 10), GridPoint(4, 10)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '44', points: [GridPoint(8, 14), GridPoint(8, 13), GridPoint(7, 13), GridPoint(7, 12), GridPoint(6, 12)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '45', points: [GridPoint(2, 9), GridPoint(2, 10), GridPoint(1, 10), GridPoint(1, 11), GridPoint(2, 11), GridPoint(2, 12)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '46', points: [GridPoint(10, 4), GridPoint(10, 5), GridPoint(11, 5), GridPoint(11, 6), GridPoint(12, 6)], direction: ArrowDirection.right, colorIndex: 4),
    PuzzlePath(id: '47', points: [GridPoint(1, 12), GridPoint(1, 13), GridPoint(2, 13), GridPoint(2, 17)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '48', points: [GridPoint(15, 1), GridPoint(14, 1), GridPoint(14, 2), GridPoint(15, 2), GridPoint(15, 3)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '49', points: [GridPoint(6, 18), GridPoint(2, 18)], direction: ArrowDirection.left, colorIndex: 1),
    PuzzlePath(id: '50', points: [GridPoint(14, 8), GridPoint(13, 8), GridPoint(13, 9), GridPoint(12, 9), GridPoint(12, 12)], direction: ArrowDirection.down, colorIndex: 2),
    PuzzlePath(id: '51', points: [GridPoint(1, 14), GridPoint(1, 18)], direction: ArrowDirection.down, colorIndex: 3),
    PuzzlePath(id: '52', points: [GridPoint(8, 4), GridPoint(9, 4), GridPoint(9, 1)], direction: ArrowDirection.up, colorIndex: 4),
    PuzzlePath(id: '53', points: [GridPoint(6, 9), GridPoint(6, 8), GridPoint(5, 8), GridPoint(5, 7), GridPoint(6, 7), GridPoint(6, 6)], direction: ArrowDirection.up, colorIndex: 5),
    PuzzlePath(id: '54', points: [GridPoint(3, 2), GridPoint(8, 2), GridPoint(8, 1)], direction: ArrowDirection.up, colorIndex: 0),
    PuzzlePath(id: '55', points: [GridPoint(15, 4), GridPoint(17, 4), GridPoint(17, 6), GridPoint(18, 6)], direction: ArrowDirection.right, colorIndex: 1),
    PuzzlePath(id: '56', points: [GridPoint(7, 1), GridPoint(1, 1)], direction: ArrowDirection.left, colorIndex: 2),
    PuzzlePath(id: '57', points: [GridPoint(18, 5), GridPoint(18, 1)], direction: ArrowDirection.up, colorIndex: 3),
    PuzzlePath(id: '58', points: [GridPoint(15, 9), GridPoint(14, 9), GridPoint(14, 10), GridPoint(13, 10), GridPoint(13, 11)], direction: ArrowDirection.down, colorIndex: 4),
    PuzzlePath(id: '59', points: [GridPoint(16, 15), GridPoint(15, 15), GridPoint(15, 16), GridPoint(16, 16), GridPoint(16, 17)], direction: ArrowDirection.down, colorIndex: 5),
    PuzzlePath(id: '60', points: [GridPoint(15, 17), GridPoint(12, 17), GridPoint(12, 18)], direction: ArrowDirection.down, colorIndex: 0),
    PuzzlePath(id: '61', points: [GridPoint(13, 18), GridPoint(18, 18)], direction: ArrowDirection.right, colorIndex: 1),
  ];
  return Level(
    levelId: 20,
    gridSize: gridSize,
    puzzlePaths: paths,
    name: 'Master Pattern',
    shapeName: 'Master Pattern',
    category: 'Complex Geometry',
    world: 2,
    worldName: LevelWorlds.world2.title,
    difficulty: 5,
    difficultyName: 'Master',
  );
}
bool isCuratedLevel(int levelId) => levelId >= 1 && levelId <= 20;
Level? getCuratedLevel(int levelId) {
  switch (levelId) {
    case 1:
      return buildCuratedLevel1();
    case 2:
      return buildCuratedLevel2();
    case 3:
      return buildCuratedLevel3();
    case 4:
      return buildCuratedLevel4();
    case 5:
      return buildCuratedLevel5();
    case 6:
      return buildCuratedLevel6();
    case 7:
      return buildCuratedLevel7();
    case 8:
      return buildCuratedLevel8();
    case 9:
      return buildCuratedLevel9();
    case 10:
      return buildCuratedLevel10();
    case 11:
      return buildCuratedLevel11();
    case 12:
      return buildCuratedLevel12();
    case 13:
      return buildCuratedLevel13();
    case 14:
      return buildCuratedLevel14();
    case 15:
      return buildCuratedLevel15();
    case 16:
      return buildCuratedLevel16();
    case 17:
      return buildCuratedLevel17();
    case 18:
      return buildCuratedLevel18();
    case 19:
      return buildCuratedLevel19();
    case 20:
      return buildCuratedLevel20();
    default:
      return null;
  }
}
