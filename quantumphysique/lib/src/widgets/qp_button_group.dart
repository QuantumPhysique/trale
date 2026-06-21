import 'package:flutter/material.dart';

import 'qp_layout.dart';

/// A horizontal Material 3 [button group](https://m3.material.io/components/button-groups/overview)
/// for selecting a single value of type [T].
///
/// Renders [items] as connected segments inside a [QPWidgetGroup]-style card.
/// The selected segment takes a colored pill ([StadiumBorder]) — matching the
/// language picker in the quantumphysique package — while unselected segments
/// stay flat with the inner tile shape.
///
/// Drop-in replacement for [SegmentedButton] in single-select scenarios.
class QPButtonGroup<T> extends StatelessWidget {
  /// Creates a [QPButtonGroup].
  const QPButtonGroup({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    required this.labelBuilder,
  });

  /// Ordered values rendered as segments, left to right.
  final List<T> items;

  /// The currently selected value. Highlighted as a colored pill.
  final T selected;

  /// Called with the value of the tapped segment.
  final ValueChanged<T> onSelected;

  /// Builds the label widget shown inside the segment for [value].
  final Widget Function(BuildContext context, T value) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      shape: QPLayout.borderShape,
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: QPLayout.space),
            Expanded(
              child: _QPButtonGroupSegment<T>(
                value: items[i],
                selected: items[i] == selected,
                onSelected: onSelected,
                label: labelBuilder(context, items[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A single tappable segment of a [QPButtonGroup].
class _QPButtonGroupSegment<T> extends StatelessWidget {
  const _QPButtonGroupSegment({
    required this.value,
    required this.selected,
    required this.onSelected,
    required this.label,
  });

  final T value;
  final bool selected;
  final ValueChanged<T> onSelected;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final Color background = selected
        ? cs.secondaryContainer
        : cs.surfaceContainerLowest;
    final Color foreground = selected
        ? cs.onSecondaryContainer
        : cs.onSurfaceVariant;
    final ShapeBorder shape = selected
        ? const StadiumBorder()
        : QPLayout.innerBorderShape;

    return AnimatedContainer(
      duration: QPLayout.transitionFast,
      curve: Curves.easeInOut,
      decoration: ShapeDecoration(color: background, shape: shape),
      clipBehavior: Clip.antiAlias,
      height: QPLayout.controlHeight,
      child: InkWell(
        onTap: () => onSelected(value),
        customBorder: shape,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: QPLayout.bentoPadding,
          ),
          child: Center(
            child: DefaultTextStyle.merge(
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.titleMedium?.copyWith(color: foreground),
              child: IconTheme.merge(
                data: IconThemeData(color: foreground),
                child: label,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
