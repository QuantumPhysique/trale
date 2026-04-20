import 'package:flutter/material.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';

/// A [primaryContainer]-coloured box with consistent QP padding.
///
/// The outer container fills [height] × [width] and clips its inner child
/// to `height - 4 × QPLayout.padding` so the colour strip sits flush
/// inside a standard list row.
class QPColoredContainer extends StatelessWidget {
  /// Constructor.
  const QPColoredContainer({
    super.key,
    required this.height,
    required this.width,
    required this.child,
  });

  /// Total height of the outer container.
  final double height;

  /// Width of the inner coloured box.
  final double width;

  /// Child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const double pad = QPLayout.padding;
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(vertical: pad),
      child: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: Container(
          height: height - 4 * pad,
          width: width,
          padding: const EdgeInsets.symmetric(vertical: pad),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: child,
        ),
      ),
    );
  }
}
