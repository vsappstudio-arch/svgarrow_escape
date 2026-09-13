import 'dart:async';

import 'sound_player.dart';

/// Plays Arrow Escape's sound effects, gated by the persisted sound
/// setting ([applySettings]). One shared instance lives for the whole
/// app (see `core/app.dart`) so the underlying player survives
/// navigation instead of being rebuilt per screen.
class AudioService {
  AudioService({SoundPlayer? player, Duration? purchaseGap})
      : _player = player ?? AudioPlayersSoundPlayer(),
        _purchaseGap = purchaseGap ?? const Duration(milliseconds: 460) {
    // Kick off pre-loading every effect right away rather than on
    // first use, so the first tap in a session isn't the one that
    // pays for it. Fire-and-forget: playOnce() awaits the same
    // loading internally if a sound is asked for before this finishes,
    // so correctness never depends on this actually completing first.
    final player = _player;
    if (player is AudioPlayersSoundPlayer) {
      unawaited(player.warmUp(_allAssets));
    }
  }

  final SoundPlayer _player;

  /// How long the coin sound gets before the unlock sound follows it.
  /// Sound effects share one player, so a second sound started too soon
  /// cuts the first one off; coin.wav is a ~0.6s cascade of coins and
  /// this lets it land before the unlock chime comes in on top of it.
  final Duration _purchaseGap;

  static const _allAssets = [
    'tap.wav',
    'escape.wav',
    'blocked.wav',
    'level_complete.wav',
    'star.wav',
    'coin.wav',
    'unlock.wav',
  ];

  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;

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

  /// A shop purchase that went through: the coins leaving, then the
  /// item arriving. The two are staggered so both are actually heard.
  ///
  /// This is the single place the purchase confirmation is played, so a
  /// successful purchase can never double up; like every other effect
  /// here it goes silent when the Sound setting is off.
  Future<void> playPurchase() async {
    await playCoin();
    if (!_soundEnabled) return;
    await Future.delayed(_purchaseGap);
    await playUnlock();
  }

  /// Applies the latest persisted sound setting. Safe to call on every
  /// [SettingsController] change (e.g. toggling haptics).
  void applySettings({required bool soundEnabled}) {
    _soundEnabled = soundEnabled;
  }

  Future<void> dispose() => _player.dispose();
}
