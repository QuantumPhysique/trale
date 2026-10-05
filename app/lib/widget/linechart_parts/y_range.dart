part of '../linechart.dart';

/// The chart's y-range for [values]: padded by a fifth of their span on each
/// side, and at least [minSpan] wide.
({double minY, double maxY}) _chartYRange(
  Iterable<double> values, {
  double minSpan = 2,
}) {
  double minY = values.reduce(min);
  double maxY = values.reduce(max);
  final double padding = 0.2 * (maxY - minY);
  minY -= padding;
  maxY += padding;
  if (maxY - minY < minSpan) {
    final double centre = (maxY + minY) / 2;
    minY = centre - minSpan / 2;
    maxY = centre + minSpan / 2;
  }
  return (minY: minY, maxY: maxY);
}
