import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/models/arrow_model.dart';
import 'package:arrow_escape/models/level_model.dart';
import 'package:arrow_escape/services/audio_service.dart';
import 'package:arrow_escape/services/haptic_service.dart';
import 'package:arrow_escape/state/game_controller.dart';
import 'package:arrow_escape/state/settings_controller.dart';

import '../services/fake_sound_player.dart';

/// Avoids touching the real HapticFeedback platform channel, which
/// isn't available outside a widget-test binding.
class _NoOpHapticService extends HapticService {
  @override
  void selectionClick() {}

  @override
  void lightImpact() {}

  @override
  void mediumImpact() {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // Mirrors puzzle_engine_test.dart's synthetic level: 'blocked' can't
  // escape until 'blocker' does, independent of real level data.
  const level = LevelModel(
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

  Future<SettingsController> settingsWith({required bool soundEnabled}) async {
    final settings = SettingsController();
    await settings.load();
    await settings.setSoundEnabled(soundEnabled);
    return settings;
  }

  group('GameController audio', () {
    test('a successful escape plays the escape sound when sound is enabled', () async {
      final settings = await settingsWith(soundEnabled: true);
      final player = FakeSoundPlayer();
      final controller = GameController(
        level,
        settings,
        audio: AudioService(player: player),
        haptics: _NoOpHapticService(),
      );

      controller.tapArrow(level.arrows.firstWhere((a) => a.id == 'blocker'));

      expect(player.playedOnce, ['audio/escape.wav']);
    });

    test('a successful escape plays nothing when sound is disabled', () async {
      final settings = await settingsWith(soundEnabled: false);
      final player = FakeSoundPlayer();
      final controller = GameController(
        level,
        settings,
        audio: AudioService(player: player),
        haptics: _NoOpHapticService(),
      );

      controller.tapArrow(level.arrows.firstWhere((a) => a.id == 'blocker'));

      expect(player.playedOnce, isEmpty);
    });

    test('a blocked tap plays the blocked sound, not the escape sound', () async {
      final settings = await settingsWith(soundEnabled: true);
      final player = FakeSoundPlayer();
      final controller = GameController(
        level,
        settings,
        audio: AudioService(player: player),
        haptics: _NoOpHapticService(),
      );

      controller.tapArrow(level.arrows.firstWhere((a) => a.id == 'blocked'));

      expect(player.playedOnce, ['audio/blocked.wav']);
    });

    test('a blocked tap plays nothing when sound is disabled', () async {
      final settings = await settingsWith(soundEnabled: false);
      final player = FakeSoundPlayer();
      final controller = GameController(
        level,
        settings,
        audio: AudioService(player: player),
        haptics: _NoOpHapticService(),
      );

      controller.tapArrow(level.arrows.firstWhere((a) => a.id == 'blocked'));

      expect(player.playedOnce, isEmpty);
    });

    test('solving the level plays the level-complete sound after the final escape', () async {
      final settings = await settingsWith(soundEnabled: true);
      final player = FakeSoundPlayer();
      final controller = GameController(
        level,
        settings,
        audio: AudioService(player: player),
        haptics: _NoOpHapticService(),
      );

      controller.tapArrow(level.arrows.firstWhere((a) => a.id == 'blocker'));
      controller.tapArrow(level.arrows.firstWhere((a) => a.id == 'blocked'));

      expect(controller.isSolved, isTrue);
      expect(player.playedOnce, ['audio/escape.wav', 'audio/escape.wav', 'audio/level_complete.wav']);
    });
  });

  group('GameController audio: every correct arrow reliably produces its SFX', () {
    // Four arrows, each already unblocked - the exact "4 correct
    // arrows in a row" scenario from the bug report - so each tap is a
    // genuine, independent, correct escape.
    const fourArrows = LevelModel(
      id: 100,
      name: 'Four Arrows',
      gridSize: 4,
      difficulty: 1,
      optimalMoves: 4,
      arrows: [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.up),
        ArrowModel(id: 'a2', row: 1, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a3', row: 3, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a4', row: 2, col: 0, direction: ArrowDirection.left),
      ],
    );

    test('four consecutive correct arrows each request the escape SFX exactly once', () async {
      final settings = await settingsWith(soundEnabled: true);
      final player = FakeSoundPlayer();
      final controller = GameController(
        fourArrows,
        settings,
        audio: AudioService(player: player),
        haptics: _NoOpHapticService(),
      );

      for (final arrow in fourArrows.arrows) {
        controller.tapArrow(arrow);
      }

      // The 4th tap also solves the level, so it fires both its own
      // escape SFX and the level-complete SFX.
      expect(player.playedOnce, [...List.filled(4, 'audio/escape.wav'), 'audio/level_complete.wav'],
          reason: 'every one of the 4 correct taps requested its own SFX - none silently skipped');
      expect(controller.isSolved, isTrue);
    });

    test('rapid consecutive correct taps (not awaited between) do not lose any SFX request', () async {
      final settings = await settingsWith(soundEnabled: true);
      final player = FakeSoundPlayer();
      final controller = GameController(
        fourArrows,
        settings,
        audio: AudioService(player: player),
        haptics: _NoOpHapticService(),
      );

      // GameController.tapArrow() never awaits its own playEscape()
      // call, so this fires all four requests back-to-back the way
      // fast real taps do, without waiting for each SFX to resolve.
      for (final arrow in fourArrows.arrows) {
        controller.tapArrow(arrow);
      }
      // Let every fire-and-forget playEscape() future actually settle.
      await Future<void>.delayed(Duration.zero);

      expect(player.playedOnce.where((a) => a == 'audio/escape.wav').length, 4);
    });

    test('a wrong tap does not consume or block the next correct tap\'s SFX', () async {
      final settings = await settingsWith(soundEnabled: true);
      final player = FakeSoundPlayer();
      final controller = GameController(
        fourArrows,
        settings,
        audio: AudioService(player: player),
        haptics: _NoOpHapticService(),
      );

      controller.tapArrow(fourArrows.arrows[0]); // correct
      controller.tapArrow(fourArrows.arrows[0]); // already gone - blocked (already removed)
      controller.tapArrow(fourArrows.arrows[1]); // correct

      expect(player.playedOnce, ['audio/escape.wav', 'audio/blocked.wav', 'audio/escape.wav'],
          reason: 'the correct tap right after a wrong one still gets its SFX, same as any other correct tap');
    });
  });

  group('GameController audio: no state leaks across levels', () {
    test('starting a fresh GameController per level, sharing one AudioService, never duplicates a play', () async {
      final settings = await settingsWith(soundEnabled: true);
      final player = FakeSoundPlayer();
      final sharedAudio = AudioService(player: player);

      // Simulates playing several levels in a row: a new GameController
      // per level (as GameScreen creates), each disposed before the
      // next "level" starts, all sharing the one app-level AudioService.
      for (var levelRun = 0; levelRun < 5; levelRun++) {
        final controller = GameController(
          const LevelModel(
            id: 1,
            name: 'L',
            gridSize: 3,
            difficulty: 1,
            optimalMoves: 1,
            arrows: [ArrowModel(id: 'only', row: 0, col: 0, direction: ArrowDirection.up)],
          ),
          settings,
          audio: sharedAudio,
          haptics: _NoOpHapticService(),
        );

        controller.tapArrow(const ArrowModel(id: 'only', row: 0, col: 0, direction: ArrowDirection.up));
        expect(controller.isSolved, isTrue);
        controller.dispose();
      }

      // Exactly one escape (+ its level-complete, since a 1-arrow level
      // solves itself) per run, five runs, no more and no less - a
      // stray listener surviving a disposed controller would double
      // these up.
      final expected = List.generate(5, (_) => ['audio/escape.wav', 'audio/level_complete.wav']).expand((e) => e).toList();
      expect(player.playedOnce, expected);
    });
  });

  group('GameController: Extra Moves booster', () {
    // 'blocked' never escapes on its own here (it stays blocked by
    // 'blocker' the whole test) so tapping it repeatedly is a reliable
    // way to spend moves without solving - optimalMoves is 2, so the
    // normal allowance (2x) is 4.
    GameController freshController() => GameController(
          level,
          SettingsController(),
          audio: AudioService(player: FakeSoundPlayer()),
          haptics: _NoOpHapticService(),
        );

    final blocked = level.arrows.firstWhere((a) => a.id == 'blocked');
    final blocker = level.arrows.firstWhere((a) => a.id == 'blocker');

    test('the normal move allowance is exactly twice optimalMoves', () {
      final controller = freshController();
      expect(controller.moveLimit, level.optimalMoves * 2);
      expect(controller.moveLimit, 4);
      expect(controller.isOutOfMoves, isFalse);
    });

    test('reaching the allowance without solving sets isOutOfMoves', () {
      final controller = freshController();

      for (var i = 0; i < 4; i++) {
        controller.tapArrow(blocked); // always blocked - never removed
      }

      expect(controller.moves, 4);
      expect(controller.isSolved, isFalse);
      expect(controller.isOutOfMoves, isTrue);
    });

    test('tapping once more while out of moves is a no-op - the move count never exceeds the limit', () {
      final controller = freshController();
      for (var i = 0; i < 4; i++) {
        controller.tapArrow(blocked);
      }

      controller.tapArrow(blocker); // would otherwise be a valid, correct tap

      expect(controller.moves, 4, reason: 'the guard in tapArrow() blocks it before the engine ever sees it');
      expect(controller.isRemoved('blocker'), isFalse);
    });

    test('using a booster grants exactly +5 moves and clears isOutOfMoves', () {
      final controller = freshController();
      for (var i = 0; i < 4; i++) {
        controller.tapArrow(blocked);
      }
      expect(controller.isOutOfMoves, isTrue);

      controller.useExtraMovesBoost();

      expect(controller.moveLimit, 9, reason: '4 (base) + 5 (one boost)');
      expect(controller.isOutOfMoves, isFalse);
    });

    test('play resumes exactly where it left off after a boost - same moves, same board', () {
      final controller = freshController();
      for (var i = 0; i < 4; i++) {
        controller.tapArrow(blocked);
      }
      final movesBeforeBoost = controller.moves;

      controller.useExtraMovesBoost();

      expect(controller.moves, movesBeforeBoost, reason: 'using the booster itself is not a move');
      expect(controller.isRemoved('blocked'), isFalse);
      expect(controller.isRemoved('blocker'), isFalse);

      // And the player can keep playing: the previously-blocked tap on
      // 'blocker' (always free) now succeeds, exactly as it would have
      // at any earlier point in the attempt.
      controller.tapArrow(blocker);
      expect(controller.isRemoved('blocker'), isTrue);
      expect(controller.moves, movesBeforeBoost + 1);
    });

    test('solving after a boost completes normally, with the correct star count', () {
      final controller = freshController();
      for (var i = 0; i < 4; i++) {
        controller.tapArrow(blocked); // 4 wasted moves
      }
      controller.useExtraMovesBoost();

      controller.tapArrow(blocker); // now free -> move 5
      controller.tapArrow(blocked); // now free -> move 6, solves it

      expect(controller.isSolved, isTrue);
      expect(controller.moves, 6);
      // optimalMoves is 2, so 6 moves is well past the optimal+1 cutoff
      // for 2 stars - exactly the same 1-star outcome this many moves
      // would earn without ever touching a booster. The boost does not
      // create a bonus star.
      expect(controller.starsEarned, 1);
    });

    test('a second Out of Moves state can be reached after the boosted allowance also runs out', () {
      final controller = freshController();
      for (var i = 0; i < 4; i++) {
        controller.tapArrow(blocked);
      }
      controller.useExtraMovesBoost(); // limit now 9

      for (var i = 0; i < 5; i++) {
        controller.tapArrow(blocked); // moves 5..9, still never solving
      }

      expect(controller.moves, 9);
      expect(controller.isOutOfMoves, isTrue);
    });

    test('restarting the attempt clears the temporary bonus back to the base allowance', () {
      final controller = freshController();
      for (var i = 0; i < 4; i++) {
        controller.tapArrow(blocked);
      }
      controller.useExtraMovesBoost();
      expect(controller.moveLimit, 9);

      controller.reset();

      expect(controller.moveLimit, 4, reason: 'the bonus was only ever local to the spent attempt');
      expect(controller.moves, 0);
      expect(controller.isOutOfMoves, isFalse);
    });

    test('a booster never changes the level itself', () {
      final controller = freshController();
      controller.useExtraMovesBoost();

      expect(controller.level, same(level));
      expect(controller.level.optimalMoves, 2, reason: 'optimalMoves is untouched by boosting');
      expect(controller.arrows, level.arrows);
    });
  });
}
