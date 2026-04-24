import 'package:flutter/material.dart';

/// Direction from which widgets should slide in.
enum SlideDirection {
  /// Slide in from the right (default).
  fromRight,

  /// Slide in from the left.
  fromLeft,
}

/// A [ChangeNotifier] that fires whenever tab-entrance animations should
/// replay.  Call [replay] to trigger all descendant [QPAnimateInEffect],
/// widgets.
class QPAnimationReplayController extends ChangeNotifier {
  /// The direction the current replay should slide from.
  SlideDirection direction = SlideDirection.fromRight;

  /// Trigger a replay of all animations listening to this controller.
  void replay({SlideDirection dir = SlideDirection.fromRight}) {
    direction = dir;
    notifyListeners();
  }
}

/// Places a [QPAnimationReplayController] into the widget tree so that
/// descendant animation widgets can look it up via
/// [QPAnimationReplayScope.of].
class QPAnimationReplayScope
    extends InheritedNotifier<QPAnimationReplayController> {
  /// Wraps a subtree whose animations should replay together.
  const QPAnimationReplayScope({
    super.key,
    required QPAnimationReplayController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Returns the nearest [QPAnimationReplayController], or `null` if none.
  static QPAnimationReplayController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<QPAnimationReplayScope>()
        ?.notifier;
  }
}
