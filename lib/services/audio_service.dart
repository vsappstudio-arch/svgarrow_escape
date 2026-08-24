import 'sound_player.dart';

/// Plays Arrow Escape's sound effects and background music, gated by
/// the persisted sound/music settings ([applySettings]). One shared
/// instance lives for the whole app (see `core/app.dart`) so that
/// background music keeps playing continuously across screens rather
/// than restarting every time a new one is built.
class AudioService {
  AudioService({SoundPlayer? player}) : _player = player ?? AudioPlayersSoundPlayer();

  final SoundPlayer _player;

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _musicStarted = false;
  bool _syncedOnce = false;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  Future<void> _playSfx(String asset) {
    if (!_soundEnabled) return Future.value();
    return _player.playOnce('audio/$asset');
  }

  /// Generic UI button/tap feedback.
  Future<void> playTap() => _playSfx('tap.wav');

  /// An arrow successfully escaping the grid.
  Future<void> playEscape() => _playSfx('escape.wav');

  /// A tap on an arrow that's currently blocked.
  Future<void> playBlocked() => _playSfx('blocked.wav');

  /// The whole puzzle being solved.
  Future<void> playLevelComplete() => _playSfx('level_complete.wav');

  /// Each star earned on the level-complete screen.
  Future<void> playStar() => _playSfx('star.wav');

  /// Coins being awarded on the level-complete screen.
  Future<void> playCoin() => _playSfx('coin.wav');

  /// A new level becoming unlocked.
  Future<void> playUnlock() => _playSfx('unlock.wav');

  /// Applies the latest persisted sound/music settings. Safe to call
  /// on every [SettingsController] change (e.g. toggling haptics) -
  /// the background track is only started/paused/resumed when
  /// [musicEnabled] actually changed (or hasn't started yet), so this
  /// never restarts music mid-playback.
  Future<void> applySettings({required bool soundEnabled, required bool musicEnabled}) async {
    _soundEnabled = soundEnabled;

    final musicStateUnchanged = _syncedOnce && musicEnabled == _musicEnabled;
    _syncedOnce = true;
    _musicEnabled = musicEnabled;
    if (musicStateUnchanged) return;

    if (!_musicEnabled) {
      await _player.pauseLoop();
      return;
    }

    if (!_musicStarted) {
      _musicStarted = true;
      await _player.loop('audio/music_loop.wav', volume: 0.35);
    } else {
      await _player.resumeLoop();
    }
  }

  Future<void> dispose() => _player.dispose();
}
