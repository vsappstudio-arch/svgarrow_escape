import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_escape/screens/about_screen.dart';

void main() {
  testWidgets('does not mention the removed ads/billing simulation, but still mentions ratings', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));

    expect(find.textContaining('ads'), findsNothing);
    expect(find.textContaining('billing'), findsNothing);
    expect(find.textContaining('ratings'), findsOneWidget);
    expect(find.text('ARROWW'), findsOneWidget);
  });

  testWidgets('does not describe the release as a prototype', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));

    expect(find.textContaining('prototype'), findsNothing);
  });
}
