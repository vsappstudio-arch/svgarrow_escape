import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/game/level_data.dart';
import 'package:arrow_escape/screens/home_tab.dart';
import 'package:arrow_escape/services/audio_service.dart';
import 'package:arrow_escape/state/progress_controller.dart';

import '../services/fake_sound_player.dart';

/// A controller holding real saved progression through
/// levels 1..[completedThrough].
Future<ProgressController> _controllerCompletedThrough(int completedThrough) async {
  final controller = ProgressController();
  await controller.load();
  for (var id = 1; id <= completedThrough; id++) {
    await controller.completeLevel(id, 3, LevelData.byId(id).optimalMoves);
  }
  return controller;
}

Future<void> _pumpHome(WidgetTester tester, ProgressController controller) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProgressController>.value(value: controller),
        Provider<AudioService>.value(value: AudioService(player: FakeSoundPlayer())),
      ],
      child: MaterialApp(
        home: Scaffold(body: HomeTab(onGoToTab: (_) {})),
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

  testWidgets('a fresh player is offered Level 1, with Level 2 locked and nothing completed', (tester) async {
    final controller = await _controllerCompletedThrough(0);

    await _pumpHome(tester, controller);

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Level 2'), findsOneWidget);
    expect(find.text('Locked'), findsOneWidget);
    expect(find.text('Completed'), findsNothing, reason: 'nothing has been finished yet');
  });

  testWidgets('after Level 1: 1 completed, 2 to play, 3 locked', (tester) async {
    final controller = await _controllerCompletedThrough(1);

    await _pumpHome(tester, controller);

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Level 2'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Level 3'), findsOneWidget);
    expect(find.text('Locked'), findsOneWidget);
  });

  testWidgets('only the single most recent completion is shown, not the whole cleared run', (tester) async {
    // 34 levels cleared - the other 33 belong on the Levels screen, not here.
    final controller = await _controllerCompletedThrough(34);

    await _pumpHome(tester, controller);

    expect(find.text('Completed'), findsOneWidget, reason: 'exactly one completed level is shown');
    expect(find.text('Locked'), findsOneWidget, reason: 'exactly one upcoming level is shown');
    expect(find.text('Level 34'), findsOneWidget);
    expect(find.text('Level 35'), findsOneWidget);
    expect(find.text('Level 36'), findsOneWidget);
    expect(find.text('Level 33'), findsNothing, reason: 'older completions are not listed here');
  });

  testWidgets('the trio follows saved progression rather than fixed levels', (tester) async {
    for (final cleared in [1, 20, 34, 48]) {
      final controller = await _controllerCompletedThrough(cleared);
      await _pumpHome(tester, controller);

      expect(find.text('Level $cleared'), findsOneWidget, reason: 'after $cleared: just finished');
      expect(find.text('Level ${cleared + 1}'), findsOneWidget, reason: 'after $cleared: play now');
      expect(find.text('Level ${cleared + 2}'), findsOneWidget, reason: 'after $cleared: up next');
      expect(find.text('Completed'), findsOneWidget, reason: 'after $cleared');
      expect(find.text('Locked'), findsOneWidget, reason: 'after $cleared');
    }
  });

  testWidgets('after Level 49 the final level is current and no Level 51 is invented', (tester) async {
    final controller = await _controllerCompletedThrough(49);

    await _pumpHome(tester, controller);

    expect(find.text('Level 49'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Level 50'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Level 51'), findsNothing);
    expect(find.text('Locked'), findsNothing, reason: 'there is nothing after Level 50 to lock');
  });

  testWidgets('after Level 50 the run closes on 49 and 50, both completed', (tester) async {
    final controller = await _controllerCompletedThrough(50);

    await _pumpHome(tester, controller);

    expect(find.text('Level 49'), findsOneWidget);
    expect(find.text('Level 50'), findsOneWidget);
    expect(find.text('Completed'), findsNWidgets(2));
    expect(find.text('Level 51'), findsNothing);
    expect(find.text('Locked'), findsNothing);
    expect(find.text('World 1 Complete'), findsOneWidget);
  });

  testWidgets('replaying an old level does not move the trio backwards', (tester) async {
    final controller = await _controllerCompletedThrough(34);

    // Replaying level 5 still pays out, but progression stays put.
    await controller.completeLevel(5, 2, LevelData.byId(5).optimalMoves + 3);
    await _pumpHome(tester, controller);

    expect(find.text('Level 34'), findsOneWidget);
    expect(find.text('Level 35'), findsOneWidget);
    expect(find.text('Level 36'), findsOneWidget);
    expect(find.text('Level 5'), findsNothing);
    expect(controller.progress.unlockedLevel, 35, reason: 'saved progression is untouched');
  });

  testWidgets('Continue still starts the current level', (tester) async {
    final controller = await _controllerCompletedThrough(34);

    await _pumpHome(tester, controller);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('playing 35'), findsOneWidget);
  });
}
