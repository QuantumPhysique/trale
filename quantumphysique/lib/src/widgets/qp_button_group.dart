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
    this.tooltipBuilder,
    this.isItemEnabled,
    this.expanded = false,
    this.color,
  });

  /// Ordered values rendered as segments, left to right.
  final List<T> items;

  /// The currently selected value. Highlighted as a colored pill.
  final T selected;

  /// Called with the value of the tapped segment.
  final ValueChanged<T> onSelected;

  /// Builds the label widget shown inside the segment for [value].
  ///
  /// [selected] reports whether [value] is the currently selected segment, so
  /// the label can adapt (e.g. swap an outlined icon for a filled one).
  final Widget Function(BuildContext context, T value, bool selected)
  labelBuilder;

  /// Optional builder for the long-press / hover tooltip of a segment.
  ///
  /// When it returns `null` (or is itself omitted) no tooltip is shown.
  final String? Function(T value)? tooltipBuilder;

  /// Whether the segment for [value] is selectable.
  ///
  /// When it returns `false` the segment is rendered greyed-out and ignores
  /// taps. When omitted, every segment is enabled.
  final bool Function(T value)? isItemEnabled;

  /// Whether segments share the available width equally ([Expanded]).
  ///
  /// Defaults to `false`, which shrinks to the segments' intrinsic size — this
  /// is required when placed in an unbounded-width slot such as a
  /// [ListTile.trailing]. Set to `true` to fill the parent's width, which is
  /// ideal when the group is given a bounded width (e.g. a full-width row).
  final bool expanded;

  /// Background color of the unselected segments.
  ///
  /// Defaults to [ColorScheme.surfaceContainerLowest] when omitted. The
  /// selected segment always uses [ColorScheme.secondaryContainer].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      shape: QPLayout.borderShape,
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: QPLayout.space),
            _maybeExpanded(
              _QPButtonGroupSegment<T>(
                value: items[i],
                selected: items[i] == selected,
                enabled: isItemEnabled?.call(items[i]) ?? true,
                onSelected: onSelected,
                tooltip: tooltipBuilder?.call(items[i]),
                unselectedColor: color,
                label: labelBuilder(context, items[i], items[i] == selected),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _maybeExpanded(Widget child) =>
      expanded ? Expanded(child: child) : child;
}

/// A single tappable segment of a [QPButtonGroup].
class _QPButtonGroupSegment<T> extends StatelessWidget {
  const _QPButtonGroupSegment({
    required this.value,
    required this.selected,
    required this.enabled,
    required this.onSelected,
    required this.label,
    this.tooltip,
    this.unselectedColor,
  });

  final T value;
  final bool selected;
  final bool enabled;
  final ValueChanged<T> onSelected;
  final Widget label;
  final String? tooltip;
  final Color? unselectedColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final Color background = selected
        ? cs.secondaryContainer
        : unselectedColor ?? cs.surfaceContainerLowest;
    final Color foreground = !enabled
        ? cs.onSurface.withValues(alpha: 0.38)
        : selected
        ? cs.onSecondaryContainer
        : cs.onSurfaceVariant;
    final ShapeBorder shape = selected
        ? const StadiumBorder()
        : QPLayout.innerBorderShape;

    final Widget inkWell = InkWell(
      onTap: enabled ? () => onSelected(value) : null,
      customBorder: shape,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: QPLayout.padding),
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
    );

    return AnimatedContainer(
      duration: QPLayout.transitionFast,
      curve: Curves.easeInOut,
      decoration: ShapeDecoration(color: background, shape: shape),
      clipBehavior: Clip.antiAlias,
      height: QPLayout.controlHeight,
      child: tooltip == null
          ? inkWell
          : Tooltip(message: tooltip!, child: inkWell),
    );
  }
}
