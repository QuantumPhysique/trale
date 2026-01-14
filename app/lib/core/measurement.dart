import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';

/// Class for weight event
class Measurement {
  /// constructor
  Measurement({
    required this.weight,
    required this.date,
    this.isMeasured = false,
  });

  /// weight of measurement
  final double weight;

  /// date of measurement
  final DateTime date;

  /// to store if measured
  final bool isMeasured;

  /// copy with applying change
  Measurement apply({double? weight, DateTime? date, bool? isMeasured}) =>
      Measurement(
        weight: weight ?? this.weight,
        date: date ?? this.date,
        isMeasured: isMeasured ?? this.isMeasured,
      );

  /// implement sorting entries by date
  /// comparator method
  int compareTo(Measurement other) => date.compareTo(other.date);

  /// check if identical
  bool isIdentical(Measurement other) =>
      (weight == other.weight) &&
      (date.difference(other.date).inMinutes.abs() <= 1);

  /// return weight in active unit
  double inUnit(BuildContext context) =>
      weight / Provider.of<TraleNotifier>(context, listen: false).unit.scaling;

  /// convert to String
  String weightToString(BuildContext context, {bool showUnit = true}) =>
      Provider.of<TraleNotifier>(
        context,
        listen: false,
      ).unit.measurementToString(this, showUnit: showUnit);

  /// convert date to String
  String dayToString(BuildContext context) => Provider.of<TraleNotifier>(
    context,
    listen: false,
  ).dayFormat(context).format(date);

  /// convert date to String
  String dateToString(BuildContext context) => Provider.of<TraleNotifier>(
    context,
    listen: false,
  ).dateFormat(context).format(date);

  /// convert date to String
  String timeToString(BuildContext context) => TimeOfDay.fromDateTime(date)
      .format(context)
      .padLeft(
        DateFormat(
              'j',
              Localizations.localeOf(context).toString(),
            ).pattern!.contains('H')
            ? 5
            : 8,
      );

  /// date followed by weight
  String measureToString(BuildContext context, {int ws = 10}) =>
      '${dayToString(context)} ${timeToString(context)} '
      '${weightToString(context).padLeft(ws)}';

  /// return day in milliseconds since epoch neglecting the hours, minutes
  int get dayInMs => DateTime(
    date.year,
    date.month,
    date.day,
    12, // use 1h offset to ignore jumps
  ).millisecondsSinceEpoch;

  /// return date in milliseconds
  int get dateInMs => date.millisecondsSinceEpoch;

  /// return string for export
  String get exportString =>
      '${date.toIso8601String()} ${weight.toStringAsFixed(10)}';

  /// copy with applying change
  static Measurement fromString({required String exportString}) {
    final List<String> strings = exportString.split(' ');

    if (strings.length != 2) {
      print('error with parsing measurement!');
    }

    return Measurement(
      weight: double.parse(strings[1]),
      date: DateTime.parse(strings[0]),
      isMeasured: true,
    );
  }

  /// compare method to use default sort method on list
  static int compare(Measurement a, Measurement b) => a.compareTo(b);
}
