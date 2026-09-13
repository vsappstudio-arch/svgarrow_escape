import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../game/level_data.dart';
import '../models/level_model.dart';
import '../state/progress_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/coin_badge.dart';
import '../widgets/star_row.dart';

/// A polished, node-based progression path for World 1 rather than a
/// plain list — completed, current, and locked levels are all visually
/// distinct, and the path opens on the player's current level so the
/// level they just finished, the one to play now, and the next locked
/// one are all in view together.
class LevelMapTab extends StatefulWidget {
  const LevelMapTab({super.key});

  @override
  State<LevelMapTab> createState() => _LevelMapTabState();
}

class _LevelMapTabState extends State<LevelMapTab> {
  static const double _connectorHeight = 36;
  static const double _listPadding = 28;

  final ScrollController _scrollController = ScrollController();

  /// The node index the path was last scrolled to, so the screen
  /// re-anchors when progression actually advances but otherwise
  /// leaves the player's own scrolling alone.
  int? _anchoredIndex;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Approximate height of one row of the path (connector + node).
  /// Only used to pick a scroll offset, so an estimate is fine — the
  /// list still lays its children out normally, and the offset is
  /// clamped to the real scroll extent.
  double _rowExtent(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    return _connectorHeight + 76 + 8 + textScaler.scale(16) + 4 + 14 + 6 + textScaler.scale(18);
  }

  /// Scrolls so the level *before* [index] sits near the top, which
  /// puts the just-completed level, the current one, and the next
  /// locked one on screen together.
  void _anchorTo(int index) {
    if (_anchoredIndex == index) return;
    _anchoredIndex = index;
    _scrollTo(_listPadding + (index - 1) * _rowExtent(context), retries: 2);
  }

  void _scrollTo(double target, {required int retries}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      final reachable = target.clamp(position.minScrollExtent, position.maxScrollExtent);
      if ((reachable - position.pixels).abs() > 0.5) _scrollController.jumpTo(reachable);
      // A lazily-built list only knows the extent of the nodes it has
      // built so far, so a jump toward the end of the path can land
      // short of the target. Another pass, with those nodes now built,
      // settles on the real offset.
      if (retries > 0 && reachable < target) _scrollTo(target, retries: retries - 1);
    });
    // The jump has to happen in a post-frame callback, so make sure
    // there is a frame for it to run after.
    WidgetsBinding.instance.scheduleFrame();
  }

  @override
  Widget build(BuildContext context) {
    final progressController = context.watch<ProgressController>();
    final progress = progressController.progress;
    final levels = LevelData.levels;

    // The current level, or the last one once the whole world is
    // cleared (there is no level beyond the final one to anchor on).
    final currentIndex = levels.indexWhere(
      (level) => progressController.statusFor(level.id) == LevelStatus.current,
    );
    if (progressController.isLoaded) {
      _anchorTo(currentIndex >= 0 ? currentIndex : levels.length - 1);
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('World 1', style: Theme.of(context).textTheme.headlineMedium),
                CoinBadge(coins: progress.coins),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: _listPadding, horizontal: 20),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                final status = progressController.statusFor(level.id);
                final align = index.isEven ? -0.55 : 0.55;

                return Column(
                  children: [
                    if (index > 0)
                      Container(
                        width: 3,
                        height: _connectorHeight,
                        color: status == LevelStatus.locked
                            ? AppColors.border
                            : AppColors.primary.withValues(alpha: 0.35),
                      ),
                    Align(
                      alignment: Alignment(align, 0),
                      child: _LevelNode(
                        level: level,
                        status: status,
                        stars: progressController.starsFor(level.id),
                        // Finished levels stay replayable, exactly as
                        // before — only locked ones refuse taps.
                        onTap: status == LevelStatus.locked
                            ? null
                            : () => Navigator.pushNamed(context, AppRoutes.game, arguments: level.id),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  final LevelModel level;
  final LevelStatus status;
  final int stars;
  final VoidCallback? onTap;

  const _LevelNode({
    required this.level,
    required this.status,
    required this.stars,
    required this.onTap,
  });

  bool get _unlocked => status != LevelStatus.locked;
  bool get _isCurrent => status == LevelStatus.current;

  Color get _borderColor {
    switch (status) {
      case LevelStatus.current:
        return AppColors.primary;
      case LevelStatus.completed:
        return AppColors.success.withValues(alpha: 0.55);
      case LevelStatus.locked:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: !_unlocked ? null : (_isCurrent ? AppColors.primaryButtonGradient : AppColors.cardGradient),
                color: _unlocked ? null : AppColors.surfaceLow,
                border: Border.all(color: _borderColor, width: _isCurrent ? 3 : 1.5),
                boxShadow: _isCurrent
                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)]
                    : null,
              ),
              child: Center(
                child: _unlocked
                    ? Text(
                        '${level.id}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : const Icon(Icons.lock_rounded, color: AppColors.textDisabled, size: 26),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              level.name,
              style: TextStyle(
                color: _unlocked ? AppColors.textPrimary : AppColors.textDisabled,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            _unlocked ? StarRow(stars: stars, size: 14) : const SizedBox(height: 14),
            const SizedBox(height: 6),
            _LevelStatusLabel(status: status),
          ],
        ),
      ),
    );
  }
}

/// The one-glance answer to "what did I just finish, what do I play
/// now, and what comes after that?".
class _LevelStatusLabel extends StatelessWidget {
  final LevelStatus status;

  const _LevelStatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case LevelStatus.completed:
        return const _StatusText(
          icon: Icons.check_circle_rounded,
          label: 'Completed',
          color: AppColors.success,
        );
      case LevelStatus.current:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            gradient: AppColors.primaryButtonGradient,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'PLAY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        );
      case LevelStatus.locked:
        return const _StatusText(
          icon: Icons.lock_rounded,
          label: 'Locked',
          color: AppColors.textDisabled,
        );
    }
  }
}

class _StatusText extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusText({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
