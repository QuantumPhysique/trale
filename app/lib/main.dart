import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/pages/home.dart';
import 'package:trale/pages/onBoarding.dart';


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

  return runApp(
    ChangeNotifierProvider<TraleNotifier>.value(
      value: traleNotifier,
      child: TraleMainApp(),
    ),
  );
}


/// MaterialApp with AdonisTheme
class TraleApp extends MaterialApp{
  /// Constructor
  TraleApp({
    required this.traleNotifier,
    Map<String, WidgetBuilder> routes = const <String, WidgetBuilder>{},
  }) : super(
    theme: traleNotifier.theme.light.themeData,
    darkTheme: traleNotifier.isAmoled
        ? traleNotifier.theme.amoled.themeData
        : traleNotifier.theme.dark.themeData,
    themeMode: traleNotifier.themeMode,
    routes: routes,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: traleNotifier.locale,
  );

  /// themeNotifier for interactive change of theme
  final TraleNotifier traleNotifier;
}


class TraleMainApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(context);
    /// shared preferences instance
    final Preferences prefs = Preferences();

    return TraleApp(
      traleNotifier: traleNotifier,
      routes:  <String, Widget Function(BuildContext)>{
        '/': (BuildContext context) {
          if (prefs.showOnBoarding) {
            return const OnBoardingPage();
          } else{
            return const Home();
          }
        }
      },
    );
  }
}
