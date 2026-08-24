import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../theme/app_colors.dart';

enum PremiumButtonStyle { primary, secondary }

/// A rounded, gradient-capable button with a tactile press-scale
/// animation, used for every primary/secondary action across the app.
class PremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PremiumButtonStyle style;
  final bool expand;

  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = PremiumButtonStyle.primary,
    this.expand = true,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final isPrimary = widget.style == PremiumButtonStyle.primary;

    final child = AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Container(
        width: widget.expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : (isPrimary ? AppColors.primaryButtonGradient : null),
          color: disabled
              ? AppColors.surfaceRaised
              : (isPrimary ? null : AppColors.surfaceRaised),
          borderRadius: BorderRadius.circular(18),
          boxShadow: disabled || !isPrimary
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 20,
                color: disabled ? AppColors.textDisabled : Colors.white,
              ),
              const SizedBox(width: 10),
            ],
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: disabled ? AppColors.textDisabled : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      onTap: disabled
          ? null
          : () {
              context.read<AudioService>().playTap();
              widget.onPressed?.call();
            },
      child: child,
    );
  }
}
