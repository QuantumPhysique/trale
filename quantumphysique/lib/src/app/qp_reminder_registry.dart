import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:quantumphysique/src/app/qp_notification_service.dart';
import 'package:quantumphysique/src/app/qp_reminder.dart';
import 'package:quantumphysique/src/preferences/qp_preferences.dart';
import 'package:quantumphysique/src/types/logger.dart';

/// Every reminder the app currently has armed.
///
/// [QPNotificationService] arms and cancels notifications; this registry
/// remembers which ones are outstanding so they can be dropped again later —
/// once the workout was done or the weight logged, say. The list is persisted
/// through the app's [QPPreferences] and survives restarts.
///
/// Reminders are addressed by [QPReminder.tag]. Tags are hierarchical and
/// `:`-separated: every method that takes a tag also matches the tags below
/// it, so `workout` reaches `workout:7` while `workout:7` reaches only that
/// one workout.
class QPReminderRegistry {
  /// Returns the singleton instance.
  factory QPReminderRegistry() => _instance;
  QPReminderRegistry._();
  static final QPReminderRegistry _instance = QPReminderRegistry._();

  QPPreferences? _prefs;
  List<QPReminder> _reminders = <QPReminder>[];

  /// Binds the registry to [prefs] and restores the armed reminders.
  ///
  /// Called by `QPApp` once preferences are loaded, before anything schedules.
  void attach(QPPreferences prefs) {
    _prefs = prefs;
    _reminders = _decode(prefs.activeReminders);
    _prune();
  }

