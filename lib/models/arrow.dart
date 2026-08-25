import 'dart:ui';

enum ArrowDirection {
  up,
  down,
  left,
  right;

  Offset get vector {
    switch (this) {
      case ArrowDirection.up:
        return const Offset(0, -1);
      case ArrowDirection.down:
        return const Offset(0, 1);
      case ArrowDirection.left:
        return const Offset(-1, 0);
      case ArrowDirection.right:
        return const Offset(1, 0);
    }
  }

  double get rotationRadians {
    switch (this) {
      case ArrowDirection.up:
        return -3.14159 / 2;
      case ArrowDirection.down:
        return 3.14159 / 2;
      case ArrowDirection.left:
        return 3.14159;
      case ArrowDirection.right:
        return 0;
    }
  }
}

enum ArrowState {
  active,
  moving,
  removed;
}

class Arrow {
  final String id;
  final int row;
  final int column;
  final ArrowDirection direction;
  ArrowState state;
  final int colorIndex;

  Arrow({
    required this.id,
    required this.row,
    required this.column,
    required this.direction,
    this.state = ArrowState.active,
    this.colorIndex = 0,
  });

  Arrow copyWith({
    String? id,
    int? row,
    int? column,
    ArrowDirection? direction,
    ArrowState? state,
    int? colorIndex,
  }) {
    return Arrow(
      id: id ?? this.id,
      row: row ?? this.row,
      column: column ?? this.column,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Arrow &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Arrow(id: $id, row: $row, col: $column, dir: $direction, state: $state)';
}