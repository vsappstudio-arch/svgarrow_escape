import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/premium_card.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _paragraphs = [
    'Arrow Escape is provided for entertainment purposes as-is, without warranty of any kind, '
        'in this prototype build.',
    'In-game currency (coins) and items (hints, undos, extra moves, Remove Ads) have no real-world '
        'monetary value and cannot be exchanged for cash. Any "purchase" flows in this build are '
        'simulated and do not process real payments.',
    'You may not reverse engineer, redistribute, or resell this application outside of the '
        'distribution channels it is officially made available through.',
    'These terms may be updated as the app develops. Continued use after an update means you '
        'accept the revised terms.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Terms of Use')),
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
