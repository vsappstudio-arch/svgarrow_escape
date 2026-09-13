import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_escape/models/player_progress.dart';
import 'package:arrow_escape/screens/shop_tab.dart';
import 'package:arrow_escape/services/audio_service.dart';
import 'package:arrow_escape/state/progress_controller.dart';
import 'package:arrow_escape/storage/game_storage.dart';
import 'package:arrow_escape/widgets/premium_button.dart';

import '../services/fake_sound_player.dart';

Future<ProgressController> _controllerWithCoins(int coins) async {
  final storage = GameStorage();
  await storage.saveProgress(PlayerProgress(coins: coins));
  final controller = ProgressController(storage: storage);
  await controller.load();
  return controller;
}

Future<void> _pumpShop(WidgetTester tester, ProgressController progress, AudioService audio) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProgressController>.value(value: progress),
        Provider<AudioService>.value(value: audio),
      ],
      child: const MaterialApp(home: Scaffold(body: ShopTab())),
    ),
  );
  await tester.pumpAndSettle();
}

/// The buy button for an item of this price - not the coin badge,
/// which shows a bare number too and can read the same after a
/// purchase changes the balance.
Finder _buyButton(String cost) =>
    find.descendant(of: find.byType(PremiumButton), matching: find.text(cost));

/// Everything the shop played apart from the tap click every button
/// makes - i.e. the purchase confirmation itself.
List<String> _purchaseSounds(FakeSoundPlayer player) =>
    player.playedOnce.where((asset) => asset != 'audio/tap.wav').toList();

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('a purchase the player can afford plays the coin then unlock sound, once each', (tester) async {
    final player = FakeSoundPlayer();
    final progress = await _controllerWithCoins(100);
    await _pumpShop(tester, progress, AudioService(player: player, purchaseGap: Duration.zero));

    await tester.tap(_buyButton('50').first); // Hint Pack
    await tester.pumpAndSettle();

    expect(_purchaseSounds(player), ['audio/coin.wav', 'audio/unlock.wav']);
    expect(find.text('Hint Pack purchased!'), findsOneWidget);
    // The purchase itself still behaves exactly as before.
    expect(progress.progress.coins, 50);
    expect(progress.progress.hints, 6);
  });

  testWidgets('a purchase the player cannot afford stays silent', (tester) async {
    final player = FakeSoundPlayer();
    final progress = await _controllerWithCoins(10);
    await _pumpShop(tester, progress, AudioService(player: player, purchaseGap: Duration.zero));

    await tester.tap(_buyButton('50').first);
    await tester.pumpAndSettle();

    expect(_purchaseSounds(player), isEmpty, reason: 'a refused purchase is not a purchase');
    expect(find.text('Not enough coins for Hint Pack'), findsOneWidget);
    expect(progress.progress.coins, 10, reason: 'nothing was spent');
  });

  testWidgets('the purchase sound respects the Sound setting', (tester) async {
    final player = FakeSoundPlayer();
    final progress = await _controllerWithCoins(100);
    final audio = AudioService(player: player, purchaseGap: Duration.zero)
      ..applySettings(soundEnabled: false);
    await _pumpShop(tester, progress, audio);

    await tester.tap(_buyButton('50').first);
    await tester.pumpAndSettle();

    expect(player.playedOnce, isEmpty);
    expect(progress.progress.coins, 50, reason: 'muting sound does not change the purchase');
  });

  testWidgets('two purchases play the confirmation twice - once each, never doubled', (tester) async {
    final player = FakeSoundPlayer();
    final progress = await _controllerWithCoins(100);
    await _pumpShop(tester, progress, AudioService(player: player, purchaseGap: Duration.zero));

    await tester.tap(_buyButton('50').first); // Hint Pack
    await tester.pumpAndSettle();
    await tester.tap(_buyButton('30').first); // Extra Moves Pack
    await tester.pumpAndSettle();

    expect(_purchaseSounds(player), [
      'audio/coin.wav',
      'audio/unlock.wav',
      'audio/coin.wav',
      'audio/unlock.wav',
    ]);
    expect(progress.progress.coins, 20);
  });

  testWidgets('the third purchase is refused once the coins run out, and is silent', (tester) async {
    final player = FakeSoundPlayer();
    final progress = await _controllerWithCoins(100);
    await _pumpShop(tester, progress, AudioService(player: player, purchaseGap: Duration.zero));

    await tester.tap(_buyButton('50').first); // 100 -> 50
    await tester.pumpAndSettle();
    await tester.tap(_buyButton('50').first); // 50 -> 0
    await tester.pumpAndSettle();
    final soundsAfterTwo = _purchaseSounds(player).length;

    await tester.tap(_buyButton('50').first); // refused
    await tester.pumpAndSettle();

    expect(_purchaseSounds(player).length, soundsAfterTwo, reason: 'the refused purchase added no sound');
    expect(progress.progress.coins, 0);
  });

  group('offline', () {
    // These purchases never touch a network - there's no
    // ConnectivityService involved in the shop at all any more, so a
    // single pump (not pumpAndSettle waiting out a connectivity
    // check) is enough to see the fully-populated shop.
    testWidgets('the shop renders its items on the very first frame, with no connectivity check pending', (tester) async {
      final player = FakeSoundPlayer();
      final progress = await _controllerWithCoins(100);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProgressController>.value(value: progress),
            Provider<AudioService>.value(value: AudioService(player: player, purchaseGap: Duration.zero)),
          ],
          child: const MaterialApp(home: Scaffold(body: ShopTab())),
        ),
      );
      await tester.pump();

      expect(find.text('Hint Pack'), findsOneWidget);
      expect(find.text('Undo Pack'), findsOneWidget);
      expect(find.text('Extra Moves Pack'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Offline'), findsNothing);
    });

    testWidgets('Hint purchase works with no internet available', (tester) async {
      final player = FakeSoundPlayer();
      final progress = await _controllerWithCoins(100);
      await _pumpShop(tester, progress, AudioService(player: player, purchaseGap: Duration.zero));

      await tester.tap(_buyButton('50').first); // Hint Pack
      await tester.pumpAndSettle();

      expect(progress.progress.coins, 50);
      expect(progress.progress.hints, 6);
      expect(_purchaseSounds(player), isNotEmpty);
    });

    testWidgets('Undo purchase works with no internet available', (tester) async {
      final player = FakeSoundPlayer();
      final progress = await _controllerWithCoins(100);
      await _pumpShop(tester, progress, AudioService(player: player, purchaseGap: Duration.zero));

      await tester.tap(_buyButton('50').last); // Undo Pack
      await tester.pumpAndSettle();

      expect(progress.progress.coins, 50);
      expect(progress.progress.undos, 6);
      expect(_purchaseSounds(player), isNotEmpty);
    });

    testWidgets('Extra Moves purchase works with no internet available', (tester) async {
      final player = FakeSoundPlayer();
      final progress = await _controllerWithCoins(100);
      await _pumpShop(tester, progress, AudioService(player: player, purchaseGap: Duration.zero));

      await tester.tap(_buyButton('30').first); // Extra Moves Pack
      await tester.pumpAndSettle();

      expect(progress.progress.coins, 70);
      expect(progress.progress.extraMoves, 5);
      expect(_purchaseSounds(player), isNotEmpty);
    });

    testWidgets('leaving and reopening the shop still shows every item, offline', (tester) async {
      final player = FakeSoundPlayer();
      final progress = await _controllerWithCoins(100);
      final audio = AudioService(player: player, purchaseGap: Duration.zero);

      await _pumpShop(tester, progress, audio);
      expect(find.text('Extra Moves Pack'), findsOneWidget);

      // "Leave": unmount the shop entirely.
      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      // "Reopen": a fresh ShopTab, same progress controller.
      await _pumpShop(tester, progress, audio);
      expect(find.text('Hint Pack'), findsOneWidget);
      expect(find.text('Undo Pack'), findsOneWidget);
      expect(find.text('Extra Moves Pack'), findsOneWidget);
    });
  });
}
