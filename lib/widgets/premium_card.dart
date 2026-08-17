import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A rounded card with the app's signature subtle gradient, border,
/// and soft shadow. The base surface for most content blocks.
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: card),
      ),
    );
  }
}
