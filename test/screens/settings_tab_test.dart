import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/screens/settings_tab.dart';
import 'package:arrow_escape/state/settings_controller.dart';

import '../services/fake_notification_service.dart';

Future<SettingsController> _pumpSettings(WidgetTester tester, FakeNotificationService notifications) async {
  final controller = SettingsController(notifications: notifications);
  await controller.load();

  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsController>.value(
      value: controller,
      child: const MaterialApp(home: Scaffold(body: SettingsTab())),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

/// The Notifications switch specifically - Settings also has a
/// Haptics switch, so `find.byType(SwitchListTile)` alone is
/// ambiguous between the two.
Finder _notificationsSwitch() => find.ancestor(of: find.text('Notifications'), matching: find.byType(SwitchListTile));

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows a Notifications toggle that is on by default', (tester) async {
    await _pumpSettings(tester, FakeNotificationService());

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Get reminders to come back and play ARROWW.'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(_notificationsSwitch()).value, isTrue);
  });

  testWidgets('turning it off updates the switch and persists the preference', (tester) async {
    final notifications = FakeNotificationService();
    final controller = await _pumpSettings(tester, notifications);

    await tester.tap(_notificationsSwitch());
    await tester.pumpAndSettle();

    expect(controller.notificationsEnabled, isFalse);
    expect(notifications.calls, contains('cancelNotifications'));
    expect(tester.widget<SwitchListTile>(_notificationsSwitch()).value, isFalse);
  });

  testWidgets('turning it back on schedules again and flips the switch back', (tester) async {
    final notifications = FakeNotificationService();
    final controller = await _pumpSettings(tester, notifications);

    await tester.tap(_notificationsSwitch()); // off
    await tester.pumpAndSettle();
    await tester.tap(_notificationsSwitch()); // on again
    await tester.pumpAndSettle();

    expect(controller.notificationsEnabled, isTrue);
    expect(notifications.calls, contains('scheduleNotifications'));
    expect(tester.widget<SwitchListTile>(_notificationsSwitch()).value, isTrue);
  });

  testWidgets('the Haptics toggle is untouched by the new Notifications tile', (tester) async {
    final controller = await _pumpSettings(tester, FakeNotificationService());

    final hapticsSwitch = find.ancestor(of: find.text('Haptics'), matching: find.byType(SwitchListTile));
    expect(hapticsSwitch, findsOneWidget);
    expect(tester.widget<SwitchListTile>(hapticsSwitch).value, isTrue);

    await tester.tap(hapticsSwitch);
    await tester.pumpAndSettle();

    expect(controller.hapticsEnabled, isFalse);
    expect(controller.notificationsEnabled, isTrue, reason: 'toggling Haptics must not affect Notifications');
  });
}
