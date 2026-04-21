part of 'qp_preferences.dart';

/// Reminder / notification preferences for [QPPreferences].
extension QPReminderPrefsExtension on QPPreferences {
  /// Get reminder-enabled flag.
  bool get reminderEnabled =>
      prefs.getBool('qp_reminderEnabled') ?? defaultReminderEnabled;

  /// Set reminder-enabled flag.
  set reminderEnabled(bool value) => prefs.setBool('qp_reminderEnabled', value);

  /// Get reminder days (ISO weekday: 1=Mon … 7=Sun).
  List<int> get reminderDays {
    final String raw = prefs.getString('qp_reminderDays') ?? '';
    if (raw.isEmpty) {
      return <int>[];
    }
    try {
      return raw.split(',').map(int.parse).toList();
    } on FormatException {
      return <int>[];
    }
  }

  /// Set reminder days.
  set reminderDays(List<int> days) {
    assert(
      days.every((int d) => d >= 1 && d <= 7),
      'reminderDays must contain ISO weekday values (1=Mon … 7=Sun)',
    );
    prefs.setString('qp_reminderDays', days.join(','));
  }

  /// Get reminder hour (0–23).
  int get reminderHour =>
      prefs.getInt('qp_reminderHour') ?? defaultReminderHour;

  /// Set reminder hour.
  set reminderHour(int value) {
    assert(value >= 0 && value <= 23, 'reminderHour must be 0–23');
    prefs.setInt('qp_reminderHour', value);
  }

  /// Get reminder minute (0–59).
  int get reminderMinute =>
      prefs.getInt('qp_reminderMinute') ?? defaultReminderMinute;

  /// Set reminder minute.
  set reminderMinute(int value) {
    assert(value >= 0 && value <= 59, 'reminderMinute must be 0–59');
    prefs.setInt('qp_reminderMinute', value);
  }

  /// Writes reminder defaults for missing keys.
  ///
  /// Called by [QPPreferences.loadDefaultSettings].
  void _loadReminderDefaults({bool override = false}) {
    if (override || !prefs.containsKey('qp_reminderEnabled')) {
      reminderEnabled = defaultReminderEnabled;
    }
    if (override || !prefs.containsKey('qp_reminderDays')) {
      reminderDays = defaultReminderDays;
    }
    if (override || !prefs.containsKey('qp_reminderHour')) {
      reminderHour = defaultReminderHour;
    }
    if (override || !prefs.containsKey('qp_reminderMinute')) {
      reminderMinute = defaultReminderMinute;
    }
  }
}
