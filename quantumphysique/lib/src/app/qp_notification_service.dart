import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quantumphysique/src/notifier/qp_notifier.dart';
import 'package:quantumphysique/src/types/logger.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Top-level callback for notification taps (required by the plugin).
@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(
  NotificationResponse notificationResponse,
) {
  // No-op: tapping opens the app via the launcher intent.
}

/// Base notification service for quantumphysique-based apps.
///
/// Provides timezone setup, plugin initialisation, and
/// cancellation helpers. Subclasses implement [scheduleAll] with
/// their app-specific notification logic.
abstract class QPNotificationService {
  /// Singleton constructor. Each concrete subclass should provide its own
  /// factory singleton.
  QPNotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Whether the service has been initialised.
  bool _initialised = false;

  /// Exposes the underlying plugin for subclass use.
  @protected
  FlutterLocalNotificationsPlugin get plugin => _plugin;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Initialises the plugin and the timezone database.
  ///
  /// [androidIconName] should be the drawable resource name for the
  /// notification tray icon (e.g. `'@drawable/ic_notification'`).
  ///
  /// Call once at app start.
  Future<void> init({String androidIconName = '@mipmap/ic_launcher'}) async {
    if (_initialised) {
      return;
    }

    // Timezone setup.
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

    await _plugin.getNotificationAppLaunchDetails();

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
  ///
  /// Exposed for apps that manage their own notification plugin rather than
  /// subclassing this service.
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
  // Scheduling (to be implemented by subclasses)
  // ---------------------------------------------------------------------------

  /// Cancels all notifications managed by this service.
  Future<void> cancelAll();

  /// Schedules notifications using the current [notifier] state.
  ///
  /// Apps override this to schedule their specific notifications
  /// (e.g. weekday weight-logging reminders).
  Future<void> scheduleAll(QPNotifier notifier);

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns the next [tz.TZDateTime] matching [weekday] (1=Mon … 7=Sun)
  /// at [hour]:[minute] local time.
  tz.TZDateTime nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }
    return scheduled;
  }
}
