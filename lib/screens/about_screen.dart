import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/premium_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('About')),
      body: AppBackground(
        safeArea: false,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Arrow Escape', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text('Version 1.0.0', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
              const SizedBox(height: 24),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Arrow Escape is a casual puzzle game about clearing a board of arrows in the '
                      'right order so each one can escape off the grid.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Built with Flutter. This build is an early prototype — some store features '
                      '(ads, billing, ratings) are simulated for testing.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                    ),
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
