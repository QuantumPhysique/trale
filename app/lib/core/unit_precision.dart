/// Enum representing the precision of units in the application
enum TraleUnitPrecision {
  /// Default: unit-based
  unitDefault,
  /// 0.1 precision
  single,
  /// 0.05 precision
  double,
}

/// extend units
extension TraleUnitPrecisionExtension on TraleUnitPrecision {
  /// get the number of ticks
  int? get ticksPerStep =>
      <TraleUnitPrecision, int?>{
        TraleUnitPrecision.unitDefault: null,
        TraleUnitPrecision.single: 10,
        TraleUnitPrecision.double: 20,
      }[this];

  /// get the number of ticks
  int? get precision =>
      <TraleUnitPrecision, int?>{
        TraleUnitPrecision.unitDefault: null,
        TraleUnitPrecision.single: 1,
        TraleUnitPrecision.double: 2,
      }[this];

  /// get string expression
  String get name => toString().split('.').last;

  /// get settings name
  String? get settingsName => <TraleUnitPrecision, String?>{
    TraleUnitPrecision.unitDefault: null,
    TraleUnitPrecision.single: '0.1',
    TraleUnitPrecision.double: '0.05',
  }[this];
}


/// convert units to string
extension TralUnitPrecisionParsing on String {
  /// convert number to difficulty
  TraleUnitPrecision? toTraleUnitPrecision() {
    for (final TraleUnitPrecision precision in TraleUnitPrecision.values) {
      if (this == precision.name) {
        return precision;
      }
    }
    return null;
  }
}