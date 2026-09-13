import 'package:arrow_escape/services/sound_player.dart';

/// A [SoundPlayer] test double that just records calls, so
/// [AudioService] tests (and anything that injects an [AudioService])
/// can assert on sound-effect/settings behavior without touching a
/// platform audio channel. Shared by audio_service_test.dart and
/// game_controller_test.dart.
class FakeSoundPlayer implements SoundPlayer {
  final List<String> playedOnce = [];
  int disposeCalls = 0;

  @override
  Future<void> playOnce(String asset) async => playedOnce.add(asset);

  @override
  Future<void> dispose() async => disposeCalls++;
}
