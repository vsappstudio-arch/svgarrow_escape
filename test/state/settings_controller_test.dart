import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/state/settings_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsController', () {
    test('starts with sound, music, and haptics on', () async {
      final controller = SettingsController();
      await controller.load();

      expect(controller.soundEnabled, isTrue);
      expect(controller.musicEnabled, isTrue);
      expect(controller.hapticsEnabled, isTrue);
    });

    test('setSoundEnabled persists across a fresh controller (app restart)', () async {
      final first = SettingsController();
      await first.load();
      await first.setSoundEnabled(false);

      final second = SettingsController();
      await second.load();

      expect(second.soundEnabled, isFalse);
      // Unrelated settings are untouched.
      expect(second.musicEnabled, isTrue);
      expect(second.hapticsEnabled, isTrue);
    });

    test('setMusicEnabled persists across a fresh controller (app restart)', () async {
      final first = SettingsController();
      await first.load();
      await first.setMusicEnabled(false);

      final second = SettingsController();
      await second.load();

      expect(second.musicEnabled, isFalse);
      expect(second.soundEnabled, isTrue);
    });

    test('ensureLoaded only loads once and returns the same future to every caller', () async {
      final controller = SettingsController();

      final first = controller.ensureLoaded();
      final second = controller.ensureLoaded();

      expect(identical(first, second), isTrue);
      await first;
      expect(controller.isLoaded, isTrue);
    });
  });
}
