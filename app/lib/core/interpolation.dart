import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trale/core/icons.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/preferences.dart';


/// return gaussian with std of 3 days in x [ms]
double gaussian(
  double x, {double sigma=72 * 3600 * 1000, double mu=0}
) => sigma == 0
  ? x - mu == 0
    ? 1
    : 0
  : 1 / (sigma * sqrt(2 * pi)) * exp(-1 / 2 * pow(x - mu, 2) / pow(sigma, 2));


/// return fermi-dirac statistic based weight with fermi-edge at 2*width
double regressionWeight({
  required double x,
  required double mu,
  required double width
}) => 1.0 / (
  1.0 + exp(
    ((mu - x) - 2 * width) / width
  )
);


/// estimate eights based on measurments
List<double> regressionWeights(int x, List<Measurement> measurements) {
  final Preferences pref = Preferences();
  final List<double> weights = <double>[
    for (final Measurement m in measurements)
      regressionWeight(
        x: m.dateInMs.toDouble(),
        mu: x.toDouble(),
        width: pref.interpolStrength.strengthMeasurement * 24 * 3600 * 1000,
      )
  ];

  final double totalWeights = weights.reduce(
    (double value, double element) => value + element
  );
  return <double>[
    for (final double w in weights)
      w / totalWeights
  ];
}


/// estimate weighted averaged weight
double regressionMeanWeight(int x, List<Measurement> measurements) {
  final List<double> weights = regressionWeights(x, measurements);
  double meanWeight = 0;
  for (int i=0; i <measurements.length; i++){
    meanWeight += measurements[i].weight * weights[i];
  }
  return meanWeight;
}


/// estimate weighted averaged weight
double regressionMeanTime(int x, List<Measurement> measurements) {
  final List<double> weights = regressionWeights(x, measurements);
  double meanTime = 0;
  for (int i=0; i <measurements.length; i++){
    meanTime += measurements[i].dateInMs * weights[i];
  }
  return meanTime;
}

/// estimate change of linear regression
double regressionMeanChange(int x, List<Measurement> measurements) {
  final List<double> weights = regressionWeights(x, measurements);
  final double tMean = regressionMeanTime(x, measurements);
  final double wMean = regressionMeanWeight(x, measurements);
  double meanDeltaTime = 0;
  double meanDeltaWeight = 0;
  double t, w;
  for (int i=0; i < measurements.length; i++){
    t = measurements[i].dateInMs.toDouble();
    w = measurements[i].weight;
    meanDeltaWeight += (w - wMean) * (t - tMean) * weights[i];
    meanDeltaTime += (t - tMean) * (t - tMean) * weights[i];
  }
  return meanDeltaWeight / meanDeltaTime;
}


/// estimate intercept of linear regression
double regressionMeanIntercept(int x, List<Measurement> measurements) {
  final double tMean = regressionMeanTime(x, measurements);
  final double wMean = regressionMeanWeight(x, measurements);
  final double cMean = regressionMeanChange(x, measurements);

  final double intercept = wMean - cMean * tMean;
  return intercept;
}


/// linear regression around time t
Measurement linearRegression(int x, int xref, List<Measurement> measurements) {
  final double intercept = regressionMeanIntercept(xref, measurements);
  final double change = regressionMeanChange(xref, measurements);
  final double weight = change * x + intercept;
  const double weightMax = 1000;
  final Measurement m = Measurement(
    weight: weight < 0
      ? 0
      : weight > weightMax
        ? weightMax
        : weight,
    date: DateTime.fromMillisecondsSinceEpoch(x),
    isMeasured: true,
  );

  return m;
}


