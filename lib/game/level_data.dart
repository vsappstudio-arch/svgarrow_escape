import '../models/arrow_model.dart';
import '../models/level_model.dart';

/// Static level definitions used until a real level loader exists.
///
/// Levels 1-5 are the tutorial: hand-written, single "chains" (the
/// last-listed arrow always starts unblocked, and removing it unblocks
/// the previous one, and so on) with zero decoys and exactly one legal
/// move at any moment - deliberately trivial, and left untouched by
/// the Level 6-30 redesign below (`test/game/level_design_test.dart`'s
/// "Levels 1-5 remain unchanged" group pins their exact layout).
///
/// Levels 6-30 are built with [_Path], the same builder Levels 31-50
/// already used. The original 1-30 (a single hand-written zigzag
/// motif, just extended by one link or one more disjoint band per
/// level) read as repetitive past the tutorial - almost every board
/// offered exactly one legal move throughout, no arrow was ever
/// genuinely misleading, and going from 30 arrows spread across
/// independent bands to a real gate only happened in the last three
/// levels. This redesign applies the two levers Levels 31-50 already
/// prove out, at a gentler pace appropriate to an earlier tier:
///  - Cross-chain dependencies: starting at Level 11, a second (and
///    from Level 13, third) "front" is gated behind another front's
///    progress via a single shared-column arrow, rather than sitting
///    fully independent - the player has to notice a front isn't
///    opening yet and go work the one that is.
///  - Decoys: from Level 15 onward, some arrows read as escapable but
///    are blocked by something 3+ cells down an otherwise-empty line.
/// Difficulty in this range comes from the resulting entanglement
/// (dependency depth, fan-in, gate/decoy count) and from genuinely
/// different board shapes level to level - not from monotonically
/// adding arrows, and not from ever-deeper single chains, which stays
/// Levels 31-50's own signature (see below). Level 22 is a full
/// replacement (the original duplicated Level 21 on a bigger grid);
/// Level 30 specifically is kept shallow (dependency depth well under
/// Level 31's 16) since `level_design_test.dart`'s Level 31-50
/// progression checks anchor directly on Level 30's numbers.
///
/// Levels 31-50 continue from there, unchanged by this redesign.
/// Their difficulty comes from reading the board, not from filling
/// it: boards stay at 9x9-12x12 and around a quarter full, but two
/// things tighten one level at a time from 31 to 50.
///  - How deep the ordering runs: the longest chain of "this arrow
///    can't leave until that one does" grows from 16 links at Level 31
///    to 39 at Level 50.
///  - How much choice there is: the number of arrows that can escape
///    at any given moment falls from about two to exactly one, so by
///    the end there is a single right move each turn and the player
///    has to find it. Decoy arrows - blocked only by something far
///    down an otherwise empty line - make that search real, since
///    tapping one is a wasted move and a lost star.
/// Dots ([ArrowModel.isDot]) stay a Level 41+ variant, arriving one at
/// a time from Level 41 and reaching roughly a third of the board by
/// Level 50, always on the decoys and gates that most need a second
/// look.
///
/// In every level [LevelModel.optimalMoves] equals the arrow count,
/// since a valid removal order exists where each arrow needs exactly
/// one successful tap - which the "solvable in exactly optimalMoves"
/// tests in test/game/puzzle_engine_test.dart verify against the real
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
    _Path(6, 5)
        .walk(0, 0, _up, 'R1 D1 R1 D1 R1 D1 R1 D1')
        .build(),
    _Path(7, 5)
        .walk(0, 0, _up, 'R1 D1 R1 D1 R1 D1 R1 U1')
        .build(),
    _Path(8, 5)
        .walk(4, 4, _down, 'L1 U1 L1 U1 L1 U1 R1 U1 L1')
        .build(),
    _Path(9, 5)
        .walk(0, 0, _up, 'R1 R1 R1 D1')
        .walk(4, 4, _down, 'L1 L1 L1 U1')
        .build(),
    _Path(10, 5)
        .walk(0, 4, _up, 'L1 L1 L1 D1 L1')
        .walk(4, 0, _down, 'R1 R1 R1 U1 R1')
        .build(),
    _Path(11, 6)
        .walk(0, 5, _right, 'L1 L1 L1 L1 L1')
        .at(5, 0, _up)
        .at(5, 1, _left)
        .at(5, 2, _left)
        .at(5, 3, _left)
        .at(5, 4, _left)
        .at(5, 5, _left)
        .build(),
    _Path(12, 6)
        .walk(0, 5, _right, 'L1 L1 D1 L1 L1 L1')
        .at(5, 0, _up)
        .at(5, 1, _left)
        .at(5, 2, _left)
        .at(5, 3, _left)
        .at(5, 4, _left)
        .at(5, 5, _left)
        .build(),
    _Path(13, 6)
        .walk(0, 5, _right, 'L1 L1 D1 L1 L1 L1')
        .at(3, 0, _up)
        .at(3, 1, _left)
        .at(3, 2, _left)
        .at(3, 3, _left)
        .at(3, 4, _left)
        .at(5, 4, _up)
        .at(5, 3, _right)
        .at(5, 2, _right)
        .at(5, 1, _right)
        .at(5, 0, _right)
        .build(),
    _Path(14, 6)
        .walk(0, 5, _right, 'L1 L1 D1 L1 L1 L1')
        .at(3, 0, _up)
        .at(3, 1, _left)
        .at(3, 2, _left)
        .at(3, 3, _left)
        .at(3, 4, _left)
        .at(3, 5, _left)
        .at(5, 5, _up)
        .at(5, 4, _right)
        .at(5, 3, _right)
        .at(5, 2, _right)
        .at(5, 1, _right)
        .at(5, 0, _right)
        .build(),
    _Path(15, 6)
        .walk(0, 5, _right, 'L1 L1 D1 L1 L1 L1 D1')
        .at(3, 0, _up)
        .at(3, 1, _left)
        .at(3, 2, _left)
        .at(3, 3, _left)
        .at(3, 4, _left)
        .at(3, 5, _left)
        .at(5, 5, _up)
        .at(5, 4, _right)
        .at(5, 3, _right)
        .at(5, 2, _right)
        .at(5, 1, _right)
        .at(2, 5, _left)
        .build(),
    _Path(16, 7)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(0, 6, _left)
        .at(6, 0, _left)
        .at(6, 1, _left)
        .at(6, 2, _left)
        .at(6, 3, _left)
        .at(6, 4, _left)
        .at(6, 5, _left)
        .at(6, 6, _left)
        .at(3, 6, _up)
        .at(3, 5, _right)
        .at(3, 4, _right)
        .at(3, 3, _right)
        .at(3, 2, _right)
        .at(1, 0, _down)
        .build(),
    _Path(17, 7)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(0, 6, _left)
        .at(6, 0, _left)
        .at(6, 1, _left)
        .at(6, 2, _left)
        .at(6, 3, _left)
        .at(6, 4, _left)
        .at(6, 5, _left)
        .at(6, 6, _left)
        .at(3, 6, _down)
        .at(3, 5, _right)
        .at(3, 4, _right)
        .at(3, 3, _right)
        .at(3, 2, _right)
        .at(3, 1, _right)
        .at(1, 0, _down)
        .at(1, 3, _left)
        .build(),
    _Path(18, 7)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(0, 6, _left)
        .at(6, 0, _left)
        .at(6, 1, _left)
        .at(6, 2, _left)
        .at(6, 3, _left)
        .at(6, 4, _left)
        .at(6, 5, _left)
        .at(6, 6, _left)
        .at(2, 6, _up)
        .at(2, 5, _right)
        .at(2, 4, _right)
        .at(2, 3, _right)
        .at(4, 6, _down)
        .at(4, 5, _right)
        .at(4, 4, _right)
        .at(4, 3, _right)
        .at(1, 0, _down)
        .at(1, 1, _down)
        .build(),
    _Path(19, 7)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(0, 6, _left)
        .at(6, 0, _left)
        .at(6, 1, _left)
        .at(6, 2, _left)
        .at(6, 3, _left)
        .at(6, 4, _left)
        .at(6, 5, _left)
        .at(6, 6, _left)
        .at(2, 6, _up)
        .at(2, 5, _right)
        .at(2, 4, _right)
        .at(2, 3, _right)
        .at(2, 2, _right)
        .at(4, 6, _down)
        .at(4, 5, _right)
        .at(4, 4, _right)
        .at(4, 3, _right)
        .at(4, 2, _right)
        .at(1, 0, _down)
        .at(1, 1, _down)
        .build(),
    _Path(20, 7)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(0, 6, _left)
        .at(6, 0, _left)
        .at(6, 1, _left)
        .at(6, 2, _left)
        .at(6, 3, _left)
        .at(6, 4, _left)
        .at(6, 5, _left)
        .at(6, 6, _left)
        .at(2, 6, _up)
        .at(2, 5, _right)
        .at(2, 4, _right)
        .at(2, 3, _right)
        .at(2, 2, _right)
        .at(2, 1, _right)
        .at(4, 6, _down)
        .at(4, 5, _right)
        .at(4, 4, _right)
        .at(4, 3, _right)
        .at(4, 2, _right)
        .at(4, 1, _right)
        .at(1, 0, _down)
        .at(1, 3, _left)
        .build(),
    _Path(21, 8)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(0, 6, _left)
        .at(7, 0, _left)
        .at(7, 1, _left)
        .at(7, 2, _left)
        .at(7, 3, _left)
        .at(7, 4, _left)
        .at(7, 5, _left)
        .at(7, 6, _left)
        .at(2, 6, _up)
        .at(2, 5, _right)
        .at(2, 4, _right)
        .at(2, 3, _right)
        .at(2, 2, _right)
        .at(2, 1, _right)
        .at(2, 0, _right)
        .at(6, 6, _down)
        .at(6, 5, _right)
        .at(6, 4, _right)
        .at(6, 3, _right)
        .at(6, 2, _right)
        .at(6, 1, _right)
        .at(6, 0, _right)
        .at(3, 0, _down)
        .at(3, 1, _down)
        .build(),
    _Path(22, 9)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(0, 6, _left)
        .at(0, 7, _left)
        .at(2, 7, _up)
        .at(2, 6, _right)
        .at(2, 5, _right)
        .at(2, 4, _right)
        .at(2, 3, _right)
        .at(2, 2, _right)
        .at(4, 5, _up)
        .at(4, 4, _right)
        .at(4, 3, _right)
        .at(4, 2, _right)
        .at(4, 1, _right)
        .at(4, 0, _right)
        .at(6, 3, _up)
        .at(6, 4, _left)
        .at(6, 5, _left)
        .at(6, 6, _left)
        .at(6, 7, _left)
        .at(1, 0, _down)
        .at(1, 1, _down)
        .at(1, 4, _left)
        .at(1, 8, _left)
        .at(3, 6, _down)
        .build(),
    _Path(23, 9)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(0, 6, _left)
        .at(0, 7, _left)
        .at(2, 7, _up)
        .at(2, 6, _right)
        .at(2, 5, _right)
        .at(2, 4, _right)
        .at(2, 3, _right)
        .at(2, 2, _right)
        .at(2, 1, _right)
        .at(4, 6, _up)
        .at(4, 5, _right)
        .at(4, 4, _right)
        .at(4, 3, _right)
        .at(4, 2, _right)
        .at(4, 1, _right)
        .at(4, 0, _right)
        .at(6, 5, _up)
        .at(6, 6, _left)
        .at(6, 7, _left)
        .at(6, 8, _left)
        .at(0, 8, _down)
        .at(1, 0, _down)
        .at(1, 3, _left)
        .at(1, 8, _down)
        .build(),
    _Path(24, 9)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(0, 6, _left)
        .at(0, 7, _left)
        .at(2, 7, _up)
        .at(2, 6, _right)
        .at(2, 5, _right)
        .at(2, 4, _right)
        .at(2, 3, _right)
        .at(2, 2, _right)
        .at(4, 5, _up)
        .at(4, 4, _right)
        .at(4, 3, _right)
        .at(4, 2, _right)
        .at(4, 1, _right)
        .at(6, 2, _up)
        .at(6, 3, _left)
        .at(6, 4, _left)
        .at(6, 5, _left)
        .at(8, 0, _up)
        .at(8, 1, _left)
        .at(8, 2, _left)
        .at(1, 1, _down)
        .at(1, 4, _left)
        .at(1, 8, _left)
        .at(3, 0, _up)
        .build(),
    _Path(25, 9)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(0, 6, _left)
        .at(0, 7, _left)
        .at(2, 7, _up)
        .at(2, 6, _right)
        .at(2, 5, _right)
        .at(2, 4, _right)
        .at(2, 3, _right)
        .at(2, 2, _right)
        .at(2, 1, _right)
        .at(4, 5, _up)
        .at(4, 4, _right)
        .at(4, 3, _right)
        .at(4, 2, _right)
        .at(4, 1, _right)
        .at(4, 0, _right)
        .at(6, 2, _up)
        .at(6, 3, _left)
        .at(6, 4, _left)
        .at(6, 5, _left)
        .at(6, 6, _left)
        .at(1, 0, _down)
        .at(1, 3, _left)
        .at(1, 6, _left)
        .at(3, 6, _down)
        .build(),
    _Path(26, 9)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(0, 6, _left)
        .at(0, 7, _left)
        .at(2, 7, _up)
        .at(2, 6, _right)
        .at(2, 5, _right)
        .at(2, 4, _right)
        .at(2, 3, _right)
        .at(2, 2, _right)
        .at(2, 1, _right)
        .at(4, 5, _up)
        .at(4, 4, _right)
        .at(4, 3, _right)
        .at(4, 2, _right)
        .at(4, 1, _right)
        .at(4, 0, _right)
        .at(6, 3, _up)
        .at(6, 4, _left)
        .at(6, 5, _left)
        .at(6, 6, _left)
        .at(6, 7, _left)
        .at(8, 1, _up)
        .at(8, 2, _left)
        .at(8, 3, _left)
        .at(8, 4, _left)
        .at(1, 6, _up)
        .at(1, 5, _right)
        .at(1, 4, _right)
        .at(1, 0, _down)
        .at(1, 1, _right)
        .at(3, 6, _down)
        .at(3, 0, _right)
        .at(3, 1, _right)
        .build(),
    _Path(27, 9)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(0, 6, _left)
        .at(0, 7, _left)
        .at(2, 7, _up)
        .at(2, 6, _right)
        .at(2, 5, _right)
        .at(2, 4, _right)
        .at(2, 3, _right)
        .at(2, 2, _right)
        .at(2, 1, _right)
        .at(2, 0, _right)
        .at(4, 5, _up)
        .at(4, 4, _right)
        .at(4, 3, _right)
        .at(4, 2, _right)
        .at(4, 1, _right)
        .at(4, 0, _right)
        .at(6, 3, _up)
        .at(6, 4, _left)
        .at(6, 5, _left)
        .at(6, 6, _left)
        .at(6, 7, _left)
        .at(6, 8, _left)
        .at(8, 1, _up)
        .at(8, 2, _left)
        .at(8, 3, _left)
        .at(8, 4, _left)
        .at(8, 5, _left)
        .at(1, 6, _up)
        .at(1, 5, _right)
        .at(1, 4, _right)
        .at(1, 3, _right)
        .at(0, 8, _down)
        .at(1, 0, _right)
        .at(3, 6, _down)
        .at(3, 0, _right)
        .at(3, 1, _right)
        .at(3, 2, _right)
        .build(),
    _Path(28, 9)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(0, 6, _left)
        .at(0, 7, _left)
        .at(2, 7, _up)
        .at(2, 6, _right)
        .at(2, 5, _right)
        .at(2, 4, _right)
        .at(2, 3, _right)
        .at(2, 2, _right)
        .at(4, 2, _up)
        .at(4, 3, _left)
        .at(4, 4, _left)
        .at(4, 5, _left)
        .at(4, 6, _left)
        .at(4, 7, _left)
        .at(4, 8, _left)
        .at(6, 8, _up)
        .at(6, 7, _right)
        .at(6, 6, _right)
        .at(6, 5, _right)
        .at(6, 4, _right)
        .at(6, 3, _right)
        .at(6, 2, _right)
        .at(8, 1, _up)
        .at(8, 2, _left)
        .at(8, 3, _left)
        .at(1, 6, _up)
        .at(1, 5, _right)
        .at(8, 8, _down)
        .at(1, 0, _right)
        .at(1, 1, _right)
        .at(1, 2, _right)
        .at(4, 0, _up)
        .at(4, 1, _up)
        .at(7, 0, _up)
        .at(7, 1, _up)
        .at(7, 4, _left)
        .at(7, 7, _left)
        .build(),
    _Path(29, 9)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(0, 6, _left)
        .at(0, 7, _left)
        .at(2, 7, _up)
        .at(2, 6, _right)
        .at(2, 5, _right)
        .at(2, 4, _right)
        .at(2, 3, _right)
        .at(2, 2, _right)
        .at(2, 1, _right)
        .at(4, 1, _up)
        .at(4, 2, _left)
        .at(4, 3, _left)
        .at(4, 4, _left)
        .at(4, 5, _left)
        .at(4, 6, _left)
        .at(4, 7, _left)
        .at(6, 7, _up)
        .at(6, 6, _right)
        .at(6, 5, _right)
        .at(6, 4, _right)
        .at(6, 3, _right)
        .at(6, 2, _right)
        .at(6, 1, _right)
        .at(6, 0, _right)
        .at(8, 1, _up)
        .at(8, 2, _left)
        .at(1, 6, _up)
        .at(1, 5, _right)
        .at(8, 8, _down)
        .at(0, 8, _down)
        .at(1, 0, _down)
        .at(1, 1, _right)
        .at(1, 2, _right)
        .at(1, 8, _down)
        .at(2, 0, _down)
        .at(2, 8, _down)
        .at(3, 0, _down)
        .at(3, 3, _left)
        .at(3, 6, _left)
        .at(3, 8, _down)
        .at(4, 8, _down)
        .at(5, 8, _down)
        .build(),
    _Path(30, 9)
        .at(0, 0, _left)
        .at(0, 1, _left)
        .at(0, 2, _left)
        .at(0, 3, _left)
        .at(0, 4, _left)
        .at(0, 5, _left)
        .at(2, 5, _up)
        .at(2, 4, _right)
        .at(2, 3, _right)
        .at(4, 3, _up)
        .at(4, 4, _left)
        .at(4, 5, _left)
        .at(6, 4, _up)
        .at(6, 3, _right)
        .at(8, 2, _up)
        .at(8, 1, _right)
        .at(1, 0, _up)
        .at(1, 1, _left)
        .at(8, 8, _down)
        .at(0, 8, _down)
        .at(1, 4, _left)
        .at(1, 7, _left)
        .at(1, 8, _down)
        .at(2, 0, _right)
        .at(2, 1, _down)
        .at(2, 8, _down)
        .at(3, 1, _down)
        .at(3, 2, _up)
        .at(3, 5, _left)
        .at(3, 8, _down)
        .at(4, 1, _down)
        .build(),

    // Levels 31-50 are laid out with _Path: a wandering chain plus
    // hand-placed openers and decoys - see the class doc.
    _Path(31, 9)
        .walk(8, 0, _down, 'U8 R8 D8 L7 U6 R5 D5 L4 U6 R5 D5')
        .at(0, 6, _up)
        .at(8, 2, _down)
        .at(2, 0, _left)
        .at(7, 8, _right)
        .at(0, 7, _up)
        .at(1, 0, _left)
        .at(8, 3, _right)
        .at(3, 1, _down)
        .at(2, 7, _left)
        .at(3, 2, _down)
        .at(5, 7, _up)
        .build(),
    _Path(32, 9)
        .walk(0, 0, _up, 'R8 D8 L8 U7 R6 D6 L5 U5 R6 D4 L5')
        .at(0, 6, _up)
        .at(8, 1, _down)
        .at(6, 8, _right)
        .at(2, 0, _left)
        .at(0, 7, _up)
        .at(7, 8, _right)
        .at(3, 0, _down)
        .at(1, 5, _left)
        .at(7, 2, _right)
        .at(2, 5, _left)
        .at(6, 3, _right)
        .build(),
    _Path(33, 10)
        .walk(0, 9, _up, 'D9 L9 U8 R8 D7 L7 U8 R5 D7 L4 U5 R5')
        .at(2, 0, _left)
        .at(8, 9, _right)
        .at(9, 1, _down)
        .at(7, 8, _right)
        .at(7, 9, _right)
        .at(0, 0, _down)
        .at(8, 2, _right)
        .at(0, 5, _left)
        .at(7, 3, _right)
        .at(2, 5, _left)
        .build(),
    _Path(34, 10)
        .walk(9, 9, _down, 'U9 L9 D9 R8 U8 L7 D7 R5 U6 L4 D5 R5 U3')
        .at(0, 1, _up)
        .at(9, 7, _down)
        .at(1, 9, _right)
        .at(7, 0, _left)
        .at(2, 8, _down)
        .at(1, 2, _right)
        .at(7, 1, _up)
        .at(8, 7, _left)
        .at(6, 2, _up)
        .at(5, 7, _down)
        .build(),
    _Path(35, 10)
        .walk(9, 0, _down, 'R9 U9 L9 D8 R8 U6 L7 D5 R6 U6 L5 D5 R4 U3')
        .at(0, 1, _up)
        .at(9, 8, _down)
        .at(1, 9, _right)
        .at(7, 0, _left)
        .at(8, 7, _left)
        .at(3, 8, _down)
        .at(6, 1, _up)
        .at(3, 7, _down)
        .at(5, 2, _up)
        .at(4, 6, _down)
        .build(),
    _Path(36, 10)
        .walk(0, 0, _up, 'R9 D9 L9 U8 R8 D7 L7 U6 R5 D5 L4 U4 R5 D3 L4')
        .at(0, 6, _up)
        .at(9, 1, _down)
        .at(7, 9, _right)
        .at(1, 7, _left)
        .at(8, 2, _right)
        .at(2, 5, _left)
        .at(2, 7, _left)
        .at(3, 5, _left)
        .at(6, 4, _right)
        .build(),
    _Path(37, 11)
        .walk(0, 10, _up, 'D10 L10 U10 R9 D9 L8 U8 R7 D7 L6 U6 R4 D5 L3 U3 R4')
        .at(0, 6, _up)
        .at(10, 1, _down)
        .at(7, 10, _right)
        .at(9, 2, _right)
        .at(2, 1, _down)
        .at(7, 8, _up)
        .at(3, 2, _down)
        .at(2, 7, _left)
        .at(3, 3, _down)
        .build(),
    _Path(38, 11)
        .walk(10, 10, _down, 'L10 U9 R10 D8 L9 U9 R8 D8 L7 U6 R5 D5 L4 U4 R5 D3 L4')
        .at(0, 7, _up)
        .at(10, 1, _down)
        .at(8, 10, _right)
        .at(2, 1, _down)
        .at(7, 9, _up)
        .at(3, 2, _down)
        .at(2, 8, _left)
        .at(4, 3, _down)
        .at(6, 5, _right)
        .build(),
    _Path(39, 11)
        .walk(10, 0, _down, 'U10 R10 D10 L9 U8 R8 D7 L7 U8 R5 D7 L4 U5 R5 D4 L4 U3 R1')
        .at(0, 7, _up)
        .at(10, 2, _down)
        .at(8, 9, _up)
        .at(9, 3, _right)
        .at(1, 6, _left)
        .at(1, 8, _left)
        .at(3, 6, _left)
        .at(7, 5, _right)
        .at(4, 6, _left)
        .build(),
    _Path(40, 11)
        .walk(0, 0, _up, 'R10 D10 L10 U9 R8 D8 L7 U6 R8 D5 L7 U6 R5 D5 L4 U3 R2 D2 L1')
        .at(0, 5, _up)
        .at(9, 10, _right)
        .at(9, 2, _right)
        .at(2, 1, _down)
        .at(8, 3, _right)
        .at(4, 2, _down)
        .at(6, 7, _up)
        .at(4, 4, _left)
        .at(4, 6, _left)
        .build(),
    _Path(41, 11)
        .walk(0, 10, _up, 'D10 L10 U10 R9 D9 L8 U8 R7 D7 L6 U6 R4 D5 L3 U3 R4 D2 L3 U3 R1')
        .at(0, 6, _up)
        .at(10, 1, _down)
        .at(7, 10, _right)
        .at(2, 1, _down)
        .at(7, 8, _up)
        .at(3, 2, _down)
        .at(2, 7, _left)
        .at(5, 3, _down)
        .at(6, 5, _right)
        .at(5, 5, _up, dot: true)
        .build(),
    _Path(42, 11)
        .walk(10, 10, _down, 'U10 L10 D10 R8 U8 L7 D7 R8 U8 L7 D7 R5 U5 L4 D4 R3 U2 L2 D1 R1 U2')
        .at(0, 1, _up)
        .at(10, 7, _down)
        .at(9, 7, _left)
        .at(1, 3, _right)
        .at(7, 2, _up)
        .at(3, 4, _right)
        .at(7, 5, _left)
        .at(4, 6, _down, dot: true)
        .at(5, 5, _right, dot: true)
        .build(),
    _Path(43, 11)
        .walk(10, 0, _down, 'U10 R10 D10 L9 U8 R8 D7 L7 U8 R5 D7 L4 U5 R5 D4 L4 U3 R1 D2 R1 U2')
        .at(0, 5, _up)
        .at(9, 3, _right)
        .at(3, 2, _down)
        .at(1, 8, _left)
        .at(4, 3, _down)
        .at(6, 8, _up)
        .at(5, 4, _down, dot: true)
        .at(5, 5, _up, dot: true)
        .at(5, 6, _down, dot: true)
        .build(),
    _Path(44, 12)
        .walk(0, 0, _up, 'R11 D11 L11 U10 R10 D9 L9 U7 R8 D6 L7 U7 R5 D6 L4 U4 R5 D3 L4 U2 R1 R1')
        .at(5, 0, _left)
        .at(4, 1, _down)
        .at(8, 9, _up)
        .at(9, 3, _right)
        .at(2, 6, _left)
        .at(8, 4, _right, dot: true)
        .at(4, 6, _left, dot: true)
        .at(6, 4, _down, dot: true)
        .at(6, 5, _up, dot: true)
        .build(),
    _Path(45, 12)
        .walk(0, 11, _up, 'L11 D11 R10 U9 L9 D8 R10 U9 L9 D8 R7 U6 L6 D5 R4 U3 L3 D2 R4 U3 L3 D2 R1')
        .at(0, 1, _up)
        .at(1, 3, _right)
        .at(8, 2, _up)
        .at(4, 9, _down, dot: true)
        .at(7, 3, _up, dot: true)
        .at(8, 8, _left, dot: true)
        .at(6, 4, _up, dot: true)
        .at(4, 6, _right, dot: true)
        .at(4, 7, _right, dot: true)
        .build(),
    _Path(46, 12)
        .walk(11, 11, _down, 'U11 L11 D11 R9 U9 L8 D8 R9 U9 L8 D8 R6 U6 L5 D5 R3 U3 R1 D2 L2 L1 U1 U2 R1 D2')
        .at(3, 10, _down)
        .at(8, 2, _up, dot: true)
        .at(4, 8, _down, dot: true)
        .at(7, 3, _up, dot: true)
        .at(8, 7, _left, dot: true)
        .at(6, 7, _up, dot: true)
        .at(4, 6, _left, dot: true)
        .at(6, 6, _down, dot: true)
        .build(),
    _Path(47, 12)
        .walk(11, 0, _down, 'U11 R11 D11 L10 U9 R8 D8 L7 U9 R8 D8 L7 U6 R5 D5 L4 U4 R3 D3 L1 U1 U1 L1 D1 D1')
        .at(0, 5, _up, dot: true)
        .at(3, 2, _down, dot: true)
        .at(8, 10, _up, dot: true)
        .at(4, 3, _down, dot: true)
        .at(7, 8, _up, dot: true)
        .at(5, 4, _down, dot: true)
        .at(6, 7, _up, dot: true)
        .at(5, 7, _up, dot: true)
        .at(4, 6, _left, dot: true)
        .build(),
    _Path(48, 12)
        .walk(0, 0, _up, 'R11 D11 L11 U10 R10 D9 L9 U7 R8 D6 L7 U7 R5 D6 L4 U4 R5 D3 L3 L1 U1 U1 R1 D1 R1 U1', dots: {9, 18})
        .at(8, 9, _up, dot: true)
        .at(9, 3, _right, dot: true)
        .at(2, 6, _left, dot: true)
        .at(8, 4, _right, dot: true)
        .at(4, 6, _left, dot: true)
        .at(7, 6, _right, dot: true)
        .at(6, 8, _up, dot: true)
        .at(5, 8, _up, dot: true)
        .at(4, 5, _left, dot: true)
        .build(),
    _Path(49, 12)
        .walk(0, 11, _up, 'L11 D11 R10 U9 L9 D8 R10 U9 L9 D8 R7 U6 L6 D5 R4 U3 L3 D2 R1 U3 R1 R1 R1 D2 L2 D1 R2 D1', dots: {6, 12, 17, 23})
        .at(9, 8, _left, dot: true)
        .at(4, 9, _down, dot: true)
        .at(7, 3, _up, dot: true)
        .at(6, 7, _down, dot: true)
        .at(6, 4, _up, dot: true)
        .at(6, 5, _down, dot: true)
        .at(5, 5, _right, dot: true)
        .at(5, 6, _right, dot: true)
        .at(7, 7, _down, dot: true)
        .build(),
    _Path(50, 12)
        .walk(11, 11, _down, 'U11 L11 D11 R9 U9 L8 D8 R9 U9 L8 D8 R6 U6 L5 D5 R3 U3 L1 L1 D1 D1 R1 U1 U2 R1 R1 D2 D1 D1', dots: {4, 9, 13, 17, 21, 26})
        .at(8, 2, _up, dot: true)
        .at(4, 8, _down, dot: true)
        .at(7, 3, _up, dot: true)
        .at(6, 6, _down, dot: true)
        .at(7, 6, _down, dot: true)
        .at(8, 5, _left, dot: true)
        .at(8, 4, _left, dot: true)
        .at(6, 3, _up, dot: true)
        .at(5, 3, _up, dot: true)
        .build(),
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
const _up = ArrowDirection.up;
const _down = ArrowDirection.down;
const _left = ArrowDirection.left;
const _right = ArrowDirection.right;

