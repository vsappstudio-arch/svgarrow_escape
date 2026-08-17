import 'package:flutter/foundation.dart';

/// Persisted player state: how far they've progressed and star ratings
/// earned per level.
@immutable
class PlayerProgress {
  final int unlockedLevel;
  final Map<int, int> starsByLevel;

  const PlayerProgress({
    this.unlockedLevel = 1,
    this.starsByLevel = const {},
  });

  PlayerProgress copyWith({
    int? unlockedLevel,
    Map<int, int>? starsByLevel,
  }) {
    return PlayerProgress(
      unlockedLevel: unlockedLevel ?? this.unlockedLevel,
      starsByLevel: starsByLevel ?? this.starsByLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unlockedLevel': unlockedLevel,
      'starsByLevel': starsByLevel.map(
        (levelId, stars) => MapEntry(levelId.toString(), stars),
      ),
    };
  }

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    final rawStars = json['starsByLevel'] as Map<String, dynamic>?;
    return PlayerProgress(
      unlockedLevel: json['unlockedLevel'] as int? ?? 1,
      starsByLevel: rawStars == null
          ? const {}
          : rawStars.map(
              (levelId, stars) => MapEntry(int.parse(levelId), stars as int),
            ),
    );
  }
}
