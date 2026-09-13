import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
// The "all" dataset (not just "latest") is required here: it's the
// only bundled variant that includes legacy IANA aliases like
// "Asia/Calcutta" - which is exactly what some real Android devices
// (observed on a physical Xiaomi/HyperOS phone) report as the local
// timezone instead of the canonical "Asia/Kolkata". Without it,
// tz.getLocation() throws for those devices and the whole service
// fails to initialize - notifications silently never get scheduled.
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules the two weekly "come back and play" reminders (Tuesday and
/// Saturday, 7 PM local time) as real Android system notifications, using
/// flutter_local_notifications' calendar-style recurrence so the OS
/// itself re-fires them every week - no backend, no Firebase, nothing
/// running while ARROWW is closed.
///
/// Every public method is defensive: a failure here (permission denied,
/// plugin not available, timezone lookup failure, ...) is caught and
/// reported as a bool/no-op rather than thrown, because a reminder
/// feature must never be able to break the rest of the app.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin}) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const int tuesdayNotificationId = 2001;
  static const int saturdayNotificationId = 2002;

  /// Only used by [scheduleDebugTestNotification] to verify the real
  /// Android notification pipeline during development. Distinct from
  /// the two production IDs so it can never collide or be mistaken
  /// for a real recurring reminder.
  static const int debugTestNotificationId = 9999;

  static const String channelId = 'arroww_reminders';
  static const String channelName = 'ARROWW Reminders';
  static const String channelDescription = 'Reminders to come back and play ARROWW.';

  static const String notificationTitle = 'ARROWW';

  static const int reminderHour = 19;
  static const int reminderMinute = 0;

  /// The 15 approved reminder bodies. Never mentions coins, purchases,
  /// ads, or rewards - just an invitation back to the game.
  static const List<String> messagePool = [
    'Your next puzzle is waiting. Can you beat your best?',
    'Got a minute? Solve a quick puzzle and sharpen your moves! 🧠',
    'A new challenge is waiting for you. Ready? 🎯',
    'Think fast. Choose wisely. Can you escape the arrows? 🏹',
    'Your puzzle streak is calling. Open ARROWW and play! 🔥',
    'One puzzle. One goal. Can you solve it with fewer moves?',
    'Time for a brain workout! Your next ARROWW challenge awaits. 🧩',
    'Can you beat your previous score? The arrows are waiting! ⚡',
    'Take a break and solve a puzzle. Your next challenge starts now!',
    'The board is ready. Your move. 👀',
    'Think you can master the arrows? Prove it! 🔥',
    'Just a few minutes of puzzle time. Ready for the challenge?',
    'New day, new challenge. How sharp are you today? 🧠',
    "Don't let the arrows wait too long. Come back and play! 🏹",
    'Your next perfect solve could be one tap away. 🎯',
  ];

  /// The message at [index], wrapping around the 15-item pool - so any
  /// non-negative index (including ones far past 15) always resolves
  /// to a valid message.
  static String messageForIndex(int index) => messagePool[index % messagePool.length];

  bool get isInitialized => _initialized;

  /// Sets up the timezone database against the device's real local
  /// timezone and creates the Android notification channel. Safe to
  /// call more than once - later calls are a no-op. Never throws;
  /// returns whether initialization actually succeeded, so callers can
  /// skip scheduling if it didn't.
  Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      tz_data.initializeTimeZones();
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      final ok = await _plugin.initialize(settings: initSettings);

      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              channelId,
              channelName,
              description: channelDescription,
              importance: Importance.defaultImportance,
            ),
          );

      _initialized = ok ?? true;
    } catch (error, stackTrace) {
      _initialized = false;
      debugPrint('NotificationService.initialize failed: $error\n$stackTrace');
    }
    return _initialized;
  }

  /// Requests Android's POST_NOTIFICATIONS permission (a no-op that
  /// returns true on API levels below 33, where no runtime permission
  /// exists). Returns false - never throws - if the platform
  /// implementation is unavailable or the request itself fails.
  Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return true;
      await android.requestNotificationsPermission();
      // Verify against the OS's own record rather than trusting the
      // request call's return value alone: on some devices the request
      // can report success even though the system dialog never actually
      // completed (observed on a physical device when the permission
      // UI process was killed under memory pressure mid-request),
      // leaving the permission not actually granted despite a "true"
      // result. areNotificationsEnabled() reflects the real, current
      // POST_NOTIFICATIONS state, so it's the source of truth here.
      return await android.areNotificationsEnabled() ?? false;
    } catch (error, stackTrace) {
      debugPrint('NotificationService.requestPermission failed: $error\n$stackTrace');
      return false;
    }
  }

  /// Cancels any existing Tuesday/Saturday schedule and recreates both
  /// from [startIndex] in the message pool - Tuesday gets
  /// `messageForIndex(startIndex)`, Saturday gets the next message
  /// after it, so the two never show the same text in one pass.
  ///
  /// Idempotent by construction: cancelling by the two fixed IDs
  /// before rescheduling means calling this any number of times
  /// always leaves exactly one Tuesday and one Saturday notification
  /// scheduled, never duplicates.
  ///
  /// Returns the index the caller should persist for the *next* call,
  /// so the pool keeps rotating instead of always starting over.
  Future<int> scheduleNotifications(int startIndex) async {
    await cancelNotifications();
    if (!_initialized && !await initialize()) return startIndex;

    final tuesdayMessage = messageForIndex(startIndex);
    final saturdayMessage = messageForIndex(startIndex + 1);

    await _scheduleWeekly(id: tuesdayNotificationId, weekday: DateTime.tuesday, body: tuesdayMessage);
    await _scheduleWeekly(id: saturdayNotificationId, weekday: DateTime.saturday, body: saturdayMessage);

    return (startIndex + 2) % messagePool.length;
  }

  /// Cancels both the Tuesday and Saturday reminders, if scheduled.
  Future<void> cancelNotifications() async {
    try {
      if (!_initialized && !await initialize()) return;
      await _plugin.cancel(id: tuesdayNotificationId);
      await _plugin.cancel(id: saturdayNotificationId);
    } catch (error, stackTrace) {
      debugPrint('NotificationService.cancelNotifications failed: $error\n$stackTrace');
    }
  }

  Future<void> _scheduleWeekly({required int id, required int weekday, required String body}) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: notificationTitle,
        body: body,
        scheduledDate: _nextInstanceOf(weekday, reminderHour, reminderMinute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        // Weekly reminder, not time-critical - inexact scheduling needs
        // no SCHEDULE_EXACT_ALARM permission and is the Android-
        // recommended mode for this kind of notification.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (error, stackTrace) {
      debugPrint('NotificationService._scheduleWeekly($id) failed: $error\n$stackTrace');
    }
  }

  /// The next moment matching [weekday] (Dart's `DateTime.monday..sunday`
  /// constants) at [hour]:[minute] in the local timezone, strictly
  /// after now - so if today already is that weekday but the time has
  /// passed, this correctly rolls over to next week rather than
  /// scheduling something in the past.
  tz.TZDateTime _nextInstanceOf(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Fires a single one-off notification a few seconds from now, to
  /// manually verify the real Android notification pipeline (channel,
  /// permission, delivery, tap-to-open) on a physical device. Not
  /// wired into any production code path or UI - development use only.
  @visibleForTesting
  Future<void> scheduleDebugTestNotification() async {
    if (!_initialized && !await initialize()) return;
    await _plugin.zonedSchedule(
      id: debugTestNotificationId,
      title: notificationTitle,
      body: messageForIndex(0),
      scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelDebugTestNotification() => _plugin.cancel(id: debugTestNotificationId);
}
