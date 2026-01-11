import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/font.dart';

import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/widget/tile_group.dart';

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
    mass: 1.0,
    stiffness: stiffness,
    ratio: ratio,
  );

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
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
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        targetPx,
        velocity,
        tolerance: tol,
      );
    }

    // Convert velocity -> number of items to travel (at least 1).
    final double deltaItems = (velocity.abs() / (snapSize * velocityDivisor))
        .clamp(1.0, maxItemsPerFling);

    // Clamp to bounds and snap to nearest tick.
    final double minPage = position.minScrollExtent / snapSize;
    final double maxPage = position.maxScrollExtent / snapSize;
    final double targetPage = (currentPage + deltaItems * velocity.sign)
        .clamp(minPage, maxPage)
        .roundToDouble();

    final double targetPx = _pixelsForPage(targetPage);
    if ((targetPx - position.pixels).abs() < tol.distance) return null;

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      targetPx,
      velocity,
      tolerance: tol,
    );
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
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Marker widget displayed at the center top of the RulerPicker
class _SliderMarker extends StatelessWidget {
  const _SliderMarker({
    required this.widthLargeTick,
    required this.heightLargeTick,
    required this.barWidth,
    required this.tickWidth,
  });

  final double widthLargeTick;
  final double heightLargeTick;
  final double barWidth;
  final double tickWidth;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    Widget triangle() {
      return SizedBox(
        width: widthLargeTick,
        height: 0,
        child: CustomPaint(
          painter: _Painter(
            lineColor: colorScheme.secondary,
            width: widthLargeTick,
            height: 2 * widthLargeTick,
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
            width: barWidth,
            height: heightLargeTick,
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: BorderRadius.circular(tickWidth),
            ),
          ),
        ],
      ),
    );
  }
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
    required this.ticksPerStep,
    required this.value,
    this.marker,
    this.height = 90,
    this.backgroundColor = Colors.white,
    RulerPickerController? controller,
    super.key,
  }) : controller = controller ?? RulerPickerController(value: value);

  final ValueChangedCallback onValueChange;
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
  final double tickWidth = 10.0;
  late num weightValue = widget.value;

  @override
  void initState() {
    super.initState();

    final int initialIndex = (widget.value * widget.ticksPerStep).round();
    _scrollController = ScrollController(
      initialScrollOffset: initialIndex * tickWidth,
    );

    // External commands to jump/change value
    widget.controller.addListener(() {
      if (!_scrollController.hasClients) {
        return;
      }
      final int targetIndex = (widget.controller.value * widget.ticksPerStep)
          .round();
      _scrollController.animateTo(
        targetIndex * tickWidth,
        duration:
            TraleTheme.of(context)?.transitionDuration.normal ??
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

  Widget _weightLabelWidget(BuildContext context, double weight, Color color) {
    final TraleNotifier notifier = Provider.of<TraleNotifier>(
      context,
      listen: false,
    );
    final Text valueLabel = Text(
      '${weight.toStringAsFixed(notifier.unit.precision)} '
      '${notifier.unit.name}',
      style: Theme.of(
        context,
      ).textTheme.emphasized.monospace.headlineLarge?.apply(color: color),
    );

    final double padding = TraleTheme.of(context)!.padding;
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(top: 0.75 * padding, bottom: 0.5 * padding),
      child: valueLabel,
    );
  }

  void _updateWeightValue(num newValue) {
    widget.onValueChange(newValue);
    setState(() {
      weightValue = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final double offset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    final double page = offset / tickWidth;
    final int nearestIndex = page.round();

    final double newValue = nearestIndex / widget.ticksPerStep;

    return WidgetGroup(
      children: <Widget>[
        GroupedWidget(
          color: colorScheme.secondary,
          child: _weightLabelWidget(context, newValue, colorScheme.onSecondary),
        ),
        GroupedWidget(
          color: colorScheme.secondaryContainer,
          child: SizedBox(
            height: widget.height,
            width: MediaQuery.of(context).size.width,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) =>
                  _WeightSlider(
                    constraints: constraints,
                    scrollController: _scrollController,
                    ticksPerStep: widget.ticksPerStep,
                    onValueChange: _updateWeightValue,
                    tickWidth: tickWidth,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeightSlider extends StatefulWidget {
  const _WeightSlider({
    required this.constraints,
    required this.scrollController,
    required this.ticksPerStep,
    required this.onValueChange,
    required this.tickWidth,
  });

  final double tickWidth;
  final BoxConstraints constraints;
  final ScrollController scrollController;
  final ValueChangedCallback onValueChange;
  final int ticksPerStep;
  @override
  State<_WeightSlider> createState() => _WeightSliderState();
}

class _WeightSliderState extends State<_WeightSlider> {
  int _lastReportedIndex = -1;

  final double barWidth = 4.0;
  final double widthLargeTick = 10.0;
  @override
  Widget build(BuildContext context) {
    final double padding = TraleTheme.of(context)!.padding;
    final double width = widget.constraints.maxWidth;
    final double height = widget.constraints.maxHeight - 1.5 * padding;
    final ScrollController scrollController = widget.scrollController;
    final double heightLargeTick = height - 2 * padding;
    final double heightSmallTick = height - 3.5 * padding;
    final double tickWidth = widget.tickWidth;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double leadTrailPad = ((width - tickWidth) / 2.0).clamp(
      0.0,
      double.infinity,
    );

    final double offset = scrollController.hasClients
        ? scrollController.offset
        : 0.0;
    final double page = offset / tickWidth;
    final int nearestIndex = page.round();

    final double newValue = nearestIndex / widget.ticksPerStep;
    final Widget marker = _SliderMarker(
      widthLargeTick: widthLargeTick,
      heightLargeTick: heightLargeTick,
      barWidth: barWidth,
      tickWidth: tickWidth,
    );

    return Container(
      width: width,
      height: height + 1.5 * padding,
      padding: EdgeInsets.only(bottom: 0.5 * padding, top: padding),
      child: Listener(
        onPointerDown: (_) => FocusScope.of(context).requestFocus(FocusNode()),
        child: AnimatedBuilder(
          animation: scrollController,
          builder: (BuildContext context, _) {
            final double offset = scrollController.hasClients
                ? scrollController.offset
                : 0.0;
            final double page = offset / tickWidth;

            // Visible items count in viewport (approx).
            final double pagesVisible = (width / tickWidth).clamp(
              1.0,
              double.infinity,
            );

            // Start fading at the third-last visible tick towards each edge
            final double edgeStart = (1.0 - 4.0 / pagesVisible).clamp(0.0, 1.0);

            // Inside build(), before scaleForIndex:
            final double zeroAtInsetPx =
                0.5 * tickWidth; // reach 0 scale this many px before the edge
            final double halfViewportPx = width / 2.0;
            final double zeroAtRel =
                ((halfViewportPx - zeroAtInsetPx) / halfViewportPx).clamp(
                  0.0,
                  1.0,
                );

            // Keep pagesVisible and edgeStart as you already compute them.
            // Then update scaleForIndex:
            double scaleForIndex(int index) {
              final double rel = ((index - page) / (pagesVisible / 2.0)).abs();
              final double denom = max(
                1e-6,
                zeroAtRel - edgeStart,
              ); // avoid div-by-zero
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
                  controller: scrollController,
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
                    final double scaley = (0.5 + scalex).clamp(0.0, 1.0);

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
                          transform: Matrix4.diagonal3Values(
                            scalex,
                            scaley,
                            1.0,
                          ),
                          child: Container(
                            width: isMajor ? barWidth : barWidth / 2,
                            height: tickHeight,
                            decoration: BoxDecoration(
                              color: colorScheme.onSecondaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        if (isMajor)
                          Positioned(
                            bottom: 0,
                            width: tickWidth * widget.ticksPerStep,
                            left:
                                -0.5 * tickWidth * (widget.ticksPerStep - 0.75),
                            child: Container(
                              alignment: Alignment.center,
                              child: Transform(
                                alignment: Alignment.topCenter,
                                origin: Offset(
                                  0,
                                  -(1 - scaley) * heightLargeTick,
                                ),
                                transform: Matrix4.diagonal3Values(
                                  scalex,
                                  scalex,
                                  1.0,
                                ),
                                child: Text(
                                  (index / widget.ticksPerStep).toStringAsFixed(
                                    0,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .monospace
                                      .titleLarge!
                                      .apply(
                                        color: colorScheme.onSecondaryContainer,
                                      ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                Positioned(top: 0, child: marker),
              ],
            );
          },
        ),
      ),
    );
  }
}
