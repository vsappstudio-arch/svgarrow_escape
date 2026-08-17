import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'confetti_overlay.dart';
import 'premium_button.dart';
import 'premium_card.dart';
import 'star_row.dart';

class LevelCompleteOverlay extends StatelessWidget {
  final int stars;
  final int moves;
  final int bestMoves;
  final int coinsAwarded;
  final bool hasNextLevel;
  final VoidCallback onNextLevel;
  final VoidCallback onHome;

  const LevelCompleteOverlay({
    super.key,
    required this.stars,
    required this.moves,
    required this.bestMoves,
    required this.coinsAwarded,
    required this.hasNextLevel,
    required this.onNextLevel,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Positioned.fill(child: ConfettiOverlay()),
        Padding(
          padding: const EdgeInsets.all(28),
          child: PremiumCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Level Complete!', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 18),
                StarRow(stars: stars, size: 38, animate: true),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatColumn(label: 'Moves', value: '$moves'),
                    Container(width: 1, height: 32, color: AppColors.border),
                    _StatColumn(label: 'Best', value: '$bestMoves'),
                  ],
                ),
                const SizedBox(height: 20),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) => Transform.scale(scale: value, child: child),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '+$coinsAwarded coins',
                            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                if (hasNextLevel) ...[
                  PremiumButton(label: 'NEXT LEVEL', icon: Icons.arrow_forward_rounded, onPressed: onNextLevel),
                  const SizedBox(height: 12),
                ],
                PremiumButton(
                  label: 'HOME',
                  icon: Icons.home_rounded,
                  style: hasNextLevel ? PremiumButtonStyle.secondary : PremiumButtonStyle.primary,
                  onPressed: onHome,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
