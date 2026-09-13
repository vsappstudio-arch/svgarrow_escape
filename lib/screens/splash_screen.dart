import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../state/settings_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _proceed());
  }

  Future<void> _proceed() async {
    final settings = context.read<SettingsController>();
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1100)),
      settings.ensureLoaded(),
    ]);
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(
      settings.tutorialSeen ? AppRoutes.home : AppRoutes.tutorial,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0, 1),
                child: Transform.scale(scale: 0.85 + value * 0.15, child: child),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                Text(
                  'ARROWW',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Clear the path. Escape the grid.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
