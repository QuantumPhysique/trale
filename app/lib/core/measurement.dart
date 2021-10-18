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
    this.isMeasured=false,
  });

  /// weight of measurement
  @HiveField(0)
  final double weight;
  /// date of measurement
  @HiveField(1)
  final DateTime date;
  /// to store if measured
  final bool isMeasured;

  /// implement sorting entries by date
  /// comparator method
  int compareTo(Measurement other) => date.compareTo(other.date);

  /// return weight in active unit
  double inUnit(BuildContext context) => weight / Provider.of<TraleNotifier>(
      context, listen: false
  ).unit.scaling;

  /// return day in milliseconds since epoch neglecting the hours, minutes
  int get dayInMs => DateTime(
    date.year, date.month, date.day
  ).millisecondsSinceEpoch;

  /// return date in milliseconds
  int get dateInMs => date.millisecondsSinceEpoch;

  /// compare method to use default sort method on list
  static int compare(Measurement a, Measurement b) => a.compareTo(b);
}


/// Class wrapping measurement with its hive key
class SortedMeasurement {
  /// constructor
  SortedMeasurement({
    required this.key,
    required this.measurement,
  });

  /// Measurement object
  final Measurement measurement;
  /// Hive key
  final dynamic key;

  /// implement sorting entries by date
  /// comparator method
  int compareTo(SortedMeasurement other)
    => measurement.date.compareTo(other.measurement.date);

  /// compare method to use default sort method on list
  static int compare(SortedMeasurement a, SortedMeasurement b)
    => a.compareTo(b);
}