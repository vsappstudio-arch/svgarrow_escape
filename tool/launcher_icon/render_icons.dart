import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'arroww_icon.dart';

/// Renders the ARROWW launcher source art into assets/icon/.
///
/// Run with:
///   flutter test tool/launcher_icon/render_icons.dart
///
/// then regenerate the Android resources with:
///   dart run flutter_launcher_icons
///
/// The art is drawn from geometry in [ArrowwIcon], so re-running this
/// reproduces the exact same PNGs; the checked-in files are just the
/// build inputs flutter_launcher_icons resizes.
Future<void> _write(String name, double size, void Function(Canvas, double) paint) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));
  paint(canvas, size);
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.round(), size.round());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File('assets/icon/$name.png');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(data!.buffer.asUint8List());
  debugPrint('wrote ${file.path} (${size.round()}x${size.round()})');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('render ARROWW launcher art', () async {
    await _write('arroww_icon', 1024, ArrowwIcon.paintFull);
    await _write('arroww_icon_foreground', 1024, ArrowwIcon.paintForeground);
    await _write('arroww_icon_background', 1024, ArrowwIcon.paintBackground);
    await _write('arroww_icon_monochrome', 1024, ArrowwIcon.paintMonochrome);
  });
}
