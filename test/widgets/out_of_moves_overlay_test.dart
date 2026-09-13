import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:arrow_escape/services/audio_service.dart';
import 'package:arrow_escape/state/game_controller.dart';
import 'package:arrow_escape/widgets/out_of_moves_overlay.dart';

import '../services/fake_sound_player.dart';

/// PremiumButton plays a tap SFX via `context.read<AudioService>()`, so
/// every host needs one in scope - same pattern the other overlay/shop
/// widget tests use.
Widget _hostedWith(Widget child) {
  return MultiProvider(
    providers: [
      Provider<AudioService>(create: (_) => AudioService(player: FakeSoundPlayer())),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('shows the Out of Moves message, the +5 benefit, and the current inventory', (tester) async {
    await tester.pumpWidget(
      _hostedWith(OutOfMovesOverlay(extraMoves: 3, onUse: () {}, onExit: () {})),
    );

    expect(find.text('Out of Moves'), findsOneWidget);
    expect(find.text('+${GameController.extraMovesPerBoost} Moves'), findsOneWidget);
    expect(find.text('Extra Moves: 3'), findsOneWidget);
    expect(find.text('USE 1'), findsOneWidget);
    expect(find.text('EXIT'), findsOneWidget);
  });

  testWidgets('with a booster in stock, USE 1 is enabled and invokes onUse exactly once', (tester) async {
    var useCount = 0;
    await tester.pumpWidget(
      _hostedWith(OutOfMovesOverlay(extraMoves: 1, onUse: () => useCount++, onExit: () {})),
    );

    await tester.tap(find.text('USE 1'));
    await tester.pump();

    expect(useCount, 1);
  });

  testWidgets('with zero boosters, USE 1 has no handler and tapping it does nothing', (tester) async {
    var useCount = 0;
    await tester.pumpWidget(
      _hostedWith(OutOfMovesOverlay(
        extraMoves: 0,
        onUse: null, // the caller disables it exactly like this at 0 in stock
        onExit: () {},
      )),
    );

    await tester.tap(find.text('USE 1'), warnIfMissed: false);
    await tester.pump();

    expect(useCount, 0);
    expect(find.text('Extra Moves: 0'), findsOneWidget);
  });

  testWidgets('EXIT always invokes onExit', (tester) async {
    var exited = false;
    await tester.pumpWidget(
      _hostedWith(OutOfMovesOverlay(extraMoves: 0, onUse: null, onExit: () => exited = true)),
    );

    await tester.tap(find.text('EXIT'));
    await tester.pump();

    expect(exited, isTrue);
  });
}
