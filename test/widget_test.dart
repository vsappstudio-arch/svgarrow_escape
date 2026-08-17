import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/core/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches to the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ArrowEscapeApp());
    await tester.pumpAndSettle();

    expect(find.text('Arrow Escape'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('Tapping Play opens the level select screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ArrowEscapeApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    expect(find.text('Select Level'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Locked'), findsWidgets);
  });

  testWidgets('Solving level 1 awards stars and unlocks level 2', (WidgetTester tester) async {
    await tester.pumpWidget(const ArrowEscapeApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Level 1'));
    await tester.pumpAndSettle();

    // Level 1: the "right"-facing arrow must escape first, which then
    // unblocks the "down"-facing arrow.
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_downward));
    await tester.pumpAndSettle();

    expect(find.text('Level Complete!'), findsOneWidget);
    expect(find.text('Moves: 2\nStars: 3'), findsOneWidget);

    await tester.tap(find.text('Back to Levels'));
    await tester.pumpAndSettle();

    expect(find.text('Select Level'), findsOneWidget);
    expect(find.text('Stars: 3'), findsOneWidget);
    expect(find.text('Locked'), findsWidgets);
  });
}
