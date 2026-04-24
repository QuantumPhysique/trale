import 'package:flutter/material.dart';
import 'package:quantumphysique/src/widgets/animation_replay_scope.dart';

/// Animated slide-in effect widget.
class QPAnimateInEffect extends StatefulWidget {
  /// Creates a [QPAnimateInEffect] widget.
  const QPAnimateInEffect({
    super.key,
    required this.child,
    this.intervalStart = 0,
    this.durationInMilliseconds = 1000,
    this.delayInMilliseconds = 0,
    this.keepAlive = false,
  });

  /// Child widget to animate.
  final Widget child;

  /// Start of the animation interval.
  final double intervalStart;

  /// Duration of the animation in milliseconds.
  final int durationInMilliseconds;

  /// Delay before starting the animation.
  final int delayInMilliseconds;

  /// Whether to keep the widget alive.
  final bool keepAlive;

  @override
  State<QPAnimateInEffect> createState() => _QPAnimateInEffectState();
}

class _QPAnimateInEffectState extends State<QPAnimateInEffect>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController animationController;
  late Animation<Offset> offsetAnimation;
  late final Animation<double> fadeAnimation;
  QPAnimationReplayController? _replayController;

  static const double _slideMagnitude = 40;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationInMilliseconds),
    );

    Future<TickerFuture>.delayed(
      Duration(milliseconds: widget.delayInMilliseconds),
      () => animationController.forward(),
    );

    _buildOffsetAnimation(SlideDirection.fromRight);

    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(widget.intervalStart, 1, curve: Curves.easeInOutCubic),
      ),
    );
  }

  void _buildOffsetAnimation(SlideDirection direction) {
    final double startX = direction == SlideDirection.fromRight
        ? _slideMagnitude
        : -_slideMagnitude;

    final Curve intervalCurve = Interval(
      widget.intervalStart,
      1,
      curve: Curves.easeInOutCubic,
    );

    offsetAnimation = Tween<Offset>(begin: Offset(startX, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: animationController, curve: intervalCurve),
        );
  }

  void _onReplay() {
    if (!mounted) {
      return;
    }
    final SlideDirection dir =
        _replayController?.direction ?? SlideDirection.fromRight;
    _buildOffsetAnimation(dir);
    animationController
      ..reset()
      ..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final QPAnimationReplayController? newController =
        QPAnimationReplayScope.of(context);

    if (newController != _replayController) {
      _replayController?.removeListener(_onReplay);
      _replayController = newController;
      _replayController?.addListener(_onReplay);
    }
  }

  @override
  void dispose() {
    _replayController?.removeListener(_onReplay);
    animationController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FadeTransition(
      opacity: fadeAnimation,
      child: AnimatedBuilder(
        animation: offsetAnimation,
        builder: (BuildContext context, Widget? child) =>
            Transform.translate(offset: offsetAnimation.value, child: child),
        child: widget.child,
      ),
    );
  }
}
