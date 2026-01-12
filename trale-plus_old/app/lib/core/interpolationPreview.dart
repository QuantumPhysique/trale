import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementInterpolation.dart';


Map<int, double> _ms_map = <int, double>{
  0: 78.1,
  1: 78.4,
  2: 78.3,
  4: 78.6,
  10: 78.9,
  14: 79.5,
  16: 79.5,
  17: 79.7,
  19: 80.3,
  21: 80.1,
};

List<Measurement> _ms = <Measurement>[
  for (int i in _ms_map.keys)
    Measurement(
      weight: _ms_map[i]!,
      date: DateTime.now().subtract(Duration(days: i)),
    ),
];



class PreviewDatabase extends MeasurementDatabaseBaseclass {
  PreviewDatabase();

  final List<Measurement> _measurements = _ms;

  /// get sorted measurements
  @override
  List<Measurement> get measurements => _measurements ?? <Measurement>[]..sort(
          (Measurement a, Measurement b) => b.compareTo(a)
  );
}


class PreviewInterpolation extends MeasurementInterpolationBaseclass {
  PreviewInterpolation();

  /// get measurements
  @override
  PreviewDatabase get db => PreviewDatabase();
}
