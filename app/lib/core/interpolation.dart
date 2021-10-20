import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/preferences.dart';


/// return gaussian with std of 3 days in x [ms]
double gaussian(
    double x, {double sigma=72 * 3600 * 1000, double mu=0}
) => 1 / (sigma * sqrt(2 * pi)) * exp(-1 / 2 * pow(x - mu, 2) / pow(sigma, 2));


/// x date in milliseconds since epoch, measurements sorted by date
Measurement gaussianInterpol(int x, List<Measurement> measurements){
  final Preferences pref = Preferences();
  double weightSum = 0;
  double meanSum = 0;
  for (final Measurement m in measurements) {
    final double weight = gaussian(
      x.toDouble(),
      mu: m.dateInMs.toDouble(),
      sigma: (
        m.isMeasured ? pref.interpolStrength.strength : 2
      ) * 24 * 3600 * 1000,
    ) * (m.isMeasured ? 10 : 1);
    weightSum += weight;
    meanSum += m.weight * weight;
  }
  return Measurement(
    weight: meanSum / weightSum,
    date: DateTime.fromMillisecondsSinceEpoch(x),
    isMeasured: false,
  );
}

/// x date in milliseconds since epoch, measurements sorted by date
Measurement linearInterpol(int x, List<Measurement> measurements){
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
  /// soft
  soft,
  /// medium
  medium,
  /// strong
  strong,
}

/// extend interpolation strength
extension InterpolStrengthExtension on InterpolStrength {
  /// get the interpolation strength in days
  int get strength => <InterpolStrength, int>{
      InterpolStrength.soft: 2,
      InterpolStrength.medium: 4,
      InterpolStrength.strong: 7,
    }[this]!;

  /// get international name
  String nameLong (BuildContext context) => <InterpolStrength, String>{
      InterpolStrength.soft: AppLocalizations.of(context)!.soft,
      InterpolStrength.medium: AppLocalizations.of(context)!.medium,
      InterpolStrength.strong: AppLocalizations.of(context)!.strong,
    }[this]!;

  /// get string expression
  String get name => toString().split('.').last;
}

/// convert string to interpolation strength
extension InterpolStrengthParsing on String {
  /// convert string to interpolation strength
  InterpolStrength? toInterpolStrength() {
    for (final InterpolStrength strength in InterpolStrength.values)
      if (this == strength.name)
        return strength;
    return null;
  }
}
