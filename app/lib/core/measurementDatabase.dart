import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/main.dart';


/// check if two integers corresponds to same day
bool sameDay(DateTime? d1, DateTime? d2) {
  if (d1 == null || d2 == null)
    return false;
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

/// check if day is in list
bool dayInMeasurements(DateTime d1, List<Measurement> measurements) =>
    <bool>[
      for (final Measurement m in measurements)
        sameDay(d1, m.date)
    ].reduce((bool value, bool element) => value || element);


/// class providing an API to handle measurements stored in hive
class MeasurementDatabase {
  /// constructor
  MeasurementDatabase();

  static final String _boxName = measurementBoxName;

  /// get unsorted measurements
  Box<Measurement> get box => Hive.box<Measurement>(_boxName);

  /// get sorted measurements
  List<Measurement> get measurements => box.values.toList()..sort(
      (Measurement a, Measurement b) => a.compareTo(b)
  );

  /// get sorted measurements, key tuples
  List<SortedMeasurement> get sortedMeasurements => <SortedMeasurement>[
      for (final dynamic key in box.keys)
        SortedMeasurement(key: key, measurement: box.get(key)!)
    ]..sort(
      (SortedMeasurement a, SortedMeasurement b) => b.compareTo(a)
    );

  /// get sorted list of daily-averaged measurements
  List<Measurement> get dailyAveragedMeasurements {
    final List<Measurement> ms = measurements;
    if (ms.isEmpty)
      return measurements;
    final List<Measurement> dailyAverage = <Measurement>[];
    final List<double> dailyWeightAverage = <double>[];

    DateTime lastDate = DateTime(
      ms[0].date.year, ms[0].date.month, ms[0].date.day, _offsetInH,
    );
    for (int idx=0; idx < ms.length; idx++){
      final DateTime date = ms[idx].date;
      if (!sameDay(date, lastDate)) {
        dailyAverage.add(
          Measurement(
            weight: dailyWeightAverage.reduce(
                (double value, double element) => value + element
              ) / dailyWeightAverage.length,
            date: lastDate,
          )
        );

        // get new date and clear list
        dailyWeightAverage.clear();
        lastDate = DateTime(date.year, date.month, date.day, _offsetInH);
      }
      dailyWeightAverage.add(ms[idx].weight);
    }
    // add last element
    dailyAverage.add(Measurement(
      weight: dailyWeightAverage.reduce(
              (double value, double element) => value + element
      ) / dailyWeightAverage.length,
      date: lastDate,
    ));
    return dailyAverage;
  }

  /// get linearly interpolated and sorted list of daily-averaged measurements
  List<Measurement> get dailyAveragedInterpolatedMeasurements {
    final List<Measurement> ms = dailyAveragedMeasurements;
    final List<Measurement> dailyMeasurements = <Measurement>[];

    final int intervalInDays =
      ms.last.date.difference(ms.first.date).inDays + 2 * _offsetInDays;
    final DateTime dateStart = ms.first.date.subtract(
      const Duration(days: _offsetInDays)
    );
    for (int days = 0; days < intervalInDays; days += 1) {
      DateTime date = dateStart.add(Duration(days: days));
      date = DateTime(date.year, date.month, date.day, _offsetInH);
      bool isDayInMeasurements = false;
      for (final Measurement m in ms) {
        if (sameDay(date, m.date)) {
          dailyMeasurements.add(
            Measurement(
              weight: m.weight,
              date: m.date,
              isMeasured: true,
            )
          );
          isDayInMeasurements = true;
          break;
        }
      }
      if (!isDayInMeasurements) {
        dailyMeasurements.add(
          Measurement(
            weight: (InterpolFunc.linear.function(
              date.millisecondsSinceEpoch, ms,
            ) as Measurement).weight,
            date: date,
            isMeasured: days < _offsetInDays ||
              days > intervalInDays - _offsetInDays,
          )
        );
      }
    }
    return dailyMeasurements;
  }

  /// offset of day in hours
  static const int _offsetInH = 12;
  /// offset of day in interpolation
  static const int _offsetInDays = 7;
}