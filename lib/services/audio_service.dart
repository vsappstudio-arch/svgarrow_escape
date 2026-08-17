import 'package:flutter/services.dart';

/// Thin wrapper around system sound effects. Swap for a real audio
/// package once sound assets are added.
class AudioService {
  Future<void> playTap() => SystemSound.play(SystemSoundType.click);

  Future<void> playSuccess() => SystemSound.play(SystemSoundType.click);
}
