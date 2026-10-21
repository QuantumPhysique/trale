part of '../linechart.dart';

/// Build two FlSpot segments for the target weight line:
/// 1. horizontal at the target weight before the start of [plan]
/// 2. along [plan], one point a week, then horizontal onwards
List<List<FlSpot>> _buildTargetWeightSegments({
  required TargetPlan plan,
  required double unitScaling,
  required double chartMaxX,
  required double chartMinX,
}) {
  final double startMs = plan.start.millisecondsSinceEpoch.toDouble();
  final double endMs = plan.end.millisecondsSinceEpoch.toDouble();
  final double target = plan.target / unitScaling;
  final double minX = min<double>(chartMinX, startMs) - 365 * dayInMs;
  final double maxX = max<double>(chartMaxX, endMs) + 365 * dayInMs;
  return <List<FlSpot>>[
    <FlSpot>[FlSpot(minX, target), FlSpot(startMs, target)],
    <FlSpot>[
      for (int day = 0; day < plan.days; day += 7)
        FlSpot(
          startMs + day * dayInMs,
          plan.weightAfterDays(day) / unitScaling,
        ),
      FlSpot(endMs, target),
      FlSpot(maxX, target),
    ],
  ];
}