/// add value of linear regression to list of Measurements
List<Measurement> addLinearRegression(List<Measurement> ms) {
  final Preferences pref = Preferences();
  final List<Measurement> msRegr = <Measurement>[
    for (final Measurement m in ms)
      Measurement(
        weight: m.weight,
        date: m.date,
        isMeasured: m.isMeasured,
      )
  ];
  final Interpolation interpol = Interpolation(
    measures: ms,
    extrapolationRange: pref.interpolStrength.strengthMeasurement,
  );

  // future extrapolation
  int dateFrom = ms.last.dateInMs + interpol.extrapolationStepWidth;
  int dateTo = dateFrom + 2 * interpol.extrapolationRange;
  msRegr.addAll(
    _createRegressionMeasurements(
      ms, dateFrom, dateTo, interpol.extrapolationStepWidth,
    ),
  );

  dateTo = ms.first.dateInMs - interpol.extrapolationStepWidth;
  dateFrom = dateTo - 2 * interpol.extrapolationRange;
  msRegr.insertAll(
      0,
      _createRegressionMeasurements(
        ms, dateFrom, dateTo, interpol.extrapolationStepWidth,
      ),
  );
  return msRegr;
}

List<Measurement> _createRegressionMeasurements(
  List<Measurement> ms, int dateFrom, int dateTo, int stepWidth,
) {
  return <Measurement>[
    for (int date=dateFrom; date < dateTo + stepWidth; date += stepWidth)
      linearRegression(date, dateFrom, ms)
  ];
}


/// estimate eights based on measurments
List<double> measurementsToWeights(int x, List<Measurement> measurements) {
  final Preferences pref = Preferences();
  List<double> weights = <double>[
    for (final Measurement m in measurements)
      gaussian(
        x.toDouble(),
        mu: m.dateInMs.toDouble(),
        sigma: (
            m.isMeasured
                ? pref.interpolStrength.strengthMeasurement
                : pref.interpolStrength.strengthInterpol
        ) * 24 * 3600 * 1000,
      ) * (m.isMeasured ? pref.interpolStrength.weight : 1)
  ];
  final double totalWeights = weights.reduce(
          (double value, double element) => value + element
  );
  return <double>[
    for (final double w in weights)
      w / totalWeights
  ];
}


/// estimate weighted averaged weight
double meanWeight(int x, List<Measurement> measurements) {
  final List<double> weights = measurementsToWeights(x, measurements);
  double meanWeight = 0;
  for (int i=0; i <measurements.length; i++){
    meanWeight += measurements[i].weight * weights[i];
  }
  return meanWeight;
}


/// x date in milliseconds since epoch, measurements sorted by date
Measurement gaussianInterpol(int x, List<Measurement> measurements){
  return Measurement(
    weight: meanWeight(x, measurements),
    date: DateTime.fromMillisecondsSinceEpoch(x),
    isMeasured: false,
  );
}

/// x date in milliseconds since epoch, measurements sorted by date
Measurement linearInterpol(int x, List<Measurement> measurements){
  if (measurements.length == 1) {
    return Measurement(
      weight: measurements.first.weight,
      date: DateTime.fromMillisecondsSinceEpoch(x),
      isMeasured: false,
    );
  }

  final int index = measurements.lastIndexWhere(
    (Measurement m) => m.dateInMs <= x
  );
  int indexBefore, indexAfter;
  if (index == -1) {
    indexBefore = 0;
    indexAfter = 1;
  } else if (index == measurements.length - 1) {
    indexBefore = measurements.length - 2;
    indexAfter = measurements.length - 1;
  } else {
    indexBefore = index;
    indexAfter = index + 1;
  }
  final Measurement mBefore = measurements[indexBefore];
  final Measurement mAfter = measurements[indexAfter];

  final double derivative = (
    mAfter.weight - mBefore.weight
  ) / (
    mAfter.dateInMs - mBefore.dateInMs
  );
  final double offset = mAfter.weight - derivative * mAfter.dateInMs;
  return Measurement(
    weight: derivative * x + offset,
    date: DateTime.fromMillisecondsSinceEpoch(x),
    isMeasured: false,
  );
}


/// Enum with all available interpolation functions
enum InterpolFunc {
  /// gaussian
  gaussian,
  /// stones
  linear,
}

