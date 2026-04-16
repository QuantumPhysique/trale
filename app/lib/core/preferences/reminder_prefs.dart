part of '../preferences.dart';

/// Extension grouping reminder_prefs settings on [Preferences].
extension ReminderPrefsExtension on Preferences {
  /// Get reminder enabled
  bool get reminderEnabled => prefs.getBool('reminderEnabled')!;

  /// Set reminder enabled
  set reminderEnabled(bool enabled) =>
      prefs.setBool('reminderEnabled', enabled);

  /// Get reminder days (ISO weekday: 1=Mon … 7=Sun)
  List<int> get reminderDays {
    final String raw = prefs.getString('reminderDays')!;
    if (raw.isEmpty) {
      return <int>[];
    }
    return raw.split(',').map(int.parse).toList();
  }

  /// Set reminder days
  set reminderDays(List<int> days) {
    assert(
      days.every((int d) => d >= 1 && d <= 7),
      'reminderDays must contain ISO weekday values (1=Mon … 7=Sun)',
    );
    prefs.setString('reminderDays', days.join(','));
  }

  /// Get reminder hour
  int get reminderHour => prefs.getInt('reminderHour')!;

  /// Set reminder hour
  set reminderHour(int hour) {
    assert(hour >= 0 && hour <= 23, 'reminderHour must be between 0 and 23');
    prefs.setInt('reminderHour', hour);
  }

  /// Get reminder minute
  int get reminderMinute => prefs.getInt('reminderMinute')!;

  /// Set reminder minute
  set reminderMinute(int minute) {
    assert(
      minute >= 0 && minute <= 59,
      'reminderMinute must be between 0 and 59',
    );
    prefs.setInt('reminderMinute', minute);
  }

  /// Get stats range
  StatsRange get statsRange => prefs.getString('statsRange')!.toStatsRange()!;

  /// Set stats range
  set statsRange(StatsRange range) => prefs.setString('statsRange', range.name);
}
