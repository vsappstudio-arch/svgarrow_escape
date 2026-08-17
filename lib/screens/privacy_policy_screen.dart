import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/premium_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _paragraphs = [
    'This is a prototype build of Arrow Escape. It does not create user accounts, does not '
        'require sign-in, and does not use analytics, advertising, or cloud services.',
    'All game progress — unlocked levels, stars, coins, and settings — is stored only on this '
        'device using local storage, and is never transmitted anywhere.',
    'No personal information is collected, shared, or sold by this app.',
    'If a future release adds online features (such as cloud save or ads), this policy will be '
        'updated before those features are enabled, and you will be able to review the changes here.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: AppBackground(
        safeArea: false,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final paragraph in _paragraphs) ...[
                      Text(paragraph, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
