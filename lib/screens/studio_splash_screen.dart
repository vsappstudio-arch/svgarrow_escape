import 'package:flutter/material.dart';

import '../core/routes.dart';

/// The very first screen the app shows, immediately after Android's
/// own native startup screen. Android 12+'s system splash screen
/// covers the entire gap between process start and Flutter's first
/// drawn frame and hands off directly into whatever that first frame
/// is - it never gives the classic `windowBackground` native splash
/// drawable (see android/app/src/main/res/drawable/launch_background.xml)
/// a visible moment. So the VS App Studio artwork is shown here, as
/// literally the first thing Flutter renders, before the existing
/// ARROWW [SplashScreen] takes over.
class StudioSplashScreen extends StatefulWidget {
  const StudioSplashScreen({super.key});

  @override
  State<StudioSplashScreen> createState() => _StudioSplashScreenState();
}

class _StudioSplashScreenState extends State<StudioSplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _proceed());
  }

  Future<void> _proceed() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.62,
          child: Image.asset(
            'assets/images/vs_app_studio.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
