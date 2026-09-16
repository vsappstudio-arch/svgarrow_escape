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
    // Same rationale as GameOverOverlay: this is a fixed-chrome modal
    // card, so it must stay legible and non-overflowing regardless of
    // the device's system font-scale setting.
    final clampedScaler = MediaQuery.textScalerOf(context).clamp(minScaleFactor: 1.0, maxScaleFactor: 1.25);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedScaler),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: ConfettiOverlay()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: PremiumCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'LEVEL COMPLETE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 18),
                    StarRow(stars: stars, size: 36, animate: true),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(child: _StatColumn(label: 'MOVES', value: '$moves')),
                        Container(width: 1, height: 32, color: AppColors.border),
                        Flexible(child: _StatColumn(label: 'BEST', value: '$bestMoves')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) => Transform.scale(scale: value, child: child),
                      child: _CoinBadge(coinsAwarded: coinsAwarded),
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
          ),
        ],
      ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

/// The "+N COINS" pill. Width-constrained and shrink-to-fit, same
/// pattern as GameOverOverlay's miss badge, so a large coin reward or
/// a scaled-up system font never pushes it past the card's edges.
class _CoinBadge extends StatelessWidget {
  final int coinsAwarded;

  const _CoinBadge({required this.coinsAwarded});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
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
            const Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 16),
            const SizedBox(width: 6),
            Text(
              '+$coinsAwarded COINS',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: AppColors.gold,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
