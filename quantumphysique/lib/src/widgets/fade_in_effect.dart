import 'package:flutter/material.dart';
import 'package:quantumphysique/src/widgets/animation_replay_scope.dart';

/// Fade-in animation wrapper.
///
/// The child fades from transparent to opaque over [durationInMilliseconds],
/// optionally delayed by [delayInMilliseconds].  When a
/// [QPAnimationReplayScope] is present in the tree the animation is replayed
/// whenever the scope fires.
class QPFadeInEffect extends StatefulWidget {
  /// Constructor.
  const QPFadeInEffect({
    super.key,
    required this.child,
    this.intervalStart = 0,
    this.durationInMilliseconds = 1000,
    this.delayInMilliseconds = 0,
    this.keepAlive = false,
  });

  /// Child widget to animate.
  final Widget child;

  /// Start of the animation interval (0.0–1.0).
  final double intervalStart;

  /// Duration of the animation in milliseconds.
  final int durationInMilliseconds;

  /// Delay before starting the animation in milliseconds.
  final int delayInMilliseconds;

  /// Whether to keep the widget alive when off-screen.
  final bool keepAlive;

  @override
  State<QPFadeInEffect> createState() => _QPFadeInEffectState();
}

class _QPFadeInEffectState extends State<QPFadeInEffect>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _animationController;
  late final Animation<double> _opacityAnimation;
  QPAnimationReplayController? _replayController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationInMilliseconds),
    );

    Future<TickerFuture>.delayed(
      Duration(milliseconds: widget.delayInMilliseconds),
      () => _animationController.forward(),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(widget.intervalStart, 1, curve: Curves.easeOut),
      ),
    );
  }

  void _onReplay() {
    _animationController.reset();
    Future<TickerFuture>.delayed(
      Duration(milliseconds: widget.delayInMilliseconds),
      () => _animationController.forward(),
    );
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FadeTransition(opacity: _opacityAnimation, child: widget.child);
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
