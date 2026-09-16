import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ARROWW's UI is unconditionally dark. Android 15+ (targetSdk 36)
  // already enforces edge-to-edge for every app, so this doesn't
  // change whether content draws behind the system bars - only how
  // they're painted: transparent, so the app's own dark background
  // shows through instead of a light system default, with light
  // icons/gesture indicator so they stay visible against it.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  runApp(const ArrowEscapeApp());
}
