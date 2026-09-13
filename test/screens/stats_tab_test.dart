import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/game/level_data.dart';
import 'package:arrow_escape/screens/stats_tab.dart';
import 'package:arrow_escape/state/progress_controller.dart';

Future<ProgressController> _freshController() async {
  final controller = ProgressController();
  await controller.load();
  return controller;
}

Future<void> _pumpStats(WidgetTester tester, ProgressController controller) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<ProgressController>.value(
      value: controller,
      child: const MaterialApp(home: Scaffold(body: StatsTab())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('fresh install: zero completed levels shows an empty-state best performance', (tester) async {
    final controller = await _freshController();

    await _pumpStats(tester, controller);

    expect(find.text('0/${LevelData.levels.length}'), findsOneWidget, reason: 'Levels Completed');
    // Total Stars and Total Moves both legitimately read "0" here.
    expect(find.text('0'), findsNWidgets(2), reason: 'Total Stars and Total Moves');
    expect(find.text('0%'), findsOneWidget, reason: 'Completion');
    expect(find.text('Play a level to see your stats!'), findsOneWidget);
  });

  testWidgets('one completed level: every total reflects exactly that level', (tester) async {
    final controller = await _freshController();
    await controller.completeLevel(5, 3, 7);

    await _pumpStats(tester, controller);

    expect(find.text('1/${LevelData.levels.length}'), findsOneWidget, reason: 'Levels Completed');
    expect(find.text('3'), findsOneWidget, reason: 'Total Stars - all 3 come from level 5');
    expect(find.text('7'), findsOneWidget, reason: 'Total Moves - all 7 come from level 5');
    // 1/50 * 100 = 2%, exactly - no rounding ambiguity at this count.
    expect(find.text('2%'), findsOneWidget, reason: 'Completion');
    expect(find.text('Level 5 · 3★ in 7 moves'), findsOneWidget);
  });

  testWidgets('best performance uses singular "move" grammar at exactly 1', (tester) async {
    final controller = await _freshController();
    await controller.completeLevel(1, 3, 1);

    await _pumpStats(tester, controller);

    expect(find.text('Level 1 · 3★ in 1 move'), findsOneWidget);
    expect(find.text('Level 1 · 3★ in 1 moves'), findsNothing);
  });

  testWidgets('multiple completed levels: totals aggregate stars and moves across all of them', (tester) async {
    final controller = await _freshController();
    await controller.completeLevel(1, 2, 4);
    await controller.completeLevel(2, 3, 6);
    await controller.completeLevel(3, 1, 9);

    await _pumpStats(tester, controller);

    expect(find.text('3/${LevelData.levels.length}'), findsOneWidget, reason: 'Levels Completed');
    expect(find.text('6'), findsOneWidget, reason: 'Total Stars: 2+3+1');
    expect(find.text('19'), findsOneWidget, reason: 'Total Moves: 4+6+9');
    // 3/50 * 100 = 6%.
    expect(find.text('6%'), findsOneWidget, reason: 'Completion');
  });

  testWidgets('best performance picks the highest star count, regardless of completion order', (tester) async {
    final controller = await _freshController();
    await controller.completeLevel(1, 2, 5); // 2 stars
    await controller.completeLevel(2, 3, 5); // 3 stars - the best
    await controller.completeLevel(3, 1, 5); // 1 star

    await _pumpStats(tester, controller);

    expect(find.text('Level 2 · 3★ in 5 moves'), findsOneWidget);
  });

  testWidgets('best performance tie-break: equal stars is broken by fewer moves', (tester) async {
    final controller = await _freshController();
    await controller.completeLevel(1, 3, 10); // 3 stars, 10 moves
    await controller.completeLevel(2, 3, 4); // 3 stars, 4 moves - fewer moves wins the tie

    await _pumpStats(tester, controller);

    expect(find.text('Level 2 · 3★ in 4 moves'), findsOneWidget);
  });

  testWidgets('best performance tie-break: equal stars and equal moves keeps the first-completed level', (tester) async {
    final controller = await _freshController();
    await controller.completeLevel(1, 3, 5); // completed first
    await controller.completeLevel(2, 3, 5); // identical result, completed second

    await _pumpStats(tester, controller);

    expect(find.text('Level 1 · 3★ in 5 moves'), findsOneWidget);
  });

  testWidgets('a player who has completed all 50 levels reads 100% and a full completed count', (tester) async {
    final controller = await _freshController();
    for (var id = 1; id <= LevelData.levels.length; id++) {
      await controller.completeLevel(id, 3, LevelData.byId(id).optimalMoves);
    }

    await _pumpStats(tester, controller);

    expect(find.text('${LevelData.levels.length}/${LevelData.levels.length}'), findsOneWidget, reason: 'Levels Completed');
    expect(find.text('100%'), findsOneWidget, reason: 'Completion');
  });

  testWidgets('replaying an already-completed level does not duplicate its contribution to the totals', (tester) async {
    final controller = await _freshController();
    await controller.completeLevel(4, 2, 12);
    final levelsCompletedAfterFirstPlay = controller.progress.starsByLevel.length;

    // Replay the same level with a better result.
    await controller.completeLevel(4, 3, 6);

    await _pumpStats(tester, controller);

    expect(controller.progress.starsByLevel.length, levelsCompletedAfterFirstPlay, reason: 'still one entry, not two');
    expect(find.text('1/${LevelData.levels.length}'), findsOneWidget, reason: 'Levels Completed stays at 1, not 2');
    expect(find.text('3'), findsOneWidget, reason: 'Total Stars reflects only the improved 3-star result, not 2+3');
    expect(find.text('6'), findsOneWidget, reason: 'Total Moves reflects only the improved 6-move result, not 12+6');
    expect(find.text('Level 4 · 3★ in 6 moves'), findsOneWidget);
  });
}
