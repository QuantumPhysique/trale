import 'package:trale/core/constants.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/unit_precision.dart';

/// Units of weight measurements
enum TraleUnit {
  /// kg
  kg,

  /// stones
  st,

  /// pounds
  lb,
}

/// extend units
extension TraleUnitExtension on TraleUnit {
  /// get the scaling factor to kg
  double get scaling => <TraleUnit, double>{
    TraleUnit.kg: 1,
    TraleUnit.st: 6.35029318,
    TraleUnit.lb: 0.45359237,
  }[this]!;

  /// get the number of ticks
  int get ticksPerStep => <TraleUnit, int>{
    TraleUnit.kg: 10,
    TraleUnit.st: 20,
    TraleUnit.lb: 10,
  }[this]!;

  /// get the number of ticks
  int get precision => <TraleUnit, int>{
    TraleUnit.kg: 1,
    TraleUnit.st: 2,
    TraleUnit.lb: 1,
  }[this]!;

  /// convert weight of measurement to string
  String measurementToString(
    Measurement m,
    TraleUnitPrecision tup, {
    bool showUnit = true,
  }) {
    return weightToString(m.weight, tup, showUnit: showUnit);
  }

  /// weight given in kg to string
  String weightToString(
    double weight,
    TraleUnitPrecision tup, {
    bool showUnit = true,
  }) {
    // get unit precision from context
    final String suffix = showUnit ? ' $name' : '';
    final double scaledVal = doubleToPrecision(weight / scaling, tup);
    return '${scaledVal.toStringAsFixed(decimals(tup))}'
        '$suffix';
  }

  /// round double to given precision
  double doubleToPrecision(double val, TraleUnitPrecision tup) {
    final int tps = tup.ticksPerStep ?? ticksPerStep;
    return (val * tps).roundToDouble() / tps;
  }

  /// number of decimals shown for this unit and precision setting
  int decimals(TraleUnitPrecision tup) => tup.precision ?? precision;

  /// parse manually typed input into a weight in this unit
  ///
  /// Returns `null` for input that is not a number. Accepts both `.` and `,`
  /// as decimal separator and snaps the result onto a tick grid, so that
  /// every accepted value can also be reached by scrolling. [grid] overrides
  /// the number of ticks per step derived from [tup] and should be set to the
  /// `ticksPerStep` of the ruler the input belongs to.
  ///
  /// Only [minWeightKg] is enforced, because that is where the ruler starts.
  /// There is deliberately no upper limit: the ruler has none either, and
  /// typing is meant to reach exactly the same values as scrolling.
  double? parseWeight(String value, TraleUnitPrecision tup, {int? grid}) {
    final double? parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null) {
      return null;
    }
    final double clamped = parsed < minWeightKg / scaling
        ? minWeightKg / scaling
        : parsed;
    if (grid == null) {
      return doubleToPrecision(clamped, tup);
    }
    return (clamped * grid).roundToDouble() / grid;
  }

  /// get string expression
  String get name => toString().split('.').last;
}

/// convert units to string
extension TralUnitParsing on String {
  /// convert number to difficulty
  TraleUnit? toTraleUnit() {
    for (final TraleUnit unit in TraleUnit.values) {
      if (this == unit.name) {
        return unit;
      }
    }
    return null;
  }
}

/// Units of height
enum TraleUnitHeight {
  /// cm
  metric,

  /// feet and inches
  imperial,
}

/// extend height units
extension TraleUnitHeightExtension on TraleUnitHeight {
  /// get display name
  String get label => <TraleUnitHeight, String>{
    TraleUnitHeight.metric: 'cm',
    TraleUnitHeight.imperial: 'ft/in',
  }[this]!;

  /// get suffix text for input fields
  String get suffixText => label;

  /// get string expression
  String get name => toString().split('.').last;

  /// convert height in cm to editable string (for TextFormField)
  String heightToString(double cm) {
    switch (this) {
      case TraleUnitHeight.metric:
        return '${cm.toInt()}';
      case TraleUnitHeight.imperial:
        final double totalInches = cm / 2.54;
        final int feet = totalInches ~/ 12;
        final int inches = (totalInches % 12).round();
        if (inches == 12) {
          return '${feet + 1}\'0"';
        }
        return '$feet\'$inches"';
    }
  }

  /// parse user input string to height in cm, returns null on invalid input
  double? parseHeight(String value) {
    switch (this) {
      case TraleUnitHeight.metric:
        return double.tryParse(value);
      case TraleUnitHeight.imperial:
        // accept formats: 5'11", 5'11, 5' 11", 5' 11, 5 11
        final RegExp regex = RegExp(r'''(\d+)[′']?\s*(\d+)[″"]?''');
        final RegExpMatch? match = regex.firstMatch(value);
        if (match != null) {
          final int? feet = int.tryParse(match.group(1)!);
          final int? inches = int.tryParse(match.group(2)!);
          if (feet != null && inches != null && inches < 12) {
            return (feet * 12 + inches) * 2.54;
          }
        }
        return null;
    }
  }
}

/// convert string to TraleUnitHeight
extension TraleUnitHeightParsing on String {
  /// convert string to TraleUnitHeight
  TraleUnitHeight? toTraleUnitHeight() {
    for (final TraleUnitHeight unit in TraleUnitHeight.values) {
      if (this == unit.name) {
        return unit;
      }
    }
    return null;
  }
}
