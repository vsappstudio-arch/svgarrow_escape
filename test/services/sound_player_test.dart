import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_escape/services/sound_player.dart';

import 'fake_one_shot_slot.dart';

/// Builds an [AudioPlayersSoundPlayer] whose slots are the fakes from
/// [FakeOneShotSlot], and gives the test a way to look up every slot
/// that was ever created, keyed by the id it was created with.
({AudioPlayersSoundPlayer player, Map<String, FakeOneShotSlot> slots, List<String> createdOrder}) _harness({
  int poolSize = 3,
}) {
  final slots = <String, FakeOneShotSlot>{};
  final createdOrder = <String>[];
  final player = AudioPlayersSoundPlayer(
    poolSize: poolSize,
    createSlot: (id) {
      createdOrder.add(id);
      return slots[id] = FakeOneShotSlot();
    },
  );
  return (player: player, slots: slots, createdOrder: createdOrder);
}

void main() {
  group('AudioPlayersSoundPlayer: repeat plays of one effect', () {
    test('a single-slot pool still plays every time, because stop() always precedes resume()', () async {
      // Pool size 1 forces every play to land on the exact same
      // fake slot - the scenario a naive single-reused-player design
      // gets wrong.
      final h = _harness(poolSize: 1);

      for (var i = 0; i < 4; i++) {
        await h.player.playOnce('escape.wav');
      }

      final slot = h.slots.values.single;
      final resumes = slot.events.where((e) => e.startsWith('resume')).toList();
      expect(resumes, ['resume:played', 'resume:played', 'resume:played', 'resume:played'],
          reason: 'every play actually played - none were silently dropped');
      expect(slot.events.where((e) => e == 'stop').length, 4,
          reason: 'a stop() preceded every single resume()');
    });

    test('four consecutive correct-arrow taps each produce their own play', () async {
      final h = _harness();

      for (var i = 0; i < 4; i++) {
        await h.player.playOnce('escape.wav');
      }

      final allResumes =
          h.slots.values.expand((s) => s.events.where((e) => e.startsWith('resume'))).toList();
      expect(allResumes.where((e) => e == 'resume:played').length, 4);
      expect(allResumes.where((e) => e == 'resume:dropped'), isEmpty,
          reason: 'nothing should ever be silently dropped');
    });

    test('a wrong tap followed by a correct tap: both actually play', () async {
      final h = _harness();

      await h.player.playOnce('blocked.wav');
      await h.player.playOnce('escape.wav');

      for (final asset in ['blocked.wav', 'escape.wav']) {
        final slot = h.slots.entries.firstWhere((e) => e.key.contains(asset)).value;
        expect(slot.events, contains('resume:played'));
      }
    });
  });

  group('AudioPlayersSoundPlayer: pooling', () {
    test('rapid overlapping plays of the same effect round-robin across the pool', () async {
      final h = _harness(poolSize: 3);

      // Fire three plays without awaiting between them, the way rapid
      // taps do - GameController never awaits playEscape().
      final futures = [
        h.player.playOnce('escape.wav'),
        h.player.playOnce('escape.wav'),
        h.player.playOnce('escape.wav'),
      ];
      await Future.wait(futures);

      // All three should have gone to different slots, and every one
      // of them should have actually played.
      final played = h.slots.values.where((s) => s.events.contains('resume:played')).length;
      expect(played, 3, reason: 'three rapid taps used three different slots, all audible');
    });

    test('a pool is built once per asset, not once per play', () async {
      final h = _harness(poolSize: 3);

      for (var i = 0; i < 10; i++) {
        await h.player.playOnce('escape.wav');
      }

      expect(h.createdOrder.length, 3, reason: 'exactly poolSize slots, regardless of play count');
    });

    test('different effects get independent pools', () async {
      final h = _harness(poolSize: 2);

      await h.player.playOnce('escape.wav');
      await h.player.playOnce('blocked.wav');

      expect(h.createdOrder.where((id) => id.contains('escape.wav')).length, 2);
      expect(h.createdOrder.where((id) => id.contains('blocked.wav')).length, 2);
    });

    test('two overlapping first-plays of a brand-new asset share one pool build', () async {
      final h = _harness(poolSize: 3);

      // Both calls race to build the pool for an asset neither has
      // seen before.
      await Future.wait([
        h.player.playOnce('star.wav'),
        h.player.playOnce('star.wav'),
      ]);

      expect(h.createdOrder.length, 3, reason: 'one pool build, not two');
    });

    test('warmUp pre-builds a pool so the first real play reuses it', () async {
      final h = _harness(poolSize: 3);

      await h.player.warmUp(['tap.wav']);
      expect(h.createdOrder.length, 3);

      await h.player.playOnce('audio/tap.wav');

      expect(h.createdOrder.length, 3, reason: 'playOnce found the warmed pool rather than building a second one');
    });
  });

  group('AudioPlayersSoundPlayer: long-session stability', () {
    test('stays correct and bounded after many sequential plays across several effects', () async {
      final h = _harness(poolSize: 3);
      const assets = ['escape.wav', 'blocked.wav', 'tap.wav', 'star.wav', 'coin.wav'];

      for (var i = 0; i < 300; i++) {
        await h.player.playOnce(assets[i % assets.length]);
      }

      // Every play actually played - none silently dropped, even
      // deep into a long, asset-alternating session.
      final allEvents = h.slots.values.expand((s) => s.events);
      expect(allEvents.where((e) => e == 'resume:dropped'), isEmpty);
      expect(allEvents.where((e) => e == 'resume:played').length, 300);

      // A fixed, bounded number of slots for the whole run: 5 assets x
      // 3 slots, never more - no per-play growth, matching what a
      // long play session must not do.
      expect(h.createdOrder.length, assets.length * 3);
    });
  });

  group('AudioPlayersSoundPlayer: disposal', () {
    test('dispose() disposes every pooled slot exactly once', () async {
      final h = _harness(poolSize: 2);
      await h.player.playOnce('escape.wav');
      await h.player.playOnce('blocked.wav');

      await h.player.dispose();

      expect(h.slots.values.every((s) => s.disposed), isTrue);
      expect(h.slots.values.map((s) => s.events.where((e) => e == 'dispose').length), everyElement(1));
    });
  });
}
