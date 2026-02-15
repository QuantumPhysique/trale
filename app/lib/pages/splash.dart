import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/pages/home.dart';
import 'package:trale/pages/onBoarding.dart';

/// splash scaffold
class Splash extends StatefulWidget {
  /// constructor
  const Splash({super.key});
  @override
  /// create state
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late final Future<void> _loadMeasurements;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _loadMeasurements = Future<void>(() {
      MeasurementDatabase().reinit();
    });
  }

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

    // Navigate once loading is complete
    if (!_navigated) {
      _navigated = true;
      _loadMeasurements.then((_) {
        if (!mounted) return;
        final Preferences prefs = Preferences();
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute<Scaffold>(
            builder: (BuildContext context) =>
                prefs.showOnBoarding ? const OnBoardingPage() : const Home(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SizedBox(
          width: 0.8 * MediaQuery.of(context).size.width,
          child: FutureBuilder<void>(
            future: _loadMeasurements,
            builder: (BuildContext context, AsyncSnapshot<void> snap) {
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
