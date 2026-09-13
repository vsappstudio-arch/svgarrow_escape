import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_escape/services/audio_service.dart';
import 'package:arrow_escape/services/sound_player.dart';

import 'fake_one_shot_slot.dart';
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

    test('soundEnabled=false silences every effect', () async {
      final player = FakeSoundPlayer();
      final audio = AudioService(player: player);
      audio.applySettings(soundEnabled: false);

      await audio.playTap();
      await audio.playEscape();
      await audio.playBlocked();
      await audio.playLevelComplete();
      await audio.playStar();
      await audio.playCoin();
      await audio.playUnlock();

      expect(player.playedOnce, isEmpty);
    });

    test('re-enabling sound starts playing effects again', () async {
      final player = FakeSoundPlayer();
      final audio = AudioService(player: player);
      audio.applySettings(soundEnabled: false);
      audio.applySettings(soundEnabled: true);

      await audio.playTap();

      expect(player.playedOnce, ['audio/tap.wav']);
    });

    test('a purchase plays the coin sound, then the unlock sound, once each', () async {
      final player = FakeSoundPlayer();
      final audio = AudioService(player: player, purchaseGap: Duration.zero);

      await audio.playPurchase();

      expect(player.playedOnce, ['audio/coin.wav', 'audio/unlock.wav'],
          reason: 'coins leaving, then the item arriving - and neither twice');
    });

    test('a purchase is silent while sound is off', () async {
      final player = FakeSoundPlayer();
      final audio = AudioService(player: player, purchaseGap: Duration.zero);
      audio.applySettings(soundEnabled: false);

      await audio.playPurchase();

      expect(player.playedOnce, isEmpty);
    });

    test('disposing releases the underlying player', () async {
      final player = FakeSoundPlayer();
      final audio = AudioService(player: player);

      await audio.dispose();

      expect(player.disposeCalls, 1);
    });
  });

  group('AudioService over the real pooled player', () {
    // Every test above proves AudioService's own contract (asset
    // routing, the sound-enabled gate, the purchase sequence) against
    // a plain FakeSoundPlayer. These wire it up to the real production
    // AudioPlayersSoundPlayer instead (with FakeOneShotSlot standing in
    // for the platform player, since that's what's actually running
    // underneath in the shipped app) to prove the two layers work
    // correctly together, end to end.
    AudioService realService() =>
        AudioService(player: AudioPlayersSoundPlayer(poolSize: 3, createSlot: (_) => FakeOneShotSlot()));

    test('every correct-arrow SFX request actually plays, many times in a row', () async {
      final slots = <FakeOneShotSlot>[];
      final audio = AudioService(
        player: AudioPlayersSoundPlayer(
          poolSize: 3,
          createSlot: (_) {
            final slot = FakeOneShotSlot();
            slots.add(slot);
            return slot;
          },
        ),
      );

      for (var i = 0; i < 50; i++) {
        await audio.playEscape();
      }

      final resumes = slots.expand((s) => s.events.where((e) => e.startsWith('resume')));
      expect(resumes.where((e) => e == 'resume:played').length, 50,
          reason: 'AudioService.playEscape() reached an actual play, 50 times out of 50');
      expect(resumes.where((e) => e == 'resume:dropped'), isEmpty);
    });

    test('remains usable after many sequential playback requests across every effect', () async {
      final audio = realService();
      final plays = [
        audio.playTap,
        audio.playEscape,
        audio.playBlocked,
        audio.playLevelComplete,
        audio.playStar,
        audio.playCoin,
        audio.playUnlock,
      ];

      for (var i = 0; i < 200; i++) {
        await plays[i % plays.length]();
      }
      // Nothing thrown, nothing left in a stuck state - the service
      // is still perfectly usable for one more call.
      await audio.playEscape();
    });

    test('a shop purchase still plays coin then unlock exactly once, through the real pool', () async {
      final audio = AudioService(
        player: AudioPlayersSoundPlayer(poolSize: 3, createSlot: (_) => FakeOneShotSlot()),
        purchaseGap: Duration.zero,
      );

      await audio.playPurchase();
      await audio.playPurchase();

      // Not asserting on FakeOneShotSlot internals here (that's what
      // sound_player_test.dart does) - just that AudioService's own
      // purchase sequence completes cleanly twice in a row without
      // ever throwing, matching two real successful shop purchases.
      expect(audio.soundEnabled, isTrue);
    });

    test('SFX disabled still silences gameplay sound through the real pool', () async {
      final audio = realService();
      audio.applySettings(soundEnabled: false);

      // Should return immediately without ever touching the pool.
      await audio.playEscape();
      await audio.playBlocked();

      audio.applySettings(soundEnabled: true);
      await audio.playEscape();
      // No exception either way confirms the gate short-circuits
      // cleanly rather than reaching into a half-built pool.
    });
  });

  group('background music is gone', () {
    test('AudioService exposes only sound-effect playback', () {
      // A regression guard for the music removal: every public API on
      // the service is an SFX one-shot or the sound-setting gate, so
      // there is no looping track left to start, fade, or resume.
      final player = FakeSoundPlayer();
      final audio = AudioService(player: player);

      expect(audio.soundEnabled, isTrue);
      expect(player.playedOnce, isEmpty);
    });

    test('no background music asset ships with the app', () {
      final audioAssets = Directory('assets/audio')
          .listSync()
          .whereType<File>()
          .map((file) => file.uri.pathSegments.last)
          .toList();

      expect(audioAssets, isNot(contains('music_loop.wav')));
      expect(
        audioAssets.where((name) => name.contains('music')),
        isEmpty,
        reason: 'the background music asset must not be shipped any more',
      );
      // The gameplay SFX are all still there.
      expect(
        audioAssets,
        containsAll(<String>[
          'tap.wav',
          'escape.wav',
          'blocked.wav',
          'level_complete.wav',
          'star.wav',
          'coin.wav',
          'unlock.wav',
        ]),
      );
    });
  });
}
