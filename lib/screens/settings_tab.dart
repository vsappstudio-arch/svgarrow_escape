import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../state/settings_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_card.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const _SectionLabel('Audio & Feedback'),
                PremiumCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.volume_up_rounded,
                        label: 'Sound Settings',
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.soundSettings),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _SettingsSwitchTile(
                        icon: Icons.vibration_rounded,
                        label: 'Haptics',
                        value: settingsController.hapticsEnabled,
                        onChanged: settingsController.setHapticsEnabled,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const _SectionLabel('Notifications'),
                PremiumCard(
                  padding: EdgeInsets.zero,
                  child: _SettingsSwitchTile(
                    icon: Icons.notifications_rounded,
                    label: 'Notifications',
                    subtitle: 'Get reminders to come back and play ARROWW.',
                    value: settingsController.notificationsEnabled,
                    onChanged: settingsController.setNotificationsEnabled,
                  ),
                ),
                const SizedBox(height: 22),
                const _SectionLabel('Gameplay'),
                PremiumCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.school_rounded,
                        label: 'Replay Tutorial',
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.tutorial),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        label: 'Language',
                        trailing: const Text('English', style: TextStyle(color: AppColors.textSecondary)),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('More languages coming soon!')),
                        ),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _SettingsTile(
                        icon: Icons.wifi_rounded,
                        label: 'Check Connection',
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.offline),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const _SectionLabel('About & Legal'),
                PremiumCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.star_rate_rounded,
                        label: 'Rate Us',
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        onTap: () => showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Rate ARROWW'),
                            content: const Text(
                              'Thanks for playing! Store ratings will be available once ARROWW is '
                              'live on Google Play.',
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        label: 'About',
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _SettingsTile(
                        icon: Icons.description_outlined,
                        label: 'Terms of Use',
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.terms),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textDisabled,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.label, required this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      trailing: trailing,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
    );
  }
}
