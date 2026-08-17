import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A lightweight, single-shot confetti burst (hand-painted, no
/// external package) used behind the level-complete celebration.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();
  late final List<_Particle> _particles = _generateParticles();

  List<_Particle> _generateParticles() {
    final random = math.Random(7);
    final palette = [...AppColors.arrowPalette, AppColors.gold];
    return List.generate(28, (i) {
      return _Particle(
        x: random.nextDouble(),
        delay: random.nextDouble() * 0.3,
        speed: 0.6 + random.nextDouble() * 0.5,
        drift: (random.nextDouble() - 0.5) * 0.6,
        color: palette[random.nextInt(palette.length)],
        size: 6 + random.nextDouble() * 6,
        rotationSpeed: (random.nextDouble() - 0.5) * 6,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(_particles, _controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Particle {
  final double x;
  final double delay;
  final double speed;
  final double drift;
  final double size;
  final double rotationSpeed;
  final Color color;

  _Particle({
    required this.x,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.size,
    required this.rotationSpeed,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final dy = t * size.height * p.speed * 1.1;
      final dx = p.x * size.width + p.drift * size.width * t;
      final opacity = (1 - t).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(t * p.rotationSpeed * math.pi);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
        Paint()..color = p.color.withValues(alpha: opacity),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
