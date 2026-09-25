import 'dart:math' as math;

import '../../models/arrow.dart';
import '../../models/puzzle_path.dart';

/// Difficulty knobs for [DenseTiler].
class TilerParams {
  /// Typical piece length in cells.
  final double meanSize;

  /// Chance that a piece aims for a long run (about twice [meanSize]).
  final double longChance;

  /// Longest piece allowed.
  final int maxSize;

  /// Score per bend (up to 5 bends).
  final double bendWeight;

  /// Score per level of chain depth.
  final double depthWeight;

  /// Penalty for a piece that is free on the full board (an opening move).
  final double freePenalty;

  /// Bonus per cell for opening-move pieces: fewer, longer free arrows.
  final double freeLengthBonus;

  /// Chance of turning at each growth step when a turn is possible.
  final double turnChance;

  /// Chance of starting a piece where its escape runs into carved pieces
  /// (builds dependency chains).
  final double blockedBias;

  const TilerParams({
    this.meanSize = 4.2,
    this.longChance = 0.1,
    this.maxSize = 10,
    this.bendWeight = 22,
    this.depthWeight = 8,
    this.freePenalty = 120,
    this.freeLengthBonus = 0,
    this.turnChance = 0.6,
    this.blockedBias = 0.85,
  });
}

/// Fills a silhouette completely with arrow pieces (100% of its cells).
///
/// Pieces are carved in *removal order*: each new piece must be able to
/// slide off the board in its arrowhead direction given the cells still
/// remaining, so every generated level is solvable by construction. The
/// same approach produced the curated Levels 1-20.
///
/// While carving, each piece's *chain depth* is known exactly: 1 plus the
/// deepest already-carved piece lying in its escape sweep (those must leave
/// first). Preferring deep pieces builds long dependency chains and few
/// free opening moves.
class DenseTiler {
  static const _dirs = ArrowDirection.values;

  static List<PuzzlePath> tile(
    Set<GridPoint> mask,
    int grid, {
    required int seed,
    TilerParams params = const TilerParams(),
    int attemptsPerPiece = 48,
  }) {
    final rng = _Lcg(seed);
    final remaining = Set<GridPoint>.of(mask);
    final order = <_Piece>[];
    final owner = <GridPoint, int>{}; // carved cell -> index in [order]
    final dirCount = <ArrowDirection, int>{for (final d in _dirs) d: 0};

    while (remaining.isNotEmpty) {
      final heads = _heads(remaining);
      final blocked = <MapEntry<ArrowDirection, GridPoint>>[
        for (final d in _dirs)
          for (final h in heads[d]!)
            if (_hitsCarved(h, d, owner, grid)) MapEntry(d, h),
      ];

      _Piece? best;
      var bestScore = double.negativeInfinity;
      final minCount = dirCount.values.reduce(math.min);
      for (int attempt = 0; attempt < attemptsPerPiece; attempt++) {
        // Often start from heads whose escape runs into carved pieces:
        // those become blocked arrows that extend dependency chains.
        final ArrowDirection d;
        final GridPoint head;
        if (blocked.isNotEmpty && rng.nextDouble() < params.blockedBias) {
          final pick = blocked[rng.next(blocked.length)];
          d = pick.key;
          head = pick.value;
        } else {
          d = _dirs[rng.next(4)];
          final hs = heads[d]!;
          if (hs.isEmpty) continue;
          head = hs[rng.next(hs.length)];
        }
        final aimLong = rng.nextDouble() < params.longChance;
        final base = aimLong ? params.meanSize * 2 : params.meanSize;
        final target = (base + (rng.nextDouble() * 2 - 1) * 2).round().clamp(
          2,
          params.maxSize,
        );

        // Grown head-first; reversed to tail->head at the end.
        final cells = <GridPoint>[head, _step(head, d, -1)];
        final own = <GridPoint>{...cells};
        while (cells.length < target) {
          final tail = cells.last;
          final ok = <GridPoint>[];
          for (final dd in _dirs) {
            final n = _step(tail, dd, 1);
            if (!remaining.contains(n) || own.contains(n)) continue;
            own.add(n);
            final exposed = _exposed(n, d, remaining, own, grid);
            own.remove(n);
            if (exposed) ok.add(n);
          }
          if (ok.isEmpty) break;
          // Prefer turning (bent pieces) most of the time.
          final prev = _dirBetween(cells[cells.length - 2], tail);
          final turning = ok
              .where((n) => _dirBetween(tail, n) != prev)
              .toList();
          final pool =
              turning.isNotEmpty && rng.nextDouble() < params.turnChance
              ? turning
              : ok;
          final next = pool[rng.next(pool.length)];
          cells.add(next);
          own.add(next);
        }

        final ordered = cells.reversed.toList();
        final depth = _depth(own, d, owner, order, grid);
        final score =
            _score(
              ordered,
              own,
              remaining,
              params,
              depth,
              dirCount[d]! - minCount,
            ) +
            rng.nextDouble();
        if (score > bestScore) {
          bestScore = score;
          best = _Piece(ordered, d, depth);
        }
      }

      // No two-cell piece fits anywhere: remove one exposed cell on its own.
      best ??= _singleCell(remaining, grid, owner, order);
      final index = order.length;
      order.add(best);
      for (final c in best.cells) {
        owner[c] = index;
      }
      remaining.removeAll(best.cells);
      dirCount[best.dir] = dirCount[best.dir]! + 1;
    }

    // Inner (last removed) pieces get the lowest ids.
    final pieces = order.reversed.toList();
    return [
      for (int i = 0; i < pieces.length; i++)
        PuzzlePath(
          id: '${i + 1}',
          points: _compress(pieces[i].cells),
          direction: pieces[i].dir,
          colorIndex: (i + 1) % 6,
        ),
    ];
  }

