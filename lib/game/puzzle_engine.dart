import '../models/arrow_model.dart';
import '../models/level_model.dart';

/// Runs the escape logic for a single [LevelModel]: which arrows can
/// currently escape, and tracks which have already left the grid.
class PuzzleEngine {
  final LevelModel level;
  final Set<String> _removedIds = {};
  int _moves = 0;

  PuzzleEngine(this.level);

  /// Total tap attempts made so far, including ones that were blocked.
  int get moves => _moves;

  bool get isSolved => _removedIds.length == level.arrows.length;

  /// 3/2/1 stars based on how close [moves] came to [LevelModel.optimalMoves]
  /// once the level is solved; 0 while still in progress.
  int get starsEarned {
    if (!isSolved) return 0;
    final optimal = level.optimalMoves;
    if (_moves <= optimal) return 3;
    if (_moves <= optimal + 1) return 2;
    return 1;
  }

  List<ArrowModel> get activeArrows =>
      level.arrows.where((arrow) => !_removedIds.contains(arrow.id)).toList();

  bool isRemoved(String arrowId) => _removedIds.contains(arrowId);

  /// Whether [arrow] has a clear path off the grid in its direction, i.e.
  /// no other active arrow sits between it and the edge.
  bool canEscape(ArrowModel arrow) {
    for (final other in activeArrows) {
      if (other.id == arrow.id) continue;
      if (_blocks(arrow, other)) return false;
    }
    return true;
  }

  bool _blocks(ArrowModel arrow, ArrowModel other) {
    switch (arrow.direction) {
      case ArrowDirection.up:
        return other.col == arrow.col && other.row < arrow.row;
      case ArrowDirection.down:
        return other.col == arrow.col && other.row > arrow.row;
      case ArrowDirection.left:
        return other.row == arrow.row && other.col < arrow.col;
      case ArrowDirection.right:
        return other.row == arrow.row && other.col > arrow.col;
    }
  }

  /// Attempts to remove the arrow with [arrowId]. Returns true if it was
  /// able to escape and was removed, false if it's currently blocked.
  /// Every attempt (blocked or not) counts toward [moves].
  bool tryRemove(String arrowId) {
    if (_removedIds.contains(arrowId)) return false;
    final arrow = level.arrows.firstWhere(
      (a) => a.id == arrowId,
      orElse: () => throw ArgumentError('Unknown arrow id: $arrowId'),
    );
    _moves++;
    if (!canEscape(arrow)) return false;
    _removedIds.add(arrowId);
    return true;
  }

  void reset() {
    _removedIds.clear();
    _moves = 0;
  }
}
