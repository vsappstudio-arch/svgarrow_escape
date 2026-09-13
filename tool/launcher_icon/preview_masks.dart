import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Composites the generated Android resources the way a launcher does -
/// background, then the foreground inset by 16% - and clips the result
/// with the mask shapes Android ships (circle, rounded square, squircle,
/// teardrop). Also renders the legacy bitmap at real launcher sizes.
///
/// Run with:
///   flutter test tool/launcher_icon/preview_masks.dart
///
/// It only writes a preview image for eyeballing; it changes nothing
/// the app ships.
const _res = 'android/app/src/main/res';
const _out = 'build/icon_preview.png';

Future<ui.Image> _load(String path) async {
  final bytes = await File(path).readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  return (await codec.getNextFrame()).image;
}

void _drawImage(Canvas canvas, ui.Image image, Rect dst) {
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    dst,
    Paint()..filterQuality = FilterQuality.high,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('preview ARROWW launcher masks', () async {
    final background = await _load('$_res/drawable-xxxhdpi/ic_launcher_background.png');
    final foreground = await _load('$_res/drawable-xxxhdpi/ic_launcher_foreground.png');
    final monochrome = await _load('$_res/drawable-xxxhdpi/ic_launcher_monochrome.png');
    final legacy = await _load('$_res/mipmap-xxxhdpi/ic_launcher.png');

    const tile = 240.0;
    const pad = 24.0;
    const cols = 5;
    const width = cols * tile + (cols + 1) * pad;
    const height = tile + pad * 2 + 140;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, width, height),
      Paint()..color = const Color(0xFF9AA3B2),
    );

    // The masks Android applies to adaptive icons.
    Path circle(Rect r) => Path()..addOval(r);
    Path rounded(Rect r) => Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(r.width * 0.20)));
    Path squircle(Rect r) => Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(r.width * 0.40)));
    Path teardrop(Rect r) => Path()
      ..addRRect(RRect.fromRectAndCorners(
        r,
        topLeft: Radius.circular(r.width / 2),
        topRight: Radius.circular(r.width / 2),
        bottomLeft: Radius.circular(r.width / 2),
        bottomRight: Radius.zero,
      ));

    final masks = <String, Path Function(Rect)>{
      'circle': circle,
      'rounded': rounded,
      'squircle': squircle,
      'teardrop': teardrop,
    };

    // Android shows only the middle 72dp of the 108dp adaptive canvas,
    // scaled to fill the icon slot, so the layers are drawn 108/72
    // oversized and then clipped by the mask.
    const canvasScale = 108 / 72;

    void drawAdaptive(Rect slot) {
      final full = Rect.fromCenter(
        center: slot.center,
        width: slot.width * canvasScale,
        height: slot.height * canvasScale,
      );
      _drawImage(canvas, background, full);
      // The 16% foreground inset lives in ic_launcher.xml.
      _drawImage(canvas, foreground, full.deflate(full.width * 0.16));
    }

    var index = 0;
    for (final entry in masks.entries) {
      final rect = Rect.fromLTWH(pad + index * (tile + pad), pad, tile, tile);
      canvas.save();
      canvas.clipPath(entry.value(rect));
      drawAdaptive(rect);
      canvas.restore();
      index++;
    }

    // Themed (monochrome) icon, as Android 13+ tints it.
    final themedRect = Rect.fromLTWH(pad + 4 * (tile + pad), pad, tile, tile);
    canvas.save();
    canvas.clipPath(circle(themedRect));
    canvas.drawRect(themedRect, Paint()..color = const Color(0xFF3B4A63));
    canvas.saveLayer(themedRect, Paint()..colorFilter = const ColorFilter.mode(Color(0xFFD8E4FF), BlendMode.srcIn));
    final themedFull = Rect.fromCenter(
      center: themedRect.center,
      width: themedRect.width * canvasScale,
      height: themedRect.height * canvasScale,
    );
    _drawImage(canvas, monochrome, themedFull.deflate(themedFull.width * 0.16));
    canvas.restore();
    canvas.restore();

    // Legacy bitmap at the sizes a launcher actually shows it.
    var x = pad;
    for (final dp in [48.0, 72.0, 96.0, 144.0]) {
      _drawImage(canvas, legacy, Rect.fromLTWH(x, tile + pad * 2 + 20, dp, dp));
      x += dp + pad;
    }
    // And the adaptive result at small size, circle-masked.
    for (final dp in [48.0, 72.0]) {
      final r = Rect.fromLTWH(x, tile + pad * 2 + 20, dp, dp);
      canvas.save();
      canvas.clipPath(circle(r));
      drawAdaptive(r);
      canvas.restore();
      x += dp + pad;
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.round(), height.round());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(_out);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
    debugPrint('wrote $_out');
  });
}
