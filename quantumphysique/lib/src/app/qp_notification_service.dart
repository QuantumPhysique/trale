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
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (e) {
      QPAppLogger.warning(
        'Could not resolve timezone name, falling back to offset',
        tag: 'QPNotifications',
        error: e,
      );
      final int offsetMs = DateTime.now().timeZoneOffset.inMilliseconds;
      final tz.Location fallback = tz.timeZoneDatabase.locations.values
          .firstWhere(
            (tz.Location l) => l.currentTimeZone.offset == offsetMs,
            orElse: () => tz.UTC,
          );
      tz.setLocalLocation(fallback);
    }

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
