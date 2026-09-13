import 'package:flutter/foundation.dart';

/// Persisted user preferences.
@immutable
class AppSettings {
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool tutorialSeen;
  final bool notificationsEnabled;

  /// Whether the one-time Android notification-permission request has
  /// already been made, so the app never re-prompts on every launch.
  final bool notificationPermissionRequested;

  /// Index into the reminder-message pool ([NotificationService.messagePool])
  /// that the next scheduled notification should start rotating from.
  final int notificationMessageIndex;

  const AppSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.tutorialSeen = false,
    this.notificationsEnabled = true,
    this.notificationPermissionRequested = false,
    this.notificationMessageIndex = 0,
  });

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? tutorialSeen,
    bool? notificationsEnabled,
    bool? notificationPermissionRequested,
    int? notificationMessageIndex,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationPermissionRequested: notificationPermissionRequested ?? this.notificationPermissionRequested,
      notificationMessageIndex: notificationMessageIndex ?? this.notificationMessageIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'hapticsEnabled': hapticsEnabled,
      'tutorialSeen': tutorialSeen,
      'notificationsEnabled': notificationsEnabled,
      'notificationPermissionRequested': notificationPermissionRequested,
      'notificationMessageIndex': notificationMessageIndex,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      tutorialSeen: json['tutorialSeen'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      notificationPermissionRequested: json['notificationPermissionRequested'] as bool? ?? false,
      notificationMessageIndex: json['notificationMessageIndex'] as int? ?? 0,
    );
  }
}
