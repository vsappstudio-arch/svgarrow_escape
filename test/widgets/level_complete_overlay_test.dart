import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:arrow_escape/services/audio_service.dart';
import 'package:arrow_escape/widgets/level_complete_overlay.dart';
import 'package:arrow_escape/widgets/star_row.dart';

import '../services/fake_sound_player.dart';

/// PremiumButton plays a tap SFX via `context.read<AudioService>()`, so
/// every host needs one in scope - same pattern the other overlay
/// widget tests use.
Widget _hostedWith(Widget child, {Size surfaceSize = const Size(400, 800)}) {
  return MultiProvider(
    providers: [
      Provider<AudioService>(create: (_) => AudioService(player: FakeSoundPlayer())),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: surfaceSize),
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets('renders title, stars, moves, best, and coin reward with no overflow', (tester) async {
    await tester.pumpWidget(
      _hostedWith(LevelCompleteOverlay(
        stars: 2,
        moves: 18,
        bestMoves: 11,
        coinsAwarded: 2,
        hasNextLevel: true,
        onNextLevel: () {},
        onHome: () {},
      )),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('LEVEL COMPLETE'), findsOneWidget);
    expect(find.byType(StarRow), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('MOVES'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('+2 COINS'), findsOneWidget);
    expect(find.text('NEXT LEVEL'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('with no next level, only HOME is shown, styled as the primary action', (tester) async {
    await tester.pumpWidget(
      _hostedWith(LevelCompleteOverlay(
        stars: 3,
        moves: 5,
        bestMoves: 5,
        coinsAwarded: 10,
        hasNextLevel: false,
        onNextLevel: () {},
        onHome: () {},
      )),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('NEXT LEVEL'), findsNothing);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('does not overflow on a small phone width, even with large move/best/coin values', (tester) async {
    tester.view.physicalSize = const Size(360, 640) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _hostedWith(
        LevelCompleteOverlay(
          stars: 1,
          moves: 999,
          bestMoves: 999,
          coinsAwarded: 9999,
          hasNextLevel: true,
          onNextLevel: () {},
          onHome: () {},
        ),
        surfaceSize: const Size(360, 640),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('+9999 COINS'), findsOneWidget);
  });

  testWidgets('does not overflow even with a large system font scale', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [Provider<AudioService>(create: (_) => AudioService(player: FakeSoundPlayer()))],
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800), textScaler: TextScaler.linear(3.0)),
            child: LevelCompleteOverlay(
              stars: 2,
              moves: 18,
              bestMoves: 11,
              coinsAwarded: 2,
              hasNextLevel: true,
              onNextLevel: () {},
              onHome: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('LEVEL COMPLETE'), findsOneWidget);
  });

  testWidgets('NEXT LEVEL is accessible and invokes onNextLevel exactly once', (tester) async {
    var count = 0;
    await tester.pumpWidget(
      _hostedWith(LevelCompleteOverlay(
        stars: 2,
        moves: 18,
        bestMoves: 11,
        coinsAwarded: 2,
        hasNextLevel: true,
        onNextLevel: () => count++,
        onHome: () {},
      )),
    );

    await tester.tap(find.text('NEXT LEVEL'));
    await tester.pump();

    expect(count, 1);
  });

  testWidgets('HOME is accessible and invokes onHome exactly once', (tester) async {
    var count = 0;
    await tester.pumpWidget(
      _hostedWith(LevelCompleteOverlay(
        stars: 2,
        moves: 18,
        bestMoves: 11,
        coinsAwarded: 2,
        hasNextLevel: true,
        onNextLevel: () {},
        onHome: () => count++,
      )),
    );

    await tester.tap(find.text('HOME'));
    await tester.pump();

    expect(count, 1);
  });
}
