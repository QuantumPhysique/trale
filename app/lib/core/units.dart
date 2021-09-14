enum TraleUnit {
  /// kg
  kg,
  /// stones
  st,
  /// pounds
  pd,
}

/// extend units
extension TraleUnitExtension on TraleUnit {
  /// get the scaling factor to kg
  double get scaling => <TraleUnit, double>{
    TraleUnit.kg: 1,
    TraleUnit.st: 6.35029318,
    TraleUnit.pd: 0.45359237,
  }[this]!;

  /// get string expression
  String get name => toString().split('.').last;
}

/// convert units to string
extension TralUnitParsing on String {
  /// convert number to difficulty
  TraleUnit? toTraleUnit() {
    for (final TraleUnit unit in TraleUnit.values)
      if (this == unit.name)
        return unit;
    return null;
  }
}