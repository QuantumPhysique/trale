part of 'qp_preferences.dart';

/// Display-related preferences for [QPPreferences].
extension QPDisplayPrefsExtension on QPPreferences {
  /// Get first day of week.
  QPFirstDay get firstDay => prefs.getString('qp_firstDay')!.toQPFirstDay()!;

  /// Set first day of week.
  set firstDay(QPFirstDay value) => prefs.setString('qp_firstDay', value.name);

  /// Get date format.
  QPDateFormat get datePrintFormat =>
      prefs.getString('qp_dateFormat')!.toQPDateFormat()!;

  /// Set date format.
  set datePrintFormat(QPDateFormat value) =>
      prefs.setString('qp_dateFormat', value.name);
}
