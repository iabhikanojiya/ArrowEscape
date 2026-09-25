import 'dart:math' as math;
import 'dart:typed_data';

import '../../models/arrow.dart';
import '../../models/puzzle_path.dart';

/// Difficulty and style knobs for [DenseTiler].
class TilerParams {
  /// Chance a piece is short (2-3 cells).
  final double shortChance;

  /// Chance a piece aims for a long run ([longMin]..[maxSize] cells).
  final double longChance;

  /// Typical medium piece length.
  final double mediumMean;

  /// Shortest "long" piece.
  final int longMin;

  /// Longest piece allowed.
  final int maxSize;

  /// Score per bend (up to 8 bends).
  final double bendWeight;

  /// Chance of turning at each growth step when a turn is possible.
  final double turnChance;

  /// Score per level of chain depth.
  final double depthWeight;

  /// Penalty for a piece that is free on the full board (an opening move).
  final double freePenalty;

  /// Bonus per cell for opening-move pieces: fewer, longer free arrows.
  final double freeLengthBonus;

  /// Chance of starting a piece where its escape runs into carved pieces
  /// (builds dependency chains).
  final double blockedBias;

  const TilerParams({
    this.shortChance = 0.2,
    this.longChance = 0.1,
    this.mediumMean = 4.5,
    this.longMin = 7,
    this.maxSize = 10,
    this.bendWeight = 22,
    this.turnChance = 0.6,
    this.depthWeight = 8,
    this.freePenalty = 120,
    this.freeLengthBonus = 0,
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
/// free opening moves. Pieces never cross colour regions, so each region
/// of the silhouette reads as one colour.
class DenseTiler {
  static const _dirs = ArrowDirection.values;
  static const _dx = [0, 0, -1, 1]; // up, down, left, right
  static const _dy = [-1, 1, 0, 0];

  /// Tiles [regions] (cell -> colour region) on a [grid] x [grid] board.
  static List<PuzzlePath> tile(
    Map<GridPoint, int> regions,
    int grid, {
    required int seed,
    TilerParams params = const TilerParams(),
    int attemptsPerPiece = 48,
  }) {
    return _Tiling(regions, grid, _Lcg(seed), params, attemptsPerPiece).run();
  }
}

class _Piece {
  final List<int> cells; // tail -> head (cell indices)
  final int dir; // index into ArrowDirection.values
  final int depth; // chain depth (1 = free on the full board)
  _Piece(this.cells, this.dir, this.depth);
}

class _Tiling {
  final int g;
  final _Lcg rng;
  final TilerParams p;
  final int attempts;
  final Int8List region; // -1 = not part of the silhouette
  final Uint8List remaining;
  final Int32List owner; // carved cell -> piece index, -1 otherwise
  final Int32List ownMark; // stamp-based "belongs to candidate" marks
  int stamp = 0;
  int remainingCount = 0;
  final pieces = <_Piece>[];
  final dirCount = List<int>.filled(4, 0);

  _Tiling(Map<GridPoint, int> regions, this.g, this.rng, this.p, this.attempts)
    : region = Int8List(g * g)..fillRange(0, g * g, -1),
      remaining = Uint8List(g * g),
      owner = Int32List(g * g)..fillRange(0, g * g, -1),
      ownMark = Int32List(g * g) {
    regions.forEach((c, r) {
      if (c.x < 0 || c.y < 0 || c.x >= g || c.y >= g) return;
      final i = c.y * g + c.x;
      region[i] = r;
      remaining[i] = 1;
      remainingCount++;
    });
  }

  int _x(int i) => i % g;
  int _y(int i) => i ~/ g;

  /// Neighbour of [i] in direction [d], or -1 off the board.
  int _nb(int i, int d) {
    final x = _x(i) + DenseTiler._dx[d], y = _y(i) + DenseTiler._dy[d];
    if (x < 0 || y < 0 || x >= g || y >= g) return -1;
    return y * g + x;
  }

  bool _own(int i) => ownMark[i] == stamp;

  /// Nothing remaining (other than the candidate's own cells) lies beyond
  /// [i] in direction [d].
  bool _exposed(int i, int d) {
    var q = _nb(i, d);
    while (q >= 0) {
      if (remaining[q] == 1 && !_own(q)) return false;
      q = _nb(q, d);
    }
    return true;
  }

  bool _hitsCarved(int i, int d) {
    var q = _nb(i, d);
    while (q >= 0) {
      if (owner[q] >= 0) return true;
      q = _nb(q, d);
    }
    return false;
  }

  List<PuzzlePath> run() {
    while (remainingCount > 0) {
      final heads = _heads();
      final blocked = <int>[]; // packed head * 4 + dir
      for (int d = 0; d < 4; d++) {
        for (final h in heads[d]) {
          if (_hitsCarved(h, d)) blocked.add(h * 4 + d);
        }
      }
      final minCount = dirCount.reduce(math.min);

      _Piece? best;
      var bestScore = double.negativeInfinity;
      for (int attempt = 0; attempt < attempts; attempt++) {
        int d, head;
        if (blocked.isNotEmpty && rng.nextDouble() < p.blockedBias) {
          final pick = blocked[rng.next(blocked.length)];
          head = pick ~/ 4;
          d = pick % 4;
        } else {
          d = rng.next(4);
          final hs = heads[d];
          if (hs.isEmpty) continue;
          head = hs[rng.next(hs.length)];
        }
        final target = _targetLength();
        final cells = _grow(head, d, target);
        final depth = _depth(cells, d);
        final score =
            _score(cells, d, depth, target, dirCount[d] - minCount) +
            rng.nextDouble();
        if (score > bestScore) {
          bestScore = score;
          best = _Piece(cells.reversed.toList(), d, depth);
        }
      }

      best ??= _singleCell();
      final index = pieces.length;
      pieces.add(best);
      for (final c in best.cells) {
        owner[c] = index;
        remaining[c] = 0;
      }
      remainingCount -= best.cells.length;
      dirCount[best.dir]++;
    }

    _absorbSingles();
    _pairSingles();

    // Inner (last removed) pieces get the lowest ids.
    final ordered = pieces
        .where((pc) => pc.cells.isNotEmpty)
        .toList()
        .reversed
        .toList();
    return [
      for (int i = 0; i < ordered.length; i++)
        PuzzlePath(
          id: '${i + 1}',
          points: _compress(ordered[i].cells),
          direction: DenseTiler._dirs[ordered[i].dir],
          colorIndex: (i + 1) % 6,
        ),
    ];
  }

  /// Attaches leftover one-cell pieces to the tail of an adjacent piece
  /// when that keeps the whole removal order valid:
  /// * the cell can slide out with its new piece, i.e. nothing removed
  ///   after that piece lies beyond it in the piece's direction, and
  /// * if the cell now leaves later than before, no piece removed in
  ///   between has it in its escape sweep.
  void _absorbSingles() {
    for (int j = 0; j < pieces.length; j++) {
      final single = pieces[j];
      if (single.cells.length != 1) continue;
      final s = single.cells.first;
      for (int dd = 0; dd < 4; dd++) {
        final n = _nb(s, dd);
        if (n < 0) continue;
        final i = owner[n];
        if (i < 0 || i == j) continue;
        final host = pieces[i];
        if (host.cells.length < 2 || host.cells.first != n) continue; // tail
        if (!_clearAfter(s, host.dir, i)) continue;
        if (i > j && _sweptBetween(s, j, i)) continue;
        pieces[i] = _Piece([s, ...host.cells], host.dir, host.depth);
        pieces[j] = _Piece(const [], single.dir, single.depth);
        owner[s] = i;
        break;
      }
    }
  }

  /// Merges two adjacent leftover one-cell pieces into one two-cell arrow
  /// (tail -> head) when the removal order stays valid, trying the pair at
  /// either piece's position and in either orientation.
  void _pairSingles() {
    for (int i = 0; i < pieces.length; i++) {
      if (pieces[i].cells.length != 1) continue;
      final a = pieces[i].cells.first;
      for (int dd = 0; dd < 4 && pieces[i].cells.length == 1; dd++) {
        final b = _nb(a, dd);
        if (b < 0) continue;
        final j = owner[b];
        if (j < 0 || j == i || pieces[j].cells.length != 1) continue;
        // Keep the pair at the earlier removal slot so neither cell leaves
        // later than before; try both orientations.
        final slot = i < j ? i : j;
        for (final pair in [[a, b], [b, a]]) {
          final tail = pair[0], head = pair[1];
          final dir = _dirOf(tail, head);
          if (!_clearAfter(head, dir, slot)) continue;
          final other = slot == i ? j : i;
          pieces[slot] = _Piece([tail, head], dir, pieces[slot].depth);
          pieces[other] = _Piece(const [], dir, 0);
          owner[a] = slot;
          owner[b] = slot;
          break;
        }
      }
    }
  }

  /// Nothing owned by a piece removed after [index] lies beyond [c] in [d].
  bool _clearAfter(int c, int d, int index) {
    var q = _nb(c, d);
    while (q >= 0) {
      if (owner[q] > index) return false;
      q = _nb(q, d);
    }
    return true;
  }

  /// Some piece removed strictly between [from] and [to] sweeps over [c].
  bool _sweptBetween(int c, int from, int to) {
    for (int k = from + 1; k < to; k++) {
      final pc = pieces[k];
      final back = _opposite(pc.dir);
      // [c] is in pc's sweep iff walking from c against pc's direction
      // reaches one of pc's cells.
      var q = _nb(c, back);
      while (q >= 0) {
        if (owner[q] == k) return true;
        q = _nb(q, back);
      }
    }
    return false;
  }

  int _targetLength() {
    final r = rng.nextDouble();
    if (r < p.shortChance) return 2 + rng.next(2);
    if (r < p.shortChance + p.longChance) {
      return p.longMin + rng.next(math.max(1, p.maxSize - p.longMin + 1));
    }
    return (p.mediumMean + (rng.nextDouble() * 2 - 1) * 1.5).round().clamp(
      3,
      p.maxSize,
    );
  }

  /// Grows a piece head-first from [head] (moving in [d]); returns cells
  /// head -> tail. All cells stay in the head's colour region, and the
  /// finished piece can slide out in [d] (it is exposed as a whole).
  ///
  /// Besides plain steps into already-exposed cells, a step may enter a
  /// blocked cell when its blockers form a straight run towards the edge:
  /// the path then continues through that run (a U-turn / comb), which
  /// unblocks it. This gives long serpentine arrows.
  List<int> _grow(int head, int d, int target) {
    stamp++;
    final back = _nb(head, _opposite(d));
    final cells = <int>[head, back];
    ownMark[head] = stamp;
    ownMark[back] = stamp;
    final reg = region[head];
    final options = <List<int>>[];
    final turning = <List<int>>[];
    while (cells.length < target) {
      final tail = cells.last;
      final prev = _dirOf(cells[cells.length - 2], tail);
      options.clear();
      turning.clear();
      for (int dd = 0; dd < 4; dd++) {
        final n = _nb(tail, dd);
        if (n < 0 || remaining[n] == 0 || _own(n) || region[n] != reg) {
          continue;
        }
        final step = _stepInto(n, d, reg, p.maxSize - cells.length);
        if (step == null) continue;
        options.add(step);
        if (dd != prev || step.length > 1) turning.add(step);
      }
      if (options.isEmpty) break;
      final pool = turning.isNotEmpty && rng.nextDouble() < p.turnChance
          ? turning
          : options;
      for (final c in pool[rng.next(pool.length)]) {
        cells.add(c);
        ownMark[c] = stamp;
      }
    }
    return cells;
  }

  /// Cells to append when stepping into [n]: just [n] if it is exposed in
  /// [d]; otherwise [n] plus the straight run of same-region blockers
  /// beyond it in [d], if that run reaches open space (so the whole run is
  /// exposed once added) and fits in [room]. Null if not possible.
  List<int>? _stepInto(int n, int d, int reg, int room) {
    final run = <int>[n];
    var q = _nb(n, d);
    while (q >= 0 && remaining[q] == 1 && !_own(q)) {
      if (region[q] != reg) return null;
      run.add(q);
      q = _nb(q, d);
    }
    if (run.length > room) return null;
    // Beyond the run nothing else may remain in the way.
    while (q >= 0) {
      if (remaining[q] == 1 && !_own(q)) return null;
      q = _nb(q, d);
    }
    return run;
  }

  /// Chain depth: 1 + deepest carved piece in the escape sweep.
  int _depth(List<int> cells, int d) {
    var deepest = 0;
    for (final c in cells) {
      var q = _nb(c, d);
      while (q >= 0) {
        final o = owner[q];
        if (o >= 0 && pieces[o].depth > deepest) deepest = pieces[o].depth;
        q = _nb(q, d);
      }
    }
    return deepest + 1;
  }

  double _score(List<int> cells, int d, int depth, int target, int dirExcess) {
    var score = 0.0;
    // Never strand a cell with no same-region neighbour left (it would
    // become a one-cell arrow).
    for (final c in cells) {
      for (int dd = 0; dd < 4; dd++) {
        final n = _nb(c, dd);
        if (n < 0 || remaining[n] == 0 || _own(n)) continue;
        var hasNeighbour = false;
        for (int d2 = 0; d2 < 4; d2++) {
          final m = _nb(n, d2);
          if (m >= 0 &&
              remaining[m] == 1 &&
              !_own(m) &&
              region[m] == region[n]) {
            hasNeighbour = true;
            break;
          }
        }
        if (!hasNeighbour) score -= 500;
      }
    }
    if (cells.length == 2 && target > 3) score -= 40;
    score -= math.max(0, target - cells.length) * 12;
    if (depth == 1) {
      score -= p.freePenalty;
      score += cells.length * p.freeLengthBonus;
    }
    score += depth * p.depthWeight;
    var turns = 0;
    for (int i = 2; i < cells.length; i++) {
      if (_dirOf(cells[i - 2], cells[i - 1]) !=
          _dirOf(cells[i - 1], cells[i])) {
        turns++;
      }
    }
    score += math.min(turns, 8) * p.bendWeight;
    score -= dirExcess * 6;
    return score;
  }

  /// Exposed cells per direction that have a same-region body cell behind
  /// them: the outermost remaining cell of each column/row on that side.
  List<List<int>> _heads() {
    final top = Int32List(g)..fillRange(0, g, -1);
    final bottom = Int32List(g)..fillRange(0, g, -1);
    final left = Int32List(g)..fillRange(0, g, -1);
    final right = Int32List(g)..fillRange(0, g, -1);
    for (int i = 0; i < g * g; i++) {
      if (remaining[i] == 0) continue;
      final x = _x(i), y = _y(i);
      if (top[x] < 0) top[x] = i;
      bottom[x] = i;
      if (left[y] < 0) left[y] = i;
      right[y] = i;
    }
    List<int> withBody(Int32List hs, int d) {
      final out = <int>[];
      for (final h in hs) {
        if (h < 0) continue;
        final b = _nb(h, _opposite(d));
        if (b >= 0 && remaining[b] == 1 && region[b] == region[h]) out.add(h);
      }
      return out;
    }

    return [
      withBody(top, 0), // up
      withBody(bottom, 1), // down
      withBody(left, 2), // left
      withBody(right, 3), // right
    ];
  }

  _Piece _singleCell() {
    stamp++;
    for (int i = 0; i < g * g; i++) {
      if (remaining[i] == 0) continue;
      for (int d = 0; d < 4; d++) {
        if (_exposed(i, d)) return _Piece([i], d, _depth([i], d));
      }
    }
    throw StateError('no exposed cell'); // unreachable: top cells are exposed
  }

  static int _opposite(int d) => const [1, 0, 3, 2][d];

  int _dirOf(int a, int b) {
    final dx = _x(b) - _x(a), dy = _y(b) - _y(a);
    if (dx > 0) return 3;
    if (dx < 0) return 2;
    if (dy > 0) return 1;
    return 0;
  }

  List<GridPoint> _compress(List<int> cells) {
    GridPoint pt(int i) => GridPoint(_x(i), _y(i));
    if (cells.length < 3) return [for (final c in cells) pt(c)];
    final pts = <GridPoint>[pt(cells.first)];
    for (int i = 1; i < cells.length - 1; i++) {
      if (_dirOf(cells[i - 1], cells[i]) != _dirOf(cells[i], cells[i + 1])) {
        pts.add(pt(cells[i]));
      }
    }
    pts.add(pt(cells.last));
    return pts;
  }
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
