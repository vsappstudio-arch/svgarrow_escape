import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/core/app.dart';

Future<void> _skipSplashAndTutorial(WidgetTester tester) async {
  await tester.pumpWidget(const ArrowEscapeApp());
  await tester.pump(const Duration(milliseconds: 1200));
  await tester.pumpAndSettle();

  expect(find.text('Skip'), findsOneWidget);
  await tester.tap(find.text('Skip'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Splash leads to the tutorial on first launch, which leads home', (WidgetTester tester) async {
    await _skipSplashAndTutorial(tester);

    expect(find.text('Arrow Escape'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('Tapping Levels shows the level map', (WidgetTester tester) async {
    await _skipSplashAndTutorial(tester);

    // The bottom navigation item, not Home's Levels shortcut - the
    // shortcut can sit below the fold on a small test viewport.
    await tester.tap(find.text('Levels').last);
    await tester.pumpAndSettle();

    expect(find.text('World 1'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsWidgets);
  });

  testWidgets('Solving level 1 shows the completion overlay and unlocks level 2', (WidgetTester tester) async {
    await _skipSplashAndTutorial(tester);

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    // Level 1: "a2" (right-facing) must escape first, which then
    // unblocks "a1" (down-facing).
    await tester.tap(find.byKey(const ValueKey('arrow_a2')));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('1 move'), findsOneWidget, reason: 'singular grammar at exactly one move');

    await tester.tap(find.byKey(const ValueKey('arrow_a1')));
    await tester.pump();
    expect(find.text('2 moves'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.text('Level Complete!'), findsOneWidget);
    expect(find.text('+40 coins'), findsOneWidget);

    await tester.tap(find.text('HOME'));
    await tester.pumpAndSettle();

    // The bottom navigation item, not Home's Levels shortcut - the
    // shortcut can sit below the fold on a small test viewport.
    await tester.tap(find.text('Levels').last);
    await tester.pumpAndSettle();

    // Level 2's node now shows its number instead of a lock icon.
    expect(find.text('2'), findsOneWidget);
  });
}
