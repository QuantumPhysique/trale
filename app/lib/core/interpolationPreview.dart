// ignore_for_file: file_names
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementInterpolation.dart';

Map<int, double> _msMap = <int, double>{
  0: 80.5,
  1: 79.7,
  // 2: 80.6,
  3: 80.2,
  4: 81.4,
  5: 81.0,
  // 6: 80.7,
  7: 80.3,
  8: 79.5,
  9: 80.1,
  10: 80.7,
  11: 80.7,
  12: 80.8,
  13: 79.7,
  14: 81.4,
  15: 80.4,
  16: 81.4,
  17: 80.3,
  18: 81.0,
  19: 81.3,
  20: 81.7,
  21: 81.9,
  22: 81.7,
  23: 81.5,
  24: 82.6,
  25: 81.7,
  26: 82.7,
  27: 81.3,
  28: 82.0,
  29: 81.1,
  30: 81.7,
  31: 81.4,
  32: 82.4,
  33: 81.2,
  // 34: 82.2,
  35: 81.7,
  36: 82.8,
  37: 81.9,
  38: 82.7,
  // 39: 82.6,
  40: 81.5,
  41: 82.6,
  42: 81.7,
  43: 82.7,
  44: 81.3,
  45: 80.6,
  46: 80.9,
  47: 81.5,
  48: 80.7,
  49: 80.7,
  50: 81.3,
  51: 80.5,
  52: 80.7,
  53: 82.5,
  54: 81.3,
  55: 80.5,
  56: 81.3,
  // 57: 80.5,
  // 58: 80.7,
  59: 82.5,
};

List<Measurement> _ms = <Measurement>[
  for (int i in _msMap.keys)
    Measurement(
      weight: _msMap[i]!,
      date: DateTime.now().subtract(Duration(days: i)),
    ),
];

/// Database backed by preview (sample) measurements.
class PreviewDatabase extends MeasurementDatabaseBaseclass {
  /// Creates the preview database.
  PreviewDatabase();

  final List<Measurement> _measurements = _ms;

  /// get sorted measurements
  @override
  List<Measurement> get measurements =>
      _measurements..sort((Measurement a, Measurement b) => b.compareTo(a));
}

/// Interpolation backed by [PreviewDatabase] for UI previews.
class PreviewInterpolation extends MeasurementInterpolationBaseclass {
  /// Creates a preview interpolation instance.
  PreviewInterpolation();

  /// get measurements
  @override
  PreviewDatabase get db => PreviewDatabase();
}
