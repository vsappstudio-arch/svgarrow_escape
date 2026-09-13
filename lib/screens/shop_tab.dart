import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/player_progress.dart';
import '../services/audio_service.dart';
import '../state/progress_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/coin_badge.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';

class ShopTab extends StatefulWidget {
  const ShopTab({super.key});

  @override
  State<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
  Future<void> _buy(String label, int cost, PlayerProgress Function(PlayerProgress current) apply) async {
    final progressController = context.read<ProgressController>();
    final ok = await progressController.spendCoins(cost, apply);
    if (!mounted) return;
    // Only a purchase that actually went through is worth celebrating:
    // spendCoins returns false when the player can't afford it, and
    // then nothing but the existing snack bar happens.
    if (ok) context.read<AudioService>().playPurchase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '$label purchased!' : 'Not enough coins for $label')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressController>().progress;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shop', style: Theme.of(context).textTheme.headlineMedium),
                CoinBadge(coins: progress.coins),
              ],
            ),
          ),
          Expanded(
            child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Spend coins you earn by playing. No real-money purchases.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _ShopSectionLabel('Boosters'),
                    _ShopItemCard(
                      icon: Icons.lightbulb_rounded,
                      color: AppColors.gold,
                      title: 'Hint Pack',
                      subtitle: '+3 hints · you have ${progress.hints}',
                      cost: 50,
                      onBuy: () => _buy('Hint Pack', 50, (p) => p.copyWith(hints: p.hints + 3)),
                    ),
                    const SizedBox(height: 12),
                    _ShopItemCard(
                      icon: Icons.undo_rounded,
                      color: AppColors.success,
                      title: 'Undo Pack',
                      subtitle: '+3 undos · you have ${progress.undos}',
                      cost: 50,
                      onBuy: () => _buy('Undo Pack', 50, (p) => p.copyWith(undos: p.undos + 3)),
                    ),
                    const SizedBox(height: 12),
                    _ShopItemCard(
                      icon: Icons.add_circle_rounded,
                      color: AppColors.primary,
                      title: 'Extra Moves Pack',
                      subtitle: '+5 extra moves · you have ${progress.extraMoves}',
                      cost: 30,
                      onBuy: () => _buy('Extra Moves Pack', 30, (p) => p.copyWith(extraMoves: p.extraMoves + 5)),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}

class _ShopSectionLabel extends StatelessWidget {
  final String text;

  const _ShopSectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(color: AppColors.textDisabled, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8),
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final int cost;
  final VoidCallback onBuy;

  const _ShopItemCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.cost,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          PremiumButton(
            label: '$cost',
            icon: Icons.monetization_on_rounded,
            expand: false,
            onPressed: onBuy,
          ),
        ],
      ),
    );
  }
}
