import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementInterpolation.dart';


List<Measurement> _ms = <Measurement>[
  Measurement(
    weight: 78.9,
    date: DateTime.now().subtract(Duration(days: 10)),
  ),
  Measurement(
    weight: 78.3,
    date: DateTime.now().subtract(Duration(days: 2)),
  ),
  Measurement(
      weight: 78.4,
      date: DateTime.now().subtract(Duration(days: 1)),
  ),
  Measurement(weight: 78.1, date: DateTime.now()),
];



class PreviewDatabase extends MeasurementDatabaseBaseclass {
  PreviewDatabase();

  List<Measurement>? _measurements = _ms;
}


class PreviewInterpolation extends MeasurementInterpolationBaseclass {
  PreviewInterpolation();

  /// get measurements
  @override
  PreviewDatabase get db => PreviewDatabase();
}
