import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/arrow_model.dart';
import '../theme/app_colors.dart';

/// A colorful, custom-painted arrow game piece with press, blocked
/// (shake), hint (glow), and escape (slide + fade) feedback.
class ArrowTile extends StatefulWidget {
  final ArrowModel arrow;
  final Color color;
  final bool removed;
  final bool hinted;
  final bool shaking;
  final VoidCallback? onTap;

  const ArrowTile({
    super.key,
    required this.arrow,
    required this.color,
    required this.removed,
    required this.hinted,
    required this.shaking,
    required this.onTap,
  });

  @override
  State<ArrowTile> createState() => _ArrowTileState();
}

class _ArrowTileState extends State<ArrowTile> with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  bool _pressed = false;

  @override
  void didUpdateWidget(covariant ArrowTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shaking && !oldWidget.shaking) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  double _angleFor(ArrowDirection direction) {
    switch (direction) {
      case ArrowDirection.up:
        return 0;
      case ArrowDirection.right:
        return math.pi / 2;
      case ArrowDirection.down:
        return math.pi;
      case ArrowDirection.left:
        return -math.pi / 2;
    }
  }

  Offset _exitOffset(ArrowDirection direction) {
    switch (direction) {
      case ArrowDirection.up:
        return const Offset(0, -1.6);
      case ArrowDirection.down:
        return const Offset(0, 1.6);
      case ArrowDirection.left:
        return const Offset(-1.6, 0);
      case ArrowDirection.right:
        return const Offset(1.6, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tile = AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final t = _shakeController.value;
        final dx = math.sin(t * math.pi * 6) * (1 - t) * 6;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Padding used to be a fixed 8, which was fine on the
            // roomy grids early levels use but left almost no room
            // for the icon (and no room to tell a dot piece's badge
            // apart from a plain arrow) once dense late-game grids
            // (e.g. Level 50's 12x12) shrink each tile well below
            // the size that padding was tuned for. Scaling it down
            // with the tile keeps a consistent fraction of the tile
            // available for the icon at every grid size.
            final tileSize = constraints.biggest.shortestSide;
            final padding = (tileSize * 0.21).clamp(2.0, 8.0);

            return Container(
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.hinted ? AppColors.gold : widget.color.withValues(alpha: 0.6),
                  width: widget.hinted ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.hinted ? AppColors.gold : widget.color).withValues(alpha: 0.35),
                    blurRadius: widget.hinted ? 14 : 8,
                    spreadRadius: widget.hinted ? 1 : 0,
                  ),
                ],
              ),
              padding: EdgeInsets.all(padding),
              child: Center(
                child: widget.arrow.isDot
                    ? _DotBadge(
                        color: widget.color,
                        child: Transform.rotate(
                          angle: _angleFor(widget.arrow.direction),
                          child: CustomPaint(size: const Size.square(16), painter: _ArrowShapePainter(Colors.white)),
                        ),
                      )
                    : Transform.rotate(
                        angle: _angleFor(widget.arrow.direction),
                        child: CustomPaint(size: const Size.square(28), painter: _ArrowShapePainter(widget.color)),
                      ),
              ),
            );
          },
        ),
      ),
    );

    return AnimatedSlide(
      offset: widget.removed ? _exitOffset(widget.arrow.direction) : Offset.zero,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInBack,
      child: AnimatedOpacity(
        opacity: widget.removed ? 0 : 1,
        duration: const Duration(milliseconds: 280),
        child: IgnorePointer(
          ignoring: widget.removed || widget.onTap == null,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: widget.onTap,
            child: tile,
          ),
        ),
      ),
    );
  }
}

/// The Level 41+ visual variant: the same-size tile now centers its
/// tappable arrow glyph inside a solid circular badge rather than
/// filling the tile directly, so a "dot" piece reads as visually
/// distinct at a glance without shrinking the actual tap target.
class _DotBadge extends StatelessWidget {
  final Color color;
  final Widget child;

  const _DotBadge({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
      ),
      child: Center(child: child),
    );
  }
}

class _ArrowShapePainter extends CustomPainter {
  final Color color;

  _ArrowShapePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.95, h * 0.42)
      ..lineTo(w * 0.68, h * 0.42)
      ..lineTo(w * 0.68, h)
      ..lineTo(w * 0.32, h)
      ..lineTo(w * 0.32, h * 0.42)
      ..lineTo(w * 0.05, h * 0.42)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _ArrowShapePainter oldDelegate) => oldDelegate.color != color;
}
