import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_escape/services/audio_service.dart';

import 'fake_sound_player.dart';

void main() {
  group('AudioService sound effects', () {
    test('plays each effect with its own asset when sound is enabled (the default)', () async {
      final player = FakeSoundPlayer();
      final audio = AudioService(player: player);

      await audio.playTap();
      await audio.playEscape();
      await audio.playBlocked();
      await audio.playLevelComplete();
      await audio.playStar();
      await audio.playCoin();
      await audio.playUnlock();

      expect(player.playedOnce, [
        'audio/tap.wav',
        'audio/escape.wav',
        'audio/blocked.wav',
        'audio/level_complete.wav',
        'audio/star.wav',
        'audio/coin.wav',
        'audio/unlock.wav',
      ]);
    });

    test('soundEnabled=false suppresses every sound effect', () async {
      final player = FakeSoundPlayer();
      final audio = AudioService(player: player);
      await audio.applySettings(soundEnabled: false, musicEnabled: true);

      await audio.playTap();
      await audio.playEscape();
      await audio.playBlocked();
      await audio.playLevelComplete();
      await audio.playStar();
      await audio.playCoin();
      await audio.playUnlock();

      expect(player.playedOnce, isEmpty);
    });

    test('re-enabling sound lets effects play again', () async {
      final player = FakeSoundPlayer();
      final audio = AudioService(player: player);
      await audio.applySettings(soundEnabled: false, musicEnabled: true);
      await audio.applySettings(soundEnabled: true, musicEnabled: true);

      await audio.playTap();

      expect(player.playedOnce, ['audio/tap.wav']);
    });
  });

  group('AudioService background music', () {
    test('the first applySettings call starts the loop when music is enabled', () async {
      final player = FakeSoundPlayer();
      final audio = AudioService(player: player);

      await audio.applySettings(soundEnabled: true, musicEnabled: true);

      expect(player.loopsStarted, ['audio/music_loop.wav']);
      expect(player.pauseCalls, 0);
    });

    test('the first applySettings call never plays music when musicEnabled is false', () async {
      final player = FakeSoundPlayer();
      final audio = AudioService(player: player);

      await audio.applySettings(soundEnabled: true, musicEnabled: false);

      expect(player.loopsStarted, isEmpty);
      expect(player.pauseCalls, 1);
    });

    test('repeated syncs with an unchanged musicEnabled do not restart the loop', () async {
      final player = FakeSoundPlayer();
      final audio = AudioService(player: player);

      await audio.applySettings(soundEnabled: true, musicEnabled: true);
      // Simulates SettingsController notifying for an unrelated change
      // (e.g. haptics toggled) - music must not restart from the top.
      await audio.applySettings(soundEnabled: true, musicEnabled: true);
      await audio.applySettings(soundEnabled: false, musicEnabled: true);

      expect(player.loopsStarted, ['audio/music_loop.wav']);
      expect(player.pauseCalls, 0);
      expect(player.resumeCalls, 0);
    });

    test('toggling musicEnabled off then on pauses then resumes, without restarting the loop', () async {
      final player = FakeSoundPlayer();
      final audio = AudioService(player: player);

      await audio.applySettings(soundEnabled: true, musicEnabled: true);
      await audio.applySettings(soundEnabled: true, musicEnabled: false);
      await audio.applySettings(soundEnabled: true, musicEnabled: true);

      expect(player.loopsStarted, ['audio/music_loop.wav']);
      expect(player.pauseCalls, 1);
      expect(player.resumeCalls, 1);
    });

    test('music stays off across repeated syncs while disabled', () async {
      final player = FakeSoundPlayer();
      final audio = AudioService(player: player);

      await audio.applySettings(soundEnabled: true, musicEnabled: false);
      await audio.applySettings(soundEnabled: true, musicEnabled: false);

      expect(player.loopsStarted, isEmpty);
      // Only the first sync (not-yet-started -> still disabled) should
      // touch the player; the second is a genuine no-op.
      expect(player.pauseCalls, 1);
    });
  });
}
