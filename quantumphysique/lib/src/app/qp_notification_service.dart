import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quantumphysique/src/app/qp_reminder.dart';
import 'package:quantumphysique/src/types/logger.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Route a tapped reminder asked for, waiting to be opened.
///
/// A tap on a running app is pushed by `QPApp`. A tap that cold-starts the app
/// lands here before there is a navigator, and is picked up by `QPSplash` once
/// it has installed the home page — an app that shows no [QPSplash] has to
/// call [takePendingReminderRoute] itself.
final ValueNotifier<QPReminderRoute?> qpPendingReminderRoute =
    ValueNotifier<QPReminderRoute?>(null);

/// Takes the route a tapped reminder asked for, emptying the slot.
QPReminderRoute? takePendingReminderRoute() {
  final QPReminderRoute? route = qpPendingReminderRoute.value;
  qpPendingReminderRoute.value = null;
  return route;
}

/// Top-level callback for notification taps (required by the plugin).
@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(NotificationResponse response) {
  final QPReminderRoute? route = qpReminderRouteFromPayload(response.payload);
  if (route != null) {
    qpPendingReminderRoute.value = route;
  }
}

/// Decodes the route a notification [payload] carries.
///
/// Returns `null` for reminders armed without a route, which only open the
/// app through the launcher intent.
QPReminderRoute? qpReminderRouteFromPayload(String? payload) {
  if (payload == null || payload.isEmpty) {
    return null;
  }
  try {
    final Map<String, dynamic> json =
        jsonDecode(payload) as Map<String, dynamic>;
    return QPReminderRoute(
      json['route'] as String,
      json['arguments'] as String?,
    );
  } on FormatException {
    QPAppLogger.warning(
      'Ignoring notification payload that is not a route: $payload',
      tag: 'QPNotifications',
    );
    return null;
  }
}

/// Arms and cancels notifications for quantumphysique-based apps.
///
/// Owns the plugin, the timezone database and the Android permissions.
/// Apps do not call [arm] directly: [QPReminderRegistry] does, and keeps a
/// record of everything that is armed.
class QPNotificationService {
  /// Returns the singleton instance.
  factory QPNotificationService() => _instance;
  QPNotificationService._();

  /// Constructor a fake subclass calls through in tests.
  @visibleForTesting
  QPNotificationService.forTesting();

  static QPNotificationService _instance = QPNotificationService._();

  /// Replaces the singleton with a fake for testing.
  @visibleForTesting
  static set testInstance(QPNotificationService instance) =>
      _instance = instance;

  /// Restores the real singleton after testing.
  @visibleForTesting
  static void resetInstance() => _instance = QPNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialised = false;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Initialises the plugin and the timezone database.
  ///
  /// [androidIconName] is the drawable resource used as the notification tray
  /// icon (e.g. `'@drawable/ic_notification'`). Call once at app start.
  Future<void> init({String androidIconName = '@mipmap/ic_launcher'}) async {
    if (_initialised) {
      return;
    }

    tz.initializeTimeZones();
    final tz.Location localLocation = resolveLocalLocation(DateTime.now());
    tz.setLocalLocation(localLocation);
    QPAppLogger.debug(
      'Local time zone resolved to "${localLocation.name}"',
      tag: 'QPNotifications',
    );

    final AndroidInitializationSettings androidInit =
        AndroidInitializationSettings(androidIconName);

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // On a cold start the tap callback has already run before the plugin was
    // initialised, so the launching notification's route is only available
    // from the launch details.
    final NotificationAppLaunchDetails? launch = await _plugin
        .getNotificationAppLaunchDetails();
    if (launch != null && launch.didNotificationLaunchApp) {
      final QPReminderRoute? route = qpReminderRouteFromPayload(
        launch.notificationResponse?.payload,
      );
      if (route != null) {
        qpPendingReminderRoute.value = route;
      }
    }

    _initialised = true;
  }

