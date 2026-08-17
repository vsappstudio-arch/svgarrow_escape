import 'package:flutter/foundation.dart';

/// Persisted player state: progression, star ratings, best move
/// counts, and the in-game currency economy.
@immutable
class PlayerProgress {
  final int unlockedLevel;
  final Map<int, int> starsByLevel;
  final Map<int, int> bestMovesByLevel;
  final int coins;
  final int hints;
  final int undos;
  final int extraMoves;
  final bool removeAdsPurchased;

  const PlayerProgress({
    this.unlockedLevel = 1,
    this.starsByLevel = const {},
    this.bestMovesByLevel = const {},
    this.coins = 100,
    this.hints = 3,
    this.undos = 3,
    this.extraMoves = 0,
    this.removeAdsPurchased = false,
  });

  PlayerProgress copyWith({
    int? unlockedLevel,
    Map<int, int>? starsByLevel,
    Map<int, int>? bestMovesByLevel,
    int? coins,
    int? hints,
    int? undos,
    int? extraMoves,
    bool? removeAdsPurchased,
  }) {
    return PlayerProgress(
      unlockedLevel: unlockedLevel ?? this.unlockedLevel,
      starsByLevel: starsByLevel ?? this.starsByLevel,
      bestMovesByLevel: bestMovesByLevel ?? this.bestMovesByLevel,
      coins: coins ?? this.coins,
      hints: hints ?? this.hints,
      undos: undos ?? this.undos,
      extraMoves: extraMoves ?? this.extraMoves,
      removeAdsPurchased: removeAdsPurchased ?? this.removeAdsPurchased,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unlockedLevel': unlockedLevel,
      'starsByLevel': starsByLevel.map((levelId, stars) => MapEntry(levelId.toString(), stars)),
      'bestMovesByLevel': bestMovesByLevel.map((levelId, moves) => MapEntry(levelId.toString(), moves)),
      'coins': coins,
      'hints': hints,
      'undos': undos,
      'extraMoves': extraMoves,
      'removeAdsPurchased': removeAdsPurchased,
    };
  }

  static Map<int, int> _decodeIntMap(dynamic raw) {
    if (raw is! Map<String, dynamic>) return const {};
    return raw.map((levelId, value) => MapEntry(int.parse(levelId), value as int));
  }

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      unlockedLevel: json['unlockedLevel'] as int? ?? 1,
      starsByLevel: _decodeIntMap(json['starsByLevel']),
      bestMovesByLevel: _decodeIntMap(json['bestMovesByLevel']),
      coins: json['coins'] as int? ?? 100,
      hints: json['hints'] as int? ?? 3,
      undos: json['undos'] as int? ?? 3,
      extraMoves: json['extraMoves'] as int? ?? 0,
      removeAdsPurchased: json['removeAdsPurchased'] as bool? ?? false,
    );
  }
}
