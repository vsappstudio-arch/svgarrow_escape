import 'package:flutter/material.dart';

import '../screens/game_screen.dart';
import '../screens/home_screen.dart';
import '../screens/level_select_screen.dart';

/// Named route table for the app.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String levelSelect = '/levels';
  static const String game = '/game';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case levelSelect:
        return MaterialPageRoute(builder: (_) => const LevelSelectScreen());
      case game:
        final levelId = settings.arguments as int? ?? 1;
        return MaterialPageRoute(builder: (_) => GameScreen(levelId: levelId));
      case home:
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
