import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The app's signature dark-navy gradient backdrop with soft glow
/// accents, wrapped around every screen's content for a consistent
/// premium feel.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool safeArea;

  const AppBackground({super.key, required this.child, this.safeArea = true});

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.backgroundGradient)),
        Positioned(
          top: -80,
          right: -60,
          child: _glow(220, AppColors.primary.withValues(alpha: 0.18)),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: _glow(260, AppColors.success.withValues(alpha: 0.12)),
        ),
        safeArea ? SafeArea(child: child) : child,
      ],
    );

    return content;
  }

  Widget _glow(double diameter, Color color) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
