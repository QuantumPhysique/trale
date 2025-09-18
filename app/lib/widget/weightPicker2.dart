import 'dart:math';

import 'package:flutter/material.dart';

import 'package:trale/core/theme.dart';

// dart
class SnapScrollPhysics extends ScrollPhysics {
  const SnapScrollPhysics({
    required this.itemExtent,
    this.stiffness = 140.0,     // lower = softer
    this.damping = 4.0,         // lower = bouncier (more oscillation)
    this.snapVelocityFactor = 0.0012, // pages per (px/s); increase for more carry
    super.parent,
  });

  final double itemExtent;
  final double stiffness;
  final double damping;
  final double snapVelocityFactor;
   // Compensates any fixed leading inset (e.g., center marker offset).

  @override
  SnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnapScrollPhysics(
      itemExtent: itemExtent,
      stiffness: stiffness,
      damping: damping,
      snapVelocityFactor: snapVelocityFactor,
      parent: buildParent(ancestor),
    );
  }

  @override
  SpringDescription get spring => SpringDescription(
    mass: 1.0,
    stiffness: stiffness,
    damping: damping,
  );

  double _getTargetPixels(ScrollMetrics position, Tolerance tol, double velocity) {
    final double page = position.pixels / itemExtent;
    double targetPage;
    if (velocity < -tol.velocity) {
      targetPage = page.floorToDouble();
    } else if (velocity > tol.velocity) {
      targetPage = page.ceilToDouble();
    } else {
      targetPage = page.roundToDouble();
    }
    return targetPage * itemExtent;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // Defer to parent only when truly out of range (bounce/back).
    if (position.outOfRange) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tol = toleranceFor(position);
    final double target = _getTargetPixels(position, tol, velocity);

    if ((target - position.pixels).abs() < tol.distance) {
      return null; // Close enough; no animation needed.
    }

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tol,
    );
  }
}



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
class NewRulerPickerController extends ValueNotifier<double> {
  NewRulerPickerController({double value = 0.0})
    : super(value);
}

typedef ValueChangedCallback = void Function(num value);

/// RulerPicker
class NewRulerPicker extends StatefulWidget {
  NewRulerPicker({
    required this.onValueChange,
    required this.width,
    required this.ticksPerStep,
    required this.value,
    this.marker,
    this.height = 60,
    this.backgroundColor = Colors.white,
    super.key,
  })
    : controller = NewRulerPickerController(value: value);

  final ValueChangedCallback onValueChange;
  final double width;
  final double height;
  final int ticksPerStep;
  final Color backgroundColor;
  /// the marker on the ruler, default is a arrow
  final Widget? marker;
  double value = 0;
  NewRulerPickerController controller;

  @override
  State<StatefulWidget> createState() {
    return NewRulerPickerState();
  }
}

