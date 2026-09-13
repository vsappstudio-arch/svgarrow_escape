import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../services/notification_service.dart';
import '../storage/game_storage.dart';

/// Holds the player's persisted preferences and keeps [GameStorage]
/// in sync whenever they change.
class SettingsController extends ChangeNotifier {
  final GameStorage _storage;
  final NotificationService _notifications;
  AppSettings _settings = const AppSettings();
  bool _isLoaded = false;
  Future<void>? _loadFuture;

  SettingsController({GameStorage? storage, NotificationService? notifications})
    : _storage = storage ?? GameStorage(),
      _notifications = notifications ?? NotificationService();

  AppSettings get settings => _settings;
  bool get isLoaded => _isLoaded;
  bool get soundEnabled => _settings.soundEnabled;
  bool get hapticsEnabled => _settings.hapticsEnabled;
  bool get tutorialSeen => _settings.tutorialSeen;
  bool get notificationsEnabled => _settings.notificationsEnabled;

  Future<void> load() async {
    _settings = await _storage.loadSettings();
    _isLoaded = true;
    notifyListeners();
  }

  /// Loads settings at most once, returning the same in-flight/completed
  /// future to every caller. Used by the splash screen to know when
  /// it's safe to read [tutorialSeen].
  Future<void> ensureLoaded() => _loadFuture ??= load();

  Future<void> _update(AppSettings next) async {
    _settings = next;
    notifyListeners();
    await _storage.saveSettings(_settings);
  }

  Future<void> setSoundEnabled(bool value) => _update(_settings.copyWith(soundEnabled: value));

  Future<void> setHapticsEnabled(bool value) => _update(_settings.copyWith(hapticsEnabled: value));

  Future<void> markTutorialSeen() => _update(_settings.copyWith(tutorialSeen: true));

  Future<void> resetTutorial() => _update(_settings.copyWith(tutorialSeen: false));

  /// Called once at app startup, after settings have loaded. On a
  /// genuine first launch (permission never requested before) this
  /// asks for Android's notification permission exactly once and
  /// records the outcome - denial simply leaves notifications off,
  /// nothing prompts again on a later launch. On every launch after
  /// that, if the preference is on, it re-establishes the Tuesday/
  /// Saturday schedule (Android clears AlarmManager schedules on
  /// reboot, so this is what makes them "survive" a restart) and
  /// advances the rotating message for next time.
  Future<void> ensureNotificationsReady() async {
    if (!await _notifications.initialize()) return;

    if (!_settings.notificationPermissionRequested) {
      final granted = _settings.notificationsEnabled ? await _notifications.requestPermission() : false;
      final nextIndex = granted ? await _notifications.scheduleNotifications(_settings.notificationMessageIndex) : _settings.notificationMessageIndex;
      await _update(
        _settings.copyWith(
          notificationPermissionRequested: true,
          notificationsEnabled: granted,
          notificationMessageIndex: nextIndex,
        ),
      );
      return;
    }

    if (_settings.notificationsEnabled) {
      final nextIndex = await _notifications.scheduleNotifications(_settings.notificationMessageIndex);
      await _update(_settings.copyWith(notificationMessageIndex: nextIndex));
    }
  }

  /// Turns the Settings notification toggle on or off. Turning on
  /// requests permission if it hasn't been resolved yet and schedules
  /// both reminders; if permission is denied, the preference is left
  /// off so the toggle never shows a state notifications can't
  /// actually reach. Turning off cancels both schedules. Either way
  /// this is idempotent - flipping it on repeatedly never creates more
  /// than one Tuesday and one Saturday schedule.
  Future<void> setNotificationsEnabled(bool value) async {
    if (!value) {
      await _notifications.cancelNotifications();
      await _update(_settings.copyWith(notificationsEnabled: false));
      return;
    }

    final initialized = await _notifications.initialize();
    final granted = initialized && await _notifications.requestPermission();
    if (!granted) {
      await _update(_settings.copyWith(notificationPermissionRequested: true, notificationsEnabled: false));
      return;
    }

    final nextIndex = await _notifications.scheduleNotifications(_settings.notificationMessageIndex);
    await _update(
      _settings.copyWith(
        notificationPermissionRequested: true,
        notificationsEnabled: true,
        notificationMessageIndex: nextIndex,
      ),
    );
  }
}
