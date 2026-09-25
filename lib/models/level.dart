import 'arrow.dart';
import 'puzzle_path.dart';

class Level {
  final int levelId;
  final int gridSize;
  final List<LevelArrow> arrows;
  final List<PuzzlePath> puzzlePaths;
  final String? name;
  final int? difficulty;
  final String? difficultyName;

  // New world/shape metadata (data-driven, backward compatible)
  final int? world;
  final String? worldName;
  final String? shapeName;
  final String? category;

  Level({
    required this.levelId,
    required this.gridSize,
    List<LevelArrow>? arrows,
    List<PuzzlePath>? puzzlePaths,
    this.name,
    this.difficulty,
    this.difficultyName,
    this.world,
    this.worldName,
    this.shapeName,
    this.category,
  }) : arrows = arrows ?? const [],
       puzzlePaths = puzzlePaths ?? const [];

  factory Level.fromJson(Map<String, dynamic> json) {
    final int levelId = json['levelId'] as int;
    final int gridSize = json['gridSize'] as int;

    final int? world = json['world'] as int?;
    final String? worldName = json['worldName'] as String?;
    final String? shapeName =
        json['shapeName'] as String? ?? json['name'] as String?;
    final String? category = json['category'] as String?;

    // New path based format
    if (json.containsKey('paths') && json['paths'] is List) {
      final paths = (json['paths'] as List)
          .map((e) => _parsePuzzlePath(e as Map<String, dynamic>))
          .toList();
      return Level(
        levelId: levelId,
        gridSize: gridSize,
        arrows: const [],
        puzzlePaths: paths,
        name: json['name'] as String? ?? shapeName,
        difficulty: json['difficulty'] as int?,
        difficultyName: json['difficultyName'] as String?,
        world: world,
        worldName: worldName,
        shapeName: shapeName,
        category: category,
      );
    }

    // Legacy arrow format
    return Level(
      levelId: levelId,
      gridSize: gridSize,
      arrows: (json['arrows'] as List)
          .map((e) => LevelArrow.fromJson(e as Map<String, dynamic>))
          .toList(),
      puzzlePaths: const [],
      name: json['name'] as String? ?? shapeName,
      difficulty: json['difficulty'] as int?,
      difficultyName: json['difficultyName'] as String?,
      world: world,
      worldName: worldName,
      shapeName: shapeName,
      category: category,
    );
  }

  static PuzzlePath _parsePuzzlePath(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final pointsRaw = json['points'] as List;
    final points = pointsRaw.map((p) {
      final arr = p as List;
      final x = (arr[0] as num).toInt();
      final y = (arr[1] as num).toInt();
      return GridPoint(x, y);
    }).toList();

    final dirVal = json['direction'];
    ArrowDirection dir;
    if (dirVal is String) {
      dir = _parseDirection(dirVal);
    } else if (dirVal is int) {
      dir = ArrowDirection.values[dirVal];
    } else {
      dir = ArrowDirection.right;
    }

    final colorIndex = json['colorIndex'] as int? ?? 0;
    return PuzzlePath(
      id: id,
      points: points,
      direction: dir,
      colorIndex: colorIndex,
    );
  }

  static ArrowDirection _parseDirection(String value) {
    switch (value.toLowerCase()) {
      case 'up':
        return ArrowDirection.up;
      case 'down':
        return ArrowDirection.down;
      case 'left':
        return ArrowDirection.left;
      case 'right':
        return ArrowDirection.right;
      default:
        return ArrowDirection.right;
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'levelId': levelId,
      'gridSize': gridSize,
      'name': name,
      'difficulty': difficulty,
      'difficultyName': difficultyName,
      'world': world,
      'worldName': worldName,
      'shapeName': shapeName,
      'category': category,
    };
    if (puzzlePaths.isNotEmpty) {
      map['paths'] = puzzlePaths
          .map(
            (p) => {
              'id': p.id,
              'points': p.points.map((pt) => [pt.x, pt.y]).toList(),
              'direction': p.direction.name,
              'colorIndex': p.colorIndex,
            },
          )
          .toList();
    } else {
      map['arrows'] = arrows.map((e) => e.toJson()).toList();
    }
    return map;
  }

