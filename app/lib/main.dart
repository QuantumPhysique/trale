import 'dart:async';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/health_connect_service.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/quick_actions_service.dart';
import 'package:trale/core/reminders.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/pages/splash.dart';

/// Hive box name for persisted measurements.
const String measurementBoxName = 'measurements';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Populate QPLanguage.supportedLanguages from AppLocalizations.
  initLanguages();

  // Register the home-screen app shortcut callback (long-press launcher icon).
  QuickActionsService().init();

  runApp(
    QPApp<TraleNotifier>(
      notifier: TraleNotifier(),
      // Monochrome trale icon for the notification tray.
      notificationIcon: '@drawable/ic_notification',
      onExtraInit: () async {
        await Hive.initFlutter();
        Hive.registerAdapter<Measurement>(MeasurementAdapter());
        await Hive.openBox<Measurement>(measurementBoxName);
        try {
          await HealthConnectService().init();
          if (Preferences().healthConnectEnabled &&
              Preferences().healthConnectImportEnabled) {
            unawaited(HealthConnectService().importMeasurements(days: 30));
          }
        } catch (e) {
          QPAppLogger.error(
            'HealthConnectService init failed',
            tag: 'Main',
            error: e,
          );
        }
      },
      buildRoutes: () => <String, WidgetBuilder>{'/': (_) => const Splash()},
      onGenerateRoute: buildReminderRoute,
      buildStrings: (BuildContext ctx) => qpStringsFromL10n(ctx.l10n),
      // AppLocalizations.localizationsDelegates is generated against
      // flutter_localizations, whose delegates provide the legacy
      // MaterialLocalizations type. material_ui's MaterialApp needs its own,
      // so pair the generated app delegate with material_ui's delegates.
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (BuildContext ctx) => ctx.l10n.trale,
    ),
  );
}
