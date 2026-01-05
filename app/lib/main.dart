import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/database/database_helper.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/pages/splash.dart';
import 'package:trale/screens/onboarding_screen.dart';
import 'package:trale/screens/home_screen.dart';


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

  // Initialize database
  await DatabaseHelper.instance.database;

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
    darkTheme: traleNotifier.isAmoled
        ? amoled.themeData
        : dark.themeData,
    themeMode: traleNotifier.themeMode,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
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
                return const AppInitializer();
              },
              '/home': (BuildContext context) {
                return const Splash();
              },
              '/onboarding': (BuildContext context) {
                return const OnboardingScreen();
              },
            },
            light: traleNotifier.theme.light(context),
            dark: traleNotifier.theme.dark(context),
            amoled: traleNotifier.theme.amoled(context),
          );
      }
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({Key? key}) : super(key: key);

  Future<bool> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkOnboardingStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isOnboardingCompleted = snapshot.data ?? false;

        // Show onboarding if not completed, otherwise home screen
        if (isOnboardingCompleted) {
          return const HomeScreen(); // New home screen with entry timeline
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}
