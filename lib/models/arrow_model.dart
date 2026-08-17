import 'package:flutter/material.dart';

/// The direction an arrow points and escapes toward.
enum ArrowDirection { up, down, left, right }

extension ArrowDirectionIcon on ArrowDirection {
  IconData get icon {
    switch (this) {
      case ArrowDirection.up:
        return Icons.arrow_upward;
      case ArrowDirection.down:
        return Icons.arrow_downward;
      case ArrowDirection.left:
        return Icons.arrow_back;
      case ArrowDirection.right:
        return Icons.arrow_forward;
    }
  }
}

/// A single arrow placed on a puzzle grid.
@immutable
class ArrowModel {
  final String id;
  final int row;
  final int col;
  final ArrowDirection direction;

  const ArrowModel({
    required this.id,
    required this.row,
    required this.col,
    required this.direction,
  });
}
