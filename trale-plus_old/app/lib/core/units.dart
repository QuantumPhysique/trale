import 'package:trale/core/measurement.dart';

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
  String measurementToString(Measurement m, {bool showUnit= true}) {
    return weightToString(m.weight, showUnit: showUnit);
  }

  /// weight given in kg to string
  String weightToString(double weight, {bool showUnit= true}) {
    final String suffix = showUnit ? ' $name' : '';
    return '${doubleToPrecision(weight / scaling).toStringAsFixed(precision)}'
      '$suffix';
  }

  /// round double to given precision
  double doubleToPrecision(double val) => (
    val * ticksPerStep
  ).roundToDouble() / ticksPerStep;

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