part of '../trale_notifier.dart';

/// Extension on [TraleNotifier] holding reminder state.
extension ReminderStateExtension on TraleNotifier {
  /// getter for reminder enabled
  bool get reminderEnabled => prefs.reminderEnabled;

  /// setter for reminder enabled
  set reminderEnabled(bool enabled) {
    if (enabled != reminderEnabled) {
      prefs.reminderEnabled = enabled;
      notify;
    }
  }

  /// getter for reminder days
  List<int> get reminderDays => prefs.reminderDays;

  /// setter for reminder days
  set reminderDays(List<int> days) {
    prefs.reminderDays = days;
    notify;
  }

  /// getter for reminder hour
  int get reminderHour => prefs.reminderHour;

  /// setter for reminder hour
  set reminderHour(int hour) {
    if (hour != reminderHour) {
      prefs.reminderHour = hour;
      notify;
    }
  }

  /// getter for reminder minute
  int get reminderMinute => prefs.reminderMinute;

  /// setter for reminder minute
  set reminderMinute(int minute) {
    if (minute != reminderMinute) {
      prefs.reminderMinute = minute;
      notify;
    }
  }

  /// get reminder TimeOfDay
  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  /// set reminder TimeOfDay
  set reminderTime(TimeOfDay time) {
    prefs.reminderHour = time.hour;
    prefs.reminderMinute = time.minute;
    notify;
  }
}
