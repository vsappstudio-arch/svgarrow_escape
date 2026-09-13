import 'package:flutter/material.dart';

import '../screens/about_screen.dart';
import '../screens/game_screen.dart';
import '../screens/main_shell.dart';
import '../screens/offline_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/sound_settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/studio_splash_screen.dart';
import '../screens/terms_screen.dart';
import '../screens/tutorial_screen.dart';
import '../widgets/page_transitions.dart';

/// Named route table for the app. Every route uses the shared
/// fade + slide transition so navigation feels consistent.
class AppRoutes {
  AppRoutes._();

  static const String studioSplash = '/';
  static const String splash = '/splash';
  static const String tutorial = '/tutorial';
  static const String home = '/home';
  static const String game = '/game';
  static const String soundSettings = '/sound-settings';
  static const String about = '/about';
  static const String privacyPolicy = '/privacy';
  static const String terms = '/terms';
  static const String offline = '/offline';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case studioSplash:
        return fadeSlideRoute((_) => const StudioSplashScreen(), settings: settings);
      case splash:
        return fadeSlideRoute((_) => const SplashScreen(), settings: settings);
      case tutorial:
        return fadeSlideRoute((_) => const TutorialScreen(), settings: settings);
      case home:
        final initialTab = settings.arguments as int? ?? 0;
        return fadeSlideRoute((_) => MainShell(initialTabIndex: initialTab), settings: settings);
      case game:
        final levelId = settings.arguments as int? ?? 1;
        return fadeSlideRoute((_) => GameScreen(levelId: levelId), settings: settings);
      case soundSettings:
        return fadeSlideRoute((_) => const SoundSettingsScreen(), settings: settings);
      case about:
        return fadeSlideRoute((_) => const AboutScreen(), settings: settings);
      case privacyPolicy:
        return fadeSlideRoute((_) => const PrivacyPolicyScreen(), settings: settings);
      case terms:
        return fadeSlideRoute((_) => const TermsScreen(), settings: settings);
      case offline:
        return fadeSlideRoute((_) => const OfflineScreen(), settings: settings);
      default:
        return fadeSlideRoute((_) => const SplashScreen(), settings: settings);
    }
  }
}
