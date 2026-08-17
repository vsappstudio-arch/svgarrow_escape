import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'premium_button.dart';

/// Shared "no connection" body, reused by the standalone Offline
/// screen and inline by the Shop tab when a connectivity check fails.
class OfflineStateContent extends StatelessWidget {
  final VoidCallback onRetry;
  final bool retrying;

  const OfflineStateContent({super.key, required this.onRetry, this.retrying = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: const Icon(Icons.wifi_off_rounded, color: AppColors.danger, size: 40),
            ),
            const SizedBox(height: 24),
            Text('No Internet Connection', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            const Text(
              'Check your connection and try again.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            PremiumButton(
              label: retrying ? 'Checking...' : 'Retry',
              icon: Icons.refresh_rounded,
              expand: false,
              onPressed: retrying ? null : onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