  /// Exposed cells per direction that have a body cell behind them: the
  /// outermost remaining cell of each column/row on that side.
  static Map<ArrowDirection, List<GridPoint>> _heads(Set<GridPoint> cells) {
    final top = <int, GridPoint>{}, bottom = <int, GridPoint>{};
    final left = <int, GridPoint>{}, right = <int, GridPoint>{};
    for (final c in cells) {
      if (top[c.x] == null || c.y < top[c.x]!.y) top[c.x] = c;
      if (bottom[c.x] == null || c.y > bottom[c.x]!.y) bottom[c.x] = c;
      if (left[c.y] == null || c.x < left[c.y]!.x) left[c.y] = c;
      if (right[c.y] == null || c.x > right[c.y]!.x) right[c.y] = c;
    }
    List<GridPoint> withBody(Iterable<GridPoint> hs, ArrowDirection d) => [
      for (final h in hs)
        if (cells.contains(_step(h, d, -1))) h,
    ]..sort(_cmp);
    return {
      ArrowDirection.up: withBody(top.values, ArrowDirection.up),
      ArrowDirection.down: withBody(bottom.values, ArrowDirection.down),
      ArrowDirection.left: withBody(left.values, ArrowDirection.left),
      ArrowDirection.right: withBody(right.values, ArrowDirection.right),
    };
  }

  /// True when the escape ray from [c] in direction [d] crosses a carved
  /// piece.
  static bool _hitsCarved(
      GridPoint c, ArrowDirection d, Map<GridPoint, int> owner, int grid) {
    var p = _step(c, d, 1);
    while (p.x >= 0 && p.y >= 0 && p.x < grid && p.y < grid) {
      if (owner.containsKey(p)) return true;
      p = _step(p, d, 1);
    }
    return false;
  }

  /// Chain depth of a piece: 1 + deepest carved piece in its escape sweep.
  static int _depth(
    Set<GridPoint> own,
    ArrowDirection d,
    Map<GridPoint, int> owner,
    List<_Piece> order,
    int grid,
  ) {
    var deepest = 0;
    for (final c in own) {
      var p = _step(c, d, 1);
      while (p.x >= 0 && p.y >= 0 && p.x < grid && p.y < grid) {
        final o = owner[p];
        if (o != null && order[o].depth > deepest) deepest = order[o].depth;
        p = _step(p, d, 1);
      }
    }
    return deepest + 1;
  }

