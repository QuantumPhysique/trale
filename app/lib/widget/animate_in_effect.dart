import 'package:flutter/material.dart';

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
  late final Animation<Offset> offsetAnimation;
  late final Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationInMilliseconds),
    );

    Future<TickerFuture>.delayed(
      Duration(
          milliseconds: widget.delayInMilliseconds),
          () => animationController.forward(),
    );

    final Curve intervalCurve = Interval(
      widget.intervalStart,
      1,
      curve: Curves.easeInOutCubic,
    );

    offsetAnimation = Tween<Offset>(
      begin: const Offset(96, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: intervalCurve,
      ),
    );

  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget? child) => Transform.translate(
        offset: offsetAnimation.value,
        child: child,
      ),
      child: widget.child,
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}