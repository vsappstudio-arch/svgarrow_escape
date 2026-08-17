import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_progress.dart';

/// Persists [PlayerProgress] locally via shared_preferences.
class GameStorage {
  static const _progressKey = 'player_progress';

  Future<PlayerProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null) return const PlayerProgress();
    return PlayerProgress.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> saveProgress(PlayerProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }
}
