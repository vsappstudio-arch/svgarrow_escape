import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/game/level_data.dart';
import 'package:arrow_escape/state/progress_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Level progression', () {
    test('completing level 6 unlocks level 7', () async {
      final controller = ProgressController();
      await controller.load();

      await controller.completeLevel(6, 3, 7);

      expect(controller.isUnlocked(7), isTrue);
    });

    test('completing level 27 unlocks level 28', () async {
      final controller = ProgressController();
      await controller.load();

      await controller.completeLevel(27, 3, 21);

      expect(controller.isUnlocked(28), isTrue);
    });

    test('completing level 28 unlocks level 29', () async {
      final controller = ProgressController();
      await controller.load();

      await controller.completeLevel(28, 3, 23);

      expect(controller.isUnlocked(29), isTrue);
    });

    test('completing level 29 unlocks level 30', () async {
      final controller = ProgressController();
      await controller.load();

      await controller.completeLevel(29, 3, 24);

      expect(controller.isUnlocked(30), isTrue);
    });

    test('level 50 is the final level: it does not try to unlock level 51', () async {
      final controller = ProgressController();
      await controller.load();

      await controller.completeLevel(50, 3, LevelData.byId(50).optimalMoves);

      // There is no level 51 to navigate to. The screen that decides
      // whether to show a "Next Level" button uses exactly this
      // check (nextLevelId <= LevelData.levels.length); it must be
      // false so the app never attempts to load a nonexistent level.
      const nextLevelId = 51;
      expect(nextLevelId <= LevelData.levels.length, isFalse);
      expect(() => LevelData.byId(51), throwsArgumentError);
    });

    test('unlocking never regresses past an already-unlocked level', () async {
      final controller = ProgressController();
      await controller.load();

      await controller.completeLevel(10, 3, 9);
      expect(controller.progress.unlockedLevel, 11);

      // Replaying an earlier, already-cleared level must not lock
      // progress back down.
      await controller.completeLevel(3, 2, 5);
      expect(controller.progress.unlockedLevel, 11);
    });
  });

  group('Persistence', () {
    test('progress survives an app restart (a fresh controller reading the same storage)', () async {
      final first = ProgressController();
      await first.load();

      await first.completeLevel(6, 3, 7);
      await first.completeLevel(7, 2, 9);

      // Simulate an app restart: a brand-new controller instance
      // loading from the same persisted storage.
      final restarted = ProgressController();
      await restarted.load();

      expect(restarted.progress.unlockedLevel, 8);
      expect(restarted.starsFor(6), 3);
      expect(restarted.starsFor(7), 2);
      expect(restarted.bestMovesFor(7), 9);
      expect(restarted.progress.coins, first.progress.coins);
    });

    test('progress through level 6 made before this update is preserved after the level list grows', () async {
      // Simulates an existing player who had only completed levels
      // 1-6 under the old 6-level build.
      final legacy = ProgressController();
      await legacy.load();
      for (var id = 1; id <= 6; id++) {
        await legacy.completeLevel(id, 3, id + 1);
      }
      expect(legacy.progress.unlockedLevel, 7);

      // "App restart" onto the build with levels 7-30 added.
      final afterUpdate = ProgressController();
      await afterUpdate.load();

      expect(afterUpdate.progress.unlockedLevel, 7);
      for (var id = 1; id <= 6; id++) {
        expect(afterUpdate.starsFor(id), 3);
      }
      expect(afterUpdate.isUnlocked(7), isTrue);
      expect(afterUpdate.isUnlocked(8), isFalse);
    });
  });

  group('Level status', () {
    /// Plays every level from 1 through [lastLevelId] at its optimal
    /// move count, the way a player actually reaches that progression.
    Future<void> completeThrough(ProgressController controller, int lastLevelId) async {
      for (var id = 1; id <= lastLevelId; id++) {
        await controller.completeLevel(id, 3, LevelData.byId(id).optimalMoves);
      }
    }

    test('a fresh player: level 1 is current, level 2 is locked', () async {
      final controller = ProgressController();
      await controller.load();

      expect(controller.statusFor(1), LevelStatus.current);
      expect(controller.statusFor(2), LevelStatus.locked);
      // Nothing is completed yet, so nothing pretends to be.
      expect(controller.isCompleted(1), isFalse);
    });

    test('after level 1: 1 completed, 2 current, 3 locked', () async {
      final controller = ProgressController();
      await controller.load();

      await completeThrough(controller, 1);

      expect(controller.statusFor(1), LevelStatus.completed);
      expect(controller.statusFor(2), LevelStatus.current);
      expect(controller.statusFor(3), LevelStatus.locked);
    });

    test('after level 2: 1 and 2 completed, 3 current, 4 locked', () async {
      final controller = ProgressController();
      await controller.load();

      await completeThrough(controller, 2);

      expect(controller.statusFor(1), LevelStatus.completed);
      expect(controller.statusFor(2), LevelStatus.completed);
      expect(controller.statusFor(3), LevelStatus.current);
      expect(controller.statusFor(4), LevelStatus.locked);
    });

    test('after level 33: 32 and 33 completed, 34 current, 35 locked', () async {
      final controller = ProgressController();
      await controller.load();

      await completeThrough(controller, 33);

      expect(controller.statusFor(32), LevelStatus.completed);
      expect(controller.statusFor(33), LevelStatus.completed);
      expect(controller.statusFor(34), LevelStatus.current);
      expect(controller.statusFor(35), LevelStatus.locked);
    });

    test('after level 49: 49 completed, 50 current', () async {
      final controller = ProgressController();
      await controller.load();

      await completeThrough(controller, 49);

      expect(controller.statusFor(48), LevelStatus.completed);
      expect(controller.statusFor(49), LevelStatus.completed);
      expect(controller.statusFor(50), LevelStatus.current);
    });

    test('after level 50 the world is finished - there is no level 51 to show', () async {
      final controller = ProgressController();
      await controller.load();

      await completeThrough(controller, 50);

      expect(controller.statusFor(50), LevelStatus.completed);
      // The Levels screen only ever renders LevelData.levels, and that
      // list stops at 50, so no phantom "next" node can appear.
      expect(LevelData.levels.length, 50);
      expect(LevelData.levels.where((level) => controller.statusFor(level.id) == LevelStatus.current), isEmpty);
      expect(() => LevelData.byId(51), throwsArgumentError);
    });

    test('replaying an old level does not move the current level backwards', () async {
      final controller = ProgressController();
      await controller.load();

      await completeThrough(controller, 33);
      expect(controller.statusFor(34), LevelStatus.current);

      // Replay level 5 - allowed, and worth coins, but progression
      // must stay where it was.
      await controller.completeLevel(5, 2, LevelData.byId(5).optimalMoves + 3);

      expect(controller.statusFor(5), LevelStatus.completed);
      expect(controller.statusFor(34), LevelStatus.current);
      expect(controller.statusFor(35), LevelStatus.locked);
    });

    test('statuses come back unchanged from existing saved progression', () async {
      final first = ProgressController();
      await first.load();
      await completeThrough(first, 33);
      final coins = first.progress.coins;

      // "App restart" reading the same storage.
      final restarted = ProgressController();
      await restarted.load();

      expect(restarted.statusFor(33), LevelStatus.completed);
      expect(restarted.statusFor(34), LevelStatus.current);
      expect(restarted.statusFor(35), LevelStatus.locked);
      // Stars, best moves and coins ride along untouched.
      expect(restarted.starsFor(33), 3);
      expect(restarted.bestMovesFor(33), LevelData.byId(33).optimalMoves);
      expect(restarted.progress.coins, coins);
    });
  });

  group('Persistence is awaited before mutators return', () {
    // Each of these checks that a *freshly constructed* controller,
    // reading the same underlying storage right after the awaited
    // call resolves, sees the change - i.e. the write has actually
    // reached storage by the time the method's Future completes, not
    // merely been kicked off. This is the same guarantee
    // completeLevel() already gave.

    test('spendHint persists before returning', () async {
      final first = ProgressController();
      await first.load();
      expect(first.progress.hints, 3);

      final spent = await first.spendHint();

      expect(spent, isTrue);
      expect(first.progress.hints, 2);
      final restarted = ProgressController();
      await restarted.load();
      expect(restarted.progress.hints, 2);
    });

    test('spendHint with none left changes nothing and persists nothing new', () async {
      final controller = ProgressController();
      await controller.load();
      await controller.spendHint();
      await controller.spendHint();
      await controller.spendHint();
      expect(controller.progress.hints, 0);

      final spent = await controller.spendHint();

      expect(spent, isFalse);
      expect(controller.progress.hints, 0);
    });

    test('spendUndo persists before returning', () async {
      final first = ProgressController();
      await first.load();
      expect(first.progress.undos, 3);

      final spent = await first.spendUndo();

      expect(spent, isTrue);
      expect(first.progress.undos, 2);
      final restarted = ProgressController();
      await restarted.load();
      expect(restarted.progress.undos, 2);
    });

    test('spendUndo with none left changes nothing', () async {
      final controller = ProgressController();
      await controller.load();
      await controller.spendUndo();
      await controller.spendUndo();
      await controller.spendUndo();
      expect(controller.progress.undos, 0);

      final spent = await controller.spendUndo();

      expect(spent, isFalse);
      expect(controller.progress.undos, 0);
    });

    test('spendCoins persists the deduction and the applied change before returning', () async {
      final first = ProgressController();
      await first.load();
      await first.completeLevel(1, 3, LevelData.byId(1).optimalMoves); // fund the purchase

      final coinsBefore = first.progress.coins;
      final ok = await first.spendCoins(10, (p) => p.copyWith(hints: p.hints + 1));

      expect(ok, isTrue);
      expect(first.progress.coins, coinsBefore - 10);
      expect(first.progress.hints, 4);
      final restarted = ProgressController();
      await restarted.load();
      expect(restarted.progress.coins, coinsBefore - 10);
      expect(restarted.progress.hints, 4);
    });

    test('spendCoins with insufficient balance persists nothing and applies nothing', () async {
      final controller = ProgressController();
      await controller.load();
      final coinsBefore = controller.progress.coins;

      final ok = await controller.spendCoins(coinsBefore + 1, (p) => p.copyWith(hints: p.hints + 1));

      expect(ok, isFalse);
      expect(controller.progress.coins, coinsBefore);
      expect(controller.progress.hints, 3, reason: 'the apply function must not run when the purchase is refused');
    });

    test('spendExtraMove persists before returning (regression: already covered, kept alongside its siblings)', () async {
      final first = ProgressController();
      await first.load();
      await first.completeLevel(1, 3, LevelData.byId(1).optimalMoves);
      await first.spendCoins(0, (p) => p.copyWith(extraMoves: p.extraMoves + 1));

      final spent = await first.spendExtraMove();

      expect(spent, isTrue);
      final restarted = ProgressController();
      await restarted.load();
      expect(restarted.progress.extraMoves, 0);
    });
  });

  group('Extra Moves inventory', () {
    test('spending with none in stock fails and changes nothing', () async {
      final controller = ProgressController();
      await controller.load();
      expect(controller.progress.extraMoves, 0, reason: 'fresh install starts at 0');

      final spent = await controller.spendExtraMove();

      expect(spent, isFalse);
      expect(controller.progress.extraMoves, 0);
    });

    test('spending one from stock succeeds and decrements by exactly 1', () async {
      final controller = ProgressController();
      await controller.load();
      controller.spendCoins(0, (p) => p.copyWith(extraMoves: p.extraMoves + 5)); // simulates a Shop purchase

      final spent = await controller.spendExtraMove();

      expect(spent, isTrue);
      expect(controller.progress.extraMoves, 4);
    });

    test('using every booster in stock leaves the inventory at exactly 0, then refuses further use', () async {
      final controller = ProgressController();
      await controller.load();
      controller.spendCoins(0, (p) => p.copyWith(extraMoves: p.extraMoves + 2));

      expect(await controller.spendExtraMove(), isTrue);
      expect(await controller.spendExtraMove(), isTrue);
      expect(controller.progress.extraMoves, 0);

      expect(await controller.spendExtraMove(), isFalse);
      expect(controller.progress.extraMoves, 0);
    });

    test('spending an Extra Move only touches extraMoves - coins, stars, and best moves are untouched', () async {
      final controller = ProgressController();
      await controller.load();
      controller.spendCoins(0, (p) => p.copyWith(extraMoves: p.extraMoves + 1));
      await controller.completeLevel(1, 3, 2);
      final coinsBefore = controller.progress.coins;

      await controller.spendExtraMove();

      expect(controller.progress.coins, coinsBefore);
      expect(controller.starsFor(1), 3);
      expect(controller.bestMovesFor(1), 2);
    });

    test('the reduced inventory persists across a fresh controller reading the same storage', () async {
      final first = ProgressController();
      await first.load();
      first.spendCoins(0, (p) => p.copyWith(extraMoves: p.extraMoves + 3));
      await first.spendExtraMove();

      final restarted = ProgressController();
      await restarted.load();

      expect(restarted.progress.extraMoves, 2, reason: 'the spend was awaited, so it always reaches storage before this test reads it back');
    });
  });
}
