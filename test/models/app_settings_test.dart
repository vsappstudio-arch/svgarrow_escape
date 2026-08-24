import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_escape/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('defaults to sound, music, and haptics on, tutorial unseen', () {
      const settings = AppSettings();

      expect(settings.soundEnabled, isTrue);
      expect(settings.musicEnabled, isTrue);
      expect(settings.hapticsEnabled, isTrue);
      expect(settings.tutorialSeen, isFalse);
    });

    test('copyWith changes only the given fields', () {
      const settings = AppSettings();

      final updated = settings.copyWith(musicEnabled: false);

      expect(updated.musicEnabled, isFalse);
      expect(updated.soundEnabled, isTrue);
      expect(updated.hapticsEnabled, isTrue);
      expect(updated.tutorialSeen, isFalse);
    });

    test('toJson/fromJson round-trips every field, including musicEnabled', () {
      const settings = AppSettings(
        soundEnabled: false,
        musicEnabled: false,
        hapticsEnabled: false,
        tutorialSeen: true,
      );

      final roundTripped = AppSettings.fromJson(settings.toJson());

      expect(roundTripped.soundEnabled, isFalse);
      expect(roundTripped.musicEnabled, isFalse);
      expect(roundTripped.hapticsEnabled, isFalse);
      expect(roundTripped.tutorialSeen, isTrue);
    });

    test('fromJson falls back to defaults for missing fields', () {
      final settings = AppSettings.fromJson(const {});

      expect(settings.soundEnabled, isTrue);
      expect(settings.musicEnabled, isTrue);
      expect(settings.hapticsEnabled, isTrue);
      expect(settings.tutorialSeen, isFalse);
    });
  });
}
