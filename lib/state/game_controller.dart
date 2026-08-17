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

  GameController(
    LevelModel level,
    this._settings, {
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
  bool get canUndo => _engine.canUndo;
  String? get hintedArrowId => _hintedArrowId;
  String? get shakingArrowId => _shakingArrowId;

  bool isRemoved(String arrowId) => _engine.isRemoved(arrowId);

  void _playTap() {
    if (_settings.soundEnabled) _audio.playTap();
    if (_settings.hapticsEnabled) _haptics.lightImpact();
  }

  void _playBlocked() {
    if (_settings.hapticsEnabled) _haptics.selectionClick();
  }

  void _playSuccess() {
    if (_settings.soundEnabled) _audio.playSuccess();
    if (_settings.hapticsEnabled) _haptics.mediumImpact();
  }

  void tapArrow(ArrowModel arrow) {
    _hintTimer?.cancel();
    _hintedArrowId = null;

    final removed = _engine.tryRemove(arrow.id);
    if (!removed) {
      _playBlocked();
      _triggerShake(arrow.id);
      return;
    }

    _playTap();
    if (_engine.isSolved) _playSuccess();
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

  void reset() {
    _hintTimer?.cancel();
    _shakeTimer?.cancel();
    _hintedArrowId = null;
    _shakingArrowId = null;
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