  static double _score(
    List<GridPoint> cells,
    Set<GridPoint> own,
    Set<GridPoint> remaining,
    TilerParams params,
    int depth,
    int dirExcess,
  ) {
    var score = 0.0;
    // Never strand a cell with no remaining neighbour (it would become a
    // one-cell arrow).
    final checked = <GridPoint>{};
    for (final c in own) {
      for (final dd in _dirs) {
        final n = _step(c, dd, 1);
        if (own.contains(n) || !remaining.contains(n) || !checked.add(n)) {
          continue;
        }
        var hasNeighbour = false;
        for (final d2 in _dirs) {
          final m = _step(n, d2, 1);
          if (remaining.contains(m) && !own.contains(m)) {
            hasNeighbour = true;
            break;
          }
        }
        if (!hasNeighbour) score -= 500;
      }
    }
    if (cells.length == 2) score -= 60;
    score -= math.max(0, params.meanSize - cells.length) * 18;
    score -= math.max(0, cells.length - params.maxSize) * 8;
    if (depth == 1) {
      score -= params.freePenalty;
      score += cells.length * params.freeLengthBonus;
    }
    score += depth * params.depthWeight;
    var turns = 0;
    for (int i = 2; i < cells.length; i++) {
      if (_dirBetween(cells[i - 2], cells[i - 1]) !=
          _dirBetween(cells[i - 1], cells[i])) {
        turns++;
      }
    }
    score += math.min(turns, 5) * params.bendWeight;
    score -= dirExcess * 6;
    return score;
  }

  static _Piece _singleCell(
    Set<GridPoint> remaining,
    int grid,
    Map<GridPoint, int> owner,
    List<_Piece> order,
  ) {
    final sorted = remaining.toList()..sort(_cmp);
    for (final c in sorted) {
      for (final d in _dirs) {
        if (_exposed(c, d, remaining, const {}, grid)) {
          return _Piece([c], d, _depth({c}, d, owner, order, grid));
        }
      }
    }
    // Unreachable: the top-most cell of any column is always exposed upward.
    return _Piece([sorted.first], ArrowDirection.up, 1);
  }

  /// True when nothing in [cells] (other than [own]) lies beyond [c] in
  /// direction [d], i.e. [c] can slide off the board that way.
  static bool _exposed(
    GridPoint c,
    ArrowDirection d,
    Set<GridPoint> cells,
    Set<GridPoint> own,
    int grid,
  ) {
    var p = _step(c, d, 1);
    while (p.x >= 0 && p.y >= 0 && p.x < grid && p.y < grid) {
      if (cells.contains(p) && !own.contains(p)) return false;
      p = _step(p, d, 1);
    }
    return true;
  }

  static GridPoint _step(GridPoint c, ArrowDirection d, int k) {
    final v = d.vector;
    return GridPoint(c.x + v.dx.toInt() * k, c.y + v.dy.toInt() * k);
  }

  static ArrowDirection _dirBetween(GridPoint a, GridPoint b) {
    if (b.x > a.x) return ArrowDirection.right;
    if (b.x < a.x) return ArrowDirection.left;
    if (b.y > a.y) return ArrowDirection.down;
    return ArrowDirection.up;
  }

  static List<GridPoint> _compress(List<GridPoint> cells) {
    if (cells.length < 3) return List.of(cells);
    final pts = <GridPoint>[cells.first];
    for (int i = 1; i < cells.length - 1; i++) {
      if (_dirBetween(cells[i - 1], cells[i]) !=
          _dirBetween(cells[i], cells[i + 1])) {
        pts.add(cells[i]);
      }
    }
    pts.add(cells.last);
    return pts;
  }

  static int _cmp(GridPoint a, GridPoint b) =>
      a.y != b.y ? a.y - b.y : a.x - b.x;
}

class _Piece {
  final List<GridPoint> cells; // tail -> head
  final ArrowDirection dir;
  final int depth; // chain depth (1 = free on the full board)
  _Piece(this.cells, this.dir, this.depth);
}

/// Small deterministic generator so levels are identical on every platform.
class _Lcg {
  int _state;
  _Lcg(int seed) : _state = (seed.abs() & 0x7FFFFFFF) | 1;

  int _nextRaw() {
    _state = (_state * 48271) % 0x7FFFFFFF;
    return _state;
  }

  int next(int max) => max <= 0 ? 0 : _nextRaw() % max;

  double nextDouble() => _nextRaw() / 0x7FFFFFFF;
}
