import 'dart:async';

import 'package:flutter/foundation.dart';

import '../game/puzzle_engine.dart';
import '../models/arrow_model.dart';
import '../models/level_model.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import 'settings_controller.dart';

/// Drives a single [PuzzleEngine] instance for the game screen and
/// notifies listeners as arrows are removed, undone, or hinted.
class GameController extends ChangeNotifier {
  final PuzzleEngine _engine;
  final AudioService _audio;
  final HapticService _haptics;
  final SettingsController _settings;

  String? _hintedArrowId;
  String? _shakingArrowId;
  Timer? _hintTimer;
  Timer? _shakeTimer;

  /// Extra moves granted to *this attempt* by spending Extra Moves
  /// boosters. Deliberately local, in-memory state - never persisted -
  /// so it resets with the attempt (restart, leaving and re-entering
  /// the level) without ever touching the player's purchased
  /// inventory, which lives in [PlayerProgress.extraMoves] instead.
  int _bonusMoves = 0;

  /// Incorrect taps made on *this attempt*. Resets with [reset], same
  /// as [_bonusMoves] - never persisted, since it describes the
  /// current attempt, not the player's overall progress.
  int _missCount = 0;

  GameController(
    LevelModel level,
    this._settings, {
    AudioService? audio,
    HapticService? haptics,
  }) : _engine = PuzzleEngine(level),
       _audio = audio ?? AudioService(),
       _haptics = haptics ?? HapticService();

  /// How many moves an Extra Moves booster adds when used.
  static const int extraMovesPerBoost = 5;

  /// The normal move allowance is a generous multiple of the level's
  /// own [LevelModel.optimalMoves] - twice it, comfortably above the
  /// optimal+1 threshold where the star rating already bottoms out at
  /// 1 star (see [PuzzleEngine.starsEarned]). That keeps the limit far
  /// out of reach of ordinary play (including the odd wrong tap on a
  /// level's decoys), so it never changes how any of the 50 approved
  /// levels actually play; it only catches a player who is genuinely
  /// stuck and flailing, which is exactly when the booster should
  /// offer to help.
  static const int _moveLimitMultiplier = 2;

  LevelModel get level => _engine.level;
  List<ArrowModel> get arrows => _engine.level.arrows;
  bool get isSolved => _engine.isSolved;
  int get moves => _engine.moves;
  int get starsEarned => _engine.starsEarned;
  bool get canUndo => _engine.canUndo;
  String? get hintedArrowId => _hintedArrowId;
  String? get shakingArrowId => _shakingArrowId;

  /// The total moves allowed on this attempt: the level's normal
  /// allowance, plus any Extra Moves boosters already used.
  int get moveLimit => level.optimalMoves * _moveLimitMultiplier + _bonusMoves;

  /// True once the player has used up [moveLimit] moves without
  /// solving the puzzle - the "Out of Moves" state, which the game
  /// screen answers with a booster offer rather than by ending the
  /// level outright.
  bool get isOutOfMoves => !isSolved && moves >= moveLimit;

  int get missCount => _missCount;

  /// Levels 1-25 tolerate 3 incorrect moves before Game Over; Levels
  /// 26-50 tolerate 5.
  int get missLimit => level.id <= 25 ? 3 : 5;

  /// True once [missCount] has reached [missLimit] on this attempt -
  /// the "Game Over" state. This is a separate mechanic from
  /// [isOutOfMoves]: it counts *incorrect* taps (a puzzle-reading
  /// mistake), not total moves spent (a resource budget), so it is
  /// never affected by [useExtraMovesBoost] and can't be rescued by
  /// one - only [reset] (Try Again) clears it.
  bool get isGameOver => _missCount >= missLimit;

  bool isRemoved(String arrowId) => _engine.isRemoved(arrowId);

  void _playEscape() {
    if (_settings.soundEnabled) _audio.playEscape();
    if (_settings.hapticsEnabled) _haptics.lightImpact();
  }

  void _playBlocked() {
    if (_settings.soundEnabled) _audio.playBlocked();
    if (_settings.hapticsEnabled) _haptics.selectionClick();
  }

  void _playLevelComplete() {
    if (_settings.soundEnabled) _audio.playLevelComplete();
    if (_settings.hapticsEnabled) _haptics.mediumImpact();
  }

  void tapArrow(ArrowModel arrow) {
    // Once the move allowance is spent, or the miss limit is reached,
    // the game screen puts up a non-dismissible overlay; this is the
    // belt-and-braces guard underneath it so a tap can never sneak
    // past either limit while one is in flight.
    if (isOutOfMoves || isGameOver) return;

    _hintTimer?.cancel();
    _hintedArrowId = null;

    final movesBefore = _engine.moves;
    final removed = _engine.tryRemove(arrow.id);
    if (!removed) {
      // moves only advances on a genuine attempt against a still-active
      // arrow (PuzzleEngine.tryRemove is a no-op on an already-removed
      // id, and doesn't touch moves then) - so this is exactly "an
      // incorrect move was attempted", the miss system's own definition.
      if (_engine.moves > movesBefore) _missCount++;
      _playBlocked();
      _triggerShake(arrow.id);
      return;
    }

    _playEscape();
    if (_engine.isSolved) _playLevelComplete();
    notifyListeners();
  }

  void _triggerShake(String arrowId) {
    _shakeTimer?.cancel();
    _shakingArrowId = arrowId;
    notifyListeners();
    _shakeTimer = Timer(const Duration(milliseconds: 400), () {
      _shakingArrowId = null;
      notifyListeners();
    });
  }

  /// Highlights an escapable arrow for a few seconds. Returns false if
  /// the puzzle has no escapable arrow left (i.e. it's solved).
  bool showHint() {
    final arrowId = _engine.hintArrowId();
    if (arrowId == null) return false;

    _hintTimer?.cancel();
    _hintedArrowId = arrowId;
    notifyListeners();
    _hintTimer = Timer(const Duration(seconds: 3), () {
      _hintedArrowId = null;
      notifyListeners();
    });
    return true;
  }

  /// Puts the last-escaped arrow back on the board. Returns false if
  /// there was nothing to undo.
  bool undo() {
    final restored = _engine.undoLast();
    if (restored == null) return false;
    if (_settings.hapticsEnabled) _haptics.selectionClick();
    notifyListeners();
    return true;
  }

  /// Spends one Extra Moves booster's worth of allowance on this
  /// attempt. The caller is responsible for actually deducting the
  /// booster from [PlayerProgress.extraMoves] first (via
  /// `ProgressController.spendExtraMove`) - this only grows the local,
  /// unpersisted [moveLimit] so play can resume immediately with the
  /// board exactly as it was.
  void useExtraMovesBoost() {
    _bonusMoves += extraMovesPerBoost;
    notifyListeners();
  }

  void reset() {
    _hintTimer?.cancel();
    _shakeTimer?.cancel();
    _hintedArrowId = null;
    _shakingArrowId = null;
    _bonusMoves = 0;
    _missCount = 0;
    _engine.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _shakeTimer?.cancel();
    super.dispose();
  }
}
