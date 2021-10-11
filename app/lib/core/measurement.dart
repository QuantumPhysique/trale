import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';

part 'measurement.g.dart';

/// Class for weight event
@HiveType(typeId: 0)
class Measurement {
  /// constructor
  Measurement({
    required this.weight,
    required this.date,
  });

  /// weight of measurement
  @HiveField(0)
  final double weight;
  /// date of measurement
  @HiveField(1)
  final DateTime date;

  /// implement sorting entries by date
  /// comparator method
  int compareTo(Measurement other) => date.compareTo(other.date);

  /// return weight in active unit
  double inUnit(BuildContext context) => weight / Provider.of<TraleNotifier>(
      context, listen: false
  ).unit.scaling;

  /// compare method to use default sort method on list
  static int compare(Measurement a, Measurement b) => a.compareTo(b);
}


class RawMeasurement {
  /// constructor
  RawMeasurement({
    required this.weight,
    required this.date,
  });

  /// construct RawMeasurment from Measurement
  RawMeasurement.fromMeasurement({
    required Measurement measurement,
  }) :
    weight = measurement.weight,
    date = DateTime(
      measurement.date.year, measurement.date.month, measurement.date.day
    ).millisecondsSinceEpoch;

  /// weight of measurement
  final double weight;
  /// date of measurement in milliseconds since epoch
  final int date;
}

