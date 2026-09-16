import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'premium_button.dart';
import 'premium_card.dart';

/// Shown when the player has made [missLimit] incorrect taps on this
/// attempt - the "Game Over" state. Unlike [OutOfMovesOverlay] this
/// can't be rescued with a booster; the only way forward is Try Again,
/// which restarts this same level from its initial state (board and
/// miss count both reset) without touching progress on any level.
class GameOverOverlay extends StatelessWidget {
  final int missCount;
  final int missLimit;
  final VoidCallback onTryAgain;
  final VoidCallback onExit;

  const GameOverOverlay({
    super.key,
    required this.missCount,
    required this.missLimit,
    required this.onTryAgain,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    // Fixed-chrome UI (a modal card with a pill-shaped stat badge)
    // must not reflow around the device's system font-scale setting -
    // a large accessibility text size is exactly what turns "Out of
    // allowed misses for this level." into oversized, awkwardly
    // wrapped text and pushes the miss badge past the card edge.
    // Clamping here keeps every string in this overlay legible without
    // ever overflowing, while still respecting *some* user scaling.
    final clampedScaler = MediaQuery.textScalerOf(context).clamp(minScaleFactor: 1.0, maxScaleFactor: 1.25);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedScaler),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: PremiumCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'GAME OVER',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColors.textPrimary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Out of allowed misses for this level.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _MissBadge(missCount: missCount, missLimit: missLimit),
                  const SizedBox(height: 24),
                  PremiumButton(label: 'TRY AGAIN', icon: Icons.refresh_rounded, onPressed: onTryAgain),
                  const SizedBox(height: 12),
                  PremiumButton(
                    label: 'EXIT',
                    icon: Icons.logout_rounded,
                    style: PremiumButtonStyle.secondary,
                    onPressed: onExit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The "N / N MISSES" pill. Width-constrained and shrink-to-fit so it
/// can never push past the card's edges, no matter the device's font
/// scale or the digit count (a two-digit miss count still fits).
class _MissBadge extends StatelessWidget {
  final int missCount;
  final int missLimit;

  const _MissBadge({required this.missCount, required this.missLimit});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.close_rounded, color: AppColors.danger, size: 16),
            const SizedBox(width: 6),
            Text(
              '$missCount / $missLimit MISSES',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: AppColors.danger,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
