part of '../weight_picker.dart';

class MultiItemSnapScrollPhysics extends ScrollPhysics {
  /// Creates snap-based scroll physics.
  const MultiItemSnapScrollPhysics({
    required this.snapSize,
    this.maxItemsPerFling = 50.0,
    this.velocityDivisor = 10.0,
    super.parent,
  });

  /// Pixel size of one snap step.
  final double snapSize;

  /// Maximum items traveled per fling gesture.
  final double maxItemsPerFling;

  /// Divisor applied to fling velocity.
  final double velocityDivisor;

  /// Spring stiffness constant.
  static const double stiffness = 140.0;

  /// Spring damping ratio.
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
      if ((targetPx - position.pixels).abs() < tol.distance) {
        return null;
      }
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
    if ((targetPx - position.pixels).abs() < tol.distance) {
      return null;
    }

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

