import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';

class MultiItemSnapScrollPhysics extends ScrollPhysics {
  const MultiItemSnapScrollPhysics({
    required this.snapSize,
    this.maxItemsPerFling = 50.0,
    this.velocityDivisor = 10.0,
    super.parent,
  });

  final double snapSize;
  final double maxItemsPerFling;
  final double velocityDivisor;
  static const double stiffness = 140.0;
  static const double ratio = 0.8;

  @override
  MultiItemSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MultiItemSnapScrollPhysics(
      snapSize: snapSize,
      maxItemsPerFling: maxItemsPerFling,
      velocityDivisor: velocityDivisor,
      parent: buildParent(ancestor),
    );
  }

  double _page(ScrollMetrics m) => (m.pixels / snapSize).clamp(-1e12, 1e12);
  double _pixelsForPage(double p) => p * snapSize;

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
    mass: 1.0, stiffness: stiffness, ratio: ratio,
  );

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // Let parent handle overscroll.
    if (position.outOfRange) {
      return parent?.createBallisticSimulation(position, velocity);
    }

    final Tolerance tol = toleranceFor(position);
    final double currentPage = _page(position);

    // Small velocity: snap to nearest tick.
    if (velocity.abs() <= tol.velocity) {
      final double targetPage = currentPage.roundToDouble();
      final double targetPx = _pixelsForPage(targetPage);
      if ((targetPx - position.pixels).abs() < tol.distance) return null;
      return ScrollSpringSimulation(spring, position.pixels, targetPx, velocity, tolerance: tol);
    }

    // Convert velocity -> number of items to travel (at least 1).
    final double deltaItems =
        (velocity.abs() / (snapSize * velocityDivisor)).clamp(1.0, maxItemsPerFling);

    // Clamp to bounds and snap to nearest tick.
    final double minPage = position.minScrollExtent / snapSize;
    final double maxPage = position.maxScrollExtent / snapSize;
    final double targetPage =
        (currentPage + deltaItems * velocity.sign).clamp(minPage, maxPage).roundToDouble();

    final double targetPx = _pixelsForPage(targetPage);
    if ((targetPx - position.pixels).abs() < tol.distance) return null;

    return ScrollSpringSimulation(spring, position.pixels, targetPx, velocity, tolerance: tol);
  }

  @override
  bool get allowImplicitScrolling => false;
}


class _Painter extends CustomPainter {
  _Painter({
    required this.width,
    required this.height,
    required this.lineColor,
  });

  final double width;
  final double height;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
      Radius.circular(width / 4),
        ), paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// dart
class RulerPickerController extends ValueNotifier<double> {
  RulerPickerController({double value = 0.0}) : super(value);
}

// dart
typedef ValueChangedCallback = void Function(num value);

class RulerPicker extends StatefulWidget {
  RulerPicker({
    required this.onValueChange,
    required this.width,
    required this.ticksPerStep,
    required this.value,
    this.marker,
    this.height = 90,
    this.backgroundColor = Colors.white,
    RulerPickerController? controller,
    super.key,
  }) : controller = controller ?? RulerPickerController(value: value);


  final ValueChangedCallback onValueChange;
  final double width;
  final double height;
  final int ticksPerStep;
  final Color backgroundColor;
  final Widget? marker;

  final double value;
  final RulerPickerController controller;

  @override
  State<StatefulWidget> createState() => RulerPickerState();
}

class RulerPickerState extends State<RulerPicker> {
  late final ScrollController _scrollController;

  // Tick visuals
  late double heightLargeTick;
  late double heightSmallTick;
  final double tickWidth = 10.0;
  final double barWidth = 4.0;
  final double widthLargeTick = 10.0;

  int _lastReportedIndex = -1;