/// Lays out one of the Levels 31-50 boards.
///
/// [walk] draws the level's spine: a chain of arrows where each one
/// points back at the arrow before it, so it stays blocked until that
/// one escapes. Because the chain turns and jumps around the board,
/// the single escapable arrow moves somewhere new every time, which is
/// what stops these levels being solved by sweeping one edge.
///
/// [at] then adds the two kinds of arrow that turn a chain into a
/// puzzle:
///  - openers: arrows that can be taken from move one, so there is
///    somewhere safe to start, and which sit in other arrows' paths so
///    that clearing them opens the board up;
///  - decoys: arrows placed so that the only thing blocking them is far
///    down an otherwise empty row or column. They read as escapable all
///    game, and tapping one early is exactly the wasted move that costs
///    a star.
///
/// Every board is checked by the tests in test/game: each level is
/// solved against the real [PuzzleEngine] in exactly optimalMoves, its
/// dependency graph is proved acyclic, and the difficulty run from 31
/// to 50 is checked to be monotonic.
class _Path {
  _Path(this._id, this._gridSize);

  final int _id;
  final int _gridSize;
  final List<ArrowModel> _arrows = [];

  _Path at(int row, int col, ArrowDirection direction, {bool dot = false}) {
    _arrows.add(ArrowModel(
      id: 'a${_arrows.length + 1}',
      row: row,
      col: col,
      direction: direction,
      isDot: dot,
    ));
    return this;
  }

