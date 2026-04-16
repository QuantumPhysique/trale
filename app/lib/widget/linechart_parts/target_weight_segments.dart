part of '../linechart.dart';

/// Build two FlSpot segments for the target weight line:
/// 1. horizontal at [targetWeight] before [setDate]
/// 2. sloped from (setDate, setWeight) to (targetDate, targetWeight),
///    then horizontal onwards
List<List<FlSpot>> _buildTargetWeightSegments({
  required double setDateMs,
  required double setWeight,
  required double targetDateMs,
  required double targetWeight,
  required double chartMaxX,
  required double chartMinX,
}) {
  final double minX =
      min<double>(chartMinX, setDateMs) - 365 * 24 * 3600 * 1000;
  final double maxX =
      max<double>(chartMaxX, targetDateMs) + 365 * 24 * 3600 * 1000;
  return <List<FlSpot>>[
    <FlSpot>[FlSpot(minX, targetWeight), FlSpot(setDateMs, targetWeight)],
    <FlSpot>[
      FlSpot(setDateMs, setWeight),
      FlSpot(targetDateMs, targetWeight),
      FlSpot(maxX, targetWeight),
    ],
  ];
}

/// Custom line chart widget for weight data.
