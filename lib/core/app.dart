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
        ChangeNotifierProvider(
          create: (_) {
            final controller = SettingsController();
            // Fire-and-forget, same as the rest of app startup: settings
            // load first, then (only once that's done) the notification
            // schedule is set up/refreshed - never blocking the first frame.
            controller.ensureLoaded().then((_) => controller.ensureNotificationsReady());
            return controller;
          },
        ),
        // One AudioService for the whole app, so the sound-effect
        // player is not rebuilt on every navigation. Re-synced against
        // the latest persisted settings whenever SettingsController
        // changes (loaded, or sound toggled).
        ProxyProvider<SettingsController, AudioService>(
          create: (_) => AudioService(),
          update: (context, settings, audio) {
            final service = audio ?? AudioService();
            if (settings.isLoaded) {
              service.applySettings(soundEnabled: settings.soundEnabled);
            }
            return service;
          },
          dispose: (_, audio) => audio.dispose(),
        ),
      ],
      child: MaterialApp(
        // Names the task in the Android recents switcher, so the app
        // reads as ARROWW there just as it does under the launcher icon.
        title: 'ARROWW',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: AppRoutes.studioSplash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
