import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/game/level_data.dart';
import 'package:arrow_escape/screens/level_map_tab.dart';
import 'package:arrow_escape/state/progress_controller.dart';

/// Builds the Levels screen against a controller holding [progress
/// through] levels 1..[completedThrough], the way a real player's
/// saved progression would look.
Future<ProgressController> _controllerCompletedThrough(int completedThrough) async {
  final controller = ProgressController();
  await controller.load();
  for (var id = 1; id <= completedThrough; id++) {
    await controller.completeLevel(id, 3, LevelData.byId(id).optimalMoves);
  }
  return controller;
}

Future<void> _pumpLevelMap(WidgetTester tester, ProgressController controller) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<ProgressController>.value(
      value: controller,
      child: MaterialApp(
        home: const Scaffold(body: LevelMapTab()),
        // Stands in for GameScreen so a tapped node's navigation can be
        // observed without booting the whole gameplay stack.
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          builder: (_) => Scaffold(body: Text('playing ${settings.arguments}')),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('a fresh player sees level 1 to play and level 2 locked', (tester) async {
    final controller = await _controllerCompletedThrough(0);

    await _pumpLevelMap(tester, controller);

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('Completed'), findsNothing, reason: 'nothing has been completed yet');
    expect(find.text('Locked'), findsWidgets);
  });

  testWidgets('after level 1 it reads completed, with level 2 to play', (tester) async {
    final controller = await _controllerCompletedThrough(1);

    await _pumpLevelMap(tester, controller);

    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('Level 2'), findsOneWidget);
    expect(find.text('Locked'), findsWidgets);
  });

  testWidgets('mid-game the path opens on the completed/current/locked trio', (tester) async {
    final controller = await _controllerCompletedThrough(33);

    await _pumpLevelMap(tester, controller);

    // Without needing to scroll 33 nodes down, the player can see what
    // they just finished, what to play, and what comes next.
    expect(find.text('Level 33'), findsOneWidget);
    expect(find.text('Level 34'), findsOneWidget);
    expect(find.text('Level 35'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Locked'), findsWidgets);
  });

  testWidgets('the final level is playable and no level 51 is invented', (tester) async {
    final controller = await _controllerCompletedThrough(49);

    await _pumpLevelMap(tester, controller);

    expect(find.text('Level 50'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('Level 51'), findsNothing);
  });

  testWidgets('with every level cleared nothing is current and nothing is locked', (tester) async {
    final controller = await _controllerCompletedThrough(50);

    await _pumpLevelMap(tester, controller);

    expect(find.text('Level 50'), findsOneWidget);
    expect(find.text('Level 51'), findsNothing);
    expect(find.text('PLAY'), findsNothing);
    expect(find.text('Locked'), findsNothing);
    expect(find.text('Completed'), findsWidgets);
  });

  testWidgets('tapping a completed level still opens it for a replay', (tester) async {
    final controller = await _controllerCompletedThrough(3);

    await _pumpLevelMap(tester, controller);

    await tester.tap(find.text('Level 3'));
    await tester.pumpAndSettle();

    // Completed levels stay replayable, as they were before.
    expect(find.text('playing 3'), findsOneWidget);
  });

  testWidgets('tapping a locked level goes nowhere', (tester) async {
    final controller = await _controllerCompletedThrough(0);

    await _pumpLevelMap(tester, controller);

    await tester.tap(find.text('Level 2'));
    await tester.pumpAndSettle();

    expect(find.text('playing 2'), findsNothing);
    expect(find.text('World 1'), findsOneWidget);
  });
}
