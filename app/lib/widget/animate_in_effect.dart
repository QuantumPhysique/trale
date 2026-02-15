import 'package:flutter/material.dart';
import 'package:trale/widget/animation_replay_scope.dart';

class AnimateInEffect extends StatefulWidget {
  const AnimateInEffect({
    super.key,
    required this.child,
    this.intervalStart = 0,
    this.durationInMilliseconds = 1000,
    this.delayInMilliseconds = 0,
    this.keepAlive = false,
  });

  final Widget child;
  final double intervalStart;
  final int durationInMilliseconds;
  final int delayInMilliseconds;
  final bool keepAlive;

  @override
  State<AnimateInEffect> createState() => _AnimateInEffectState();
}

class _AnimateInEffectState extends State<AnimateInEffect>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController animationController;
  late Animation<Offset> offsetAnimation;
  late final Animation<double> fadeAnimation;
  AnimationReplayController? _replayController;

  /// The horizontal start offset magnitude.
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

    // Default: slide in from the right
    _buildOffsetAnimation(SlideDirection.fromRight);
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
    final SlideDirection dir =
        _replayController?.direction ?? SlideDirection.fromRight;
    _buildOffsetAnimation(dir);
    animationController.reset();
    Future<TickerFuture>.delayed(
      Duration(milliseconds: widget.delayInMilliseconds),
      () => animationController.forward(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final AnimationReplayController? newController = AnimationReplayScope.of(
      context,
    );
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
  Widget build(BuildContext context) {
    super.build(context);

    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget? child) =>
          Transform.translate(offset: offsetAnimation.value, child: child),
      child: widget.child,
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
