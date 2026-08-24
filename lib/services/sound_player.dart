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

  /// Starts (or restarts) a looping background track at [volume].
  Future<void> loop(String asset, {double volume = 1});

  Future<void> pauseLoop();

  Future<void> resumeLoop();

  Future<void> dispose();
}

/// Real [SoundPlayer] backed by the `audioplayers` package: one
/// low-latency player for overlapping SFX, one dedicated player for
/// the looping background track (so music keeps playing underneath
/// sound effects instead of being interrupted by them).
class AudioPlayersSoundPlayer implements SoundPlayer {
  AudioPlayersSoundPlayer()
      : _sfx = AudioPlayer(playerId: 'arrow_escape_sfx'),
        _music = AudioPlayer(playerId: 'arrow_escape_music') {
    _sfx.setPlayerMode(PlayerMode.lowLatency);
    _music.setReleaseMode(ReleaseMode.loop);
  }

  final AudioPlayer _sfx;
  final AudioPlayer _music;

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
  Future<void> playOnce(String asset) => _guard(() => _sfx.play(AssetSource(asset)));

  @override
  Future<void> loop(String asset, {double volume = 1}) => _guard(() async {
        await _music.setVolume(volume);
        await _music.play(AssetSource(asset));
      });

  @override
  Future<void> pauseLoop() => _guard(() => _music.pause());

  @override
  Future<void> resumeLoop() => _guard(() => _music.resume());

  @override
  Future<void> dispose() => _guard(() async {
        await _sfx.dispose();
        await _music.dispose();
      });
}
