import 'package:flutter/material.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';
import 'package:quantumphysique/src/widgets/tile_group/tile_group.dart';

/// Default shape builder for [QPSelectionCarousel] items.
///
/// Returns a [StadiumBorder] for selected items and an asymmetric
/// [RoundedRectangleBorder] (outer radius 16, inner radius 4) for the rest.
ShapeBorder qpSelectionCarouselItemShape(
  BuildContext context,
  int index,
  int length,
  bool isSelected,
) {
  if (isSelected) {
    return const StadiumBorder();
  }
  const double outerRadius = QPLayout.borderRadius;
  const double innerRadius = QPLayout.innerBorderRadius;
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(
      left: Radius.circular(index == 0 ? outerRadius : innerRadius),
      right: Radius.circular(index == length - 1 ? outerRadius : innerRadius),
    ),
  );
}

/// A generic horizontal carousel for selecting from a list of items.
///
/// Used by [QPThemeSettingsPage] for palette and scheme-variant selection.
class QPSelectionCarousel<T> extends StatefulWidget {
  /// Creates a [QPSelectionCarousel].
  const QPSelectionCarousel({
    super.key,
    required this.items,
    required this.isSelected,
    required this.onSelected,
    required this.previewBuilder,
    this.shapeBuilder,
  });

  /// Items to display.
  final List<T> items;

  /// Returns `true` if [item] is the currently selected value.
  final bool Function(T item) isSelected;

  /// Called when the user selects [item].
  final void Function(T item) onSelected;

  /// Builds the preview widget shown inside each carousel card.
  final Widget Function(BuildContext context, T item) previewBuilder;

  /// Optional custom shape per item. Defaults to [qpSelectionCarouselItemShape].
  final ShapeBorder Function(
    BuildContext context,
    int index,
    int length,
    bool isSelected,
  )?
  shapeBuilder;

  @override
  State<QPSelectionCarousel<T>> createState() => _QPSelectionCarouselState<T>();
}

class _QPSelectionCarouselState<T> extends State<QPSelectionCarousel<T>> {
  late final CarouselController _carouselController;
  bool _initialized = false;

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  double _estimateHeight(BuildContext context, double width) {
    const double padding = QPLayout.padding;
    const double space = QPLayout.space;
    final double labelFontSize = Theme.of(
      context,
    ).textTheme.labelMedium!.fontSize!;
    final double labelHeight = labelFontSize * 1.2;
    const double radioBlockHeight = 24.0 + 0.5 * padding;
    final double colorAreaHeight = (width * 0.25).clamp(
      4 * labelFontSize,
      width * 0.65,
    );
    return ((0.5 * padding) +
            labelHeight +
            (0.5 * padding) +
            colorAreaHeight +
            (2 * space) +
            radioBlockHeight)
        .clamp(140.0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _initialized = true;
      final int idx = widget.items.indexWhere(widget.isSelected);
      final int start = idx < 0
          ? 0
          : (idx < widget.items.length - 3 ? idx : widget.items.length - 3);
      _carouselController = CarouselController(initialItem: start);
    }

    const double padding = QPLayout.padding;
    const double space = QPLayout.space;
    final List<T> items = widget.items;
    final T selectedItem = items.firstWhere(
      widget.isSelected,
      orElse: () => items.first,
    );

    final ShapeBorder Function(BuildContext, int, int, bool) shapeFn =
        widget.shapeBuilder ?? qpSelectionCarouselItemShape;

    Widget buildCarousel() {
      return CarouselView.weighted(
        controller: _carouselController,
        scrollDirection: Axis.horizontal,
        flexWeights: const <int>[1, 3, 3, 3, 1],
        padding: const EdgeInsets.symmetric(horizontal: space),
        itemSnapping: true,
        backgroundColor: Colors.transparent,
        onTap: (int index) => widget.onSelected(items[index]),
        shape: QPLayout.innerBorderShape,
        children: List<Widget>.generate(items.length, (int index) {
          final T item = items[index];
          final bool isSelected = widget.isSelected(item);
          return QPGroupedWidget(
            key: ValueKey<T>(item),
            shape: shapeFn(context, index, items.length, isSelected),
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.5 * padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: widget.previewBuilder(context, item)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      0.5 * padding,
                      0,
                      0.5 * padding,
                      0.5 * padding,
                    ),
                    child: SizedBox(
                      height: 24,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          height: 24,
                          child: Center(
                            child: Radio<T>(
                              value: item,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                                vertical: -4,
                              ),
                              splashRadius: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    }

    return RadioGroup<T>(
      groupValue: selectedItem,
      onChanged: (T? value) {
        if (value != null && !widget.isSelected(value)) {
          widget.onSelected(value);
        }
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget carousel = buildCarousel();
          if (constraints.hasBoundedHeight && constraints.maxHeight.isFinite) {
            return carousel;
          }
          final double width =
              constraints.hasBoundedWidth && constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width;
          return SizedBox(
            height: _estimateHeight(context, width),
            child: carousel,
          );
        },
      ),
    );
  }
}
