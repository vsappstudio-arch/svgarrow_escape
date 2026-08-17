import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../game/level_data.dart';
import '../state/progress_controller.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progressController = context.watch<ProgressController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Level')),
      body: ListView.builder(
        itemCount: LevelData.levels.length,
        itemBuilder: (context, index) {
          final level = LevelData.levels[index];
          final unlocked = progressController.isUnlocked(level.id);
          final stars = progressController.starsFor(level.id);

          return ListTile(
            leading: Icon(unlocked ? Icons.lock_open : Icons.lock),
            title: Text(level.name),
            subtitle: Text(unlocked ? 'Stars: $stars' : 'Locked'),
            onTap: unlocked
                ? () => Navigator.pushNamed(
                    context,
                    AppRoutes.game,
                    arguments: level.id,
                  )
                : null,
          );
        },
      ),
    );
  }
}
