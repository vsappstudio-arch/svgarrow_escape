import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A small pill showing the coin icon and current balance, used in
/// the home screen header, shop, and stats.
class CoinBadge extends StatelessWidget {
  final int coins;

  const CoinBadge({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 18),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
