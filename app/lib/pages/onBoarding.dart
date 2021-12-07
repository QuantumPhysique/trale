import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/pages/home.dart';
import 'package:trale/pages/settings.dart';
import 'package:trale/widget/weightPicker.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {

  /// shared preferences instance
  final Preferences prefs = Preferences();

  /// in kg
  late double _currentSliderValue;

  void _onIntroEnd(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const Home()),
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  List<bool> unitIsSelected =
    TraleUnit.values.map(
            (TraleUnit unit) => unit == TraleUnit.kg
    ).toList();

  @override
  Widget build(BuildContext context) {
    final TraleNotifier notifier =
      Provider.of<TraleNotifier>(context, listen: false);

    final PageDecoration pageDecoration = PageDecoration(
      titleTextStyle: Theme.of(context).textTheme.headline4!,
      bodyTextStyle: Theme.of(context).textTheme.bodyText1!,
      titlePadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding,
      ),
      imageFlex: 3,
      bodyFlex: 5,
      descriptionPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding),
      imagePadding: EdgeInsets.all(
        2 * TraleTheme.of(context)!.padding,
      ),
      contentMargin: EdgeInsets.zero,
      boxDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            TraleTheme.of(context)!.bg,
            TraleTheme.of(context)!.bgShade4,
          ],
        )
      ),
      footerPadding: EdgeInsets.zero,
    );

    final List<PageViewModel> pageViewModels = <PageViewModel>[
      PageViewModel(
        title: AppLocalizations.of(context)!.welcome + ' \u{1F642}',
        body: AppLocalizations.of(context)!.onBoarding1,
        image: _buildImage(
          'launcher/foreground_crop2.png',
          MediaQuery.of(context).size.width / 2,
        ),
        decoration: pageDecoration.copyWith(
          bodyFlex: 1,
          imageFlex: 1,
        ),
      ),
      PageViewModel(
        title: 'Style \u{1F60E}',
        bodyWidget: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 2 * TraleTheme.of(context)!.padding),
              child: Text(
                AppLocalizations.of(context)!.onBoarding2,
                style: Theme.of(context).textTheme.bodyText1!,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        image: Container(
          width: MediaQuery.of(context).size.width,
          height: 0.5 * MediaQuery.of(context).size.width,
          child: const ThemeSelection(),
        ),
        decoration: pageDecoration.copyWith(
          imagePadding: EdgeInsets.symmetric(
              vertical: 2 * TraleTheme.of(context)!.padding,
              horizontal: 0),
          bodyFlex: 1,
          imageFlex: 1
        ),
      ),
    ];

    return IntroductionScreen(
      globalBackgroundColor: TraleTheme.of(context)!.bgShade4,
      isTopSafeArea: true,
      pages: pageViewModels,
      onDone: () {
        prefs.showOnboarding = false;
        _onIntroEnd(context);
      },
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      //rtl: true, // Display as right-to-left
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done'),
      skipColor: TraleTheme.of(context)!.bgFont,
      nextColor: TraleTheme.of(context)!.bgFont,
      doneColor: TraleTheme.of(context)!.bgFont,
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: EdgeInsets.all(2 * TraleTheme.of(context)!.padding),
      controlsPadding: EdgeInsets.symmetric(
          vertical: TraleTheme.of(context)!.padding / 2,
          horizontal: TraleTheme.of(context)!.padding),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: TraleTheme.of(context)!.bgFont,
        activeSize: const Size(22.0, 10.0),
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        activeColor: TraleTheme.of(context)!.accent,
      ),
    );
  }
}
