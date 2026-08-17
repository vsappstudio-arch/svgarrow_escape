import 'package:flutter/foundation.dart';

import 'arrow_model.dart';

/// A single puzzle level: a square grid populated with arrows.
@immutable
class LevelModel {
  final int id;
  final String name;
  final int gridSize;
  final int difficulty;
  final int optimalMoves;
  final List<ArrowModel> arrows;

  const LevelModel({
    required this.id,
    required this.name,
    required this.gridSize,
    required this.difficulty,
    required this.optimalMoves,
    required this.arrows,
  });
}
