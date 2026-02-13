import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/firstDayLocalizationsDelegate.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/notificationService.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/pages/splash.dart';

const String measurementBoxName = 'measurements';

Future<void> main() async {
  // load singleton
  WidgetsFlutterBinding.ensureInitialized();
  final Preferences prefs = Preferences();
  await prefs.loaded;
  final TraleNotifier traleNotifier = TraleNotifier();

  await Hive.initFlutter();
  Hive.registerAdapter<Measurement>(MeasurementAdapter());
  await Hive.openBox<Measurement>(measurementBoxName);

  // Initialise the notification service.
  final NotificationService notificationService = NotificationService();
  await notificationService.init();

  return runApp(
    ChangeNotifierProvider<TraleNotifier>.value(
      value: traleNotifier,
      child: const TraleMainApp(),
    ),
  );
}

/// MaterialApp with AdonisTheme
class TraleApp extends MaterialApp {
  /// Constructor
  TraleApp({
    super.key,
    required this.traleNotifier,
    super.routes,
    required this.light,
    required this.dark,
    required this.amoled,
  }) : super(
         theme: light.themeData,
         darkTheme: traleNotifier.isAmoled ? amoled.themeData : dark.themeData,
         themeMode: traleNotifier.themeMode,
         localizationsDelegates: <LocalizationsDelegate<dynamic>>[
           AppLocalizations.delegate,
           FirstDayMaterialLocalizationsDelegate(
             firstDay: traleNotifier.firstDay,
           ),
           GlobalWidgetsLocalizations.delegate,
         ],
         supportedLocales: AppLocalizations.supportedLocales,
         locale: traleNotifier.locale,
       );

  /// themeNotifier for interactive change of theme
  final TraleNotifier traleNotifier;
  final TraleTheme light;
  final TraleTheme dark;
  final TraleTheme amoled;
}

class TraleMainApp extends StatelessWidget {
  const TraleMainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(context);

    /// shared preferences instance
    final Preferences prefs = Preferences();

    return DynamicColorBuilder(
      builder: (ColorScheme? systemLight, ColorScheme? systemDark) {
        traleNotifier.setColorScheme(systemLight, systemDark);
        return TraleApp(
          traleNotifier: traleNotifier,
          routes: <String, Widget Function(BuildContext)>{
            '/': (BuildContext context) {
              return const Splash();
            },
          },
          light: traleNotifier.theme.light(context),
          dark: traleNotifier.theme.dark(context),
          amoled: traleNotifier.theme.amoled(context),
        );
      },
    );
  }
}
