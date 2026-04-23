import 'package:flutter/material.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/notification_service.dart';

/// Settings sub-page for configuring weight-logging reminders.
///
/// Thin wrapper around [QPNotificationsSettingsPage] that wires up
/// trale's [NotificationService].
class ReminderSettingsPage extends StatelessWidget {
  /// Constructor.
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationService ns = NotificationService();
    final AppLocalizations l10n = context.l10n;

    return QPNotificationsSettingsPage(
      strings: qpStringsFromL10n(l10n),
      onScheduleChanged: (QPNotifier notifier) async {
        if (notifier.reminderEnabled && notifier.reminderDays.isNotEmpty) {
          await ns.rescheduleFromPreferences(
            title: l10n.reminderNotificationTitle,
            body: l10n.reminderNotificationBody,
          );
        } else {
          await ns.cancelAllReminders();
        }
      },
      onRequestPermission: () => ns.requestPermission(),
      onRequestExactAlarmPermission: () => ns.requestExactAlarmPermission(),
      footerWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: QPLayout.padding),
        child: Text(
          l10n.reminderExplanation,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
