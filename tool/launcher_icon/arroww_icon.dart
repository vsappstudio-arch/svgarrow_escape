import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Draws the ARROWW launcher mark.
///
/// The mark is the four directional arrows of the approved ARROWW key
/// art - blue up, green left, red right, yellow down - sitting on the
/// dark slate 3x3 board inside a blue neon frame. The wordmark and
/// tagline from the key art are deliberately left out: at 48dp they
/// turn into illegible smudges, so the launcher carries the arrows and
/// the app label carries the name.
///
/// Everything is drawn from geometry rather than resampled from a big
/// image, so each density is rendered crisply at its own size.
class ArrowwIcon {
  const ArrowwIcon._();

  // Board and frame
  static const Color _backdropTop = Color(0xFF0B1030);
  static const Color _backdropBottom = Color(0xFF03050F);
  static const Color _panel = Color(0xFF070B1C);
  static const Color _tileTop = Color(0xFF25334F);
  static const Color _tileBottom = Color(0xFF141F36);
  static const Color _neon = Color(0xFF3BAAFF);
  static const Color _neonBright = Color(0xFFB4E2FF);

  /// The four arrows, in the order they sit around the board.
  static const List<_Arrow> _arrows = [
    _Arrow(// up - blue
      turns: 0,
      cell: Offset(1, 0),
      light: Color(0xFF7FD0FF),
      base: Color(0xFF2E9BFF),
      dark: Color(0xFF0B57D0),
      glow: Color(0xFF3BAAFF),
    ),
    _Arrow(// left - green
      turns: 3,
      cell: Offset(0, 1),
      light: Color(0xFFA6F573),
      base: Color(0xFF52DE24),
      dark: Color(0xFF1B8F09),
      glow: Color(0xFF5CE62E),
    ),
    _Arrow(// right - red
      turns: 1,
      cell: Offset(2, 1),
      light: Color(0xFFFF9A8F),
      base: Color(0xFFFF3B30),
      dark: Color(0xFFB80D0D),
      glow: Color(0xFFFF4B3E),
    ),
    _Arrow(// down - yellow
      turns: 2,
      cell: Offset(1, 2),
      light: Color(0xFFFFE68A),
      base: Color(0xFFFFC107),
      dark: Color(0xFFE07C00),
      glow: Color(0xFFFFC93C),
    ),
  ];

