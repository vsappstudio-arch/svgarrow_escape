import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/settings_controller.dart';
import '../theme/app_colors.dart';
import 'premium_button.dart';
import 'premium_card.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onLevels;
  final VoidCallback onHome;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onLevels,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: PremiumCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Paused', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: settingsController.soundEnabled,
                onChanged: settingsController.setSoundEnabled,
                secondary: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                title: const Text('Sound', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              PremiumButton(label: 'Resume', icon: Icons.play_arrow_rounded, onPressed: onResume),
              const SizedBox(height: 12),
              PremiumButton(
                label: 'Restart',
                icon: Icons.refresh_rounded,
                style: PremiumButtonStyle.secondary,
                onPressed: onRestart,
              ),
              const SizedBox(height: 12),
              PremiumButton(
                label: 'Levels',
                icon: Icons.map_rounded,
                style: PremiumButtonStyle.secondary,
                onPressed: onLevels,
              ),
              const SizedBox(height: 12),
              PremiumButton(
                label: 'Home',
                icon: Icons.home_rounded,
                style: PremiumButtonStyle.secondary,
                onPressed: onHome,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
