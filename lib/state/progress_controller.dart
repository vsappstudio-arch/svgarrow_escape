import 'package:flutter/foundation.dart';

import '../models/player_progress.dart';
import '../storage/game_storage.dart';

/// Holds the player's persisted progress in memory and keeps
/// [GameStorage] in sync whenever it changes.
class ProgressController extends ChangeNotifier {
  final GameStorage _storage;
  PlayerProgress _progress = const PlayerProgress();
  bool _isLoaded = false;

  ProgressController({GameStorage? storage}) : _storage = storage ?? GameStorage();

  PlayerProgress get progress => _progress;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    _progress = await _storage.loadProgress();
    _isLoaded = true;
    notifyListeners();
  }

  bool isUnlocked(int levelId) => levelId <= _progress.unlockedLevel;

  int starsFor(int levelId) => _progress.starsByLevel[levelId] ?? 0;

  Future<void> completeLevel(int levelId, int stars) async {
    final bestStars = stars > starsFor(levelId) ? stars : starsFor(levelId);
    final updatedStars = Map<int, int>.from(_progress.starsByLevel)
      ..[levelId] = bestStars;
    final nextUnlocked = levelId + 1 > _progress.unlockedLevel
        ? levelId + 1
        : _progress.unlockedLevel;

    _progress = _progress.copyWith(
      unlockedLevel: nextUnlocked,
      starsByLevel: updatedStars,
    );
    notifyListeners();
    await _storage.saveProgress(_progress);
  }
}