  QPPreferences get _store {
    final QPPreferences? prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'QPReminderRegistry is not attached to any preferences. '
        'QPApp calls attach() during start-up; tests have to call it too.',
      );
    }
    return prefs;
  }

  // ---------------------------------------------------------------------------
  // Reading
  // ---------------------------------------------------------------------------

  /// Every armed reminder, earliest fire instant first.
  List<QPReminder> get active {
    _prune();
    final List<QPReminder> sorted = List<QPReminder>.of(_reminders);
    sorted.sort(
      (QPReminder a, QPReminder b) => a.scheduledFor.compareTo(b.scheduledFor),
    );
    return sorted;
  }

  /// The armed reminders under [tag], earliest fire instant first.
  List<QPReminder> withTag(String tag) =>
      active.where((QPReminder r) => _matches(r, tag)).toList();

  /// The next reminder under [tag] that has yet to fire.
  QPReminder? next(String tag) {
    final List<QPReminder> tagged = withTag(tag);
    return tagged.isEmpty ? null : tagged.first;
  }

  // ---------------------------------------------------------------------------
  // Arming
  // ---------------------------------------------------------------------------

  /// Arms a reminder and records it.
  ///
  /// [tag] groups the reminder with its siblings, [title] and [body] are the
  /// message, and [route] is the named route a tap opens — pass it with
  /// [routeArguments] to land on a specific item. Returns the armed reminder,
  /// whose [QPReminder.id] the registry assigned.
  Future<QPReminder> schedule({
    required String tag,
    required String title,
    required String body,
    required DateTime scheduledFor,
    required QPNotificationChannel channel,
    QPReminderRepeat repeat = QPReminderRepeat.once,
    String? route,
    String? routeArguments,
  }) async {
    final QPReminder reminder = QPReminder(
      id: _takeId(),
      tag: tag,
      title: title,
      body: body,
      scheduledFor: scheduledFor,
      channel: channel,
      repeat: repeat,
      route: route,
      routeArguments: routeArguments,
    );
    await QPNotificationService().arm(reminder);
    _reminders.add(reminder);
    await _persist();
    return reminder;
  }

  // ---------------------------------------------------------------------------
  // Cancelling
  // ---------------------------------------------------------------------------

  /// Cancels the reminder armed under [id].
  Future<void> cancel(int id) => _cancelWhere((QPReminder r) => r.id == id);

  /// Cancels every reminder under [tag].
  Future<void> cancelTag(String tag) =>
      _cancelWhere((QPReminder r) => _matches(r, tag));

  /// Cancels every armed reminder.
  Future<void> cancelAll() => _cancelWhere((QPReminder r) => true);

  Future<void> _cancelWhere(bool Function(QPReminder) test) async {
    final List<QPReminder> doomed = _reminders.where(test).toList();
    if (doomed.isEmpty) {
      return;
    }
    for (final QPReminder reminder in doomed) {
      await QPNotificationService().cancel(reminder.id);
    }
    _reminders.removeWhere(test);
    await _persist();
  }

  // ---------------------------------------------------------------------------
  // Skipping
  // ---------------------------------------------------------------------------

  /// Drops the next occurrence of the earliest reminder under [tag].
  ///
  /// What the workout being done or the weight being logged calls: a one-shot
  /// reminder is cancelled outright, a weekly one loses only this week's
  /// occurrence and keeps running.
  Future<void> skipNext(String tag) async {
    final QPReminder? upcoming = next(tag);
    if (upcoming != null) {
      await _skip(upcoming);
    }
  }

  /// Drops the occurrence of every reminder under [tag] that falls on [day].
  Future<void> skipOn(String tag, DateTime day) async {
    final List<QPReminder> due = withTag(
      tag,
    ).where((QPReminder r) => _sameDay(r.scheduledFor, day)).toList();
    for (final QPReminder reminder in due) {
      await _skip(reminder);
    }
  }

  Future<void> _skip(QPReminder reminder) async {
    if (!reminder.scheduledFor.isAfter(DateTime.now())) {
      return;
    }
    await QPNotificationService().cancel(reminder.id);
    _reminders.removeWhere((QPReminder r) => r.id == reminder.id);
    if (reminder.repeat == QPReminderRepeat.weekly) {
      final QPReminder nextWeek = reminder.withScheduledFor(
        _plusWeek(reminder.scheduledFor),
      );
      await QPNotificationService().arm(nextWeek);
      _reminders.add(nextWeek);
    }
    await _persist();
  }

  // ---------------------------------------------------------------------------
  // Book-keeping
  // ---------------------------------------------------------------------------

  /// Forgets one-shot reminders that have fired and moves weekly ones on to
  /// their next occurrence, which Android has already re-armed on its own.
  void _prune() {
    final DateTime now = DateTime.now();
    final List<QPReminder> live = <QPReminder>[];
    for (final QPReminder reminder in _reminders) {
      if (reminder.scheduledFor.isAfter(now)) {
        live.add(reminder);
      } else if (reminder.repeat == QPReminderRepeat.weekly) {
        DateTime when = reminder.scheduledFor;
        while (!when.isAfter(now)) {
          when = _plusWeek(when);
        }
        live.add(reminder.withScheduledFor(when));
      }
    }
    _reminders = live;
  }

  Future<void> _persist() async {
    _prune();
    _store.activeReminders = jsonEncode(
      _reminders.map((QPReminder r) => r.toJson()).toList(),
    );
  }

  int _takeId() {
    final int id = _store.nextReminderId;
    // Android notification ids are 32-bit; wrap well before that so a
    // long-lived install never hands out an id the platform rejects.
    _store.nextReminderId = id >= 1 << 30 ? 1 : id + 1;
    return id;
  }

  static List<QPReminder> _decode(String raw) {
    if (raw.isEmpty) {
      return <QPReminder>[];
    }
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((dynamic e) => QPReminder.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException catch (e) {
      QPAppLogger.error(
        'Discarding unreadable reminder registry',
        tag: 'QPReminders',
        error: e,
      );
      return <QPReminder>[];
    }
  }

  static bool _matches(QPReminder reminder, String tag) =>
      reminder.tag == tag || reminder.tag.startsWith('$tag:');

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Same wall-clock time a week on. Built through the constructor so a
  /// daylight saving transition in between does not move the hour.
  static DateTime _plusWeek(DateTime when) =>
      DateTime(when.year, when.month, when.day + 7, when.hour, when.minute);

  /// Empties the registry without touching the system. Tests only.
  @visibleForTesting
  void resetForTesting() {
    _prefs = null;
    _reminders = <QPReminder>[];
  }
}
