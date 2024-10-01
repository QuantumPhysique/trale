import 'dart:math';

import 'package:flutter/material.dart';

import 'package:trale/core/theme.dart';

/// a mark painter
class _Painter extends CustomPainter {
  _Painter({
    required this.lineColor,
    required this.lineSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    paint.color = lineColor;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(lineSize / 2, lineSize / 2), lineSize / 2, paint);
  }

  final double lineSize;
  final Color lineColor;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

/// The controller for the ruler picker
/// init the ruler value from the controller
class RulerPickerController extends ValueNotifier<double> {
  RulerPickerController({double value = 0.0})
    : super(value);
}

typedef ValueChangedCallback = void Function(num value);

/// RulerPicker
class RulerPicker extends StatefulWidget {
  RulerPicker({
    required this.onValueChange,
    required this.width,
    required this.ticksPerStep,
    required this.value,
    this.marker,
    this.height = 60,
    this.backgroundColor = Colors.white,
    super.key,
  })
    : controller = RulerPickerController(value: value);

  final ValueChangedCallback onValueChange;
  final double width;
  final double height;
  final int ticksPerStep;
  final Color backgroundColor;
  /// the marker on the ruler, default is a arrow
  final Widget? marker;
  double value = 0;
  RulerPickerController controller;

  @override
  State<StatefulWidget> createState() {
    return RulerPickerState();
  }
}

class RulerPickerState extends State<RulerPicker> {
  double lastOffset = 0;
  bool isPosFixed = false;
  String? value;
  ScrollController? scrollController;

  late double heightLargeTick;
  late double heightSmallTick;
  final double widthLargeTick = 10;
  final double tickWidth = 10;

  /// default mark
  Widget mark(BuildContext context) {
    /// default mark arrow
    Widget triangle() {
      return SizedBox(
        width: widthLargeTick,
        height: heightLargeTick / 2,
        child: CustomPaint(
          painter: _Painter(
            lineColor: Theme.of(context).colorScheme.primary,
            lineSize: widthLargeTick,
          ),
        ),
      );
    }

    return SizedBox(
      width: widthLargeTick,
      height: heightLargeTick,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          triangle(),
          Container(
            width: 2,
            height: heightLargeTick,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        width: widget.width,
        height: widget.height + 2 * TraleTheme.of(context)!.padding,
        padding: EdgeInsets.symmetric(
          vertical: TraleTheme.of(context)!.padding,
        ),
        color: Theme.of(context).colorScheme.primaryContainer,
        // decoration: BoxDecoration(
        //   boxShadow: <BoxShadow>[
        //     BoxShadow(
        //       color: ElevationOverlay.colorWithOverlay(
        //         Theme.of(context).colorScheme.surface,
        //         Theme.of(context).colorScheme.onSurface,
        //         3.0,
        //       ),
        //     ),
        //     BoxShadow(
        //       color: backgroundcolor,
        //       spreadRadius: -shadowOffset,
        //       blurRadius: shadowOffset,
        //       offset: const Offset(shadowOffset, 0),
        //     ),
        //     BoxShadow(
        //       color: backgroundcolor,
        //       spreadRadius: -shadowOffset,
        //       blurRadius: shadowOffset,
        //       offset: const Offset(-shadowOffset, 0),
        //     ),
        //   ],
        // ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Listener(
              onPointerDown: (PointerDownEvent event) {
                FocusScope.of(context).requestFocus(FocusNode());
                isPosFixed = false;
              },
              onPointerUp: (PointerUpEvent event) {},
              child: NotificationListener(
                onNotification: (Object? scrollNotification) {
                  if (scrollNotification is ScrollStartNotification) {
                  } else if (scrollNotification is ScrollUpdateNotification) {
                  } else if (scrollNotification is ScrollEndNotification) {
                    if (!isPosFixed) {
                      isPosFixed = true;
                      fixPosition(
                        scrollNotification.metrics.pixels.roundToDouble()
                      );
                    }
                  }
                  return true;
                },
                child: ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: EdgeInsets.only(
                        left: index == 0
                          ? widget.width / 2
                          : 0
                      ),
                      child: SizedBox(
                        width: tickWidth,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Container(
                              width: index % widget.ticksPerStep == 0 ? 2 : 1,
                              height: index % widget.ticksPerStep == 0
                                ? heightLargeTick
                                : index % 5 == 0
                                  ? 0.5 * (heightLargeTick + heightSmallTick)
                                  : heightSmallTick,
                              color: Theme.of(context).
                                colorScheme.onPrimaryContainer,
                            ),
                            Positioned(
                              bottom: 0,
                              width: tickWidth * widget.ticksPerStep,
                              left: - tickWidth * widget.ticksPerStep / 2,
                              child: index % widget.ticksPerStep == 0
                                  ? Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      (
                                          index / widget.ticksPerStep
                                      ).toStringAsFixed(0),
                                      style: Theme.of(
                                          context
                                      ).textTheme.bodyLarge!.apply(
                                        color: Theme.of(context).
                                          colorScheme.onPrimaryContainer,
                                      )
                                    ),
                                  )
                                  : Container(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            widget.marker ?? mark(context),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    heightLargeTick = widget.height - 30;
    heightSmallTick = widget.height - 40;

    scrollController = ScrollController(
        initialScrollOffset: widget.value * tickWidth * widget.ticksPerStep,
    );
    scrollController!.addListener(() {
      setState(() {
        widget.value = (
            scrollController!.offset / (tickWidth * widget.ticksPerStep)
            * widget.ticksPerStep
        ).roundToDouble() / widget.ticksPerStep;
        widget.value = max<double>(widget.value, 0.0);
        widget.onValueChange(widget.value);
      });
    });
    widget.controller.addListener(() {
      setPositionByValue(widget.controller.value);
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController!.dispose();
  }

  @override
  void didUpdateWidget(RulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void fixPosition(double curPos) {
    final double targetPos = max<double>(
        (curPos / tickWidth).roundToDouble() * tickWidth,
        0.0,
    );
    scrollController!.jumpTo(targetPos);
  }

  void setPositionByValue(double value) {
    final double targetPos = max<double>(value * tickWidth, 0.0);
    scrollController!.jumpTo(targetPos);
  }
}