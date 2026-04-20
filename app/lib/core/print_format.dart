import 'package:quantumphysique/quantumphysique.dart';

/// Backward-compat alias: [TraleDatePrintFormat] is now [QPDateFormat].
typedef TraleDatePrintFormat = QPDateFormat;

/// Bridge: convert a stored [String] to [TraleDatePrintFormat]
/// (= [QPDateFormat]).
extension TraleDateFormatParsing on String {
  /// Convert a serialised name to [TraleDatePrintFormat],
  /// or `null` if unrecognised.
  TraleDatePrintFormat? toTraleDateFormat() => toQPDateFormat();
}
