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

  static const String _boxName = measurementBoxName;

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

    final int intervalInDays = ms.last.date.difference(ms.first.date).inDays;
    final DateTime dateStart = ms.first.date;

    for (int days = 0; days <= intervalInDays; days += 1) {
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
          InterpolFunc.linear.function(
            date.millisecondsSinceEpoch, ms,
          ) as Measurement
        );
      }
    }
    return dailyMeasurements;
  }

  /// get linearly extrapolation based on gaussian interpolation
  List<Measurement> get dailyAveragedExtrapolatedMeasurements {
    final List<Measurement> ms = dailyAveragedInterpolatedMeasurements;
    final List<Measurement> msGaussian = gaussianInterpolatedMeasurements;

    final List<Measurement> extrapolH = <Measurement>[];
    final List<Measurement> extrapolF = <Measurement>[];

    final DateTime dateStartH = ms.first.date.subtract(
        const Duration(days: _offsetInDays)
    );
    final DateTime dateStartF = ms.last.date;
    for (int days = 1; days - 1 <= _offsetInDays; days += 1) {
      DateTime dateF = dateStartF.add(Duration(days: days));
      DateTime dateH = dateStartH.add(Duration(days: days));
      dateF = DateTime(dateF.year, dateF.month, dateF.day, _offsetInH);
      dateH = DateTime(dateH.year, dateH.month, dateH.day, _offsetInH);
      extrapolF.add(
        (InterpolFunc.linear.function(
          dateF.millisecondsSinceEpoch, msGaussian,
        ) as Measurement).apply(isMeasured: true),
      );
      extrapolH.add(
        (InterpolFunc.linear.function(
            dateH.millisecondsSinceEpoch, msGaussian,
        ) as Measurement).apply(isMeasured: true),
      );
    }
    ms.addAll(extrapolF);
    ms.insertAll(0, extrapolH);
    return ms;
  }

  /// return daily averaged and linearly extrapolated measurements
  /// and smooth them with gaussian filter
  List<Measurement> get gaussianExtrapolatedMeasurements => Interpolation(
    measures: dailyAveragedExtrapolatedMeasurements,
  ).interpolate(InterpolFunc.gaussian);

  /// return daily averaged and linearly interpolated measurements
  /// and smooth them with gaussian filter
  List<Measurement> get gaussianInterpolatedMeasurements => Interpolation(
    measures: dailyAveragedInterpolatedMeasurements,
  ).interpolate(InterpolFunc.gaussian);

  /// get slope in unit / day
  double get slope {
    final List<Measurement> measurementsInterpol =
      gaussianInterpolatedMeasurements;

    final Measurement mLast = measurementsInterpol.last;
    final Measurement m2Last = measurementsInterpol.elementAt(
      measurementsInterpol.length - 2
    );

    return (
      mLast.weight - m2Last.weight
    ) / (
      mLast.dateInMs - m2Last.dateInMs
    ) * 24 * 3600 * 1000;
  }

  /// offset of day in hours
  static const int _offsetInH = 12;
  /// offset of day in interpolation
  static const int _offsetInDays = 7;
}