import 'package:flutter/material.dart';

import '../core/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Arrow Escape', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.levelSelect),
                child: const Text('Play'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
