import 'package:flutter/material.dart';

import '../state/game_controller.dart';
import '../theme/app_colors.dart';
import 'premium_button.dart';
import 'premium_card.dart';

/// Shown when the player has used up the level's move allowance
/// without solving it. Offers to spend one Extra Moves booster
/// (bought in the Shop) for [GameController.extraMovesPerBoost] more
/// moves on this same attempt - board state, prior moves, and score
/// all untouched - or to leave the level.
class OutOfMovesOverlay extends StatelessWidget {
  final int extraMoves;
  final VoidCallback? onUse;
  final VoidCallback onExit;

  const OutOfMovesOverlay({
    super.key,
    required this.extraMoves,
    required this.onUse,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: PremiumCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Out of Moves', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const Text(
                'Need a few more moves?',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '+${GameController.extraMovesPerBoost} Moves',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Extra Moves: $extraMoves',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 22),
              PremiumButton(label: 'USE 1', icon: Icons.bolt_rounded, onPressed: onUse),
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
    );
  }
}
