import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/pages/home.dart';


Future<void> main() async {
  // load singleton
  WidgetsFlutterBinding.ensureInitialized();
  final Preferences prefs = Preferences();
  await prefs.loaded;
  final TraleNotifier traleNotifier = TraleNotifier();

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

    return TraleApp(
      traleNotifier: traleNotifier,
      routes: {
        '/': (BuildContext context) => const Home(),
      },
    );
  }
}
