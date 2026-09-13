import 'package:flutter/foundation.dart';

import 'package:audioplayers/audioplayers.dart';

/// A minimal seam over the platform audio player. [AudioService]'s
/// settings-gating logic depends on this interface (not directly on
/// [AudioPlayer]) so it can be unit-tested with a fake, without
/// touching platform channels.
abstract class SoundPlayer {
  /// Plays a short one-shot sound effect from `assets/audio/[asset]`,
  /// interrupting whatever this player was playing before.
  Future<void> playOnce(String asset);

  Future<void> dispose();
}

/// One native low-latency playback slot, pre-loaded with a single
/// asset for its whole lifetime.
///
/// This is the seam [AudioPlayersSoundPlayer]'s pool uses instead of
/// depending on `audioplayers`' concrete [AudioPlayer] directly, so
/// the pool/round-robin/reset logic below can be unit-tested against a
/// fake that reproduces the real platform quirk it exists to work
/// around (see [AudioPlayersSlot]'s doc) - without a device.
@visibleForTesting
abstract class OneShotSlot {
  /// Loads [asset] once. Never called again after the first call.
  Future<void> prepare(String asset);

  Future<void> stop();

  Future<void> resume();

  Future<void> dispose();
}

/// Real [OneShotSlot], backed by one low-latency `audioplayers`
/// [AudioPlayer].
///
/// On Android, a low-latency player is backed by [SoundPool], which
/// has no "playback finished" callback - so the plugin's internal
/// "is this player currently playing" flag latches `true` on the
/// first successful play and *never resets itself*. Every later
/// `resume()` call on that same player then hits the plugin's own
/// `if (!playing) ...` guard and is silently dropped: nothing plays,
/// no exception, no signal that anything went wrong. An explicit
/// `stop()` is the only thing that clears that flag - and because the
/// slot's [ReleaseMode] is `stop` rather than the default `release`,
/// calling it does not unload the decoded sound, so the follow-up
/// `resume()` is still instant. This is exactly why [prepare] is
/// called once and [stop] is always called immediately before
/// [resume]: skip either step and repeat or rapid plays of the same
/// asset on this slot go silent.
class AudioPlayersSlot implements OneShotSlot {
  AudioPlayersSlot(String playerId) : _player = AudioPlayer(playerId: playerId);

  final AudioPlayer _player;

  @override
  Future<void> prepare(String asset) async {
    await _player.setPlayerMode(PlayerMode.lowLatency);
    // Arrow Escape's sound effects are short, incidental feedback -
    // they shouldn't take exclusive Android audio focus and interrupt
    // whatever the player is already listening to.
    await _player.setAudioContext(AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build());
    // `stop`, not the default `release`: release() unloads the
    // decoded sound from the native player, so the next play would
    // have to re-decode it from scratch. stop() only resets playback
    // position/state and keeps the asset loaded.
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setSource(AssetSource(asset));
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> resume() => _player.resume();

  @override
  Future<void> dispose() => _player.dispose();
}

/// Real [SoundPlayer] backed by `audioplayers`: a small, bounded,
/// persistent pool of pre-loaded low-latency slots *per sound effect*.
///
/// Each asset gets its own pool of [poolSize] slots, each loaded
/// exactly once (on first use) and never re-sourced again; plays are
/// round-robined across an asset's slots, and every play does an
/// explicit `stop()` immediately before `resume()`.
///
/// This exists to fix two problems the previous single-reused-player
/// design had, both stemming from the platform behavior documented on
/// [AudioPlayersSlot]:
///
///  - Repeated or rapid taps on the SAME effect went silent after the
///    first, because replaying one asset on one already-`playing`
///    low-latency player is a native no-op with no reset in between.
///  - Every tap on a *different* effect than the one before it forced
///    the previous asset to be unloaded and the new one decoded fresh
///    (this is what a single shared player does whenever its source
///    changes) - real, repeated decode work and native object churn
///    on nearly every tap, which is what made play sessions feel
///    progressively laggier the longer they ran.
///
/// Loading each asset once into its own slots up front and never
/// touching their source again removes both: every slot's `resume()`
/// is always preceded by a `stop()` (so it never goes silent), and no
/// slot is ever re-sourced after its first load (so nothing is ever
/// re-decoded mid-game).
class AudioPlayersSoundPlayer implements SoundPlayer {
  AudioPlayersSoundPlayer({this.poolSize = 3, @visibleForTesting OneShotSlot Function(String playerId)? createSlot})
      : _createSlot = createSlot ?? ((id) => AudioPlayersSlot(id));

  /// Slots per asset. 3 gives a rapid-tapping player comfortable
  /// headroom for overlapping in-flight plays of the same effect
  /// without being wasteful - each slot is a tiny, cheap native object,
  /// and slots sharing an asset share its decoded audio underneath.
  final int poolSize;
  final OneShotSlot Function(String playerId) _createSlot;

  final Map<String, List<OneShotSlot>> _pools = {};
  final Map<String, int> _nextSlot = {};

  /// Pool-creation is async (each slot awaits its own load), so two
  /// overlapping first-plays of the same brand-new asset must share
  /// one in-flight creation rather than each building their own pool.
  final Map<String, Future<List<OneShotSlot>>> _pending = {};

  /// Pre-loads the pool for each of [assets], so a later [playOnce]
  /// for any of them finds its pool already built instead of paying
  /// for it on the first play. Assets already loaded (or loading) are
  /// left alone; safe to call more than once.
  Future<void> warmUp(List<String> assets) => _guard(() async {
        await Future.wait(assets.map((asset) => _poolFor('audio/$asset')));
      });

  Future<List<OneShotSlot>> _poolFor(String asset) {
    final ready = _pools[asset];
    if (ready != null) return Future.value(ready);
    return _pending[asset] ??= _createPool(asset).then((pool) {
      _pools[asset] = pool;
      _pending.remove(asset);
      return pool;
    });
  }

  Future<List<OneShotSlot>> _createPool(String asset) async {
    final slots = <OneShotSlot>[];
    for (var i = 0; i < poolSize; i++) {
      final slot = _createSlot('arrow_escape_sfx_${asset}_$i');
      await slot.prepare(asset);
      slots.add(slot);
    }
    return slots;
  }

  /// Playback can fail for reasons outside our control (no audio
  /// output device, codec hiccup, a plugin channel that isn't
  /// available in a test harness) - none of that should ever crash
  /// gameplay, so failures are swallowed here rather than propagated.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stackTrace) {
      debugPrint('AudioPlayersSoundPlayer: playback failed: $error');
      FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stackTrace, silent: true));
    }
  }

  @override
  Future<void> playOnce(String asset) => _guard(() async {
        final pool = await _poolFor(asset);
        final index = _nextSlot[asset] ?? 0;
        _nextSlot[asset] = (index + 1) % pool.length;
        final slot = pool[index];
        // Always reset before playing - see AudioPlayersSlot's doc for
        // why skipping this makes repeat plays go silent.
        await slot.stop();
        await slot.resume();
      });

  @override
  Future<void> dispose() => _guard(() async {
        final pools = _pools.values.toList();
        _pools.clear();
        _nextSlot.clear();
        for (final pool in pools) {
          for (final slot in pool) {
            await slot.dispose();
          }
        }
      });
}
