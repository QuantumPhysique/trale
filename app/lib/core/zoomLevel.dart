import 'package:ml_linalg/linalg.dart';

import 'package:trale/core/measurementInterpolation.dart';

/// zoom level for line chart in [month]
enum ZoomLevel { two, six, year, twoYear, fourYear, all }

/// extend zoom levels
extension ZoomLevelExtension on ZoomLevel {
  /// get the window length in month
  double get _rangeInMilliseconds =>
      <ZoomLevel, int>{
        ZoomLevel.two: 2,
        ZoomLevel.six: 6,
        ZoomLevel.year: 12,
        ZoomLevel.twoYear: 24,
        ZoomLevel.fourYear: 48,
        ZoomLevel.all: -1,
      }[this]! *
      30 *
      24 *
      3600 *
      1000;

  /// get range
  double get rangeInMilliseconds => maxX - minX;

  /// get next zoom level
  ZoomLevel get next {
    if (this == ZoomLevel.all) {
      return ZoomLevel.two;
    }
    return zoomOut;
  }

  /// zoom out
  ZoomLevel get zoomOut {
    /// if already at all return all
    if (this == ZoomLevel.all) {
      return ZoomLevel.all;
    }
    final ZoomLevel nextLevel = ZoomLevel.values[index + 1];

    /// if range of measurements to short show all available
    if ((_times.last - _times.first).abs() < nextLevel._rangeInMilliseconds) {
      return nextLevel.zoomOut;
    }
    return nextLevel;
  }

  /// zoom in
  ZoomLevel get zoomIn {
    /// if already at all return all
    if (this == ZoomLevel.two) {
      return ZoomLevel.two;
    }
    final ZoomLevel nextLevel = ZoomLevel.values[index - 1];

    /// if range of measurements to short show all available
    if ((_times.last - _times.first).abs() < nextLevel._rangeInMilliseconds) {
      return nextLevel.zoomIn;
    }
    return nextLevel;
  }

  /// get maxX value in [ms]
  double get maxX => _times.isNotEmpty ? _times.last.toDouble() : DateTime.now().millisecondsSinceEpoch.toDouble();

  /// get minX vale in [ms]
  double get minX {
    if (this == ZoomLevel.all) {
      return _times.isNotEmpty ? _times.first.toDouble() : DateTime.now().subtract(const Duration(days: 365)).millisecondsSinceEpoch.toDouble();
    }
    return maxX - _rangeInMilliseconds;
  }

  /// get measurements to estimate range, maxX, and minX
  Vector get _times => MeasurementInterpolation().times;

  /// get string expression
  String get name => toString().split('.').last;
}

/// convert units to string
extension ZoomLevelParsing on int {
  /// convert number to difficulty
  ZoomLevel? toZoomLevel() =>
      this < ZoomLevel.values.length ? ZoomLevel.values[this] : null;
}
