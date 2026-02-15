import 'package:flutter/material.dart';
import 'package:trale/core/theme.dart';

/// Container with bgShade1 on full width
class ColoredContainer extends StatelessWidget {
  /// Constructor
  const ColoredContainer({
    super.key,
    required this.height,
    required this.width,
    required this.child,
  });

  /// height of inner Container
  final double height;

  /// width
  final double width;

  /// child of inner Container
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(vertical: TraleTheme.of(context)!.padding),
      child: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: Container(
          height: height - 4 * TraleTheme.of(context)!.padding,
          width: width,
          padding: EdgeInsets.symmetric(
            vertical: TraleTheme.of(context)!.padding,
          ),
          color: Theme.of(context).colorScheme.primaryContainer,
          // decoration: BoxDecoration(
          //   boxShadow: <BoxShadow>[
          //     BoxShadow(
          //       color: Colors.black.withOpacity(0.2),
          //     ),
          //     BoxShadow(
          //       color: TraleTheme.of(context)!.isDark
          //         ?  TraleTheme.of(context)!.bgShade3
          //         :  Theme.of(context).colorScheme.background,
          //       spreadRadius: -shadowOffset,
          //       blurRadius: shadowOffset,
          //       offset: const Offset(2 * shadowOffset, 0),
          //     ),
          //     BoxShadow(
          //       color: TraleTheme.of(context)!.isDark
          //           ?  TraleTheme.of(context)!.bgShade3
          //           :  Theme.of(context).colorScheme.background,
          //       spreadRadius: -shadowOffset,
          //       blurRadius: shadowOffset,
          //       offset: const Offset(- 2 * shadowOffset, 0),
          //     ),
          //   ],
          // ),
          child: child,
        ),
      ),
    );
  }
}
