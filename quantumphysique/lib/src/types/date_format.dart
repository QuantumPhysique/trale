/// Date format preference for QP apps.
library;

import 'package:intl/intl.dart';

/// All available date format patterns.
enum QPDateFormat {
  /// System default (locale-driven)
  systemDefault,

  /// yyyy/MM/dd  (e.g. 2024/10/26)
  yyyyMMdd,

  /// dd/MM/yyyy  (e.g. 26/10/2024)
  ddMMyyyy,

  /// MM/dd/yyyy  (e.g. 10/26/2024)
  // ignore: constant_identifier_names
  MMddyyyy,

  /// dd.MM.yyyy  (e.g. 26.10.2024)
  ddMMyyyyDot,

  /// ISO 8601    (e.g. 2024-10-26)
  iso8601,
}

/// Utility methods for [QPDateFormat].
extension QPDateFormatExtension on QPDateFormat {
  static const Map<QPDateFormat, String?> _patternMapping =
      <QPDateFormat, String?>{
        QPDateFormat.systemDefault: null,
        QPDateFormat.yyyyMMdd: 'yyyy/MM/dd',
        QPDateFormat.ddMMyyyy: 'dd/MM/yyyy',
        QPDateFormat.MMddyyyy: 'MM/dd/yyyy',
        QPDateFormat.ddMMyyyyDot: 'dd.MM.yyyy',
        QPDateFormat.iso8601: 'yyyy-MM-dd',
      };

  static const Map<QPDateFormat, String?> _patternMappingShort =
      <QPDateFormat, String?>{
        QPDateFormat.systemDefault: null,
        QPDateFormat.yyyyMMdd: 'MM/dd',
        QPDateFormat.ddMMyyyy: 'dd/MM',
        QPDateFormat.MMddyyyy: 'MM/dd',
        QPDateFormat.ddMMyyyyDot: 'dd.MM',
        QPDateFormat.iso8601: 'MM-dd',
      };

  /// Full date pattern string, or `null` for system default.
  String? get pattern => _patternMapping[this];

  /// Short (day + month) pattern string, or `null` for system default.
  String? get patternShort => _patternMappingShort[this];

  /// A [DateFormat] for full dates.
  DateFormat get dateFormat => DateFormat(pattern);

  /// A [DateFormat] for day-and-month display.
  DateFormat get dayFormat => DateFormat(patternShort);

  /// Serialization name (enum value name).
  String get name => toString().split('.').last;
}

/// Parse a [String] to [QPDateFormat].
extension QPDateFormatParsing on String {
  /// Returns the matching [QPDateFormat], or `null` if not found.
  QPDateFormat? toQPDateFormat() {
    for (final QPDateFormat format in QPDateFormat.values) {
      if (this == format.name) {
        return format;
      }
    }
    return null;
  }
}
