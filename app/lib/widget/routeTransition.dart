import 'package:flutter/material.dart';

/// Define slide directions
enum TransitionDirection {
  /// slide to the left
  left,
  /// slide to the right
  right,
  /// slide to the top
  top,
  /// slide to the bottom
  bottom,
  /// slide from top left
  topLeft,
  /// slide from top right
  topRight,
  /// slide from bottom left
  bottomLeft,
  /// slide from bottom right
  bottomRight,
}

/// slide right route navigation
class SlideRoute extends PageRouteBuilder<dynamic> {
  /// super constructor
  SlideRoute({
    required this.page,
    required this.direction
  }) : super(
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) => page,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) => SlideTransition(
      position: Tween<Offset>(
        begin: _offset(direction),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.ease)).animate(animation),
      child: child,
    ),
  );
  /// widget (route) which will be opened
  final Widget page;
  /// direction of animation
  final TransitionDirection direction;
  /// get offset corresponding to sliding direction
  static Offset _offset(TransitionDirection direction) {
    switch(direction) {
      case TransitionDirection.left:
        return const Offset(-1.0, 0.0);
      case TransitionDirection.right:
        return const Offset(1.0, 0.0);
      case TransitionDirection.bottom:
        return const Offset(0.0, -1.0);
      case TransitionDirection.top:
        return const Offset(0.0, 1.0);
      case TransitionDirection.topLeft:
        return const Offset(-1.0, 1.0);
      case TransitionDirection.topRight:
        return const Offset(1.0, 1.0);
      case TransitionDirection.bottomLeft:
        return const Offset(-1.0, -1.0);
      case TransitionDirection.bottomRight:
        return const Offset(1.0, -1.0);
    }
    // set default return value
    return Offset.zero;
  }
}