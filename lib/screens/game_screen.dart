import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../game/level_data.dart';
import '../models/arrow_model.dart';
import '../services/audio_service.dart';
import '../state/game_controller.dart';
import '../state/progress_controller.dart';
import '../state/settings_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/arrow_tile.dart';
import '../widgets/level_complete_overlay.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/star_row.dart';

class GameScreen extends StatelessWidget {
  final int levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameController(
        LevelData.byId(levelId),
        context.read<SettingsController>(),
        audio: context.read<AudioService>(),
      ),
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
  bool _overlayShown = false;

  ArrowModel? _arrowAt(List<ArrowModel> arrows, int row, int col) {
    for (final arrow in arrows) {
      if (arrow.row == row && arrow.col == col) return arrow;
    }
    return null;
  }

  Future<void> _openPause(GameController controller) async {
    final navigator = Navigator.of(context);
    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Paused',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => PauseOverlay(
        onResume: () => navigator.pop(),
        onRestart: () {
          navigator.pop();
          controller.reset();
          setState(() => _overlayShown = false);
        },
        onLevels: () => navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false, arguments: 1),
        onHome: () => navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  Future<void> _handleSolved(GameController controller) async {
    final progressController = context.read<ProgressController>();
    final previousUnlockedLevel = progressController.progress.unlockedLevel;
    final result = await progressController.completeLevel(
      controller.level.id,
      controller.starsEarned,
      controller.moves,
    );
    if (!mounted) return;

    final didUnlockNewLevel = progressController.progress.unlockedLevel > previousUnlockedLevel;
    _playCompletionSounds(stars: controller.starsEarned, unlockedNewLevel: didUnlockNewLevel);

    final nextLevelId = controller.level.id + 1;
    final hasNextLevel = nextLevelId <= LevelData.levels.length;
    final navigator = Navigator.of(context);

    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Level Complete',
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) => LevelCompleteOverlay(
        stars: controller.starsEarned,
        moves: controller.moves,
        bestMoves: result.bestMoves,
        coinsAwarded: result.coinsAwarded,
        hasNextLevel: hasNextLevel,
        onNextLevel: () {
          navigator.pop();
          navigator.pushReplacementNamed(AppRoutes.game, arguments: nextLevelId);
        },
        onHome: () => navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  /// Fires the level-complete screen's reward sounds, staggered to
  /// roughly track [LevelCompleteOverlay]'s own reveal animation
  /// (each star in [StarRow] pops in at 350ms + index*150ms, and the
  /// coin badge's elastic scale-in starts immediately) without this
  /// screen needing to know anything about that widget's internals.
  void _playCompletionSounds({required int stars, required bool unlockedNewLevel}) {
    final audio = context.read<AudioService>();
    for (var i = 0; i < stars; i++) {
      Future.delayed(Duration(milliseconds: 350 + i * 150), () {
        if (mounted) audio.playStar();
      });
    }
    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) audio.playCoin();
    });
    if (unlockedNewLevel) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) audio.playUnlock();
      });
    }
  }

  void _onHint(GameController controller) {
    final progressController = context.read<ProgressController>();
    if (!progressController.spendHint()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hints left — visit the shop')),
      );
      return;
    }
    controller.showHint();
  }

  void _onUndo(GameController controller) {
    if (!controller.canUndo) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing to undo')));
      return;
    }
    final progressController = context.read<ProgressController>();
    if (!progressController.spendUndo()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No undos left — visit the shop')),
      );
      return;
    }
    controller.undo();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final progress = context.watch<ProgressController>().progress;
    final level = controller.level;

    if (controller.isSolved && !_overlayShown) {
      _overlayShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleSolved(controller));
    }

    final optimal = level.optimalMoves;
    final projectedStars = controller.moves <= optimal
        ? 3
        : (controller.moves <= optimal + 1 ? 2 : 1);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(level.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.pause_rounded),
            onPressed: () => _openPause(controller),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HudChip(icon: Icons.swap_horiz_rounded, label: '${controller.moves} moves'),
                  StarRow(stars: projectedStars, size: 18),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                        boxShadow: const [
                          BoxShadow(color: Colors.black38, blurRadius: 24, offset: Offset(0, 12)),
                        ],
                      ),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: level.gridSize,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: level.gridSize * level.gridSize,
                        itemBuilder: (context, index) {
                          final row = index ~/ level.gridSize;
                          final col = index % level.gridSize;
                          final arrow = _arrowAt(controller.arrows, row, col);
                          if (arrow == null) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLow,
                                borderRadius: BorderRadius.circular(14),
                              ),
                            );
                          }

                          final arrowIndex = level.arrows.indexOf(arrow);
                          return ArrowTile(
                            key: ValueKey('arrow_${arrow.id}'),
                            arrow: arrow,
                            color: AppColors.arrowColor(arrowIndex),
                            removed: controller.isRemoved(arrow.id),
                            hinted: controller.hintedArrowId == arrow.id,
                            shaking: controller.shakingArrowId == arrow.id,
                            onTap: () => controller.tapArrow(arrow),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: _ToolButton(
                      icon: Icons.undo_rounded,
                      label: 'Undo',
                      badge: progress.undos,
                      onTap: () => _onUndo(controller),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToolButton(
                      icon: Icons.lightbulb_rounded,
                      label: 'Hint',
                      badge: progress.hints,
                      onTap: () => _onHint(controller),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToolButton(
                      icon: Icons.refresh_rounded,
                      label: 'Restart',
                      onTap: () {
                        controller.reset();
                        setState(() => _overlayShown = false);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HudChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? badge;
  final VoidCallback onTap;

  const _ToolButton({required this.icon, required this.label, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: AppColors.primary, size: 22),
                  if (badge != null)
                    Positioned(
                      right: -10,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '$badge',
                          style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
