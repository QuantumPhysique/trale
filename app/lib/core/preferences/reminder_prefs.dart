part of '../preferences.dart';

/// Extension grouping reminder_prefs settings on [Preferences].
///
/// [reminderEnabled], [reminderDays], [reminderHour], [reminderMinute] are now
/// owned by [QPReminderPrefsExtension] on [QPPreferences].
extension ReminderPrefsExtension on Preferences {
  /// Get stats range
  StatsRange get statsRange => prefs.getString('statsRange')!.toStatsRange()!;

  /// Set stats range
  set statsRange(StatsRange range) => prefs.setString('statsRange', range.name);
}
