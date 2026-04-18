/// Contrast level enum for [QPPreferences] / [QPNotifier].
library;

/// All available contrast levels.
enum QPContrast {
  /// Normal (no contrast boost)
  normal,

  /// Contrast level 1
  one,

  /// Contrast level 2
  two,

  /// Contrast level 3
  three,

  /// Contrast level 4
  four,

  /// Contrast level 5
  five,
}

/// Extend [QPContrast] with utility methods.
extension QPContrastExtension on QPContrast {
  /// The numeric contrast value used by Material color utilities.
  double get contrast => const <QPContrast, double>{
    QPContrast.normal: 0,
    QPContrast.one: 0.1,
    QPContrast.two: 0.2,
    QPContrast.three: 0.3,
    QPContrast.four: 0.4,
    QPContrast.five: 0.5,
  }[this]!;

  /// Human-readable contrast label (e.g. "0", "1", …).
  String get nameLong => (contrast * 10).round().toString();

  /// Serialization name (enum value name).
  String get name => toString().split('.').last;

  /// Index of this value in [QPContrast.values].
  int get idx {
    for (int i = 0; i < QPContrast.values.length; i++) {
      if (QPContrast.values[i] == this) {
        return i;
      }
    }
    return -1;
  }
}

/// Parse a [String] to [QPContrast].
extension QPContrastParsing on String {
  /// Returns the matching [QPContrast], or `null` if not found.
  QPContrast? toQPContrast() {
    for (final QPContrast lvl in QPContrast.values) {
      if (this == lvl.name) {
        return lvl;
      }
    }
    return null;
  }
}
