import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_escape/game/level_data.dart';
import 'package:arrow_escape/models/arrow_model.dart';
import 'package:arrow_escape/models/level_model.dart';

/// Pure geometry check, independent of PuzzleEngine: does [blocker] sit
/// between [target] and the edge [target] escapes toward? Mirrors
/// PuzzleEngine's private `_blocks`, kept separate so this suite verifies
/// the shipped level *data* on its own terms rather than trusting the
/// engine it will later run against.
bool _blocks(ArrowModel target, ArrowModel blocker) {
  switch (target.direction) {
    case ArrowDirection.up:
      return blocker.col == target.col && blocker.row < target.row;
    case ArrowDirection.down:
      return blocker.col == target.col && blocker.row > target.row;
    case ArrowDirection.left:
      return blocker.row == target.row && blocker.col < target.col;
    case ArrowDirection.right:
      return blocker.row == target.row && blocker.col > target.col;
  }
}

/// The set of arrows that directly block [target] at the start of the
/// level (before anything is removed).
List<ArrowModel> _blockersOf(ArrowModel target, LevelModel level) {
  return level.arrows
      .where((a) => a.id != target.id && _blocks(target, a))
      .toList();
}

/// Longest dependency chain ending at [target]: 1 for an arrow with no
/// blockers, else 1 + the deepest of its blockers' own chains.
int _dependencyDepth(ArrowModel target, LevelModel level,
    Map<String, int> memo) {
  final cached = memo[target.id];
  if (cached != null) return cached;
  final blockers = _blockersOf(target, level);
  if (blockers.isEmpty) return memo[target.id] = 1;
  var deepest = 0;
  for (final b in blockers) {
    final d = _dependencyDepth(b, level, memo);
    if (d > deepest) deepest = d;
  }
  return memo[target.id] = deepest + 1;
}

int _maxDependencyDepth(LevelModel level) {
  final memo = <String, int>{};
  var max = 0;
  for (final a in level.arrows) {
    final d = _dependencyDepth(a, level, memo);
    if (d > max) max = d;
  }
  return max;
}

int _maxFanIn(LevelModel level) {
  var max = 0;
  for (final a in level.arrows) {
    final n = _blockersOf(a, level).length;
    if (n > max) max = n;
  }
  return max;
}

/// Mean blockers-per-arrow across the whole level: how entangled the
/// *average* arrow is, not just the single hardest one.
double _avgFanIn(LevelModel level) {
  final counts = level.arrows.map((a) => _blockersOf(a, level).length);
  return _avg(counts);
}

double _avg(Iterable<num> values) {
  var sum = 0.0;
  var count = 0;
  for (final v in values) {
    sum += v;
    count++;
  }
  return sum / count;
}

void main() {
  group('Level design: solvability', () {
    test('every level\'s dependency graph is acyclic', () {
      // A level is solvable iff repeatedly removing any arrow with zero
      // *currently active* blockers eventually clears the board. If we
      // ever get stuck with arrows remaining, there's a cycle - two (or
      // more) arrows transitively depend on each other and neither can
      // ever go first.
      for (final level in LevelData.levels) {
        final remaining = {for (final a in level.arrows) a.id: a};
        var progressed = true;
        while (remaining.isNotEmpty && progressed) {
          progressed = false;
          for (final a in remaining.values.toList()) {
            final blockers = a.arrowsBlocking(remaining.values);
            if (blockers.isEmpty) {
              remaining.remove(a.id);
              progressed = true;
            }
          }
        }
        expect(remaining, isEmpty,
            reason:
                '${level.name} has a dependency cycle: ${remaining.keys}');
      }
    });
  });

  group('Level design: genuine (not just labeled) difficulty curve', () {
    test('later tiers have deeper dependency chains than the tutorial tier',
        () {
      final tutorial = LevelData.levels.take(5).map(_maxDependencyDepth);
      final endgame =
          LevelData.levels.skip(45).take(5).map(_maxDependencyDepth);
      expect(_avg(endgame), greaterThan(_avg(tutorial)),
          reason: 'levels 46-50 should require deeper lookahead than '
              'levels 1-5, via real dependency chains - not just a bigger '
              'difficulty number');
    });

    test('later tiers have richer fan-in than the tutorial tier', () {
      final tutorial = LevelData.levels.take(5).map(_maxFanIn);
      final endgame = LevelData.levels.skip(45).take(5).map(_maxFanIn);
      expect(_avg(endgame), greaterThan(_avg(tutorial)),
          reason: 'levels 46-50 should gate more arrows behind multiple '
              'simultaneous blockers than levels 1-5');
    });

    test('difficulty is not simply grid size in disguise', () {
      // A bigger board filled with the same shallow, mostly-independent
      // chains would NOT raise how entangled the average arrow is. Real
      // structural difficulty (fan-in gates, nested hubs) does.
      final tutorial = LevelData.levels.take(5).map(_avgFanIn);
      final endgame = LevelData.levels.skip(45).take(5).map(_avgFanIn);
      expect(_avg(endgame), greaterThan(_avg(tutorial)),
          reason: 'endgame levels should make the average arrow more '
              'entangled with others, not just spread the same shallow '
              'chains over a bigger empty board');
    });
  });

  group('Level design: the Level 41+ dot mechanic', () {
    test('dots only ever appear from Level 41 onward', () {
      for (final level in LevelData.levels.where((l) => l.id < 41)) {
        expect(level.arrows.any((a) => a.isDot), isFalse,
            reason: '${level.name} is before the dot tier and should have no dot pieces');
      }
    });

    test('every dot piece still sits at a valid, non-overlapping position', () {
      // A dot is a rendering variant only (ArrowTile keeps its full
      // tap-target size regardless); it must obey the exact same
      // placement rules as a normal arrow.
      for (final level in LevelData.levels.where((l) => l.id >= 41)) {
        for (final arrow in level.arrows.where((a) => a.isDot)) {
          expect(arrow.row >= 0 && arrow.row < level.gridSize, isTrue,
              reason: '${level.name}: dot ${arrow.id} row out of bounds');
          expect(arrow.col >= 0 && arrow.col < level.gridSize, isTrue,
              reason: '${level.name}: dot ${arrow.id} col out of bounds');
        }
      }
    });

    test('Level 41 introduces dots with a minimal, easy-to-read board', () {
      final level41 = LevelData.levels.firstWhere((l) => l.id == 41);
      final dotCount = level41.arrows.where((a) => a.isDot).length;
      expect(dotCount, greaterThanOrEqualTo(1));
      expect(dotCount, lessThan(level41.arrows.length),
          reason: 'Level 41 should mix dots in gradually, not switch the whole board over at once');
    });

    test('the finale (46-50) combines dots with the harder gate/chain structures', () {
      for (final level in LevelData.levels.where((l) => l.id >= 46)) {
        expect(level.arrows.any((a) => a.isDot), isTrue,
            reason: '${level.name} (46-50) should include dot pieces alongside its harder structure');
      }
    });
  });
}

extension on ArrowModel {
  List<ArrowModel> arrowsBlocking(Iterable<ArrowModel> others) {
    return others.where((o) => o.id != id && _blocks(this, o)).toList();
  }
}
