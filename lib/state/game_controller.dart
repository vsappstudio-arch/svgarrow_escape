import 'package:flutter/foundation.dart';

import '../game/puzzle_engine.dart';
import '../models/arrow_model.dart';
import '../models/level_model.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';

/// Drives a single [PuzzleEngine] instance for the game screen and
/// notifies listeners as arrows are removed.
class GameController extends ChangeNotifier {
  final PuzzleEngine _engine;
  final AudioService _audio;
  final HapticService _haptics;

  GameController(
    LevelModel level, {
    AudioService? audio,
    HapticService? haptics,
  }) : _engine = PuzzleEngine(level),
       _audio = audio ?? AudioService(),
       _haptics = haptics ?? HapticService();

  LevelModel get level => _engine.level;
  List<ArrowModel> get arrows => _engine.level.arrows;
  bool get isSolved => _engine.isSolved;
  int get moves => _engine.moves;
  int get starsEarned => _engine.starsEarned;

  bool isRemoved(String arrowId) => _engine.isRemoved(arrowId);

  void tapArrow(ArrowModel arrow) {
    final removed = _engine.tryRemove(arrow.id);
    if (!removed) {
      _haptics.selectionClick();
      notifyListeners();
      return;
    }

    _haptics.lightImpact();
    _audio.playTap();
    if (_engine.isSolved) {
      _haptics.mediumImpact();
      _audio.playSuccess();
    }
    notifyListeners();
  }

  void reset() {
    _engine.reset();
    notifyListeners();
  }
}
