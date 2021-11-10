import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
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
    _currentSliderValue = (
      notifier.userTargetWeight ?? prefs.defaultUserWeight
    ) / notifier.unit.scaling;
    print(_currentSliderValue);
    final String askingForName = prefs.userName == ''
      ? 'How shall we call you?'
      : 'Hi ' + prefs.userName + ' \u{1F44B}';

    final String _sliderLabel = notifier.unit.weightToString(
      _currentSliderValue * notifier.unit.scaling
    );

    final RulerPicker rulerPicker = RulerPicker(
      onValueChange: (num newValue) {
        notifier.userTargetWeight =
        newValue.toDouble() * notifier.unit.scaling;
      },
      width: MediaQuery.of(context).size.width,
      value: notifier.unit.doubleToPrecision(_currentSliderValue),
      ticksPerStep: notifier.unit.ticksPerStep,
      key: ValueKey<TraleUnit>(notifier.unit),
    );

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

    final List<Color> gradientColors = <Color>[
      Color.alphaBlend(
        TraleTheme.of(context)!.accent.withOpacity(0.2),
        TraleTheme.of(context)!.bg,
      ),
      Color.alphaBlend(
        TraleTheme.of(context)!.accent.withOpacity(0.4),
        TraleTheme.of(context)!.bg,
      ),
    ];

    final List<Measurement> data = <Measurement>[
      Measurement(weight: 5, date: DateTime.utc(2021, 11, 1)),
      Measurement(weight: 4, date: DateTime.utc(2021, 11, 3)),
      Measurement(weight: 4.25, date: DateTime.utc(2021, 11, 5)),
      Measurement(weight: 3.75, date: DateTime.utc(2021, 11, 7)),
      Measurement(weight: 3.25, date: DateTime.utc(2021, 11, 9)),
      Measurement(weight: 3.5, date: DateTime.utc(2021, 11, 11)),
      Measurement(weight: 3.125, date: DateTime.utc(2021, 11, 13)),
      Measurement(weight: 2.75, date: DateTime.utc(2021, 11, 15)),
    ];

    FlSpot measurementToFlSpot (Measurement measurement) {
      return FlSpot(
        measurement.date.millisecondsSinceEpoch.toDouble(),
        measurement.inUnit(context),
      );
    }

    final List<FlSpot> measurements = data.map(measurementToFlSpot).toList();
    final List<FlSpot> measurementsInterpol = Interpolation(
      measures: data,
    ).interpolate(InterpolFunc.gaussian).map(measurementToFlSpot).toList();

    final Widget linechart = LineChart(
      LineChartData(
        lineTouchData: LineTouchData(enabled: false),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        minY: 2,
        maxY: 6,
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: measurementsInterpol,
            isCurved: true,
            colors: <Color>[Colors.transparent],
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradientFrom: const Offset(0, 1),
              gradientTo: const Offset(0, 0.5),
              colors: gradientColors,
            ),
          ),
          LineChartBarData(
            spots: measurements,
            isCurved: false,
            colors: <Color>[TraleTheme.of(context)!.accent],
            barWidth: 0,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
            ),
          ),
        ],
      ),
      swapAnimationDuration: TraleTheme.of(context)!
          .transitionDuration.normal,
      swapAnimationCurve: Curves.easeIn,
    );

    final List<PageViewModel> pageViewModels = <PageViewModel>[
      PageViewModel(
        title: 'Welcome \u{1F642}',
        body: 'Tracking body weight facilitates weight-loss. \n'
          'Trale, a privacy-friendly app, provides a simple, yet beautiful log '
          'of your body weight.',
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
        title: 'Goal \u{1F3C1}',
        decoration: pageDecoration.copyWith(
          descriptionPadding: EdgeInsets.zero,
          imageFlex: 0,
          titlePadding: EdgeInsets.symmetric(
            horizontal: 2 * TraleTheme.of(context)!.padding,
            vertical: 2 * TraleTheme.of(context)!.padding,
          ),
        ),
        bodyWidget: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 2 * TraleTheme.of(context)!.padding),
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 200,
                    child: linechart,
                  ),
                  SizedBox(height: 3 * TraleTheme.of(context)!.padding),
                  Text('What is your feel-good weight? + setting goals is important',
                    style: Theme.of(context).textTheme.bodyText1!,
                    textAlign: TextAlign.center),
                  SizedBox(height: TraleTheme.of(context)!.padding),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.unit,
                      style: Theme.of(context).textTheme.headline6!,
                    ),
                    trailing: ToggleButtons(
                      renderBorder: false,
                      fillColor: Colors.transparent,
                      children: TraleUnit.values.map(
                        (TraleUnit unit) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: TraleTheme.of(context)!.padding),
                          child: Text(
                            unit.name,
                            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                                  color: unit == notifier.unit
                                      ?  TraleTheme.of(context)!.accent
                                      :  TraleTheme.of(context)!.bgFont
                            ),
                          ),
                        )
                      ).toList(),
                      isSelected: unitIsSelected,
                      onPressed: (int index) {
                        setState(() {
                          notifier.unit = TraleUnit.values[index];
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'target weight',
                      style: Theme.of(context).textTheme.headline6!,
                    ),
                    trailing: Padding(
                      padding: EdgeInsets.only(
                        right: TraleTheme.of(context)!.padding),
                      child: Text(
                        _sliderLabel,
                        style: Theme.of(context).textTheme.bodyText1!,
                      ),
                    ),
                  ),
                  SizedBox(height: TraleTheme.of(context)!.padding),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: rulerPicker,
            ),
          ],
        ),
      ),
      PageViewModel(
        title: 'Style \u{1F60E}',
        bodyWidget: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 2 * TraleTheme.of(context)!.padding),
              child: Text('Choose a theme to personalize the app, '
                'expressing your feelings.',
                style: Theme.of(context).textTheme.bodyText1!,
                textAlign: TextAlign.center,
              ),
            ),
            const ThemeSelection(),
          ],
        ),
        image: _buildImage(
          'launcher/foreground_crop2.png',
          MediaQuery.of(context).size.width / 2,
        ),
        decoration: pageDecoration.copyWith(
          descriptionPadding: EdgeInsets.zero),
      ),
  /*    PageViewModel(
        title: askingForName,
        bodyWidget: Container(
          width: 2 / 3 * MediaQuery.of(context).size.width,
          child: TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              hintText: 'What do people call you?',
              labelText: 'Name',
            ),
            initialValue: notifier.userName,
            onFieldSubmitted: (String? name) {
              setState(() => prefs.userName = name ?? '');
            },
          ),
        ),
        image: _buildImage(
          'launcher/foreground_crop2.png',
          MediaQuery.of(context).size.width / 2,
        ),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: "What's your body size",
        bodyWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('click')
          ],
        ),
        image: _buildImage(
          'launcher/foreground_crop2.png',
          MediaQuery.of(context).size.width / 2,
        ),
        decoration: pageDecoration,
      ),*/
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
