import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/units.dart';
import 'package:trale/pages/home.dart';
import 'package:trale/pages/settings.dart';
import 'package:trale/widget/iconHero.dart';

/// Page shown on the very first opening of the app
class OnBoardingPage extends StatefulWidget {
  ///
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {

  /// shared preferences instance
  final Preferences prefs = Preferences();

  void _onIntroEnd(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const Home()),
    );
  }

  List<bool> unitIsSelected =
    TraleUnit.values.map(
            (TraleUnit unit) => unit == TraleUnit.kg
    ).toList();

  @override
  Widget build(BuildContext context) {

    final PageDecoration pageDecoration = PageDecoration(
      titleTextStyle: Theme.of(context).textTheme.headline4!,
      bodyTextStyle: Theme.of(context).textTheme.bodyText1!,
      titlePadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding,
      ),
      imageFlex: 1,
      bodyFlex: 1,
      bodyPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding),
      imagePadding: EdgeInsets.all(
        2 * TraleTheme.of(context)!.padding,
      ),
      contentMargin: EdgeInsets.zero,
      boxDecoration: BoxDecoration(
        gradient: TraleTheme.of(context)!.bgGradient,
      ),
      footerPadding: EdgeInsets.zero,
    );

    final List<PageViewModel> pageViewModels = <PageViewModel>[
      PageViewModel(
        title: '${AppLocalizations.of(context)!.welcome} 😃',
        body: AppLocalizations.of(context)!.onBoarding1,
        image: IconHero(),
        decoration: pageDecoration
      ),
      PageViewModel(
        title: '${AppLocalizations.of(context)!.onBoarding2Title} \u{1F60E}',
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
        image: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 0.5 * MediaQuery.of(context).size.width,
          child: const ThemeSelection(),
        ),
        decoration: pageDecoration.copyWith(
          imagePadding: EdgeInsets.symmetric(
              vertical: 2 * TraleTheme.of(context)!.padding,
              horizontal: 0),
        ),
      ),
      PageViewModel(
        title: '${AppLocalizations.of(context)!.onBoarding3Title} 🔒',
        bodyWidget: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 2 * TraleTheme.of(context)!.padding),
              child: Text(
                AppLocalizations.of(context)!.onBoarding3,
                style: Theme.of(context).textTheme.bodyText1!,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        image: Container(),
        decoration: pageDecoration.copyWith(imageFlex: 1, bodyFlex: 2),
      ),
    ];

    void closingOnBoarding (BuildContext context) {
      prefs.showOnBoarding = false;
      _onIntroEnd(context);
    }

    return IntroductionScreen(
      globalBackgroundColor: TraleTheme.of(context)!.bgShade4,
      isTopSafeArea: true,
      pages: pageViewModels,
      onDone: () => closingOnBoarding(context),
      onSkip: () => closingOnBoarding(context),
      showSkipButton: true,
      nextFlex: 1,
      skip: Text(
        AppLocalizations.of(context)!.skip,
        style: Theme.of(context).textTheme.bodyText1!,
        overflow: TextOverflow.ellipsis,
      ),
      next: Icon(
        CustomIcons.next,
        color: Theme.of(context).iconTheme.color,
      ),
      done: Text(
        AppLocalizations.of(context)!.startApp,
        style: Theme.of(context).textTheme.bodyText1!,
        overflow: TextOverflow.ellipsis,
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: EdgeInsets.all(2 * TraleTheme.of(context)!.padding),
      controlsPadding: EdgeInsets.symmetric(
          vertical: TraleTheme.of(context)!.padding / 2,
          horizontal: TraleTheme.of(context)!.padding),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: Theme.of(context).colorScheme.onBackground,
        activeSize: const Size(22.0, 10.0),
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
