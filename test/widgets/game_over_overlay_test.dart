import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:arrow_escape/services/audio_service.dart';
import 'package:arrow_escape/widgets/game_over_overlay.dart';

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
  testWidgets('Levels 1-25: renders "3 / 3 MISSES" with no overflow', (tester) async {
    await tester.pumpWidget(
      _hostedWith(GameOverOverlay(missCount: 3, missLimit: 3, onTryAgain: () {}, onExit: () {})),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('GAME OVER'), findsOneWidget);
    expect(find.text('Out of allowed misses for this level.'), findsOneWidget);
    expect(find.text('3 / 3 MISSES'), findsOneWidget);
    expect(find.text('TRY AGAIN'), findsOneWidget);
    expect(find.text('EXIT'), findsOneWidget);
  });

  testWidgets('Levels 26-50: renders "5 / 5 MISSES" with no overflow', (tester) async {
    await tester.pumpWidget(
      _hostedWith(GameOverOverlay(missCount: 5, missLimit: 5, onTryAgain: () {}, onExit: () {})),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('5 / 5 MISSES'), findsOneWidget);
  });

  testWidgets('the explanatory sentence and miss badge do not overflow on a small phone width', (tester) async {
    tester.view.physicalSize = const Size(360, 640) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _hostedWith(
        GameOverOverlay(missCount: 5, missLimit: 5, onTryAgain: () {}, onExit: () {}),
        surfaceSize: const Size(360, 640),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Out of allowed misses for this level.'), findsOneWidget);
    expect(find.text('5 / 5 MISSES'), findsOneWidget);
  });

  testWidgets('does not overflow even with a large system font scale', (tester) async {
    // Simulates a device with an enlarged accessibility text size - the
    // overlay clamps its own text scaling internally, so this must
    // still lay out cleanly rather than blowing past the card edges.
    await tester.pumpWidget(
      MultiProvider(
        providers: [Provider<AudioService>(create: (_) => AudioService(player: FakeSoundPlayer()))],
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800), textScaler: TextScaler.linear(3.0)),
            child: GameOverOverlay(missCount: 5, missLimit: 5, onTryAgain: () {}, onExit: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('5 / 5 MISSES'), findsOneWidget);
  });

  testWidgets('TRY AGAIN is accessible and invokes onTryAgain exactly once', (tester) async {
    var tries = 0;
    await tester.pumpWidget(
      _hostedWith(GameOverOverlay(missCount: 3, missLimit: 3, onTryAgain: () => tries++, onExit: () {})),
    );

    await tester.tap(find.text('TRY AGAIN'));
    await tester.pump();

    expect(tries, 1);
  });

  testWidgets('EXIT is accessible and invokes onExit exactly once', (tester) async {
    var exits = 0;
    await tester.pumpWidget(
      _hostedWith(GameOverOverlay(missCount: 3, missLimit: 3, onTryAgain: () {}, onExit: () => exits++)),
    );

    await tester.tap(find.text('EXIT'));
    await tester.pump();

    expect(exits, 1);
  });
}
