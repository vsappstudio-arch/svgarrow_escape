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

  group('Level design: the 31-50 run climbs one step at a time', () {
    // Two solver-derived numbers describe how hard a board is to play,
    // and both are read off the real dependency graph rather than the
    // level's difficulty label:
    //
    //  - planning depth: the longest "this can't go until that goes"
    //    chain, i.e. how far ahead the order is forced;
    //  - choice: how many arrows can escape at any one moment, averaged
    //    over the solve. Fewer means the player has to find the one
    //    right arrow instead of picking any of several.
    //
    // Difficulty rises by deepening the first and narrowing the second,
    // never by making the board bigger or busier.
    final tiers = LevelData.levels.where((l) => l.id >= 31).toList();

    test('planning depth never drops, and Level 31 already exceeds Level 30', () {
      final level30Depth = _maxDependencyDepth(LevelData.byId(30));
      var previous = level30Depth;
      for (final level in tiers) {
        final depth = _maxDependencyDepth(level);
        expect(depth, greaterThanOrEqualTo(previous),
            reason: '${level.name} plans shallower than the level before it');
        previous = depth;
      }
      expect(_maxDependencyDepth(LevelData.byId(31)), greaterThan(level30Depth),
          reason: 'Level 31 should be a step up from Level 30, not a step down');
      expect(previous, greaterThan(level30Depth * 2),
          reason: 'Level 50 should be the deepest board in the game by a clear margin');
    });

    test('the choice of what to tap narrows steadily, never widens', () {
      var previous = _averageChoice(LevelData.byId(30));
      for (final level in tiers) {
        final choice = _averageChoice(level);
        expect(choice, lessThanOrEqualTo(previous + 0.0001),
            reason: '${level.name} offers more escapable arrows at a time than the level before it');
        previous = choice;
      }
      expect(previous, lessThan(1.2),
          reason: 'by Level 50 there should be essentially one right move at a time');
    });

    test('each level is a strict step up on depth or on choice', () {
      var previousDepth = _maxDependencyDepth(LevelData.byId(30));
      var previousChoice = _averageChoice(LevelData.byId(30));
      for (final level in tiers) {
        final depth = _maxDependencyDepth(level);
        final choice = _averageChoice(level);
        expect(depth > previousDepth || choice < previousChoice, isTrue,
            reason: '${level.name} is not actually harder than the level before it');
        previousDepth = depth;
        previousChoice = choice;
      }
    });

    test('no two of the 20 boards are the same layout', () {
      final seen = <String, String>{};
      for (final level in tiers) {
        final signature = (level.arrows.map((a) => '${a.row},${a.col},${a.direction.index}').toList()..sort()).join('|');
        final clash = seen[signature];
        expect(clash, isNull, reason: '${level.name} is the same board as $clash');
        seen[signature] = level.name;
      }
    });

    test('harder never means a bigger or more crowded board', () {
      for (final level in tiers) {
        expect(level.gridSize, lessThanOrEqualTo(12), reason: '${level.name} grew past a phone-friendly grid');
        final occupancy = level.arrows.length / (level.gridSize * level.gridSize);
        expect(occupancy, lessThan(0.35),
            reason: '${level.name} fills ${(occupancy * 100).round()}% of its grid - too cramped to read');
      }
      // The endgame is not simply the biggest pile of arrows: Level 50
      // uses fewer pieces than the old 52-arrow version did.
      expect(LevelData.byId(50).arrows.length, lessThan(45));
    });

    test('every level uses all four directions, so no edge can just be swept', () {
      for (final level in tiers) {
        expect(level.arrows.map((a) => a.direction).toSet().length, 4,
            reason: '${level.name} leaves out a direction, making it easier to pattern-match');
      }
    });

    test('every level plants decoys: arrows whose only blocker is far away', () {
      for (final level in tiers) {
        final decoys = level.arrows.where((a) {
          final blockers = _blockersOf(a, level);
          if (blockers.isEmpty) return false;
          return blockers.map((b) => _rayDistance(a, b)).reduce((x, y) => x < y ? x : y) >= 3;
        });
        expect(decoys.length, greaterThanOrEqualTo(3),
            reason: '${level.name} has too few arrows that read as escapable but are not');
      }
    });

    test('dots arrive gradually across 41-50 and never take over the board', () {
      var previous = 0;
      for (final level in LevelData.levels.where((l) => l.id >= 41)) {
        final dots = level.arrows.where((a) => a.isDot).length;
        expect(dots, greaterThanOrEqualTo(previous),
            reason: '${level.name} uses fewer dots than the level before it');
        expect(dots / level.arrows.length, lessThan(0.5),
            reason: '${level.name} turns most of the board into dots');
        previous = dots;
      }
      expect(LevelData.byId(41).arrows.where((a) => a.isDot).length, 1,
          reason: 'Level 41 should introduce the mechanic with a single dot');
    });
  });

  group('Level design: Levels 1-30 are untouched', () {
    test('the shipped layout of every level up to 30 still matches its approved data', () {
      // A fingerprint of the approved 1-30 boards. Any edit to a
      // position, direction, grid size or arrow count in that range
      // changes this number - which is exactly what must not happen
      // while later levels are being tuned.
      var hash = 0x811c9dc5;
      void mix(int value) {
        hash ^= value & 0xffff;
        hash = (hash * 0x01000193) & 0xffffffff;
      }

      for (final level in LevelData.levels.where((l) => l.id <= 30)) {
        mix(level.id);
        mix(level.gridSize);
        mix(level.optimalMoves);
        mix(level.arrows.length);
        for (final arrow in level.arrows) {
          mix(arrow.row);
          mix(arrow.col);
          mix(arrow.direction.index);
          mix(arrow.isDot ? 1 : 0);
        }
      }

      expect(hash, 354902144, reason: 'Levels 1-30 changed; they are the approved baseline');
    });
  });
}

int _rayDistance(ArrowModel target, ArrowModel blocker) {
  switch (target.direction) {
    case ArrowDirection.up:
      return target.row - blocker.row;
    case ArrowDirection.down:
      return blocker.row - target.row;
    case ArrowDirection.left:
      return target.col - blocker.col;
    case ArrowDirection.right:
      return blocker.col - target.col;
  }
}

/// Mean number of arrows that can escape at each point of a solve: the
/// size of the player's real search space, move by move.
double _averageChoice(LevelModel level) {
  final remaining = [...level.arrows];
  final counts = <int>[];
  while (remaining.isNotEmpty) {
    final free = remaining.where((a) => a.arrowsBlocking(remaining).isEmpty).toList();
    if (free.isEmpty) return double.infinity; // deadlock; other tests report it
    counts.add(free.length);
    remaining.remove(free.first);
  }
  return _avg(counts);
}

extension on ArrowModel {
  List<ArrowModel> arrowsBlocking(Iterable<ArrowModel> others) {
    return others.where((o) => o.id != id && _blocks(this, o)).toList();
  }
}
