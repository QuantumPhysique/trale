import 'package:flutter/material.dart';
import 'package:trale/core/theme.dart';

/// Container with bgShade1 on full width
class ColoredContainer extends StatelessWidget {
  /// Constructor
  const ColoredContainer({
    required this.height, required this.width, required this.child,
  });
  /// height of inner Container
  final double height;
  /// width
  final double width;
  /// child of inner Container
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const double shadowOffset = 6;
    return Container(
        height: height + 2 * TraleTheme.of(context)!.padding,
        padding: EdgeInsets.symmetric(
          vertical: TraleTheme.of(context)!.padding
        ),
        child: ClipRect(
          clipBehavior: Clip.hardEdge,
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                ),
                BoxShadow(
                  color: TraleTheme.of(context)!.bgShade3,
                  spreadRadius: -shadowOffset,
                  blurRadius: shadowOffset,
                  offset: const Offset(shadowOffset, 0),
                ),
                BoxShadow(
                  color: TraleTheme.of(context)!.bgShade3,
                  spreadRadius: -shadowOffset,
                  blurRadius: shadowOffset,
                  offset: const Offset(-shadowOffset, 0),
                ),
              ],
            ),
            child: child,
          ),
        )
    );
  }
}