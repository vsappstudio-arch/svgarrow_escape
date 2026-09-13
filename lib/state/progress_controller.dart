import 'package:flutter/foundation.dart';

import '../models/player_progress.dart';
import '../storage/game_storage.dart';

/// What happened when a level was finished, so the UI can show a
/// coin-reward toast without recomputing the economy itself.
@immutable
class LevelCompletionResult {
  final int coinsAwarded;
  final bool isFirstCompletion;
  final bool isNewBestStars;
  final int bestMoves;

  const LevelCompletionResult({
    required this.coinsAwarded,
    required this.isFirstCompletion,
    required this.isNewBestStars,
    required this.bestMoves,
  });
}

/// Where a level sits in the player's journey through the world, as
/// shown on the Levels screen.
enum LevelStatus {
  /// Already cleared at least once (its stars are recorded).
  completed,

  /// Unlocked but not cleared yet - the level to play next.
  current,

  /// Not reachable yet.
  locked,
}

/// Holds the player's persisted progress and currency in memory and
/// keeps [GameStorage] in sync whenever either changes.
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

  Future<void> _persist() => _storage.saveProgress(_progress);

  bool isUnlocked(int levelId) => levelId <= _progress.unlockedLevel;

  /// Whether the level has ever been cleared. Completion is recorded
  /// by [completeLevel] writing the level's star rating, so the star
  /// map doubles as the set of finished levels.
  bool isCompleted(int levelId) => _progress.starsByLevel.containsKey(levelId);

  /// Derives the Levels screen's completed/current/locked state from
  /// the saved progress - no separate progression state of its own.
  /// Replaying a finished level leaves it [LevelStatus.completed], so
  /// progression never moves backwards.
  LevelStatus statusFor(int levelId) {
    if (isCompleted(levelId)) return LevelStatus.completed;
    return isUnlocked(levelId) ? LevelStatus.current : LevelStatus.locked;
  }

  int starsFor(int levelId) => _progress.starsByLevel[levelId] ?? 0;

  int bestMovesFor(int levelId) => _progress.bestMovesByLevel[levelId] ?? 0;

  /// Records a level completion: unlocks the next level, keeps the
  /// best star rating and best move count, and awards coins. Persists
  /// before returning, so unlocking is guaranteed to have happened by
  /// the time a completion overlay is shown.
  Future<LevelCompletionResult> completeLevel(int levelId, int stars, int moves) async {
    final previousBestStars = starsFor(levelId);
    final isFirstCompletion = !_progress.starsByLevel.containsKey(levelId);
    final isNewBestStars = stars > previousBestStars;
    final newBestStars = isNewBestStars ? stars : previousBestStars;

    final previousBestMoves = _progress.bestMovesByLevel[levelId];
    final bestMoves = previousBestMoves == null ? moves : (moves < previousBestMoves ? moves : previousBestMoves);

    final coinsAwarded = isFirstCompletion
        ? 10 + stars * 10
        : (isNewBestStars ? (stars - previousBestStars) * 10 : 2);

    final updatedStars = Map<int, int>.from(_progress.starsByLevel)..[levelId] = newBestStars;
    final updatedBestMoves = Map<int, int>.from(_progress.bestMovesByLevel)..[levelId] = bestMoves;
    final nextUnlocked = levelId + 1 > _progress.unlockedLevel ? levelId + 1 : _progress.unlockedLevel;

    _progress = _progress.copyWith(
      unlockedLevel: nextUnlocked,
      starsByLevel: updatedStars,
      bestMovesByLevel: updatedBestMoves,
      coins: _progress.coins + coinsAwarded,
    );
    notifyListeners();
    await _persist();

    return LevelCompletionResult(
      coinsAwarded: coinsAwarded,
      isFirstCompletion: isFirstCompletion,
      isNewBestStars: isNewBestStars,
      bestMoves: bestMoves,
    );
  }

  Future<bool> spendHint() async {
    if (_progress.hints <= 0) return false;
    _progress = _progress.copyWith(hints: _progress.hints - 1);
    notifyListeners();
    await _persist();
    return true;
  }

  Future<bool> spendUndo() async {
    if (_progress.undos <= 0) return false;
    _progress = _progress.copyWith(undos: _progress.undos - 1);
    notifyListeners();
    await _persist();
    return true;
  }

  /// Spends one Extra Moves booster from inventory, for the in-game
  /// "Out of Moves" rescue offer. Returns false without changing
  /// anything if none are left. Persistence is awaited so the caller
  /// - which immediately grants the bonus and resumes gameplay - only
  /// does so once the reduced inventory has actually reached storage.
  Future<bool> spendExtraMove() async {
    if (_progress.extraMoves <= 0) return false;
    _progress = _progress.copyWith(extraMoves: _progress.extraMoves - 1);
    notifyListeners();
    await _persist();
    return true;
  }

  /// Spends [cost] coins and applies [apply] to the current progress
  /// if there's enough balance. Returns true if the purchase went
  /// through.
  Future<bool> spendCoins(int cost, PlayerProgress Function(PlayerProgress current) apply) async {
    if (_progress.coins < cost) return false;
    final withCost = _progress.copyWith(coins: _progress.coins - cost);
    _progress = apply(withCost);
    notifyListeners();
    await _persist();
    return true;
  }
}
