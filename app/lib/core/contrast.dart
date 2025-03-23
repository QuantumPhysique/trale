/// Enum with all available contrast levels
enum ContrastLevel {
  /// none
  normal,
  /// 1
  one,
  /// 2
  two,
  /// 3
  three,
  /// 4
  four,
  /// 5
  five,
}

/// extend contrast level
extension ContrastLevelExtension on ContrastLevel {
  /// get the interpolation strength of measurements [days]
  double get contrast => <ContrastLevel, double>{
      ContrastLevel.normal: 0,
      ContrastLevel.one: 0.1,
      ContrastLevel.two: 0.2,
      ContrastLevel.three: 0.3,
      ContrastLevel.four: 0.4,
      ContrastLevel.five: 0.5,
    }[this]!;

  /// get international name
  String get nameLong => (contrast * 10).round().toString();

  /// get string expression
  String get name => toString().split('.').last;

  /// get index
  int get idx {
    for (int i=0; i<ContrastLevel.values.length; i++) {
      if (ContrastLevel.values[i] == this) {
        return i;
      }
    }
    return -1;
  }
}

/// convert string to interpolation strength
extension ContrastLevelParsing on String {
  /// convert string to interpolation strength
  ContrastLevel? toContrastLevel() {
    for (final ContrastLevel lvl in ContrastLevel.values) {
      if (this == lvl.name) {
        return lvl;
    }
      }
    return null;
  }
}