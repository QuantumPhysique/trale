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

  /// Whether the reminder ids of pre-registry builds have been cancelled.
  bool get legacyReminderIdsCleared =>
      prefs.getBool('legacyReminderIdsCleared') ?? false;

  /// Records that the reminder ids of pre-registry builds are gone.
  set legacyReminderIdsCleared(bool value) =>
      prefs.setBool('legacyReminderIdsCleared', value);
}
