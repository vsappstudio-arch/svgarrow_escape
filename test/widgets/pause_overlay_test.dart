import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/state/settings_controller.dart';
import 'package:arrow_escape/widgets/pause_overlay.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // Regression test for a physical-device crash: PauseOverlay is shown
  // via showGeneralDialog, which inserts its widget straight into the
  // Navigator's overlay rather than under the calling screen's
  // Scaffold. Its SwitchListTile then had no Material ancestor to find,
  // throwing "No Material widget found. ListTile widgets require a
  // Material widget ancestor." This reproduces that exact placement -
  // PauseOverlay as `home`, with no surrounding Scaffold - to prove the
  // fix holds.
  testWidgets('PauseOverlay renders without a Material ancestor and its Sound switch works',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsController()..ensureLoaded(),
        child: MaterialApp(
          home: PauseOverlay(
            onResume: () {},
            onRestart: () {},
            onLevels: () {},
            onHome: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Paused'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