  /// Places the first arrow at ([row], [col]) facing [firstDir], then
  /// follows [moves] - 'R3 D2 L4' means "three cells right, two down,
  /// four left". Each step's arrow points back the way it came, so it
  /// is blocked by the arrow it just came from. [dots] marks chain
  /// positions that render as the Level 41+ dot variant.
  _Path walk(int row, int col, ArrowDirection firstDir, String moves, {Set<int> dots = const {}}) {
    at(row, col, firstDir, dot: dots.contains(0));
    var r = row;
    var c = col;
    var index = 0;
    for (final move in moves.split(' ')) {
      final step = int.parse(move.substring(1));
      index++;
      switch (move[0]) {
        case 'R':
          c += step;
          at(r, c, ArrowDirection.left, dot: dots.contains(index));
        case 'L':
          c -= step;
          at(r, c, ArrowDirection.right, dot: dots.contains(index));
        case 'D':
          r += step;
          at(r, c, ArrowDirection.up, dot: dots.contains(index));
        case 'U':
          r -= step;
          at(r, c, ArrowDirection.down, dot: dots.contains(index));
      }
    }
    return this;
  }

  LevelModel build() {
    return LevelModel(
      id: _id,
      name: 'Level $_id',
      gridSize: _gridSize,
      difficulty: _id,
      optimalMoves: _arrows.length,
      arrows: List.unmodifiable(_arrows),
    );
  }
}
