import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_escape/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('defaults to sound and haptics on, tutorial unseen', () {
      const settings = AppSettings();

      expect(settings.soundEnabled, isTrue);
      expect(settings.hapticsEnabled, isTrue);
      expect(settings.tutorialSeen, isFalse);
    });

    test('defaults notifications to enabled, permission not yet requested, rotation at the start', () {
      const settings = AppSettings();

      expect(settings.notificationsEnabled, isTrue);
      expect(settings.notificationPermissionRequested, isFalse);
      expect(settings.notificationMessageIndex, 0);
    });

    test('copyWith changes only the given fields', () {
      const settings = AppSettings();

      final updated = settings.copyWith(soundEnabled: false);

      expect(updated.soundEnabled, isFalse);
      expect(updated.hapticsEnabled, isTrue);
      expect(updated.tutorialSeen, isFalse);
    });

    test('toJson/fromJson round-trips every field', () {
      const settings = AppSettings(
        soundEnabled: false,
        hapticsEnabled: false,
        tutorialSeen: true,
        notificationsEnabled: false,
        notificationPermissionRequested: true,
        notificationMessageIndex: 7,
      );

      final roundTripped = AppSettings.fromJson(settings.toJson());

      expect(roundTripped.soundEnabled, isFalse);
      expect(roundTripped.hapticsEnabled, isFalse);
      expect(roundTripped.tutorialSeen, isTrue);
      expect(roundTripped.notificationsEnabled, isFalse);
      expect(roundTripped.notificationPermissionRequested, isTrue);
      expect(roundTripped.notificationMessageIndex, 7);
    });

    test('fromJson falls back to defaults for missing fields', () {
      final settings = AppSettings.fromJson(const {});

      expect(settings.soundEnabled, isTrue);
      expect(settings.hapticsEnabled, isTrue);
      expect(settings.tutorialSeen, isFalse);
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.notificationPermissionRequested, isFalse);
      expect(settings.notificationMessageIndex, 0);
    });
  });
}
