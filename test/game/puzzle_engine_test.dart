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