  List<Arrow> createArrows() {
    if (arrows.isNotEmpty) {
      return arrows
          .map(
            (data) => Arrow(
              id: data.id.toString(),
              row: data.row,
              column: data.column,
              direction: data.direction,
              colorIndex: data.colorIndex ?? _getDefaultColorIndex(data.id),
            ),
          )
          .toList();
    }
    // Convert puzzlePaths single-head fallback for legacy engine
    return puzzlePaths
        .map(
          (p) => Arrow(
            id: p.id,
            row: p.head.y,
            column: p.head.x,
            direction: p.direction,
            colorIndex: p.colorIndex,
          ),
        )
        .toList();
  }

  List<PuzzlePath> createPuzzlePaths() {
    if (puzzlePaths.isNotEmpty) {
      return puzzlePaths.map((p) => p.copyWith()).toList();
    }
    // Convert legacy arrows to single-point paths
    return arrows
        .map(
          (a) => PuzzlePath(
            id: a.id.toString(),
            points: [GridPoint(a.column, a.row)],
            direction: a.direction,
            colorIndex: a.colorIndex ?? _getDefaultColorIndex(a.id),
          ),
        )
        .toList();
  }

  int _getDefaultColorIndex(int id) {
    return id % 6;
  }

  bool get isValid {
    if (gridSize < 3 || gridSize > 30) return false;
    final effectiveCount = puzzlePaths.isNotEmpty
        ? puzzlePaths.length
        : arrows.length;
    if (effectiveCount == 0) return false;

    if (puzzlePaths.isNotEmpty) {
      final seen = <String>{};
      for (final p in puzzlePaths) {
        if (p.points.isEmpty) return false;
        for (final pt in p.points) {
          if (pt.x < 0 || pt.x >= gridSize) return false;
          if (pt.y < 0 || pt.y >= gridSize) return false;
        }
        // check consecutive points are axis-aligned
        for (int i = 0; i < p.points.length - 1; i++) {
          final a = p.points[i];
          final b = p.points[i + 1];
          if (a.x != b.x && a.y != b.y) return false;
        }
        // check occupancy not overlapping with other paths is not validated here (allowed interlocking at crossing? we forbid overlapping cells)
        for (final cell in p.occupiedCells) {
          final key = '${cell.x},${cell.y}';
          if (seen.contains(key)) return false;
          seen.add(key);
        }
      }
    } else {
      final seenPositions = <String>{};
      for (final arrow in arrows) {
        final key = '${arrow.row},${arrow.column}';
        if (seenPositions.contains(key)) return false;
        seenPositions.add(key);
        if (arrow.row < 0 || arrow.row >= gridSize) return false;
        if (arrow.column < 0 || arrow.column >= gridSize) return false;
      }
    }
    return true;
  }

  bool get isPathBased => puzzlePaths.isNotEmpty;
}

class LevelArrow {
  final int id;
  final int row;
  final int column;
  final ArrowDirection direction;
  final int? colorIndex;

  LevelArrow({
    required this.id,
    required this.row,
    required this.column,
    required this.direction,
    this.colorIndex,
  });

  factory LevelArrow.fromJson(Map<String, dynamic> json) {
    final directionValue = json['direction'];
    ArrowDirection direction;

    if (directionValue is String) {
      direction = _parseDirection(directionValue);
    } else if (directionValue is int) {
      direction = ArrowDirection.values[directionValue];
    } else {
      direction = ArrowDirection.up;
    }

    return LevelArrow(
      id: json['id'] as int,
      row: json['row'] as int,
      column: json['column'] as int,
      direction: direction,
      colorIndex: json['colorIndex'] as int?,
    );
  }

  static ArrowDirection _parseDirection(String value) {
    switch (value.toLowerCase()) {
      case 'up':
        return ArrowDirection.up;
      case 'down':
        return ArrowDirection.down;
      case 'left':
        return ArrowDirection.left;
      case 'right':
        return ArrowDirection.right;
      default:
        return ArrowDirection.up;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'row': row,
      'column': column,
      'direction': direction.name,
      'colorIndex': colorIndex,
    };
  }
}

class LevelCollection {
  final List<Level> levels;

  LevelCollection({required this.levels});

  factory LevelCollection.fromJson(Map<String, dynamic> json) {
    return LevelCollection(
      levels: (json['levels'] as List)
          .map((e) => Level.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'levels': levels.map((e) => e.toJson()).toList()};
  }

  Level? getLevel(int levelId) {
    try {
      return levels.firstWhere((level) => level.levelId == levelId);
    } catch (_) {
      return null;
    }
  }

  List<Level> getLevelsInRange(int start, int end) {
    return levels
        .where((level) => level.levelId >= start && level.levelId <= end)
        .toList();
  }
}
