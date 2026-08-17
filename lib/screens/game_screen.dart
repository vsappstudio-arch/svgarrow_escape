import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/level_data.dart';
import '../models/arrow_model.dart';
import '../state/game_controller.dart';
import '../state/progress_controller.dart';

class GameScreen extends StatelessWidget {
  final int levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(LevelData.byId(levelId)),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatefulWidget {
  const _GameView();

  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> {
  bool _dialogShown = false;

  ArrowModel? _arrowAt(List<ArrowModel> arrows, int row, int col) {
    for (final arrow in arrows) {
      if (arrow.row == row && arrow.col == col) return arrow;
    }
    return null;
  }

  Future<void> _handleSolved(GameController controller) async {
    final progressController = context.read<ProgressController>();
    await progressController.completeLevel(controller.level.id, controller.starsEarned);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Level Complete!'),
        content: Text('Moves: ${controller.moves}\nStars: ${controller.starsEarned}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Levels'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final level = controller.level;

    if (controller.isSolved && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleSolved(controller));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(level.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _dialogShown = false);
              controller.reset();
            },
          ),
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: level.gridSize,
              ),
              itemCount: level.gridSize * level.gridSize,
              itemBuilder: (context, index) {
                final row = index ~/ level.gridSize;
                final col = index % level.gridSize;
                final arrow = _arrowAt(controller.arrows, row, col);
                final removed = arrow != null && controller.isRemoved(arrow.id);

                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: arrow == null || removed
                        ? null
                        : InkWell(
                            onTap: () => controller.tapArrow(arrow),
                            child: Icon(arrow.direction.icon),
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
