import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import '../state/progress_controller.dart';
import '../theme/app_theme.dart';

class ArrowEscapeApp extends StatelessWidget {
  const ArrowEscapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProgressController()..load(),
      child: MaterialApp(
        title: 'Arrow Escape',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
