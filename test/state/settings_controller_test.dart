import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/state/settings_controller.dart';

import '../services/fake_notification_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsController', () {
    test('starts with sound and haptics on', () async {
      final controller = SettingsController();
      await controller.load();

      expect(controller.soundEnabled, isTrue);
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
      expect(second.hapticsEnabled, isTrue);
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

  group('notifications', () {
    test('default preference is enabled, with permission not yet requested', () async {
      final controller = SettingsController(notifications: FakeNotificationService());
      await controller.load();

      expect(controller.notificationsEnabled, isTrue);
    });

    test('ensureNotificationsReady requests permission once on first run and schedules when granted', () async {
      final notifications = FakeNotificationService();
      final controller = SettingsController(notifications: notifications);
      await controller.load();

      await controller.ensureNotificationsReady();

      expect(notifications.calls, ['initialize', 'requestPermission', 'scheduleNotifications']);
      expect(controller.notificationsEnabled, isTrue);
    });

    test('a denied first-run permission request leaves notifications off and does not schedule', () async {
      final notifications = FakeNotificationService()..permissionResult = false;
      final controller = SettingsController(notifications: notifications);
      await controller.load();

      await controller.ensureNotificationsReady();

      expect(notifications.calls, ['initialize', 'requestPermission']);
      expect(controller.notificationsEnabled, isFalse);
    });

    test('ensureNotificationsReady never re-requests permission on a later launch', () async {
      final notifications = FakeNotificationService();
      final first = SettingsController(notifications: notifications);
      await first.load();
      await first.ensureNotificationsReady(); // first launch: requests + schedules

      final second = SettingsController(notifications: notifications);
      await second.load();
      await second.ensureNotificationsReady(); // later launch: must not prompt again

      expect(notifications.calls, ['initialize', 'requestPermission', 'scheduleNotifications', 'initialize', 'scheduleNotifications']);
    });

    test('ensureNotificationsReady on a later launch does nothing when the preference is off', () async {
      final notifications = FakeNotificationService();
      final controller = SettingsController(notifications: notifications);
      await controller.load();
      await controller.setNotificationsEnabled(false);
      notifications.calls.clear();

      await controller.ensureNotificationsReady();

      expect(notifications.calls, ['initialize']);
    });

    test('setNotificationsEnabled(true) requests permission and schedules both reminders', () async {
      final notifications = FakeNotificationService();
      final controller = SettingsController(notifications: notifications);
      await controller.load();

      await controller.setNotificationsEnabled(true);

      expect(controller.notificationsEnabled, isTrue);
      expect(notifications.calls, contains('requestPermission'));
      expect(notifications.calls, contains('scheduleNotifications'));
    });

    test('setNotificationsEnabled(false) cancels both reminders', () async {
      final notifications = FakeNotificationService();
      final controller = SettingsController(notifications: notifications);
      await controller.load();
      await controller.setNotificationsEnabled(true);
      notifications.calls.clear();

      await controller.setNotificationsEnabled(false);

      expect(controller.notificationsEnabled, isFalse);
      expect(notifications.calls, ['cancelNotifications']);
    });

    test('turning it on repeatedly never schedules more than once per toggle - no duplicates', () async {
      final notifications = FakeNotificationService();
      final controller = SettingsController(notifications: notifications);
      await controller.load();

      await controller.setNotificationsEnabled(true);
      await controller.setNotificationsEnabled(true);
      await controller.setNotificationsEnabled(true);

      expect(notifications.calls.where((c) => c == 'scheduleNotifications'), hasLength(3));
      // Each call is its own self-contained cancel-then-recreate inside
      // scheduleNotifications, so 3 calls still means exactly one
      // Tuesday + one Saturday schedule, never a growing pile.
    });

    test('denying permission when explicitly turning on leaves the toggle off, not stuck on', () async {
      final notifications = FakeNotificationService()..permissionResult = false;
      final controller = SettingsController(notifications: notifications);
      await controller.load();

      await controller.setNotificationsEnabled(true);

      expect(controller.notificationsEnabled, isFalse);
      expect(notifications.calls, isNot(contains('scheduleNotifications')));
    });

    test('the message rotation index persists and advances across scheduling calls', () async {
      final notifications = FakeNotificationService();
      final first = SettingsController(notifications: notifications);
      await first.load();
      await first.setNotificationsEnabled(true); // consumes messages 0,1 -> next index 2

      final second = SettingsController(notifications: notifications);
      await second.load();

      expect(second.settings.notificationMessageIndex, 2);
    });

    test('the toggle state matches the persisted preference after a restart', () async {
      final notifications = FakeNotificationService();
      final first = SettingsController(notifications: notifications);
      await first.load();
      await first.setNotificationsEnabled(false);

      final second = SettingsController(notifications: notifications);
      await second.load();

      expect(second.notificationsEnabled, isFalse);

      await second.setNotificationsEnabled(true);
      final third = SettingsController(notifications: notifications);
      await third.load();

      expect(third.notificationsEnabled, isTrue);
    });

    test('an initialization failure in ensureNotificationsReady does not throw and leaves the app usable', () async {
      final notifications = FakeNotificationService()..initializeResult = false;
      final controller = SettingsController(notifications: notifications);
      await controller.load();

      await expectLater(controller.ensureNotificationsReady(), completes);
      expect(controller.notificationsEnabled, isTrue, reason: 'the preference itself is untouched by a plugin failure');
    });
  });
}
