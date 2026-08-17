import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../game/level_data.dart';
import '../state/progress_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/coin_badge.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/star_row.dart';

class HomeTab extends StatelessWidget {
  final ValueChanged<int> onGoToTab;

  const HomeTab({super.key, required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressController>().progress;
    final totalLevels = LevelData.levels.length;
    final hasStarted = progress.starsByLevel.isNotEmpty;
    final allComplete = progress.unlockedLevel > totalLevels;
    final currentLevelId = progress.unlockedLevel.clamp(1, totalLevels);
    final currentLevel = LevelData.byId(currentLevelId);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryButtonGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text('Arrow Escape', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                CoinBadge(coins: progress.coins),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    allComplete ? 'All levels cleared!' : 'Ready to escape?',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    allComplete
                        ? 'You\'ve mastered every level in World 1.'
                        : 'Clear the grid, one arrow at a time.',
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  PremiumCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  allComplete ? 'World 1 Complete' : currentLevel.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  allComplete
                                      ? 'Revisit any level for a better score'
                                      : 'Difficulty ${currentLevel.difficulty} · ${currentLevel.arrows.length} arrows',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                            if (!allComplete) StarRow(stars: progress.starsByLevel[currentLevelId] ?? 0, size: 18),
                          ],
                        ),
                        const SizedBox(height: 20),
                        PremiumButton(
                          label: allComplete ? 'Play Again' : (hasStarted ? 'Continue' : 'Play'),
                          icon: Icons.play_arrow_rounded,
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.game,
                            arguments: currentLevelId,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.map_rounded,
                          label: 'Levels',
                          onTap: () => onGoToTab(1),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.bar_chart_rounded,
                          label: 'Stats',
                          onTap: () => onGoToTab(3),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.settings_rounded,
                          label: 'Settings',
                          onTap: () => onGoToTab(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
