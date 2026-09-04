import 'package:material_ui/material_ui.dart';
import 'package:quantumphysique/quantumphysique.dart';

import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/widget/add_weight_dialog.dart';

/// Named route that opens the add-weight dialog over the running app.
const String addWeightRoute = '/addWeight';

/// Tag every weight-logging reminder is registered under.
///
/// The reminder of a single weekday is tagged `weight:<ISO weekday>`, so the
/// tag below addresses all seven of them at once.
const String weightReminderTag = 'weight';

/// Channel the weight reminders are posted on.
const QPNotificationChannel weightReminderChannel = QPNotificationChannel(
  id: 'trale_weight_reminder',
  name: 'Weight reminder',
  description: 'Reminders to log your weight',
);

/// Cancels and re-arms the weekly weight reminders from the stored settings.
///
/// Call on every app start, and that is not book-keeping.
/// flutter_local_notifications persists every armed notification on the
/// Android side together with the time-zone *name* that was current when it
/// was armed, and re-schedules the next weekly occurrence itself. A reminder
/// armed while `tz.local` was still UTC therefore keeps firing two hours late
/// in CEST forever, even once the app resolves the zone correctly. Re-arming
/// drops the stale id and schedules it again against the resolved zone.
Future<void> rescheduleWeightReminders({
  required String title,
  required String body,
}) async {
  final Preferences prefs = Preferences();
  await prefs.loaded;

  await QPReminderRegistry().cancelTag(weightReminderTag);
  if (!prefs.reminderEnabled) {
    return;
  }

  for (final int day in prefs.reminderDays) {
    await QPReminderRegistry().schedule(
      tag: '$weightReminderTag:$day',
      title: title,
      body: body,
      scheduledFor: QPNotificationService.nextWeekdayInstance(
        day,
        prefs.reminderHour,
        prefs.reminderMinute,
      ),
      channel: weightReminderChannel,
      repeat: QPReminderRepeat.weekly,
      route: addWeightRoute,
    );
  }

  await skipTodaysWeightReminder();
}

/// Drops today's weight reminder once a measurement for today exists.
///
/// The weekly series keeps running; only this week's occurrence is skipped.
Future<void> skipTodaysWeightReminder() async {
  final DateTime today = DateTime.now();
  if (dayInMeasurements(today, MeasurementDatabase().measurements)) {
    await QPReminderRegistry().skipOn(weightReminderTag, today);
  }
}

/// Serves the routes a tapped reminder opens.
///
/// [addWeightRoute] is transparent so the dialog appears over the screen the
/// user was last on instead of over a blank page.
Route<void>? buildReminderRoute(RouteSettings settings) {
  if (settings.name != addWeightRoute) {
    return null;
  }
  return PageRouteBuilder<void>(
    settings: settings,
    opaque: false,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) => const AddWeightOverlay(),
  );
}
