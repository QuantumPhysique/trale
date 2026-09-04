import 'package:material_ui/material_ui.dart';
import 'package:quantumphysique/quantumphysique.dart';

import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/quick_actions_service.dart';
import 'package:trale/core/reminders.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/pages/home.dart';

/// Splash screen for trale.
///
/// Delegates all generic splash behaviour to [QPSplash] and injects
/// trale-specific initialisation (database + notification rescheduling).
class Splash extends StatelessWidget {
  /// constructor
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return QPSplash(
      onInit: () async {
        await MeasurementDatabase().reinit();
        if (!context.mounted) {
          return;
        }
        final AppLocalizations? l10n = AppLocalizations.of(context);
        if (l10n != null) {
          rescheduleWeightReminders(
            title: l10n.reminderNotificationTitle,
            body: l10n.reminderNotificationBody,
          );
          // Register the (translated) home-screen shortcut entry.
          QuickActionsService().setShortcuts(title: l10n.addWeight);
        }
      },
      homeBuilder: (_) => const Home(),
    );
  }
}
