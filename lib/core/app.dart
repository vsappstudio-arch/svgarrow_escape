import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import '../services/audio_service.dart';
import '../state/progress_controller.dart';
import '../state/settings_controller.dart';
import '../theme/app_theme.dart';

class ArrowEscapeApp extends StatelessWidget {
  const ArrowEscapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressController()..load()),
        ChangeNotifierProvider(create: (_) => SettingsController()..ensureLoaded()),
        // One AudioService for the whole app, so background music
        // plays continuously across screens instead of restarting on
        // every navigation. Re-synced against the latest persisted
        // settings whenever SettingsController changes (loaded, or
        // sound/music toggled).
        ProxyProvider<SettingsController, AudioService>(
          create: (_) => AudioService(),
          update: (context, settings, audio) {
            final service = audio ?? AudioService();
            if (settings.isLoaded) {
              service.applySettings(soundEnabled: settings.soundEnabled, musicEnabled: settings.musicEnabled);
            }
            return service;
          },
          dispose: (_, audio) => audio.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'Arrow Escape',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
