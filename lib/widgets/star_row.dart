import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Three stars, filled up to [stars]. When [animate] is true, filled
/// stars pop in one after another for a celebratory reveal.
class StarRow extends StatelessWidget {
  final int stars;
  final double size;
  final bool animate;

  const StarRow({super.key, required this.stars, this.size = 28, this.animate = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final filled = index < stars;
        final star = Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          color: filled ? AppColors.gold : AppColors.textDisabled,
          size: size,
        );

        if (!animate) {
          return Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: star);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: filled ? 1 : 0.6),
            duration: Duration(milliseconds: 350 + index * 150),
            curve: Curves.elasticOut,
            builder: (context, value, child) => Transform.scale(scale: value, child: child),
            child: star,
          ),
        );
      }),
    );
  }
}
