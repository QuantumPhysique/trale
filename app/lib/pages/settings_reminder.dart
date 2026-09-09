import 'package:material_ui/material_ui.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/reminders.dart';

/// Settings sub-page for configuring weight-logging reminders.
///
/// Thin wrapper around [QPNotificationsSettingsPage] that re-arms trale's
/// weight reminders whenever a setting changes.
class ReminderSettingsPage extends StatelessWidget {
  /// Constructor.
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final QPNotificationService ns = QPNotificationService();
    final AppLocalizations l10n = context.l10n;

    return QPNotificationsSettingsPage(
      strings: qpStringsFromL10n(l10n),
      onScheduleChanged: (QPNotifier notifier) => rescheduleWeightReminders(
        title: l10n.reminderNotificationTitle,
        body: l10n.reminderNotificationBody,
      ),
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
