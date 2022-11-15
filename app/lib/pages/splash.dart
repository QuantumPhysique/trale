import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/pages/home.dart';
import 'package:trale/pages/onBoarding.dart';
import 'package:trale/widget/splashHero.dart';


/// splash scaffold
class Splash extends StatefulWidget {
  /// constructor
  const Splash({Key? key}) : super(key: key);
  @override

  /// create state
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // color system bottom navigation bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        /// default values of flutter definition
        /// https://github.com/flutter/flutter/blob/ee4e09cce01d6f2d7f4baebd247fde02e5008851/packages/flutter/lib/src/material/navigation_bar.dart#L1237
        systemNavigationBarColor: ElevationOverlay.colorWithOverlay(
          Theme.of(context).colorScheme.surface,
          Theme.of(context).colorScheme.primary,
          3.0,
        ),
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Theme.of(context).brightness,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void onStop() {
      final Preferences prefs = Preferences();
      // leave settings
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute<Scaffold>(
          builder: (BuildContext context) => prefs.showOnBoarding
            ? const OnBoardingPage()
            : const Home(),
        ),
      );
    }

    final Future<void> loadMeasurements = Future<void>(
      () {
        MeasurementDatabase().reinit();
      },
    );

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SizedBox(
          width: 0.8 * MediaQuery.of(context).size.width,
            child: FutureBuilder<void>(
              future: loadMeasurements,
              builder: (BuildContext context, AsyncSnapshot<void> snap) {
                return SplashHero(onStop: onStop);
              },
            )
        ),
      ),
    );
  }
}
