import 'package:arrow_escape/services/sound_player.dart';

/// A [OneShotSlot] test double that reproduces the exact native
/// platform quirk [AudioPlayersSlot] exists to work around: on a real
/// Android low-latency (SoundPool-backed) player, once a slot has
/// played it stays marked "playing" forever (there is no completion
/// callback to clear it), so a later `resume()` that isn't preceded
/// by an explicit `stop()` is a silent no-op - nothing plays, nothing
/// throws.
///
/// Modelling that here lets sound_player_test.dart prove, without a
/// device, that `AudioPlayersSoundPlayer`'s pool really does call
/// `stop()` before every `resume()`: skip that and this fake starts
/// recording `resume:dropped` instead of `resume:played`.
class FakeOneShotSlot implements OneShotSlot {
  FakeOneShotSlot();

  /// Every call this slot received, in order: `prepare:<asset>`,
  /// `stop`, `resume:played`, `resume:dropped`, or `dispose`.
  final List<String> events = [];

  String? asset;
  bool _playing = false;
  bool disposed = false;

  @override
  Future<void> prepare(String newAsset) async {
    asset = newAsset;
    events.add('prepare:$newAsset');
  }

  @override
  Future<void> stop() async {
    _playing = false;
    events.add('stop');
  }

  @override
  Future<void> resume() async {
    if (_playing) {
      // The real bug: already "playing" (latched, not actually still
      // audible) means SoundPool.resume() on a finished stream - a
      // no-op.
      events.add('resume:dropped');
      return;
    }
    _playing = true;
    events.add('resume:played');
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    events.add('dispose');
  }
}
