import 'package:flutter/foundation.dart';

/// Persisted user preferences.
@immutable
class AppSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool tutorialSeen;

  const AppSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.tutorialSeen = false,
  });

  AppSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? tutorialSeen,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'hapticsEnabled': hapticsEnabled,
      'tutorialSeen': tutorialSeen,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      tutorialSeen: json['tutorialSeen'] as bool? ?? false,
    );
  }
}
