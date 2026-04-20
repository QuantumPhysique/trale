import 'package:quantumphysique/quantumphysique.dart';

/// Backward-compat alias: [TraleFirstDay] is now [QPFirstDay].
typedef TraleFirstDay = QPFirstDay;

/// Bridge: convert a stored [String] to [TraleFirstDay] (= [QPFirstDay]).
extension TraleFirstDayParsing on String {
  /// Convert a serialised name to [TraleFirstDay], or `null` if unrecognised.
  TraleFirstDay? toTraleFirstDay() => toQPFirstDay();
}

// Shim so call sites using TraleFirstDayExtension.loadLocalizedNames /
// TraleFirstDayExtension.getLocalizedName still compile unchanged.
/// Shim extension for [TraleFirstDay] (= [QPFirstDay]) localization helpers.
extension TraleFirstDayExtension on TraleFirstDay {
  /// Loads and caches localised weekday names for [locale].
  static Future<void> loadLocalizedNames(String locale) =>
      QPFirstDayExtension.loadLocalizedNames(locale);

  /// Returns the localised name for [day] in [locale].
  static String getLocalizedName(TraleFirstDay day, String locale) =>
      QPFirstDayExtension.getLocalizedName(day, locale);

  /// Returns the [TraleFirstDay] matching [weekday] (a [DateTime] weekday int).
  static TraleFirstDay fromDateTimeWeekday(int weekday) =>
      QPFirstDayExtension.fromDateTimeWeekday(weekday);
}
