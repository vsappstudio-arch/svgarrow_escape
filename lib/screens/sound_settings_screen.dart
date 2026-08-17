import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/settings_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/premium_card.dart';

class SoundSettingsScreen extends StatelessWidget {
  const SoundSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Sound Settings')),
      body: AppBackground(
        safeArea: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: PremiumCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    value: settingsController.soundEnabled,
                    onChanged: settingsController.setSoundEnabled,
                    secondary: const Icon(Icons.music_note_rounded, color: AppColors.primary),
                    title: const Text('Sound Effects', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Taps, escapes, and level wins', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  SwitchListTile(
                    value: settingsController.musicEnabled,
                    onChanged: settingsController.setMusicEnabled,
                    secondary: const Icon(Icons.library_music_rounded, color: AppColors.primary),
                    title: const Text('Music', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Background music', style: TextStyle(color: AppColors.textSecondary)),
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
