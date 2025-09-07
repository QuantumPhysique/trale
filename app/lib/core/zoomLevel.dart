import 'package:ml_linalg/linalg.dart';

import 'package:trale/core/measurementInterpolation.dart';


/// zoom level for line chart in [month]
enum ZoomLevel {
  two,
  six,
  year,
  all,
}

/// extend zoom levels
extension ZoomLevelExtension on ZoomLevel {
  /// get the window length in month
  double get _rangeInMilliseconds => <ZoomLevel, int>{
      ZoomLevel.two: 2,
      ZoomLevel.six: 6,
      ZoomLevel.year: 12,
      ZoomLevel.all: -1,
    }[this]! * 30 * 24 * 3600 * 1000;

  /// get range
  double get rangeInMilliseconds => maxX - minX;

  /// get next zoom level
  ZoomLevel get next {
    final ZoomLevel nextLevel = ZoomLevel.values[
      (index + 1) % ZoomLevel.values.length
    ];

    /// if range of measurements to short show all available
    if (
      (_times.last - _times.first).abs() < nextLevel._rangeInMilliseconds
    ) {
      return ZoomLevel.all;
    }
    return nextLevel;
  }

  /// zoom out
  ZoomLevel get zoomOut {
    /// if already at all return all
    if (this == ZoomLevel.all) {
      return ZoomLevel.all;
    }
    return ZoomLevel.values[index + 1];
  }
  /// zoom in
  ZoomLevel get zoomIn {
    /// if already at all return all
    if (this == ZoomLevel.two) {
      return ZoomLevel.two;
    }
    return ZoomLevel.values[index - 1];
  }

  /// get maxX value in [ms]
  double get maxX => _times.last;

  /// get minX vale in [ms]
  double get minX {
    if (this == ZoomLevel.all) {
      return _times.first;
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
  ZoomLevel? toZoomLevel() => this < ZoomLevel.values.length
    ? ZoomLevel.values[this]
    : null;
}