import 'package:intl/intl.dart';

/// Enum for available date formats
enum TraleDatePrintFormat {
  /// Default format MM/dd/yyyy
  systemDefault,

  /// yyyy/MM/dd format (e.g., 2024/10/26)
  yyyyMMdd,

  /// dd/MM/yyyy format (e.g., 26/10/2024)
  ddMMyyyy,

  /// MM/dd/yyyy format (e.g., 10/26/2024)
  MMddyyyy,

  ddMMyyyyDot,
}

/// Extension to add functionality to TraleDatePrintFormat
extension TraleDateFormatExtension on TraleDatePrintFormat {
  /// Mapping of date formats to their patterns
  static const Map<TraleDatePrintFormat, String?> _patternMapping = <TraleDatePrintFormat, String?>{
    TraleDatePrintFormat.systemDefault: null,
    TraleDatePrintFormat.yyyyMMdd: 'yyyy/MM/dd',
    TraleDatePrintFormat.ddMMyyyy: 'dd/MM/yyyy',
    TraleDatePrintFormat.MMddyyyy: 'MM/dd/yyyy',
    TraleDatePrintFormat.ddMMyyyyDot: 'dd.MM.yyyy',
  };

  /// Mapping of date formats to their patterns
  static const Map<TraleDatePrintFormat, String?> _patternMappingShort = <TraleDatePrintFormat, String?>{
    TraleDatePrintFormat.systemDefault: null,
    TraleDatePrintFormat.yyyyMMdd: 'MM/dd',
    TraleDatePrintFormat.ddMMyyyy: 'dd/MM',
    TraleDatePrintFormat.MMddyyyy: 'MM/dd',
    TraleDatePrintFormat.ddMMyyyyDot: 'dd.MM',
  };

  /// Get the pattern associated with each format option, using a custom format if provided
  String? get pattern => _patternMapping[this];

  /// Get the pattern associated with each format option, using a custom format if provided
  String? get patternShort => _patternMappingShort[this];

  /// Format a DateTime object according to the selected format
  DateFormat get dateFormat => DateFormat(pattern);

  /// Format a DateTime object according to the selected format without year
  DateFormat get dayFormat => DateFormat(patternShort);

  /// Get the string name for each date format
  String get name => toString().split('.').last;
}

/// Extension for string parsing to convert a string to TraleDateFormat
extension TraleDateFormatParsing on String {
  /// Convert string to TraleDateFormat enum
  TraleDatePrintFormat? toTraleDateFormat() {
    for (final TraleDatePrintFormat format in TraleDatePrintFormat.values) {
      if (this == format.name) {
        return format;
      }
    }
    return null;
  }
}
