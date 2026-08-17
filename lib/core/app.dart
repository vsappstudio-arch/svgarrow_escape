import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
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
