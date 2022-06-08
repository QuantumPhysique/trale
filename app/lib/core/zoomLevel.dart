import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';


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
  double get rangeInMilliseconds => <ZoomLevel, int>{
    ZoomLevel.two: 2,
    ZoomLevel.six: 6,
    ZoomLevel.year: 12,
    ZoomLevel.all: -1,
  }[this]! * 31 * 24 * 3600 * 1000;

  /// get next zoom level
  ZoomLevel get next {
    final ZoomLevel nextLevel = ZoomLevel.values[
      index % ZoomLevel.values.length
    ];

    /// if range of measurements to short show all available
    if (
      (_measurements.last.dayInMs - _measurements.first.dayInMs).toDouble()
      < nextLevel.rangeInMilliseconds
    ) {
      return ZoomLevel.all;
    }
    return nextLevel;
  }

  /// get maxX value in [ms]
  double get maxX => _measurements.last.dayInMs.toDouble();

  /// get minX vale in [ms]
  double get minX {
    if (this == ZoomLevel.all) {
      return _measurements.first.dayInMs.toDouble();
    }
    return _measurements.last.dayInMs - rangeInMilliseconds;
  }

  /// get measurements to estimate range, maxX, and minX
  List<Measurement> get _measurements =>
    MeasurementDatabase().gaussianExtrapolatedMeasurements;

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