  /// Number of days probed when matching the device time zone against the
  /// IANA database. Spans more than a year so that every daylight saving
  /// transition the device observes is covered.
  static const int _timeZoneProbeDays = 400;

  /// Interval between probes, in hours. Daylight saving transitions happen
  /// at different hours in different regions, so sub-day resolution is
  /// needed to tell otherwise similar zones apart.
  static const int _timeZoneProbeIntervalHours = 6;

  /// Resolves the [tz.Location] to use as the device's local time zone.
  ///
  /// `DateTime.timeZoneName` reports an abbreviation on most platforms
  /// (`CEST`, `PST`, …) rather than an IANA identifier, so it cannot simply
  /// be handed to [tz.getLocation]. A few abbreviations *are* database
  /// entries but carry different rules — `EST` is a fixed UTC-5 zone that
  /// never observes daylight saving — so even a name that does resolve has
  /// to be verified before it is trusted.
  ///
  /// Candidates are therefore checked against the UTC offsets Dart itself
  /// reports for the coming [_timeZoneProbeDays] days: the first location
  /// that agrees on all of them keeps the same wall clock as the device, so
  /// scheduling against it lands on the intended minute. The chosen name may
  /// differ from the device's own (`Africa/Ceuta` rather than
  /// `Europe/Berlin`, say) — only the offsets and transition instants matter
  /// here.
  ///
  /// Falls back to the closest partial match and finally to a synthetic
  /// fixed-offset zone, so the result is never silently UTC.
  static tz.Location resolveLocalLocation(DateTime now) {
    final List<int> probeAt = <int>[];
    final List<int> probeOffsetMs = <int>[];
    const Duration step = Duration(hours: _timeZoneProbeIntervalHours);
    final int probeCount =
        _timeZoneProbeDays * 24 ~/ _timeZoneProbeIntervalHours;
    DateTime probe = now;
    for (int i = 0; i <= probeCount; i++) {
      probeAt.add(probe.millisecondsSinceEpoch);
      probeOffsetMs.add(probe.timeZoneOffset.inMilliseconds);
      probe = probe.add(step);
    }

    int matchingProbes(tz.Location location) {
      int matches = 0;
      for (int i = 0; i < probeAt.length; i++) {
        if (location.timeZone(probeAt[i]).offset.inMilliseconds ==
            probeOffsetMs[i]) {
          matches++;
        }
      }
      return matches;
    }

    tz.Location? best;
    int bestMatches = 0;

    // Platforms that do report an IANA identifier keep their own name, as
    // long as it actually behaves like the device's zone.
    try {
      final tz.Location named = tz.getLocation(now.timeZoneName);
      final int matches = matchingProbes(named);
      if (matches == probeAt.length) {
        return named;
      }
      best = named;
      bestMatches = matches;
    } on tz.LocationNotFoundException {
      // Expected whenever the platform reports an abbreviation.
    }

    for (final tz.Location candidate in tz.timeZoneDatabase.locations.values) {
      // Skip the ~95% of zones that do not even agree on the current
      // offset before paying for a full probe sweep.
      if (candidate.timeZone(probeAt.first).offset.inMilliseconds !=
          probeOffsetMs.first) {
        continue;
      }
      final int matches = matchingProbes(candidate);
      if (matches > bestMatches) {
        best = candidate;
        bestMatches = matches;
        if (matches == probeAt.length) {
          break;
        }
      }
    }

    if (best != null && bestMatches > 0) {
      if (bestMatches < probeAt.length) {
        QPAppLogger.warning(
          'No exact time zone match for "${now.timeZoneName}"; using '
          '"${best.name}" ($bestMatches/${probeAt.length} probes)',
          tag: 'QPNotifications',
        );
      }
      return best;
    }

    QPAppLogger.warning(
      'Could not match "${now.timeZoneName}" against the time zone '
      'database; falling back to a fixed offset',
      tag: 'QPNotifications',
    );
    return _fixedOffsetLocation(now.timeZoneOffset);
  }