/// extend units
extension InterpolFuncExtension on InterpolFunc {
  /// get the scaling factor to kg
  Function(int, List<Measurement>) get function =>
    <InterpolFunc, Function(int, List<Measurement>)>{
      InterpolFunc.gaussian: gaussianInterpol,
      InterpolFunc.linear: linearInterpol,
    }[this]!;
  /// get string expression
  String get name => toString().split('.').last;
}

/// class for interpolating measurement values
class Interpolation {
  /// constructor
  Interpolation({
    required this.measures,
    /// Step width [days]
    double extrapolationStepWidth=1,
    /// Extrapolation range [days]
    double extrapolationRange=0,
  }) {
    this.extrapolationRange = (extrapolationRange * 24*3600*1000).toInt();
    this.extrapolationStepWidth = (
      extrapolationStepWidth * 24*3600*1000
    ).toInt();
  }

  /// interpolate Measurements
  List<Measurement> interpolate(InterpolFunc interpolFunc){
    final int dateFrom = measures.first.dateInMs - extrapolationRange;
    final int dateTo = measures.last.dateInMs + extrapolationRange;
    return <Measurement>[
      for (
        int date=dateFrom;
        date < dateTo + extrapolationStepWidth;
        date += extrapolationStepWidth
      )
        interpolFunc.function(date, measures) as Measurement
    ];
  }

  /// extrapolationRange in milliseconds
  late int extrapolationRange;
  /// step widths in milliseconds
  late int extrapolationStepWidth;
  /// daily-averaged and sorted Measurements
  late List<Measurement> measures;
}

/// Enum with all available interpolation functions
enum InterpolStrength {
  /// none
  none,
  /// soft
  soft,
  /// medium
  medium,
  /// strong
  strong,
}

/// extend interpolation strength
extension InterpolStrengthExtension on InterpolStrength {
  /// get the interpolation strength of measurements [days]
  double get strengthMeasurement => <InterpolStrength, double>{
      InterpolStrength.none: 0.01,
      InterpolStrength.soft: 2,
      InterpolStrength.medium: 4,
      InterpolStrength.strong: 7,
    }[this]!;

  /// get the interpolation strength of measurements [days]
  double get strengthInterpol => <InterpolStrength, double>{
    InterpolStrength.none: 0,
    InterpolStrength.soft: 1,
    InterpolStrength.medium: 2,
    InterpolStrength.strong: 3,
  }[this]!;

  /// get the ratio how much the measurements are weighted more than interpols
  double get weight => <InterpolStrength, double>{
    InterpolStrength.none: 1,
    InterpolStrength.soft: 10,
    InterpolStrength.medium: 5,
    InterpolStrength.strong: 3,
  }[this]!;

  /// get international name
  String nameLong (BuildContext context) => <InterpolStrength, String>{
      InterpolStrength.none: AppLocalizations.of(context)!.none,
      InterpolStrength.soft: AppLocalizations.of(context)!.soft,
      InterpolStrength.medium: AppLocalizations.of(context)!.medium,
      InterpolStrength.strong: AppLocalizations.of(context)!.strong,
    }[this]!;

  /// get string expression
  String get name => toString().split('.').last;

  /// get icon
  IconData get icon => <InterpolStrength, IconData>{
    InterpolStrength.none: CustomIcons.interpol_none,
    InterpolStrength.soft: CustomIcons.interpol_weak,
    InterpolStrength.medium: CustomIcons.interpol_medium,
    InterpolStrength.strong: CustomIcons.interpol_strong,
  }[this]!;
}

/// convert string to interpolation strength
extension InterpolStrengthParsing on String {
  /// convert string to interpolation strength
  InterpolStrength? toInterpolStrength() {
    for (final InterpolStrength strength in InterpolStrength.values) {
      if (this == strength.name) {
        return strength;
    }
      }
    return null;
  }
}
