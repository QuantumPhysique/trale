part of 'qp_notifier.dart';

/// Extension on [QPNotifier] holding reminder / notification state.
extension QPReminderStateExtension on QPNotifier {
  /// Whether reminders are enabled.
  bool get reminderEnabled => prefs.reminderEnabled;

  /// Sets the reminder-enabled flag.
  set reminderEnabled(bool value) {
    if (value != reminderEnabled) {
      prefs.reminderEnabled = value;
      notify;
    }
  }

  /// Active reminder days (ISO weekday: 1=Mon … 7=Sun).
  List<int> get reminderDays => prefs.reminderDays;

  /// Sets the active reminder days.
  set reminderDays(List<int> days) {
    prefs.reminderDays = days;
    notify;
  }

  /// Reminder hour (0–23).
  int get reminderHour => prefs.reminderHour;

  /// Sets the reminder hour.
  set reminderHour(int value) {
    if (value != reminderHour) {
      prefs.reminderHour = value;
      notify;
    }
  }

  /// Reminder minute (0–59).
  int get reminderMinute => prefs.reminderMinute;

  /// Sets the reminder minute.
  set reminderMinute(int value) {
    if (value != reminderMinute) {
      prefs.reminderMinute = value;
      notify;
    }
  }

  /// Reminder time as a [TimeOfDay].
  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  /// Sets the reminder time from a [TimeOfDay].
  set reminderTime(TimeOfDay time) {
    prefs.reminderHour = time.hour;
    prefs.reminderMinute = time.minute;
    notify;
  }
}
