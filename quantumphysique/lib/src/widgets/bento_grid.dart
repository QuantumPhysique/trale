import 'package:flutter/material.dart';
import 'package:quantumphysique/src/widgets/bento_card.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';

/// Computed position and size for a single [QPBentoCard] within the grid.
class _BentoPlacement {
  _BentoPlacement({
    required this.card,
    required this.column,
    required this.row,
  });

  final QPBentoCard card;
  final int column;
  final int row;
}

/// A bento-style grid layout that auto-arranges [QPBentoCard] children.
class QPBentoGrid extends StatelessWidget {
  /// Constructor.
  const QPBentoGrid({required this.children, this.columns = 12, super.key});

  /// Cards to lay out.
  final List<QPBentoCard> children;

  /// Total number of columns in the grid.
  final int columns;

  /// Pack cards using a 2D first-fit algorithm.
  List<_BentoPlacement> _computePlacements(double gap) {
    final int initialRows = children.length * 2;
    final List<List<bool>> grid = List<List<bool>>.generate(
      initialRows,
      (_) => List<bool>.filled(columns, false),
    );

    final List<_BentoPlacement> placements = <_BentoPlacement>[];

    for (final QPBentoCard card in children) {
      final int colSpan = card.columnSpan.clamp(1, columns);
      final int rowSpan = card.rowSpan.clamp(1, 100);

      bool placed = false;
      for (int row = 0; !placed; row++) {
        while (row + rowSpan > grid.length) {
          grid.add(List<bool>.filled(columns, false));
        }
        for (int col = 0; col <= columns - colSpan; col++) {
          if (_fits(grid, row, col, rowSpan, colSpan)) {
            placements.add(_BentoPlacement(card: card, column: col, row: row));
            _occupy(grid, row, col, rowSpan, colSpan);
            placed = true;
            break;
          }
        }
      }
    }

    return placements;
  }

  static bool _fits(
    List<List<bool>> grid,
    int row,
    int col,
    int rowSpan,
    int colSpan,
  ) {
    for (int r = row; r < row + rowSpan; r++) {
      for (int c = col; c < col + colSpan; c++) {
        if (grid[r][c]) {
          return false;
        }
      }
    }
    return true;
  }

  static void _occupy(
    List<List<bool>> grid,
    int row,
    int col,
    int rowSpan,
    int colSpan,
  ) {
    for (int r = row; r < row + rowSpan; r++) {
      for (int c = col; c < col + colSpan; c++) {
        grid[r][c] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double gap = QPLayout.bentoPadding;
    const double outerPadding = QPLayout.padding;
    final double availableWidth =
        MediaQuery.sizeOf(context).width - 2 * outerPadding;
    final double cellSize = (availableWidth - (columns - 1) * gap) / columns;

    final List<_BentoPlacement> placements = _computePlacements(gap);

    int maxRow = 0;
    for (final _BentoPlacement p in placements) {
      final int endRow = p.row + p.card.rowSpan.clamp(1, 100);
      if (endRow > maxRow) {
        maxRow = endRow;
      }
    }

    final double totalHeight = maxRow > 0
        ? maxRow * cellSize + (maxRow - 1) * gap
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: outerPadding),
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          children: <Widget>[
            for (final _BentoPlacement p in placements)
              Positioned(
                left: p.column * (cellSize + gap),
                top: p.row * (cellSize + gap),
                width:
                    p.card.columnSpan * cellSize +
                    (p.card.columnSpan - 1) * gap,
                height: () {
                  final int rs = p.card.rowSpan.clamp(1, 100);
                  return rs * cellSize + (rs - 1) * gap;
                }(),
                child: p.card,
              ),
          ],
        ),
      ),
    );
  }
}
