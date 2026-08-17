import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../models/player_progress.dart';
import '../services/connectivity_service.dart';
import '../state/progress_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/coin_badge.dart';
import '../widgets/offline_state_content.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';

enum _ConnCheck { checking, online, offline }

class ShopTab extends StatefulWidget {
  const ShopTab({super.key});

  @override
  State<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
  final _connectivity = ConnectivityService();
  _ConnCheck _conn = _ConnCheck.checking;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() => _conn = _ConnCheck.checking);
    final online = await _connectivity.hasConnection();
    if (!mounted) return;
    setState(() => _conn = online ? _ConnCheck.online : _ConnCheck.offline);
  }

  void _buy(String label, int cost, PlayerProgress Function(PlayerProgress current) apply) {
    final progressController = context.read<ProgressController>();
    final ok = progressController.spendCoins(cost, apply);
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
            child: switch (_conn) {
              _ConnCheck.checking => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              _ConnCheck.offline => OfflineStateContent(onRetry: _check),
              _ConnCheck.online => ListView(
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
                              'Prototype store — all purchases are simulated. No real payments.',
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
                    const SizedBox(height: 24),
                    const _ShopSectionLabel('Premium'),
                    PremiumCard(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.removeAds),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.block_rounded, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  progress.removeAdsPurchased ? 'Ads Removed ✓' : 'Remove Ads',
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                const Text('Simulated purchase', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
            },
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