class NewRulerPickerState extends State<NewRulerPicker> {
  double lastOffset = 0;
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
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Listener(
              onPointerDown: (PointerDownEvent event) {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              onPointerUp: (PointerUpEvent event) {},
              child: AnimatedBuilder(
                 animation: scrollController!,
                 builder: (context, _) {
                   final ctrl = scrollController;
                   final bool attached = ctrl?.hasClients == true;

                   // Use 0.0 until the controller is attached to the ListView.
                   final double offset = attached ? ctrl!.offset : 0.0;
                   //final double offset = scrollController?.offset ?? 0.0;

                   final double viewportStart = offset;
                   final double viewportEnd = offset + widget.width;
                   final double leading = widget.width / 2; // first item's left inset
                   const double edgeFraction = 0.10;        // 10% on each side
                   final double edgeWidth = widget.width * edgeFraction;
                   final double leftEdgeEnd = viewportStart + edgeWidth;
                   final double rightEdgeStart = viewportEnd - edgeWidth;

                   // Scale values
                   const double minScale = 0.50; // scale at the very edge
                   double edgeEase(double t) {
                     // Quadratic in for smoother falloff toward the edge
                     t = t.clamp(0.0, 1.0);
                     return t * t;
                   }

                   // dart
                   return ListView.builder(
                     controller: scrollController,
                     scrollDirection: Axis.horizontal,
                     physics: SnapScrollPhysics(
                       itemExtent: tickWidth,
                       parent: const ClampingScrollPhysics(),
                     ),
                     itemBuilder: (BuildContext context, int index) {
                       // Visual center in content coordinates
                       final double leading = widget.width / 2;
                       final double itemCenter = leading + index * tickWidth + tickWidth / 2;

                       // Edge bands and easing are computed above in your builder:
                       // leftEdgeEnd, rightEdgeStart, edgeWidth, edgeEase(t)

                       // Scale at edges: shrink height, widen width
                       const double minScaleY = 0.70;  // min height scale at edge
                       const double maxScaleX = 2.50;  // max width scale at edge (tweak 1.2–1.6)

                       double scaleY = 1.0;
                       double scaleX = 1.0;

                       if (itemCenter <= leftEdgeEnd) {
                         final double t = (leftEdgeEnd - itemCenter) / edgeWidth;
                         final double e = edgeEase(t);
                         scaleY = 1.0 - (1.0 - minScaleY) * e;      // shorter near edge
                         scaleX = 1.0 + (maxScaleX - 1.0) * e;      // wider near edge
                       } else if (itemCenter >= rightEdgeStart) {
                         final double t = (itemCenter - rightEdgeStart) / edgeWidth;
                         final double e = edgeEase(t);
                         scaleY = 1.0 - (1.0 - minScaleY) * e;
                         scaleX = 1.0 + (maxScaleX - 1.0) * e;
                       }

                       return Container(
                         padding: EdgeInsets.only(left: index == 0 ? leading : 0),
                         child: Transform(
                           alignment: Alignment.topCenter,
                           // Non‑uniform scaling: X gets wider, Y gets shorter at edges
                           transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
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
                                   color: Theme.of(context).colorScheme.onPrimaryContainer,
                                 ),
                                 Positioned(
                                   bottom: 0,
                                   width: tickWidth * widget.ticksPerStep,
                                   left: -tickWidth * widget.ticksPerStep / 2,
                                   child: index % widget.ticksPerStep == 0
                                       ? Container(
                                           alignment: Alignment.center,
                                           child: Text(
                                             (index / widget.ticksPerStep).toStringAsFixed(0),
                                             style: Theme.of(context).textTheme.bodyLarge!.apply(
                                                   color: Theme.of(context)
                                                       .colorScheme
                                                       .onPrimaryContainer,
                                                 ),
                                           ),
                                         )
                                       : const SizedBox.shrink(),
                                 ),
                               ],
                             ),
                           ),
                         ),
                       );
                     },
                   );

                   // 2) Dispose order (prevent callbacks after super.dispose)
                   @override
                   void dispose() {
                     scrollController?.dispose();
                     super.dispose();
                   }

                 },
               )
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
      final double raw = scrollController!.offset.clamp(0.0, double.infinity);
      final double ticks = (raw / tickWidth).roundToDouble();
      final double newValue = ticks / widget.ticksPerStep;

      if (newValue != widget.value) {
        setState(() => widget.value = newValue);
        widget.onValueChange(widget.value);
      }
    });
    widget.controller.addListener(() {
      setPositionByValue(widget.controller.value);
    });
  }

  @override
  void dispose() {
    scrollController!.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NewRulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void setPositionByValue(double value) {
      final double targetPos = (value * tickWidth * widget.ticksPerStep).clamp(0.0, double.infinity);
      if (scrollController?.hasClients != true) return;

      final double cur = scrollController!.offset;
      if ((cur - targetPos).abs() < 0.5) return; // avoid jitter loops

      final duration = TraleTheme.of(context)?.transitionDuration.normal
          ?? const Duration(milliseconds: 250);
      scrollController!.animateTo(
        targetPos,
        duration: duration,
        curve: Curves.easeOutCubic,
      );
  }
}