  /// Builds a [tz.Location] with a constant [offset] and no daylight saving.
  ///
  /// Last resort for devices whose zone is missing from the bundled
  /// database: reminders stay correct until the next transition instead of
  /// being scheduled against UTC.
  static tz.Location _fixedOffsetLocation(Duration offset) {
    final String name = _fixedOffsetName(offset);
    return tz.Location(name, <int>[tz.minTime], <int>[0], <tz.TimeZone>[
      tz.TimeZone(offset, isDst: false, abbreviation: name),
    ]);
  }

  /// Formats [offset] as a zone name such as `UTC+02:00`.
  static String _fixedOffsetName(Duration offset) {
    if (offset == Duration.zero) {
      return 'UTC';
    }
    final Duration magnitude = offset.abs();
    final String sign = offset.isNegative ? '-' : '+';
    final String hours = magnitude.inHours.toString().padLeft(2, '0');
    final String minutes = (magnitude.inMinutes % Duration.minutesPerHour)
        .toString()
        .padLeft(2, '0');
    return 'UTC$sign$hours:$minutes';
  }

  // ---------------------------------------------------------------------------
  // Permissions
  // ---------------------------------------------------------------------------

  /// Requests notification permission on Android 13+.
  /// Returns `true` if granted.
  Future<bool> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) {
      return false;
    }
    final bool? granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Requests the exact-alarm permission required on Android 14+.
  /// Returns `true` if granted.
  Future<bool> requestExactAlarmPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) {
      return false;
    }
    final bool? granted = await androidPlugin.requestExactAlarmsPermission();
    return granted ?? false;
  }

  // ---------------------------------------------------------------------------
  // Arming
  // ---------------------------------------------------------------------------

  /// Arms [reminder] with the system.
  ///
  /// Uses an exact alarm so the notification fires at its minute; Android
  /// defers inexact alarms — even `allowWhileIdle` ones — by up to several
  /// hours while the device dozes. Falls back to an inexact alarm when the
  /// exact-alarm permission was denied (Android 14+).
  Future<void> arm(QPReminder reminder) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          reminder.channel.id,
          reminder.channel.name,
          channelDescription: reminder.channel.description,
          importance: reminder.channel.importance,
          priority: Priority.high,
        );
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    final DateTime when = reminder.scheduledFor;
    final tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      when.year,
      when.month,
      when.day,
      when.hour,
      when.minute,
    );
    final DateTimeComponents? repeat =
        reminder.repeat == QPReminderRepeat.weekly
        ? DateTimeComponents.dayOfWeekAndTime
        : null;
    final String? payload = reminder.route == null
        ? null
        : jsonEncode(<String, String?>{
            'route': reminder.route,
            'arguments': reminder.routeArguments,
          });

    try {
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        payload: payload,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: repeat,
      );
    } on PlatformException {
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        payload: payload,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: repeat,
      );
    }
  }

  /// Cancels the notification armed under [id].
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns the next local instant matching [weekday] (1=Mon … 7=Sun) at
  /// [hour]:[minute], counted from [from] (defaults to now).
  static DateTime nextWeekdayInstance(
    int weekday,
    int hour,
    int minute, {
    DateTime? from,
  }) {
    assert(weekday >= 1 && weekday <= 7, 'weekday must be 1 (Mon) … 7 (Sun)');
    final DateTime now = from ?? DateTime.now();
    // Days are added through the constructor, not as a Duration: across a
    // daylight saving transition a 24-hour Duration moves the wall clock by
    // an hour and the reminder would fire at the wrong time.
    int offset = (weekday - now.weekday) % 7;
    DateTime scheduled = DateTime(
      now.year,
      now.month,
      now.day + offset,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      offset += 7;
      scheduled = DateTime(now.year, now.month, now.day + offset, hour, minute);
    }
    return scheduled;
  }
}
