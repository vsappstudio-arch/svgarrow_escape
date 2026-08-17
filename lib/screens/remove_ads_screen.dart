import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/progress_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';

class RemoveAdsScreen extends StatelessWidget {
  const RemoveAdsScreen({super.key});

  Future<void> _confirmPurchase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simulated Purchase'),
        content: const Text(
          'This is a prototype. No real payment will be processed — confirming just '
          'flips the Remove Ads flag for testing.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm')),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<ProgressController>().setRemoveAdsPurchased(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchased = context.watch<ProgressController>().progress.removeAdsPurchased;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Remove Ads')),
      body: AppBackground(
        safeArea: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                PremiumCard(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          purchased ? Icons.check_circle_rounded : Icons.block_rounded,
                          color: purchased ? AppColors.success : AppColors.primary,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        purchased ? 'Ads Removed' : 'Remove Ads',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        purchased
                            ? 'You already own this. Thanks for the support!'
                            : 'Enjoy an uninterrupted, ad-free experience across the whole game.',
                        style: const TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '(Simulated purchase — this prototype has no real ads or billing yet)',
                        style: TextStyle(color: AppColors.textDisabled, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),
                      if (!purchased)
                        PremiumButton(
                          label: r'$2.99 (Simulated)',
                          icon: Icons.shopping_bag_rounded,
                          onPressed: () => _confirmPurchase(context),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
