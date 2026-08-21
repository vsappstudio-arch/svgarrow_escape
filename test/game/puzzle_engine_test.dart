import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_escape/game/level_data.dart';
import 'package:arrow_escape/game/puzzle_engine.dart';
import 'package:arrow_escape/models/arrow_model.dart';
import 'package:arrow_escape/models/level_model.dart';

void main() {
  group('PuzzleEngine', () {
    late LevelModel level;

    setUp(() {
      level = const LevelModel(
        id: 99,
        name: 'Test Level',
        gridSize: 3,
        difficulty: 1,
        optimalMoves: 2,
        arrows: [
          ArrowModel(id: 'blocked', row: 0, col: 0, direction: ArrowDirection.down),
          ArrowModel(id: 'blocker', row: 2, col: 0, direction: ArrowDirection.right),
        ],
      );
    });

    test('an arrow with another arrow in its path cannot escape', () {
      final engine = PuzzleEngine(level);
      expect(engine.tryRemove('blocked'), isFalse);
      expect(engine.isRemoved('blocked'), isFalse);
    });

    test('removing the blocker unblocks the other arrow', () {
      final engine = PuzzleEngine(level);
      expect(engine.tryRemove('blocker'), isTrue);
      expect(engine.tryRemove('blocked'), isTrue);
      expect(engine.isSolved, isTrue);
    });

    test('blocked attempts still count toward moves', () {
      final engine = PuzzleEngine(level);
      engine.tryRemove('blocked'); // blocked, +1 move
      engine.tryRemove('blocker'); // succeeds, +1 move
      engine.tryRemove('blocked'); // succeeds, +1 move
      expect(engine.moves, 3);
      expect(engine.isSolved, isTrue);
    });

    test('starsEarned is 0 until solved, then scales with efficiency', () {
      final engine = PuzzleEngine(level);
      expect(engine.starsEarned, 0);

      engine.tryRemove('blocker');
      engine.tryRemove('blocked');
      expect(engine.moves, level.optimalMoves);
      expect(engine.starsEarned, 3);
    });

    test('an extra blocked attempt drops the level from 3 to 2 stars', () {
      final engine = PuzzleEngine(level);
      engine.tryRemove('blocked'); // wasted attempt
      engine.tryRemove('blocker');
      engine.tryRemove('blocked');
      expect(engine.moves, level.optimalMoves + 1);
      expect(engine.starsEarned, 2);
    });

    test('reset clears removed arrows and move count', () {
      final engine = PuzzleEngine(level);
      engine.tryRemove('blocker');
      engine.tryRemove('blocked');
      engine.reset();
      expect(engine.moves, 0);
      expect(engine.isSolved, isFalse);
      expect(engine.activeArrows.length, level.arrows.length);
    });

    test('tryRemove on an already-removed arrow returns false without counting a move', () {
      final engine = PuzzleEngine(level);
      engine.tryRemove('blocker');
      final movesAfterFirstRemoval = engine.moves;
      expect(engine.tryRemove('blocker'), isFalse);
      expect(engine.moves, movesAfterFirstRemoval);
    });
  });

  group('LevelData structure', () {
    test('exactly 50 levels exist', () {
      expect(LevelData.levels.length, 50);
    });

    test('level ids are exactly 1..50, in order, with no gaps or duplicates', () {
      expect(LevelData.levels.map((l) => l.id).toList(), List.generate(50, (i) => i + 1));
    });

    test('every level has at least one arrow and a positive optimalMoves', () {
      for (final level in LevelData.levels) {
        expect(level.arrows, isNotEmpty, reason: '${level.name} has no arrows');
        expect(level.optimalMoves, greaterThan(0), reason: '${level.name} has a non-positive optimalMoves');
      }
    });

    test('every arrow sits on the grid with no two arrows overlapping', () {
      for (final level in LevelData.levels) {
        final seen = <String>{};
        for (final arrow in level.arrows) {
          expect(
            arrow.row >= 0 && arrow.row < level.gridSize && arrow.col >= 0 && arrow.col < level.gridSize,
            isTrue,
            reason: '${level.name}: ${arrow.id} at (${arrow.row},${arrow.col}) is outside its ${level.gridSize}x${level.gridSize} grid',
          );
          final key = '${arrow.row},${arrow.col}';
          expect(seen.add(key), isTrue, reason: '${level.name}: two arrows overlap at $key');
        }
      }
    });

    test('difficulty is non-decreasing from level 1 to level 50', () {
      for (var i = 1; i < LevelData.levels.length; i++) {
        expect(
          LevelData.levels[i].difficulty,
          greaterThanOrEqualTo(LevelData.levels[i - 1].difficulty),
          reason: '${LevelData.levels[i].name} has lower difficulty than ${LevelData.levels[i - 1].name}',
        );
      }
    });

    test('every level has unique arrow ids and optimalMoves equal to its arrow count', () {
      // This game's engine only ever wastes a move on a genuinely
      // blocked tap; a solvable level always admits an order with
      // zero waste, so optimalMoves (and therefore the 3-star bar)
      // must equal the arrow count exactly - never more, never less.
      for (final level in LevelData.levels) {
        final ids = level.arrows.map((a) => a.id).toSet();
        expect(ids.length, level.arrows.length, reason: '${level.name} has duplicate arrow ids');
        expect(level.optimalMoves, level.arrows.length,
            reason: '${level.name}: optimalMoves (${level.optimalMoves}) should equal its arrow count (${level.arrows.length})');
      }
    });

    test('grid sizes stay small enough for arrows to stay tappable on a phone', () {
      // The Level 20 physical-device test found 19x19-style boards
      // unplayable: tiles shrink below a comfortably tappable size.
      // Every level - including the Level 50 finale - must stay well
      // under that.
      for (final level in LevelData.levels) {
        expect(level.gridSize, lessThanOrEqualTo(12),
            reason: '${level.name} has a ${level.gridSize}x${level.gridSize} grid, too large for comfortable phone taps');
      }
    });

    test('no dot-based pieces before Level 41; the dot mechanic begins at Level 41', () {
      for (final level in LevelData.levels.where((l) => l.id <= 40)) {
        expect(level.arrows.any((a) => a.isDot), isFalse,
            reason: '${level.name} (<=40) should only use normal, fully-visible arrows');
      }

      final level41 = LevelData.byId(41);
      expect(level41.arrows.any((a) => a.isDot), isTrue,
          reason: 'Level 41 should introduce the first dot-based piece');
    });

    test('Level 50 is the final level: it does not try to unlock/load Level 51', () {
      expect(LevelData.levels.last.id, 50);
      const nextLevelId = 51;
      expect(nextLevelId <= LevelData.levels.length, isFalse);
      expect(() => LevelData.byId(51), throwsArgumentError);
    });
  });

  group('LevelData', () {
    for (final level in LevelData.levels) {
      test('${level.name} is solvable in exactly optimalMoves', () {
        final engine = PuzzleEngine(level);

        // Monotonic property: once an arrow can escape, removing other
        // arrows never re-blocks it. So greedily removing any currently
        // escapable arrow, repeated, solves any solvable level.
        var progressed = true;
        while (!engine.isSolved && progressed) {
          progressed = false;
          for (final arrow in engine.activeArrows) {
            if (engine.canEscape(arrow)) {
              engine.tryRemove(arrow.id);
              progressed = true;
              break;
            }
          }
        }

        expect(engine.isSolved, isTrue, reason: '${level.name} could not be solved');
        expect(engine.moves, level.optimalMoves);
      });
    }
  });
}
