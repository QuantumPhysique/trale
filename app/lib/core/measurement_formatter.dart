import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/unit_precision.dart';
import 'package:trale/core/units.dart';

/// Formats [Measurement] values without requiring direct access to
/// [BuildContext].
///
/// Construct via [MeasurementFormatter.fromContext] or directly with
/// the required formatting parameters for testing.
class MeasurementFormatter {
  /// Create a formatter with explicit dependencies (testable).
  const MeasurementFormatter({
    required this.unit,
    required this.unitPrecision,
    required this.dateFormat,
    required this.dayFormat,
    required this.locale,
  });

  /// Convenience factory that extracts dependencies from [context].
  factory MeasurementFormatter.fromContext(BuildContext context) {
    final TraleNotifier notifier = Provider.of<TraleNotifier>(
      context,
      listen: false,
    );
    return MeasurementFormatter(
      unit: notifier.unit,
      unitPrecision: notifier.unitPrecision,
      dateFormat: notifier.dateFormat(context),
      dayFormat: notifier.dayFormat(context),
      locale: Localizations.localeOf(context).toString(),
    );
  }

  /// The weight unit to display.
  final TraleUnit unit;

  /// The precision to use for weight display.
  final TraleUnitPrecision unitPrecision;

  /// Full date format (with year).
  final DateFormat dateFormat;

  /// Short date format (without year).
  final DateFormat dayFormat;

  /// Locale string for time formatting.
  final String locale;

  /// Return [m]'s weight in the active unit.
  double inUnit(Measurement m) => m.weight / unit.scaling;

  /// Format [m]'s weight as a string.
  String weightToString(Measurement m, {bool showUnit = true}) =>
      unit.measurementToString(m, unitPrecision, showUnit: showUnit);

  /// Format [m]'s date (short, no year).
  String dayToString(Measurement m) => dayFormat.format(m.date);

  /// Format [m]'s date (full, with year).
  String dateToString(Measurement m) => dateFormat.format(m.date);

  /// Whether the locale uses 24-hour time format.
  bool get is24Hour => (DateFormat('j', locale).pattern ?? '').contains('H');

  /// Format [m]'s time of day.
  ///
  /// Pass [formattedTime] if you already have a context-formatted time
  /// string (e.g. from `TimeOfDay.format(context)`). Otherwise falls
  /// back to DateFormat-based formatting.
  String timeToString(Measurement m, {String? formattedTime}) {
    final int padWidth = is24Hour ? 5 : 8;
    final String time = formattedTime ?? DateFormat.jm(locale).format(m.date);
    return time.padLeft(padWidth);
  }

  /// Format date and weight together.
  String measureToString(Measurement m, {int ws = 10}) =>
      '${dayToString(m)} ${timeToString(m)} '
      '${weightToString(m).padLeft(ws)}';
}
