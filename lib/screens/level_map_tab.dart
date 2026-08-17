import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../game/level_data.dart';
import '../models/level_model.dart';
import '../state/progress_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/coin_badge.dart';
import '../widgets/star_row.dart';

/// A polished, node-based progression path for World 1 rather than a
/// plain list — completed, current, unlocked, and locked levels are
/// all visually distinct.
class LevelMapTab extends StatelessWidget {
  const LevelMapTab({super.key});

  @override
  Widget build(BuildContext context) {
    final progressController = context.watch<ProgressController>();
    final progress = progressController.progress;
    final levels = LevelData.levels;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('World 1', style: Theme.of(context).textTheme.headlineMedium),
                CoinBadge(coins: progress.coins),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                final unlocked = progressController.isUnlocked(level.id);
                final stars = progressController.starsFor(level.id);
                final isCurrent = unlocked && stars == 0 && level.id == progress.unlockedLevel;
                final align = index.isEven ? -0.55 : 0.55;

                return Column(
                  children: [
                    if (index > 0)
                      Container(
                        width: 3,
                        height: 36,
                        color: AppColors.border,
                      ),
                    Align(
                      alignment: Alignment(align, 0),
                      child: _LevelNode(
                        level: level,
                        unlocked: unlocked,
                        stars: stars,
                        isCurrent: isCurrent,
                        onTap: unlocked
                            ? () => Navigator.pushNamed(context, AppRoutes.game, arguments: level.id)
                            : null,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  final LevelModel level;
  final bool unlocked;
  final int stars;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _LevelNode({
    required this.level,
    required this.unlocked,
    required this.stars,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: !unlocked
                    ? null
                    : (isCurrent ? AppColors.primaryButtonGradient : AppColors.cardGradient),
                color: unlocked ? null : AppColors.surfaceLow,
                border: Border.all(
                  color: isCurrent ? AppColors.primary : AppColors.border,
                  width: isCurrent ? 3 : 1.5,
                ),
                boxShadow: isCurrent
                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)]
                    : null,
              ),
              child: Center(
                child: unlocked
                    ? Text(
                        '${level.id}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : const Icon(Icons.lock_rounded, color: AppColors.textDisabled, size: 26),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              level.name,
              style: TextStyle(
                color: unlocked ? AppColors.textPrimary : AppColors.textDisabled,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            unlocked ? StarRow(stars: stars, size: 14) : const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
