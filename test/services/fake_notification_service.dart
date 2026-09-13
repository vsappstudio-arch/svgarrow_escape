import 'package:arrow_escape/services/notification_service.dart';

/// Records every call [SettingsController] makes into the notification
/// service, without touching any real platform channel - lets
/// SettingsController's permission/scheduling orchestration be tested
/// in plain `flutter test`, no device or plugin required.
class FakeNotificationService extends NotificationService {
  bool initializeResult = true;
  bool permissionResult = true;

  final List<String> calls = [];
  int? lastScheduleStartIndex;

  @override
  Future<bool> initialize() async {
    calls.add('initialize');
    return initializeResult;
  }

  @override
  Future<bool> requestPermission() async {
    calls.add('requestPermission');
    return permissionResult;
  }

  @override
  Future<int> scheduleNotifications(int startIndex) async {
    calls.add('scheduleNotifications');
    lastScheduleStartIndex = startIndex;
    return (startIndex + 2) % NotificationService.messagePool.length;
  }

  @override
  Future<void> cancelNotifications() async {
    calls.add('cancelNotifications');
  }
}
