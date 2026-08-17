import '../models/arrow_model.dart';
import '../models/level_model.dart';

/// Static level definitions used until a real level loader exists.
///
/// Each level is a "chain": the last-listed arrow always starts
/// unblocked, and removing it unblocks the previous one, and so on.
/// [LevelModel.optimalMoves] equals the arrow count, since each arrow
/// needs exactly one successful tap when removed in the right order.
class LevelData {
  LevelData._();

  static final List<LevelModel> levels = [
    LevelModel(
      id: 1,
      name: 'Level 1',
      gridSize: 3,
      difficulty: 1,
      optimalMoves: 2,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a2', row: 2, col: 1, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 2,
      name: 'Level 2',
      gridSize: 4,
      difficulty: 2,
      optimalMoves: 3,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a2', row: 2, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a3', row: 2, col: 3, direction: ArrowDirection.up),
      ],
    ),
    LevelModel(
      id: 3,
      name: 'Level 3',
      gridSize: 4,
      difficulty: 3,
      optimalMoves: 4,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a2', row: 2, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a3', row: 2, col: 3, direction: ArrowDirection.up),
        ArrowModel(id: 'a4', row: 1, col: 3, direction: ArrowDirection.left),
      ],
    ),
    LevelModel(
      id: 4,
      name: 'Level 4',
      gridSize: 4,
      difficulty: 4,
      optimalMoves: 5,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a2', row: 2, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a3', row: 2, col: 3, direction: ArrowDirection.up),
        ArrowModel(id: 'a4', row: 1, col: 3, direction: ArrowDirection.left),
        ArrowModel(id: 'a5', row: 1, col: 2, direction: ArrowDirection.down),
      ],
    ),
    LevelModel(
      id: 5,
      name: 'Level 5',
      gridSize: 4,
      difficulty: 5,
      optimalMoves: 6,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a2', row: 2, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a3', row: 2, col: 3, direction: ArrowDirection.up),
        ArrowModel(id: 'a4', row: 1, col: 3, direction: ArrowDirection.left),
        ArrowModel(id: 'a5', row: 1, col: 2, direction: ArrowDirection.down),
        ArrowModel(id: 'a6', row: 3, col: 2, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 6,
      name: 'Level 6',
      gridSize: 4,
      difficulty: 6,
      optimalMoves: 7,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a2', row: 2, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a3', row: 2, col: 3, direction: ArrowDirection.up),
        ArrowModel(id: 'a4', row: 1, col: 3, direction: ArrowDirection.left),
        ArrowModel(id: 'a5', row: 1, col: 2, direction: ArrowDirection.down),
        ArrowModel(id: 'a6', row: 3, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 3, col: 3, direction: ArrowDirection.right),
      ],
    ),
  ];

  static LevelModel byId(int id) {
    return levels.firstWhere(
      (level) => level.id == id,
      orElse: () => throw ArgumentError('Unknown level id: $id'),
    );
  }
}
