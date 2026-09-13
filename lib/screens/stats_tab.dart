import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/level_data.dart';
import '../state/progress_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_card.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressController>().progress;
    final totalLevels = LevelData.levels.length;
    final levelsCompleted = progress.starsByLevel.length;
    final totalStars = progress.starsByLevel.values.fold<int>(0, (sum, s) => sum + s);
    final completionPercent = totalLevels == 0 ? 0 : ((levelsCompleted / totalLevels) * 100).round();
    final totalMoves = progress.bestMovesByLevel.values.fold<int>(0, (sum, m) => sum + m);

    int? bestLevelId;
    if (progress.starsByLevel.isNotEmpty) {
      bestLevelId = progress.starsByLevel.keys.reduce((a, b) {
        final starsA = progress.starsByLevel[a]!;
        final starsB = progress.starsByLevel[b]!;
        if (starsA != starsB) return starsA > starsB ? a : b;
        final movesA = progress.bestMovesByLevel[a] ?? 999;
        final movesB = progress.bestMovesByLevel[b] ?? 999;
        return movesA <= movesB ? a : b;
      });
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Stats', style: Theme.of(context).textTheme.headlineMedium),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(child: _StatCard(icon: Icons.flag_rounded, label: 'Levels Completed', value: '$levelsCompleted/$totalLevels')),
                    const SizedBox(width: 14),
                    Expanded(child: _StatCard(icon: Icons.star_rounded, label: 'Total Stars', value: '$totalStars', accent: AppColors.gold)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _StatCard(icon: Icons.percent_rounded, label: 'Completion', value: '$completionPercent%')),
                    const SizedBox(width: 14),
                    Expanded(child: _StatCard(icon: Icons.swap_horiz_rounded, label: 'Total Moves', value: '$totalMoves')),
                  ],
                ),
                const SizedBox(height: 14),
                PremiumCard(
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Best Performance', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              bestLevelId == null
                                  ? 'Play a level to see your stats!'
                                  : '${LevelData.byId(bestLevelId).name} · ${progress.starsByLevel[bestLevelId]}★ in ${_moveLabel(progress.bestMovesByLevel[bestLevelId]!)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "1 move" / "2 moves" — matches the singular/plural handling already
/// used for the in-game move counter.
String _moveLabel(int moves) => moves == 1 ? '1 move' : '$moves moves';

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _StatCard({required this.icon, required this.label, required this.value, this.accent = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