  @override
  void initState() {
    super.initState();

    heightLargeTick = widget.height - 30.0;
    heightSmallTick = widget.height - 45.0;

    final int initialIndex = (widget.value * widget.ticksPerStep).round();
    _scrollController = ScrollController(initialScrollOffset: initialIndex * tickWidth);

    // External commands to jump/change value
    widget.controller.addListener(() {
      if (!_scrollController.hasClients) return;
      final int targetIndex = (widget.controller.value * widget.ticksPerStep).round();
      _scrollController.animateTo(
        targetIndex * tickWidth,
        duration: TraleTheme.of(context)?.transitionDuration.normal ??
            const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _defaultMarker(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double padding = TraleTheme.of(context)!.padding;
    Widget triangle() {
      return SizedBox(
        width: widthLargeTick,
        height: 0, //2 * widthLargeTick - padding,
        child: CustomPaint(
          painter: _Painter(
            lineColor: colorScheme.tertiary,
            width: widthLargeTick,
            height: padding + widthLargeTick / 4,
          ),
        ),
      );
    }

    return SizedBox(
      width: widthLargeTick,
      height: heightLargeTick + widthLargeTick / 4,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Transform.translate(
            offset: Offset(0, -padding - widthLargeTick / 4),
            child: triangle(),
          ),
          Transform.translate(
            offset: Offset(0,- widthLargeTick / 4),
            child: Container(
              width: barWidth,
              height: heightLargeTick + widthLargeTick / 4,
              decoration: BoxDecoration(
                color: colorScheme.tertiary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double padding = TraleTheme.of(context)!.padding;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TraleNotifier notifier =
      Provider.of<TraleNotifier>(context, listen: false);

    final double leadTrailPad = ((widget.width - tickWidth) / 2.0).clamp(0.0, double.infinity);

    final double offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final double page = offset / tickWidth;
    final int nearestIndex = page.round();

    final double newValue = nearestIndex / widget.ticksPerStep;
    final Text valueLabel = Text(
      '${newValue.toStringAsFixed(notifier.unit.precision)} '
      '${notifier.unit.name}',
      style: Theme.of(context).textTheme.headlineMedium?.apply(
        color: colorScheme.onTertiaryContainer,
        fontFamily: 'CourierPrime',
      ),
    );

    final Widget marker = widget.marker ?? _defaultMarker(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Column(
        children: <Widget>[
          Container(
            width: widget.width,
            alignment: Alignment.topCenter,
            //color: colorScheme.primaryContainer,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                padding,
                0.5 * padding,
                padding,
                0.25 * padding,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                // only draw the top border
                border: Border(
                  bottom: BorderSide(color: colorScheme.tertiary, width: barWidth),
                  //  bottom: BorderSide(color: colorScheme.tertiary, width: barWidth),
                ),
                // optional: round only the top corners
                borderRadius: BorderRadius.vertical(
                  //top: Radius.circular(TraleTheme.of(context)!.borderRadius),
                  top: Radius.circular(TraleTheme.of(context)!.borderRadius),
                ),
              ),
              child: valueLabel,
            ),
          ),
          Container(
            width: widget.width,
            height: widget.height + 1.5 * padding,
            padding: EdgeInsets.only(bottom: 0.5 * padding, top: padding),
            color: colorScheme.primaryContainer,
            child: Listener(
              onPointerDown: (_) => FocusScope.of(context).requestFocus(FocusNode()),
              child: AnimatedBuilder(
                animation: _scrollController,
                builder: (BuildContext context, _) {
                  final double offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                  final double page = offset / tickWidth;

                  // Visible items count in viewport (approx).
                  final double pagesVisible = (widget.width / tickWidth).clamp(1.0, double.infinity);

                  // Start fading at the third-last visible tick towards each edge
                  final double edgeStart = (1.0 - 4.0 / pagesVisible).clamp(0.0, 1.0);

                  // Inside build(), before scaleForIndex:
                  final double zeroAtInsetPx = 0.5 * tickWidth; // reach 0 scale this many px before the edge
                  final double halfViewportPx = widget.width / 2.0;
                  final double zeroAtRel = ((halfViewportPx - zeroAtInsetPx) / halfViewportPx).clamp(0.0, 1.0);

                  // Keep pagesVisible and edgeStart as you already compute them.
                  // Then update scaleForIndex:
                  double scaleForIndex(int index) {
                    final double rel = ((index - page) / (pagesVisible / 2.0)).abs();
                    final double denom = max(1e-6, zeroAtRel - edgeStart); // avoid div-by-zero
                    final double t = ((rel - edgeStart) / denom).clamp(0.0, 1.0);
                    return 1.0 - t;
                  }

                  // Report snapped value when the nearest index changes.
                  final int nearestIndex = page.round();
                  if (nearestIndex != _lastReportedIndex) {
                    _lastReportedIndex = nearestIndex;
                    final double newValue = nearestIndex / widget.ticksPerStep;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) {
                        return;
                      }
                      widget.onValueChange(newValue);
                    });
                  }

                  return Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: leadTrailPad),
                        physics: MultiItemSnapScrollPhysics(
                          snapSize: tickWidth,
                          parent: const ClampingScrollPhysics(),
                        ),
                        itemExtent: tickWidth,
                        itemBuilder: (BuildContext context, int index) {
                          final bool isMajor = index % widget.ticksPerStep == 0;
                          final bool isMedium = index % 5 == 0;
                          final double scalex = scaleForIndex(index);
                          const double scaley = 1.0;

                          final double tickHeight = isMajor
                              ? heightLargeTick
                              : isMedium
                                  ? 0.5 * (heightLargeTick + heightSmallTick)
                                  : heightSmallTick;

                          return Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: <Widget>[
                              Transform(
                                alignment: Alignment.topCenter,
                                transform: Matrix4.diagonal3Values(scalex, scaley, 1.0),
                                child: Container(
                                  width: isMajor ? barWidth : barWidth / 2,
                                  height: tickHeight,
                                  decoration: BoxDecoration(
                                    color: colorScheme.onPrimaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              if (isMajor)
                                Positioned(
                                  bottom: 0,
                                  width: tickWidth * widget.ticksPerStep,
                                  left: -0.5 * tickWidth * (widget.ticksPerStep - 0.75),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Transform(
                                      alignment: Alignment.topCenter,
                                      transform: Matrix4.diagonal3Values(scalex, scalex, 1.0),
                                      child: Text(
                                        (index / widget.ticksPerStep).toStringAsFixed(0),
                                        style: Theme.of(context).textTheme.bodyLarge!.apply(
                                          color: colorScheme.onPrimaryContainer,
                                          fontFamily: 'CourierPrime',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      Positioned(
                        top: 0,
                        child: marker,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

        ],
      ),
    );
  }
}