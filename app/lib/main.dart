import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:quantumphysique/quantumphysique.dart';

import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/notification_service.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/pages/splash.dart';

/// Hive box name for persisted measurements.
const String measurementBoxName = 'measurements';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Populate QPLanguage.supportedLanguages from AppLocalizations.
  initLanguages();

  runApp(
    QPApp<TraleNotifier>(
      notifier: TraleNotifier(),
      onExtraInit: () async {
        await Hive.initFlutter();
        Hive.registerAdapter<Measurement>(MeasurementAdapter());
        await Hive.openBox<Measurement>(measurementBoxName);
        try {
          await NotificationService().init();
        } catch (e) {
          QPAppLogger.error(
            'NotificationService init failed',
            tag: 'Main',
            error: e,
          );
        }
      },
      buildRoutes: () => <String, WidgetBuilder>{'/': (_) => const Splash()},
      buildStrings: (BuildContext ctx) => qpStringsFromL10n(ctx.l10n),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      //onboardingBuilder: (_) => const OnBoardingPage(),
      onGenerateTitle: (BuildContext ctx) => ctx.l10n.trale,
    ),
  );
}
