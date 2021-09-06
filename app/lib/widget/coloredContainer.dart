import 'package:flutter/material.dart';
import 'package:trale/core/theme.dart';

/// Container with bgShade1 on full width
class ColoredContainer extends StatelessWidget {
  /// Constructor
  const ColoredContainer({required this.height, required this.child});
  /// height of inner Container
  final double height;
  /// child of inner Container
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height + 2 * TraleTheme.of(context)!.padding,
        padding: EdgeInsets.symmetric(
            vertical: TraleTheme.of(context)!.padding),
        child: Container(
          height: height,
          width: MediaQuery.of(context).size.width,
          color: TraleTheme.of(context)!.bgShade1,
          child: child,
        )
    );
  }
}