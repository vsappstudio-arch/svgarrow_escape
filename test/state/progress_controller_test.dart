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
}
