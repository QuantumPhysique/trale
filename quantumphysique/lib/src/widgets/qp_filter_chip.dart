import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'qp_layout.dart';

/// A Material 3 expressive [filter chip](https://m3.material.io/components/chips/overview).
///
/// When [selected] the chip takes a tonal ([ColorScheme.secondaryContainer])
/// fill and grows a leading "check" icon; otherwise it stays flat with a thin
/// outline. Selection animates over [QPLayout.transitionFast].
class QPFilterChip extends StatelessWidget {
  /// Creates a [QPFilterChip].
  const QPFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  /// Text shown inside the chip.
  final String label;

  /// Whether the chip is currently selected (tonal + check icon).
  final bool selected;

  /// Called when the chip is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final Color background = selected
        ? cs.secondaryContainer
        : cs.surfaceContainerHighest;
    final Color foreground = selected
        ? cs.onSecondaryContainer
        : cs.onSurfaceVariant;
    final ShapeBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(QPLayout.bentoPadding),
      side: selected ? BorderSide.none : BorderSide(color: cs.outlineVariant),
    );

    return AnimatedContainer(
      duration: QPLayout.transitionFast,
      curve: Curves.easeInOut,
      decoration: ShapeDecoration(color: background, shape: shape),
      clipBehavior: Clip.antiAlias,
      height: QPLayout.chipHeight,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Padding(
          // Material spec: 16 dp inset on both edges, tightened to 8 dp on the
          // leading edge when the check icon is shown.
          padding: EdgeInsets.only(
            left: selected ? QPLayout.chipPadding / 2 : QPLayout.chipPadding,
            right: QPLayout.chipPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedSize(
                duration: QPLayout.transitionFast,
                curve: Curves.easeInOut,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(
                          right: QPLayout.chipPadding / 2,
                        ),
                        child: Icon(
                          PhosphorIconsBold.check,
                          size: 18,
                          color: foreground,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Text(label, style: tt.labelLarge?.copyWith(color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A horizontally scrollable row of [QPFilterChip]s.
///
/// Lays [children] out left to right with a uniform gap; when the chips exceed
/// the available width the row scrolls horizontally instead of wrapping.
class QPFilterChipBar extends StatelessWidget {
  /// Creates a [QPFilterChipBar].
  const QPFilterChipBar({super.key, required this.children});

  /// The chips to display, typically [QPFilterChip]s.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: QPLayout.bentoPadding,
        children: children,
      ),
    );
  }
}
