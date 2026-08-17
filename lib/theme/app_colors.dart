import 'package:flutter/material.dart';

/// Arrow Escape's premium dark-navy palette. All screens should pull
/// colors from here rather than hardcoding values, so the design
/// system stays consistent.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color backgroundTop = Color(0xFF0B0E2A);
  static const Color backgroundBottom = Color(0xFF171B44);
  static const Color surface = Color(0xFF1A1E45);
  static const Color surfaceRaised = Color(0xFF232A5C);
  static const Color surfaceLow = Color(0xFF141834);

  // Brand / actions
  static const Color primary = Color(0xFFFF7A3D);
  static const Color primaryDark = Color(0xFFE05A22);
  static const Color primaryLight = Color(0xFFFFB27A);

  // Text
  static const Color textPrimary = Color(0xFFF5F6FC);
  static const Color textSecondary = Color(0xFFA3A8CC);
  static const Color textDisabled = Color(0xFF5B6091);

  // Accents
  static const Color gold = Color(0xFFFFC93C);
  static const Color success = Color(0xFF4ECDC4);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color border = Color(0x332A2F5C);
  static const Color glow = Color(0x33FF7A3D);

  /// Cycled per-arrow so a puzzle board reads as colorful, distinct
  /// game pieces rather than uniform icons.
  static const List<Color> arrowPalette = [
    Color(0xFFFF6B6B), // coral red
    Color(0xFF4ECDC4), // teal
    Color(0xFFFFD93D), // yellow
    Color(0xFF8C7CFF), // purple
    Color(0xFF4D96FF), // blue
    Color(0xFFA0E426), // lime
  ];

  static Color arrowColor(int index) => arrowPalette[index % arrowPalette.length];

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundBottom],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9A56), primary],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceRaised, surface],
  );
}
