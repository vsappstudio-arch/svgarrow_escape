import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../storage/game_storage.dart';

/// Holds the player's persisted preferences and keeps [GameStorage]
/// in sync whenever they change.
class SettingsController extends ChangeNotifier {
  final GameStorage _storage;
  AppSettings _settings = const AppSettings();
  bool _isLoaded = false;
  Future<void>? _loadFuture;

  SettingsController({GameStorage? storage}) : _storage = storage ?? GameStorage();

  AppSettings get settings => _settings;
  bool get isLoaded => _isLoaded;
  bool get soundEnabled => _settings.soundEnabled;
  bool get musicEnabled => _settings.musicEnabled;
  bool get hapticsEnabled => _settings.hapticsEnabled;
  bool get tutorialSeen => _settings.tutorialSeen;

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

  Future<void> setMusicEnabled(bool value) => _update(_settings.copyWith(musicEnabled: value));

  Future<void> setHapticsEnabled(bool value) => _update(_settings.copyWith(hapticsEnabled: value));

  Future<void> markTutorialSeen() => _update(_settings.copyWith(tutorialSeen: true));

  Future<void> resetTutorial() => _update(_settings.copyWith(tutorialSeen: false));
}
