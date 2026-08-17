import 'package:flutter/material.dart';

/// Central theme definition for Arrow Escape.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: Colors.indigo,
    );
  }
}
