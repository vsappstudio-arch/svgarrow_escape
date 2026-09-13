import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_escape/services/notification_service.dart';

const _pluginChannel = MethodChannel('dexterous.com/flutter/local_notifications');
const _timezoneChannel = MethodChannel('flutter_timezone');

/// Records every call made to the real flutter_local_notifications
/// platform channel and answers with sensible defaults, so
/// [NotificationService] can be exercised end-to-end (including its
/// own internal timezone/plugin initialization) without a real
/// Android device or plugin implementation.
List<MethodCall> _mockChannels({
  Future<Object?> Function(MethodCall call)? onPluginCall,
}) {
  final calls = <MethodCall>[];
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_pluginChannel, (call) async {
    calls.add(call);
    if (onPluginCall != null) return onPluginCall(call);
    return true;
  });
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_timezoneChannel, (call) async => 'Europe/London');
  return calls;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // In a real app, Flutter's generated plugin registrant calls this for
  // every federated plugin on startup. Plain `flutter test` never runs
  // that registration step, so the platform-interface singleton this
  // package relies on is left unset unless a test does it manually.
  AndroidFlutterLocalNotificationsPlugin.registerWith();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_pluginChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_timezoneChannel, null);
  });

  group('message pool', () {
    test('has exactly the 15 approved messages', () {
      expect(NotificationService.messagePool.length, 15);
      expect(NotificationService.messagePool.first, 'Your next puzzle is waiting. Can you beat your best?');
      expect(NotificationService.messagePool.last, 'Your next perfect solve could be one tap away. 🎯');
    });

    test('never mentions coins, purchases, ads, subscriptions, or rewards', () {
      for (final message in NotificationService.messagePool) {
        final lower = message.toLowerCase();
        expect(lower, isNot(contains('coin')));
        expect(lower, isNot(contains('purchase')));
        expect(lower, isNot(contains('advert')));
        expect(lower, isNot(contains('subscri')));
        expect(lower, isNot(contains('reward')));
        expect(lower, isNot(contains('discount')));
      }
    });

    test('messageForIndex walks the pool in order and wraps 15 back to 1', () {
      for (var i = 0; i < 15; i++) {
        expect(NotificationService.messageForIndex(i), NotificationService.messagePool[i]);
      }
      expect(NotificationService.messageForIndex(15), NotificationService.messagePool[0], reason: 'wraps back to the first message');
      expect(NotificationService.messageForIndex(16), NotificationService.messagePool[1]);
      expect(NotificationService.messageForIndex(29), NotificationService.messagePool[14]);
      expect(NotificationService.messageForIndex(30), NotificationService.messagePool[0], reason: 'wraps a second time too');
    });
  });

  group('notification IDs', () {
    test('Tuesday and Saturday use fixed, distinct IDs', () {
      expect(NotificationService.tuesdayNotificationId, 2001);
      expect(NotificationService.saturdayNotificationId, 2002);
      expect(NotificationService.tuesdayNotificationId, isNot(NotificationService.saturdayNotificationId));
    });
  });

  group('initialize', () {
    test('succeeds and creates the notification channel exactly once', () async {
      final calls = _mockChannels();
      final service = NotificationService();

      expect(await service.initialize(), isTrue);
      expect(service.isInitialized, isTrue);
      expect(calls.where((c) => c.method == 'initialize'), hasLength(1));
      expect(calls.where((c) => c.method == 'createNotificationChannel'), hasLength(1));
    });

    test('calling it again is a cheap no-op, not a second setup', () async {
      final calls = _mockChannels();
      final service = NotificationService();

      await service.initialize();
      await service.initialize();

      expect(calls.where((c) => c.method == 'initialize'), hasLength(1));
    });

    test('a plugin failure is caught and reported as false, never thrown', () async {
      _mockChannels(onPluginCall: (call) async => throw PlatformException(code: 'boom'));
      final service = NotificationService();

      expect(await service.initialize(), isFalse);
      expect(service.isInitialized, isFalse);
    });
  });

  group('requestPermission', () {
    test('returns true when the platform grants it', () async {
      _mockChannels();
      final service = NotificationService();

      expect(await service.requestPermission(), isTrue);
    });

    test('denial is reported as false and handled safely, not thrown', () async {
      // requestNotificationsPermission() itself can report "true" on some
      // devices even when the OS dialog never actually completed - the
      // real source of truth is areNotificationsEnabled(), so that's
      // what determines the result here.
      _mockChannels(
        onPluginCall: (call) async => call.method == 'areNotificationsEnabled' ? false : true,
      );
      final service = NotificationService();

      expect(await service.requestPermission(), isFalse);
    });

    test('a permission-request failure is caught and reported as false', () async {
      _mockChannels(
        onPluginCall: (call) async {
          if (call.method == 'requestNotificationsPermission') throw PlatformException(code: 'boom');
          return true;
        },
      );
      final service = NotificationService();

      expect(await service.requestPermission(), isFalse);
    });
  });

  group('scheduleNotifications', () {
    test('schedules Tuesday and Saturday at exactly 7:00 PM with the ARROWW title', () async {
      final calls = _mockChannels();
      final service = NotificationService();

      await service.scheduleNotifications(0);

      final scheduled = calls.where((c) => c.method == 'zonedSchedule').toList();
      expect(scheduled, hasLength(2));

      final tuesday = scheduled.firstWhere((c) => (c.arguments as Map)['id'] == NotificationService.tuesdayNotificationId);
      final saturday = scheduled.firstWhere((c) => (c.arguments as Map)['id'] == NotificationService.saturdayNotificationId);

      for (final call in [tuesday, saturday]) {
        final args = call.arguments as Map;
        expect(args['title'], 'ARROWW');
        final scheduledAt = DateTime.parse(args['scheduledDateTime'] as String);
        expect(scheduledAt.hour, 19);
        expect(scheduledAt.minute, 0);
        expect(args['matchDateTimeComponents'], DateTimeComponents.dayOfWeekAndTime.index);
      }

      final tuesdayAt = DateTime.parse((tuesday.arguments as Map)['scheduledDateTime'] as String);
      final saturdayAt = DateTime.parse((saturday.arguments as Map)['scheduledDateTime'] as String);
      expect(tuesdayAt.weekday, DateTime.tuesday);
      expect(saturdayAt.weekday, DateTime.saturday);
    });

    test('Tuesday and Saturday get different messages from the pool in the same pass', () async {
      final calls = _mockChannels();
      final service = NotificationService();

      await service.scheduleNotifications(0);

      final scheduled = calls.where((c) => c.method == 'zonedSchedule').toList();
      final bodies = scheduled.map((c) => (c.arguments as Map)['body']).toSet();
      expect(bodies, hasLength(2), reason: 'the same message should not be repeated when avoidable');
      expect(bodies, {NotificationService.messageForIndex(0), NotificationService.messageForIndex(1)});
    });

    test('advances the rotation by 2 and reports the next start index', () async {
      _mockChannels();
      final service = NotificationService();

      expect(await service.scheduleNotifications(0), 2);
      expect(await service.scheduleNotifications(13), 0, reason: '13 + 2 == 15, which wraps back to 0');
    });

    test('is idempotent: repeated calls always cancel first, never accumulating duplicate schedules', () async {
      final calls = _mockChannels();
      final service = NotificationService();

      await service.scheduleNotifications(0);
      await service.scheduleNotifications(2);
      await service.scheduleNotifications(4);

      final cancelledIds = calls.where((c) => c.method == 'cancel').map((c) => (c.arguments as Map)['id']).toList();
      // Every one of the 3 calls cancels both IDs before recreating them,
      // so the net result is always exactly one Tuesday + one Saturday
      // schedule - never a growing pile of duplicates.
      expect(cancelledIds, [2001, 2002, 2001, 2002, 2001, 2002]);
      expect(calls.where((c) => c.method == 'zonedSchedule'), hasLength(6));
    });

    test('an initialization failure leaves the start index unchanged instead of scheduling anything', () async {
      _mockChannels(onPluginCall: (call) async => throw PlatformException(code: 'boom'));
      final service = NotificationService();

      expect(await service.scheduleNotifications(3), 3);
    });
  });

  group('cancelNotifications', () {
    test('cancels both the Tuesday and Saturday IDs', () async {
      final calls = _mockChannels();
      final service = NotificationService();

      await service.cancelNotifications();

      final cancelledIds = calls.where((c) => c.method == 'cancel').map((c) => (c.arguments as Map)['id']).toSet();
      expect(cancelledIds, {2001, 2002});
    });

    test('a cancellation failure is caught, not thrown', () async {
      _mockChannels(onPluginCall: (call) async => throw PlatformException(code: 'boom'));
      final service = NotificationService();

      await expectLater(service.cancelNotifications(), completes);
    });
  });
}
