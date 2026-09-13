import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../game/level_data.dart';
import '../models/level_model.dart';
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
    final progressController = context.watch<ProgressController>();
    final progress = progressController.progress;
    final totalLevels = LevelData.levels.length;
    final hasStarted = progress.starsByLevel.isNotEmpty;
    final allComplete = progress.unlockedLevel > totalLevels;
    final currentLevelId = progress.unlockedLevel.clamp(1, totalLevels);
    final currentLevel = LevelData.byId(currentLevelId);

    // The level just finished, above the level to play now, above the
    // one still locked - so Home answers "what did I just finish, what
    // now, and what comes next" without opening the map. Only the one
    // most recent completion is shown; the rest of the cleared run
    // lives on the Levels screen.
    final lastCompletedId = allComplete ? totalLevels - 1 : currentLevelId - 1;
    final showLastCompleted = lastCompletedId >= 1 && progressController.isCompleted(lastCompletedId);
    // Once the world is cleared there is no Level 51 to look forward
    // to, so the run closes on Level 50 itself.
    final upNextId = allComplete ? totalLevels : currentLevelId + 1;
    final showUpNext = upNextId <= totalLevels;

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
                  if (showLastCompleted) ...[
                    _ProgressionRow(
                      level: LevelData.byId(lastCompletedId),
                      stars: progress.starsByLevel[lastCompletedId] ?? 0,
                      icon: Icons.check_circle_rounded,
                      label: 'Completed',
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 10),
                  ],
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
                  if (showUpNext) ...[
                    const SizedBox(height: 10),
                    _ProgressionRow(
                      level: LevelData.byId(upNextId),
                      stars: allComplete ? (progress.starsByLevel[upNextId] ?? 0) : 0,
                      icon: allComplete ? Icons.check_circle_rounded : Icons.lock_rounded,
                      label: allComplete ? 'Completed' : 'Locked',
                      color: allComplete ? AppColors.success : AppColors.textDisabled,
                      dimmed: !allComplete,
                    ),
                  ],
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

/// One quiet line of context around the level the player is on: the
/// level just finished above it, the level still locked below it. Kept
/// deliberately smaller and calmer than the Continue card so the eye
/// still lands on what to play now.
class _ProgressionRow extends StatelessWidget {
  final LevelModel level;
  final int stars;
  final IconData icon;
  final String label;
  final Color color;
  final bool dimmed;

  const _ProgressionRow({
    required this.level,
    required this.stars,
    required this.icon,
    required this.label,
    required this.color,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              level.name,
              style: TextStyle(
                color: dimmed ? AppColors.textDisabled : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (stars > 0) ...[
            StarRow(stars: stars, size: 13),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
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
