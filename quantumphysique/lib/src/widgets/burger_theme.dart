/// Burger-style colour-swatch preview widget.
library;

import 'package:flutter/material.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';
import 'package:quantumphysique/src/widgets/tile_group/tile_group.dart';

/// A card showing colour swatches arranged in a "burger" stack.
///
/// Used by theme-selection and scheme-variant carousels to give a compact
/// visual preview of a [ColorScheme].
///
/// The bottom row switches to [colorScheme.primary] when [isSelected] is
/// `true`, signalling the active selection.
class QPBurgerTheme extends StatelessWidget {
  /// Creates a [QPBurgerTheme].
  const QPBurgerTheme({
    super.key,
    required this.colorScheme,
    required this.isSelected,
  });

  /// Colour scheme to preview.
  final ColorScheme colorScheme;

  /// Whether this item is currently selected in the carousel.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.transparent,
        shape: QPLayout.borderShape,
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact =
                constraints.maxWidth < (3 + 4 * 2) * QPLayout.space;
            final List<Color> middleRowColors = compact
                ? <Color>[
                    colorScheme.secondaryContainer,
                    colorScheme.tertiaryContainer,
                  ]
                : <Color>[
                    colorScheme.secondary,
                    colorScheme.secondaryContainer,
                    colorScheme.tertiary,
                    colorScheme.tertiaryContainer,
                  ];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: QPLayout.space,
              children: <Widget>[
                Expanded(
                  child: QPGroupedWidget(
                    color: colorScheme.primary,
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: middleRowColors
                        .map(
                          (Color color) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: QPLayout.space / 2,
                              ),
                              child: QPGroupedWidget(
                                color: color,
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(
                  child: QPGroupedWidget(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.primaryContainer,
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
