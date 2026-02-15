import 'package:flutter/material.dart';

/// Direction from which widgets should slide in.
enum SlideDirection {
  /// Slide in from the right (default, e.g. app launch, returning from settings,
  /// or navigating to a tab further right).
  fromRight,

  /// Slide in from the left (navigating to a tab further left).
  fromLeft,
}

/// A [ChangeNotifier] that fires whenever tab-entrance animations should
/// replay.  Call [replay] to trigger all descendant [AnimateInEffect],
/// [FadeInEffect] and [TextSizeInEffect] widgets.
class AnimationReplayController extends ChangeNotifier {
  /// The direction the current replay should slide from.
  SlideDirection direction = SlideDirection.fromRight;

  /// Trigger a replay of all animations listening to this controller.
  void replay({SlideDirection dir = SlideDirection.fromRight}) {
    direction = dir;
    notifyListeners();
  }
}

/// Places an [AnimationReplayController] into the widget tree so that
/// descendant animation widgets can look it up via
/// `AnimationReplayScope.of(context)`.
class AnimationReplayScope
    extends InheritedNotifier<AnimationReplayController> {
  /// Wrap a subtree whose animations should replay together.
  const AnimationReplayScope({
    super.key,
    required AnimationReplayController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Look up the nearest [AnimationReplayController], or `null` if none.
  static AnimationReplayController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AnimationReplayScope>()
        ?.notifier;
  }
}
