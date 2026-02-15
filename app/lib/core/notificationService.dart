// ignore_for_file: file_names
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/preferences.dart';

/// Top-level callback for notification taps (required by the plugin).
@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(
  NotificationResponse notificationResponse,
) {
  // No-op: tapping opens the app via the launcher intent.
}

/// Service that manages daily weight-logging reminder notifications.
class NotificationService {
  /// Singleton constructor.
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Whether the service has been initialised.
  bool _initialised = false;

  /// Android notification channel constants.
  static const String _channelId = 'trale_weight_reminder';
  static const String _channelName = 'Weight reminder';
  static const String _channelDescription =
      'Daily reminders to log your weight';

  /// Base notification id – one per weekday (0 = Monday … 6 = Sunday).
  static const int _baseNotificationId = 1000;

  // ──────────────────────────────────────────────────────────────────────────
  // Initialisation
  // ──────────────────────────────────────────────────────────────────────────

  /// Initialise the plugin and the timezone database.
  /// Call once at app start (in `main()`).
  Future<void> init() async {
    if (_initialised) {
      return;
    }

    // Timezone setup.
    tz.initializeTimeZones();
    try {
      // On Android, timeZoneName returns IANA identifiers (e.g. "Europe/Berlin").
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (e) {
      // Fallback: find a location whose current UTC offset matches the device.
      debugPrint('Could not resolve timezone name, falling back to offset: $e');
      final int offsetMs = DateTime.now().timeZoneOffset.inMilliseconds;
      final tz.Location fallback = tz.timeZoneDatabase.locations.values
          .firstWhere(
            (tz.Location l) => l.currentTimeZone.offset == offsetMs,
            orElse: () => tz.UTC,
          );
      tz.setLocalLocation(fallback);
    }

    // Plugin setup – use the monochrome trale icon for the notification tray.
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@drawable/ic_notification');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // If the app was launched by tapping a notification, the plugin already
    // brings it to the foreground.  We call getNotificationAppLaunchDetails()
    // so the plugin can complete the launch handshake on a cold start.
    await _plugin.getNotificationAppLaunchDetails();

    _initialised = true;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Permissions
  // ──────────────────────────────────────────────────────────────────────────

  /// Request notification permission (Android 13+).
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

  /// Request the exact-alarm permission required for scheduled notifications
  /// on Android 14+.
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

  // ──────────────────────────────────────────────────────────────────────────
  // Scheduling helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Schedule weekly notifications for the given [days] (1 = Monday …
  /// 7 = Sunday) at [hour]:[minute].
  ///
  /// Before firing, the callback checks whether the user has already logged
  /// a measurement today; if so, the notification is still scheduled (the
  /// system will show it), but we rely on cancellation at app start /
  /// when a measurement is added to suppress it.
  Future<void> scheduleWeeklyReminders({
    required List<int> days,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    // Cancel existing reminders first.
    await cancelAllReminders();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    for (final int day in days) {
      final int notificationId = _baseNotificationId + day;
      final tz.TZDateTime scheduledDate = _nextInstanceOfWeekdayTime(
        day,
        hour,
        minute,
      );

      await _plugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Cancel all scheduled weight-reminder notifications.
  Future<void> cancelAllReminders() async {
    for (int day = 1; day <= 7; day++) {
      await _plugin.cancel(id: _baseNotificationId + day);
    }
  }

  /// Cancel today's notification if a measurement has been logged.
  /// Call this when a new measurement is inserted or at app startup.
  Future<void> cancelTodayIfMeasured() async {
    final Preferences prefs = Preferences();
    await prefs.loaded;

    if (!prefs.reminderEnabled) {
      return;
    }

    final MeasurementDatabase db = MeasurementDatabase();
    final bool loggedToday =
        db.measurements.isNotEmpty &&
        dayInMeasurements(DateTime.now(), db.measurements);

    if (loggedToday) {
      final int todayWeekday = DateTime.now().weekday; // 1=Mon … 7=Sun
      await _plugin.cancel(id: _baseNotificationId + todayWeekday);
    }
  }

  /// Re-schedule reminders from stored preferences.
  /// Call at app startup and whenever settings change.
  Future<void> rescheduleFromPreferences({
    required String title,
    required String body,
  }) async {
    final Preferences prefs = Preferences();
    await prefs.loaded;

    if (!prefs.reminderEnabled || prefs.reminderDays.isEmpty) {
      await cancelAllReminders();
      return;
    }

    await scheduleWeeklyReminders(
      days: prefs.reminderDays,
      hour: prefs.reminderHour,
      minute: prefs.reminderMinute,
      title: title,
      body: body,
    );

    // Suppress today's notification if measurement already exists.
    await cancelTodayIfMeasured();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Return the next [tz.TZDateTime] that matches [weekday] at
  /// [hour]:[minute].  [weekday] uses ISO 8601 (1 = Monday … 7 = Sunday).
  tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Move to the correct weekday.
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // If the resulting time is in the past, advance by one week.
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    return scheduled;
  }
}
