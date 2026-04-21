part of 'qp_preferences.dart';

/// Display-related preferences for [QPPreferences].
extension QPDisplayPrefsExtension on QPPreferences {
  /// Get first day of week.
  QPFirstDay get firstDay =>
      prefs.getString('qp_firstDay')?.toQPFirstDay() ?? defaultFirstDay;

  /// Set first day of week.
  set firstDay(QPFirstDay value) => prefs.setString('qp_firstDay', value.name);

  /// Get date format.
  QPDateFormat get datePrintFormat =>
      prefs.getString('qp_dateFormat')?.toQPDateFormat() ??
      defaultDatePrintFormat;

  /// Set date format.
  set datePrintFormat(QPDateFormat value) =>
      prefs.setString('qp_dateFormat', value.name);

  /// Writes display defaults for missing keys.
  ///
  /// Called by [QPPreferences.loadDefaultSettings].
  void _loadDisplayDefaults({bool override = false}) {
    if (override || !prefs.containsKey('qp_firstDay')) {
      firstDay = defaultFirstDay;
    }
    if (override || !prefs.containsKey('qp_dateFormat')) {
      datePrintFormat = defaultDatePrintFormat;
    }
  }
}
