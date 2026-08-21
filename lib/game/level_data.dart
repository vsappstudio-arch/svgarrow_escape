import '../models/arrow_model.dart';
import '../models/level_model.dart';

/// Static level definitions used until a real level loader exists.
///
/// Levels 1-30 are the original, deliberately gentle progression:
/// 1-12 are single "chains" (the last-listed arrow always starts
/// unblocked, and removing it unblocks the previous one, and so on),
/// 13+ combine multiple independent chains placed in disjoint row
/// bands, and 28-30 add a "gate" arrow whose column-based dependency
/// transitively requires two or more whole chains to be cleared
/// first.
///
/// Levels 31-50 extend the same chain/gate vocabulary further using
/// [_Builder]:
///  - 31-40 ("hard / endgame prep"): longer chains, more of them per
///    level, and deeper gate-of-gates nesting (a gate whose own
///    dependency is itself two other gates). Grids top out at 12x12
///    and every piece is a normal, fully-visible arrow.
///  - 41-50 ("very hard finale"): the same structures, but arrows can
///    now render as the Level 41+ "dot" visual variant
///    ([ArrowModel.isDot]) - introduced gradually from 41, mixed with
///    the harder gate structures from 46 on, converging on Level 50's
///    three-way gate-of-gates finale.
///
/// In every level [LevelModel.optimalMoves] equals the arrow count,
/// since a valid removal order exists where each arrow needs exactly
/// one successful tap - a property [_Builder.build] relies on, and
/// which the "solvable in exactly optimalMoves" tests in
/// test/game/puzzle_engine_test.dart verify against the real
/// [PuzzleEngine] for every level in [LevelData.levels].
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
    LevelModel(
      id: 7,
      name: 'Level 7',
      gridSize: 5,
      difficulty: 7,
      optimalMoves: 8,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.down),
        ArrowModel(id: 'a2', row: 1, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a4', row: 2, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a5', row: 2, col: 2, direction: ArrowDirection.down),
        ArrowModel(id: 'a6', row: 3, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 3, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a8', row: 4, col: 3, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 8,
      name: 'Level 8',
      gridSize: 5,
      difficulty: 8,
      optimalMoves: 8,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.down),
        ArrowModel(id: 'a5', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 2, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a7', row: 3, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 3, col: 4, direction: ArrowDirection.down),
      ],
    ),
    LevelModel(
      id: 9,
      name: 'Level 9',
      gridSize: 5,
      difficulty: 9,
      optimalMoves: 9,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.down),
        ArrowModel(id: 'a2', row: 1, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a4', row: 2, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a5', row: 2, col: 2, direction: ArrowDirection.down),
        ArrowModel(id: 'a6', row: 3, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 3, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a8', row: 4, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a9', row: 4, col: 4, direction: ArrowDirection.down),
      ],
    ),
    LevelModel(
      id: 10,
      name: 'Level 10',
      gridSize: 5,
      difficulty: 10,
      optimalMoves: 9,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.down),
        ArrowModel(id: 'a5', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 2, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a7', row: 3, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 3, col: 4, direction: ArrowDirection.down),
        ArrowModel(id: 'a9', row: 4, col: 4, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 11,
      name: 'Level 11',
      gridSize: 6,
      difficulty: 11,
      optimalMoves: 10,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.down),
        ArrowModel(id: 'a2', row: 1, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a4', row: 2, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a5', row: 2, col: 2, direction: ArrowDirection.down),
        ArrowModel(id: 'a6', row: 3, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 3, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a8', row: 4, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a9', row: 4, col: 4, direction: ArrowDirection.down),
        ArrowModel(id: 'a10', row: 5, col: 4, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 12,
      name: 'Level 12',
      gridSize: 6,
      difficulty: 12,
      optimalMoves: 10,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.down),
        ArrowModel(id: 'a5', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 2, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a7', row: 3, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 3, col: 4, direction: ArrowDirection.down),
        ArrowModel(id: 'a9', row: 4, col: 4, direction: ArrowDirection.right),
        ArrowModel(id: 'a10', row: 4, col: 5, direction: ArrowDirection.down),
      ],
    ),
    LevelModel(
      id: 13,
      name: 'Level 13',
      gridSize: 6,
      difficulty: 13,
      optimalMoves: 11,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a8', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a9', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a10', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a11', row: 2, col: 3, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 14,
      name: 'Level 14',
      gridSize: 6,
      difficulty: 14,
      optimalMoves: 12,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 0, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a9', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a10', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a11', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a12', row: 2, col: 3, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 15,
      name: 'Level 15',
      gridSize: 6,
      difficulty: 15,
      optimalMoves: 13,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 0, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a9', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a10', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a11', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a12', row: 2, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a13', row: 3, col: 3, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 16,
      name: 'Level 16',
      gridSize: 7,
      difficulty: 16,
      optimalMoves: 14,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 0, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a7', row: 1, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a9', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a10', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a11', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a12', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a13', row: 2, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a14', row: 3, col: 3, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 17,
      name: 'Level 17',
      gridSize: 7,
      difficulty: 17,
      optimalMoves: 15,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 0, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a7', row: 1, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a9', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a10', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a11', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a12', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a13', row: 2, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a14', row: 3, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a15', row: 3, col: 4, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 18,
      name: 'Level 18',
      gridSize: 7,
      difficulty: 18,
      optimalMoves: 16,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 0, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a7', row: 1, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 1, col: 4, direction: ArrowDirection.right),
        ArrowModel(id: 'a9', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a10', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a11', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a12', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a13', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a14', row: 2, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a15', row: 3, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a16', row: 3, col: 4, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 19,
      name: 'Level 19',
      gridSize: 7,
      difficulty: 19,
      optimalMoves: 14,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a8', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a9', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a10', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a11', row: 4, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a12', row: 4, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a13', row: 4, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a14', row: 4, col: 3, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 20,
      name: 'Level 20',
      gridSize: 7,
      difficulty: 20,
      optimalMoves: 15,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a8', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a9', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a10', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a11', row: 2, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a12', row: 4, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a13', row: 4, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a14', row: 4, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a15', row: 4, col: 3, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 21,
      name: 'Level 21',
      gridSize: 7,
      difficulty: 21,
      optimalMoves: 17,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 0, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a9', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a10', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a11', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a12', row: 2, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a13', row: 4, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a14', row: 4, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a15', row: 4, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a16', row: 4, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a17', row: 4, col: 4, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 22,
      name: 'Level 22',
      gridSize: 8,
      difficulty: 22,
      optimalMoves: 17,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 0, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a9', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a10', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a11', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a12', row: 2, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a13', row: 4, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a14', row: 4, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a15', row: 4, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a16', row: 4, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a17', row: 4, col: 4, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 23,
      name: 'Level 23',
      gridSize: 8,
      difficulty: 23,
      optimalMoves: 18,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 0, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a9', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a10', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a11', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a12', row: 2, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a13', row: 3, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a14', row: 4, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a15', row: 4, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a16', row: 4, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a17', row: 4, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a18', row: 4, col: 4, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 24,
      name: 'Level 24',
      gridSize: 8,
      difficulty: 24,
      optimalMoves: 20,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 0, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a7', row: 1, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a9', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a10', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a11', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a12', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a13', row: 2, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a14', row: 3, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a15', row: 4, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a16', row: 4, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a17', row: 4, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a18', row: 4, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a19', row: 4, col: 4, direction: ArrowDirection.right),
        ArrowModel(id: 'a20', row: 4, col: 5, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 25,
      name: 'Level 25',
      gridSize: 8,
      difficulty: 25,
      optimalMoves: 18,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a8', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a9', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a10', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a11', row: 4, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a12', row: 4, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a13', row: 4, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a14', row: 4, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a15', row: 5, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a16', row: 5, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a17', row: 5, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a18', row: 5, col: 3, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 26,
      name: 'Level 26',
      gridSize: 8,
      difficulty: 26,
      optimalMoves: 19,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 0, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a9', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a10', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a11', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a12', row: 4, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a13', row: 4, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a14', row: 4, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a15', row: 4, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a16', row: 5, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a17', row: 5, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a18', row: 5, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a19', row: 5, col: 3, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 27,
      name: 'Level 27',
      gridSize: 8,
      difficulty: 27,
      optimalMoves: 21,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 0, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a9', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a10', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a11', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a12', row: 2, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a13', row: 4, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a14', row: 4, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a15', row: 4, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a16', row: 4, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a17', row: 4, col: 4, direction: ArrowDirection.right),
        ArrowModel(id: 'a18', row: 5, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a19', row: 5, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a20', row: 5, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a21', row: 5, col: 3, direction: ArrowDirection.right),
      ],
    ),
    LevelModel(
      id: 28,
      name: 'Level 28',
      gridSize: 9,
      difficulty: 28,
      optimalMoves: 23,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 0, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a7', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a9', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a10', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a11', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a12', row: 2, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a13', row: 4, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a14', row: 4, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a15', row: 4, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a16', row: 4, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a17', row: 4, col: 4, direction: ArrowDirection.right),
        ArrowModel(id: 'a18', row: 5, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a19', row: 5, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a20', row: 5, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a21', row: 5, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a22', row: 5, col: 4, direction: ArrowDirection.right),
        ArrowModel(id: 'a23', row: 6, col: 0, direction: ArrowDirection.up),
      ],
    ),
    LevelModel(
      id: 29,
      name: 'Level 29',
      gridSize: 9,
      difficulty: 29,
      optimalMoves: 24,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 0, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a7', row: 1, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a9', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a10', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a11', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a12', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a13', row: 2, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a14', row: 4, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a15', row: 4, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a16', row: 4, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a17', row: 4, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a18', row: 4, col: 4, direction: ArrowDirection.right),
        ArrowModel(id: 'a19', row: 5, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a20', row: 5, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a21', row: 5, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a22', row: 5, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a23', row: 5, col: 4, direction: ArrowDirection.right),
        ArrowModel(id: 'a24', row: 6, col: 0, direction: ArrowDirection.up),
      ],
    ),
    LevelModel(
      id: 30,
      name: 'Level 30',
      gridSize: 9,
      difficulty: 30,
      optimalMoves: 27,
      arrows: const [
        ArrowModel(id: 'a1', row: 0, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a2', row: 0, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a3', row: 1, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a4', row: 1, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a5', row: 0, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a6', row: 0, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a7', row: 1, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a8', row: 2, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a9', row: 2, col: 1, direction: ArrowDirection.down),
        ArrowModel(id: 'a10', row: 3, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a11', row: 3, col: 2, direction: ArrowDirection.up),
        ArrowModel(id: 'a12', row: 2, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a13', row: 2, col: 3, direction: ArrowDirection.down),
        ArrowModel(id: 'a14', row: 3, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a15', row: 4, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a16', row: 4, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a17', row: 4, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a18', row: 4, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a19', row: 4, col: 4, direction: ArrowDirection.right),
        ArrowModel(id: 'a20', row: 4, col: 5, direction: ArrowDirection.right),
        ArrowModel(id: 'a21', row: 5, col: 0, direction: ArrowDirection.right),
        ArrowModel(id: 'a22', row: 5, col: 1, direction: ArrowDirection.right),
        ArrowModel(id: 'a23', row: 5, col: 2, direction: ArrowDirection.right),
        ArrowModel(id: 'a24', row: 5, col: 3, direction: ArrowDirection.right),
        ArrowModel(id: 'a25', row: 5, col: 4, direction: ArrowDirection.right),
        ArrowModel(id: 'a26', row: 5, col: 5, direction: ArrowDirection.right),
        ArrowModel(id: 'a27', row: 6, col: 0, direction: ArrowDirection.up),
      ],
    ),

    // Levels 31-50 are built from _Builder's two composable, provably
    // acyclic primitives - see the class doc for why mixing them can
    // never deadlock a level.
    _Builder()
        .chain(0, 0, 4)
        .chain(1, 0, 4)
        .chain(2, 0, 4)
        .gate(3, 0)
        .build(31, 9),
    _Builder()
        .chain(0, 0, 5)
        .chain(1, 0, 5)
        .chain(2, 0, 5)
        .gate(3, 0)
        .build(32, 9),
    _Builder()
        .chain(0, 0, 4)
        .chain(1, 0, 4)
        .chain(2, 0, 4)
        .chain(3, 0, 4)
        .gate(4, 0)
        .build(33, 10),
    _Builder()
        .chain(0, 0, 5)
        .chain(1, 0, 5)
        .chain(2, 0, 5)
        .chain(3, 0, 5)
        .gate(4, 0)
        .build(34, 10),
    _Builder()
        .chain(0, 1, 4)
        .chain(1, 1, 4)
        .chain(2, 5, 4)
        .chain(3, 5, 4)
        .chain(4, 8, 2)
        .gate(5, 1)
        .gate(5, 5)
        .gate(5, 8)
        .chain(6, 0, 1)
        .build(35, 10),
    _Builder()
        .chain(0, 1, 5)
        .chain(1, 1, 5)
        .chain(2, 6, 5)
        .chain(3, 6, 5)
        .chain(4, 2, 3)
        .gate(6, 1)
        .gate(6, 6)
        .chain(7, 0, 1)
        .build(36, 11),
    _Builder()
        .chain(0, 1, 5)
        .chain(1, 1, 5)
        .chain(2, 6, 5)
        .chain(3, 6, 5)
        .chain(4, 1, 5)
        .chain(5, 1, 5)
        .gate(6, 1)
        .gate(6, 6)
        .chain(7, 0, 1)
        .build(37, 11),
    _Builder()
        .chain(0, 1, 5)
        .chain(1, 1, 5)
        .chain(2, 1, 5)
        .chain(3, 1, 5)
        .chain(4, 6, 5)
        .chain(5, 6, 5)
        .chain(6, 6, 5)
        .gate(7, 1)
        .gate(7, 6)
        .chain(8, 0, 1)
        .build(38, 11),
    _Builder()
        .chain(0, 1, 4)
        .chain(1, 1, 4)
        .chain(2, 5, 4)
        .chain(3, 5, 4)
        .gate(4, 1)
        .gate(4, 5)
        .chain(4, 0, 1)
        .chain(5, 1, 4)
        .chain(6, 1, 4)
        .chain(7, 5, 4)
        .chain(8, 5, 4)
        .gate(9, 1)
        .gate(9, 5)
        .chain(9, 0, 1)
        .gate(10, 0)
        .build(39, 11),
    _Builder()
        .chain(0, 1, 5)
        .chain(1, 1, 5)
        .chain(2, 6, 5)
        .chain(3, 6, 5)
        .gate(4, 1)
        .gate(4, 6)
        .chain(4, 0, 1)
        .chain(5, 1, 5)
        .chain(6, 1, 5)
        .chain(7, 6, 5)
        .chain(8, 6, 5)
        .gate(9, 1)
        .gate(9, 6)
        .chain(9, 0, 1)
        .gate(10, 0)
        .build(40, 12),

    // Levels 41-50: the Level 41+ "dot" visual variant is introduced
    // gradually (41 has a single dot; by 50 dots make up roughly half
    // the board), layered onto the same chain/gate structures used
    // above so grids stay small and every piece - dot or not - keeps
    // a full-size tap target (see ArrowModel.isDot, ArrowTile).
    _Builder()
        .chain(0, 0, 4)
        .chain(1, 0, 4)
        .chain(2, 0, 4)
        .gate(3, 0, isDot: true)
        .build(41, 9),
    _Builder()
        .chain(0, 0, 4, dotOffsets: {0})
        .chain(1, 0, 4)
        .chain(2, 0, 4)
        .gate(3, 0, isDot: true)
        .build(42, 9),
    _Builder()
        .chain(0, 0, 4)
        .chain(1, 0, 4, dotOffsets: {1, 2})
        .chain(2, 0, 4)
        .chain(3, 0, 4)
        .gate(4, 0, isDot: true)
        .build(43, 10),
    _Builder()
        .chain(0, 0, 4)
        .chain(1, 0, 4)
        .chain(2, 0, 4, dotOffsets: {0, 1, 2, 3})
        .gate(3, 0)
        .build(44, 10),
    _Builder()
        .chain(0, 1, 3)
        .chain(1, 1, 3)
        .gate(2, 1, isDot: true)
        .chain(3, 5, 3)
        .chain(4, 5, 3)
        .gate(5, 5, isDot: true)
        .build(45, 10),
    _Builder()
        .chain(0, 1, 4)
        .chain(1, 1, 4, dotOffsets: {2, 3})
        .chain(2, 5, 4)
        .chain(3, 5, 4)
        .chain(4, 9, 2, dotOffsets: {0, 1})
        .gate(5, 1)
        .gate(5, 5, isDot: true)
        .gate(5, 9)
        .chain(6, 0, 1)
        .build(46, 11),
    _Builder()
        .chain(0, 1, 5)
        .chain(1, 1, 5, dotOffsets: {2, 3, 4})
        .chain(2, 6, 5, dotOffsets: {0, 1})
        .chain(3, 6, 5)
        .gate(4, 1, isDot: true)
        .gate(4, 6)
        .chain(5, 0, 1)
        .build(47, 11),
    _Builder()
        .chain(0, 1, 4)
        .chain(1, 1, 4)
        .chain(2, 5, 4, dotOffsets: {0, 1, 2, 3})
        .chain(3, 5, 4, dotOffsets: {0, 1, 2, 3})
        .gate(4, 1)
        .gate(4, 5)
        .chain(4, 0, 1)
        .chain(5, 1, 4)
        .chain(6, 1, 4)
        .chain(7, 5, 4)
        .chain(8, 5, 4)
        .gate(9, 1, isDot: true)
        .gate(9, 5)
        .chain(9, 0, 1)
        .gate(10, 0)
        .build(48, 11),
    _Builder()
        .chain(0, 1, 5, dotOffsets: {0, 1, 2, 3, 4})
        .chain(1, 1, 5, dotOffsets: {0, 1, 2, 3, 4})
        .chain(2, 5, 5)
        .chain(3, 5, 5)
        .gate(4, 1)
        .gate(4, 5, isDot: true)
        .chain(4, 0, 1)
        .chain(5, 1, 5, dotOffsets: {0, 1, 2, 3, 4})
        .chain(6, 1, 5, dotOffsets: {0, 1, 2, 3, 4})
        .chain(7, 5, 5)
        .chain(8, 5, 5)
        .gate(9, 1)
        .gate(9, 5, isDot: true)
        .chain(9, 0, 1)
        .gate(10, 0, isDot: true)
        .build(49, 11),
    _Builder()
        .chain(0, 1, 5)
        .chain(1, 1, 5)
        .chain(2, 6, 5, dotOffsets: {0, 1, 2, 3, 4})
        .chain(3, 6, 5, dotOffsets: {0, 1, 2, 3, 4})
        .gate(4, 1)
        .gate(4, 6)
        .chain(4, 0, 1, dotOffsets: {0})
        .chain(5, 1, 5, dotOffsets: {0, 1, 2, 3, 4})
        .chain(6, 1, 5, dotOffsets: {0, 1, 2, 3, 4})
        .chain(7, 6, 5)
        .chain(8, 6, 5)
        .gate(9, 1)
        .gate(9, 6)
        .chain(9, 0, 1, dotOffsets: {0})
        .chain(10, 0, 5)
        .gate(11, 0, isDot: true)
        .build(50, 12),
  ];

  static LevelModel byId(int id) {
    return levels.firstWhere(
      (level) => level.id == id,
      orElse: () => throw ArgumentError('Unknown level id: $id'),
    );
  }
}

/// Builds a level's arrow list from two composable pieces:
///  - [chain]: a horizontal run of right-pointing arrows that clears
///    right-to-left; its leftmost ("anchor") arrow is the one blocked
///    by everything else in the chain.
///  - [gate]: a single up-pointing arrow blocked by everything above
///    it in its column - typically one or more chains' anchors,
///    making it depend on all of them being fully cleared first. A
///    length-1 [chain] doubles as a horizontal "gate" that merges two
///    or more [gate]s sharing its row into one dependency, enabling
///    multi-level "gate of gates" nesting.
///
/// [chain] only ever looks at other arrows in its own row; [gate]
/// only ever looks at other arrows in its own column. Two blocking
/// rules restricted to disjoint axes like that can never point back
/// at each other, so any level built purely from these two primitives
/// is guaranteed acyclic (and therefore solvable) regardless of how
/// they're combined - a property the "dependency graph is acyclic"
/// and "solvable in exactly optimalMoves" tests confirm against the
/// real engine for every shipped level.
class _Builder {
  final List<ArrowModel> _arrows = [];
  int _count = 0;

  String _nextId() => 'a${++_count}';

  _Builder chain(int row, int startCol, int length, {Set<int> dotOffsets = const {}}) {
    for (var i = 0; i < length; i++) {
      _arrows.add(ArrowModel(
        id: _nextId(),
        row: row,
        col: startCol + i,
        direction: ArrowDirection.right,
        isDot: dotOffsets.contains(i),
      ));
    }
    return this;
  }

  _Builder gate(int row, int col, {bool isDot = false}) {
    _arrows.add(ArrowModel(id: _nextId(), row: row, col: col, direction: ArrowDirection.up, isDot: isDot));
    return this;
  }

  LevelModel build(int id, int gridSize) {
    return LevelModel(
      id: id,
      name: 'Level $id',
      gridSize: gridSize,
      difficulty: id,
      optimalMoves: _arrows.length,
      arrows: List.unmodifiable(_arrows),
    );
  }
}
