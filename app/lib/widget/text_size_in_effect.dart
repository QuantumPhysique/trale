import 'package:flutter/material.dart';
import 'package:trale/widget/animation_replay_scope.dart';

class TextSizeInEffect extends StatefulWidget {
  const TextSizeInEffect({
    super.key,
    required this.text,
    required this.textStyle,
    this.durationInMilliseconds = 1000,
    this.delayInMilliseconds = 0,
    this.keepAlive = false,
  });

  final String text;
  final TextStyle textStyle;
  final int durationInMilliseconds;
  final int delayInMilliseconds;
  final bool keepAlive;

  @override
  State<TextSizeInEffect> createState() => _TextSizeInEffectState();
}

class _TextSizeInEffectState extends State<TextSizeInEffect>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController animationController;
  late final Animation<double> sizeAnimation;
  AnimationReplayController? _replayController;

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

    sizeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0, 1, curve: Curves.easeOut),
      ),
    );
  }

  void _onReplay() {
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
    return AnimatedOpacity(
      opacity: sizeAnimation.value == 0 ? 0 : 1,
      duration: Duration(milliseconds: widget.durationInMilliseconds),
      child: Text(widget.text, style: widget.textStyle),
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
