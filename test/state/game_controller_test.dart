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
}