  /// The full mark: neon frame, board, and arrows. Used for the legacy
  /// launcher bitmap and the store listing.
  static void paintFull(Canvas canvas, double size) {
    final margin = size * 0.02;
    final outer = Rect.fromLTWH(margin, margin, size - margin * 2, size - margin * 2);
    final outerRadius = Radius.circular(size * 0.225);
    final silhouette = RRect.fromRectAndRadius(outer, outerRadius);

    // Backdrop.
    canvas.drawRRect(
      silhouette,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_backdropTop, _backdropBottom],
        ).createShader(outer),
    );

    // The neon bloom is kept inside the icon's own shape - a glow that
    // spills past it would show as a halo around the tile in a launcher.
    canvas.save();
    canvas.clipRRect(silhouette);
    _paintFrame(canvas, outer, outerRadius, size);
    canvas.restore();

    final panel = outer.deflate(size * 0.085);
    canvas.drawRRect(
      RRect.fromRectAndRadius(panel, Radius.circular(size * 0.15)),
      Paint()..color = _panel,
    );

    _paintBoard(canvas, panel, size);
  }

  /// The adaptive-icon foreground: the arrows alone, on transparency,
  /// kept inside the 66/108 safe zone so no launcher mask - circle,
  /// squircle, teardrop - can clip them.
  static void paintForeground(Canvas canvas, double size) {
    for (final entry in _clusterBoxes(size).entries) {
      _paintArrow(canvas, entry.value, entry.key);
    }
  }

  /// The arrows arranged as a compact plus.
  ///
  /// Sized for how flutter_launcher_icons writes the adaptive layers:
  /// it insets the foreground (and monochrome) drawable by 16% a side,
  /// so the art is drawn into the middle 68% of the 108dp canvas. Ink
  /// reaching 0.449 of this canvas therefore lands at 0.449 x 0.68 =
  /// 0.305 of the icon - exactly the 66/108 safe circle, so no launcher
  /// mask can clip an arrow.
  static Map<_Arrow, Rect> _clusterBoxes(double size) {
    final arrow = size * 0.365;
    final offset = size * 0.266;
    final centre = Offset(size / 2, size / 2);
    return {
      for (final a in _arrows)
        a: Rect.fromCenter(
          center: centre + Offset((a.cell.dx - 1) * offset, (a.cell.dy - 1) * offset),
          width: arrow,
          height: arrow,
        ),
    };
  }

  /// The adaptive-icon background: the dark board colour with the neon
  /// glow behind it. No hard frame, because a launcher mask would slice
  /// its corners off.
  static void paintBackground(Canvas canvas, double size) {
    final full = Rect.fromLTWH(0, 0, size, size);
    canvas.drawRect(
      full,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_backdropTop, _backdropBottom],
        ).createShader(full),
    );
    // Blue bloom behind the arrows, so the neon identity survives even
    // when the frame cannot.
    canvas.drawRect(
      full,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(size / 2, size * 0.47),
          size * 0.42,
          [
            _neon.withValues(alpha: 0.34),
            _neon.withValues(alpha: 0.10),
            const Color(0x00000000),
          ],
          [0.0, 0.55, 1.0],
        ),
    );
  }

  /// Android 13 themed icons: one flat silhouette, no colour.
  static void paintMonochrome(Canvas canvas, double size) {
    for (final entry in _clusterBoxes(size).entries) {
      final arrow = entry.key;
      final box = entry.value;
      final path = _arrowPath(box, arrow.turns);
      canvas.drawPath(path, Paint()..color = Colors.white);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = box.width * 0.08
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..color = Colors.white,
      );
    }
  }

  static void _paintFrame(Canvas canvas, Rect outer, Radius radius, double size) {
    final frameRect = outer.deflate(size * 0.035);
    final frame = RRect.fromRectAndRadius(frameRect, Radius.circular(radius.x - size * 0.035));

    // Outer bloom, then the tube, then the hot inner line.
    for (final pass in [
      [0.075, 0.30, 0.055],
      [0.040, 0.55, 0.035],
    ]) {
      canvas.drawRRect(
        frame,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size * pass[2]
          ..color = _neon.withValues(alpha: pass[1])
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * pass[0]),
      );
    }
    canvas.drawRRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.022
        ..color = _neon,
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.008
        ..color = _neonBright.withValues(alpha: 0.9),
    );
  }

  static void _paintBoard(Canvas canvas, Rect panel, double size) {
    final board = panel.deflate(size * 0.028);
    _paintArrows(canvas, board, size, tiles: true);
  }

  static void _paintArrows(Canvas canvas, Rect board, double size, {required bool tiles}) {
    final cell = board.width / 3;
    final gap = cell * 0.07;

    if (tiles) {
      for (var row = 0; row < 3; row++) {
        for (var col = 0; col < 3; col++) {
          if (row == 1 && col == 1) continue; // the middle stays empty
          final tile = Rect.fromLTWH(
            board.left + col * cell + gap / 2,
            board.top + row * cell + gap / 2,
            cell - gap,
            cell - gap,
          );
          final rrect = RRect.fromRectAndRadius(tile, Radius.circular(cell * 0.16));
          canvas.drawRRect(
            rrect,
            Paint()
              ..shader = const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_tileTop, _tileBottom],
              ).createShader(tile),
          );
          // Bevel: a light top edge and a dark bottom edge.
          canvas.drawRRect(
            rrect.deflate(cell * 0.012),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = cell * 0.024
              ..color = Colors.white.withValues(alpha: 0.06),
          );
        }
      }
    }

    for (final arrow in _arrows) {
      final box = Rect.fromLTWH(
        board.left + arrow.cell.dx * cell,
        board.top + arrow.cell.dy * cell,
        cell,
        cell,
      ).deflate(cell * (tiles ? 0.09 : 0.045));
      _paintArrow(canvas, box, arrow);
    }
  }

  static void _paintArrow(Canvas canvas, Rect box, _Arrow arrow) {
    final path = _arrowPath(box, arrow.turns);
    final round = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = box.width * 0.09
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Neon spill onto the board.
    canvas.drawPath(
      path,
      Paint()
        ..color = arrow.glow.withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, box.width * 0.13),
    );
    // Contact shadow so the arrow sits above the tile.
    canvas.save();
    canvas.translate(0, box.height * 0.035);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF000000).withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, box.width * 0.05),
    );
    canvas.restore();

    // Body: light at the top, saturated through the middle, deep at the
    // bottom - the moulded plastic look of the key art.
    final body = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [arrow.light, arrow.base, arrow.dark],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(box);
    canvas.drawPath(path, round..shader = body);
    canvas.drawPath(path, Paint()..shader = body);

    // Glossy top half.
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      box,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.45),
            Colors.white.withValues(alpha: 0.06),
            const Color(0x00FFFFFF),
          ],
          stops: const [0.0, 0.42, 0.62],
        ).createShader(box),
    );
    canvas.restore();

    // Bright rim, brightest where the light hits.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = box.width * 0.022
        ..strokeJoin = StrokeJoin.round
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.85),
            arrow.light.withValues(alpha: 0.35),
          ],
        ).createShader(box),
    );
  }

  /// A blocky arrow pointing up inside [box], rotated by [turns]
  /// quarter-turns clockwise. Corners are softened by the round stroke
  /// in [_paintArrow], so the polygon itself is kept slightly inside
  /// the box to leave room for it.
  static Path _arrowPath(Rect box, int turns) {
    const tip = 0.5;
    const headY = 0.52;
    const shaftHalf = 0.19;
    final points = <Offset>[
      const Offset(tip, 0.07),
      const Offset(0.93, headY),
      const Offset(0.5 + shaftHalf, headY),
      const Offset(0.5 + shaftHalf, 0.93),
      const Offset(0.5 - shaftHalf, 0.93),
      const Offset(0.5 - shaftHalf, headY),
      const Offset(0.07, headY),
    ];

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final offset = Offset(box.left + p.dx * box.width, box.top + p.dy * box.height);
      if (i == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    path.close();

    if (turns == 0) return path;
    final matrix = Matrix4.identity()
      ..translateByDouble(box.center.dx, box.center.dy, 0, 1)
      ..rotateZ(turns * math.pi / 2)
      ..translateByDouble(-box.center.dx, -box.center.dy, 0, 1);
    return path.transform(matrix.storage);
  }
}

class _Arrow {
  const _Arrow({
    required this.turns,
    required this.cell,
    required this.light,
    required this.base,
    required this.dark,
    required this.glow,
  });

  /// Quarter-turns clockwise from pointing up.
  final int turns;

  /// Which cell of the 3x3 board the arrow sits in.
  final Offset cell;
  final Color light;
  final Color base;
  final Color dark;
  final Color glow;
}
