import 'dart:math';

import 'package:trale/core/measurement.dart';


/// return gaussian with std of 3 days in x [ms]
double gaussian(
    double x, {double sigma=72 * 3600 * 1000, double mu=0}
) => 1 / (sigma * sqrt(2 * pi)) * exp(-1 / 2 * pow(x - mu, 2) / pow(sigma, 2));


/// x date in milliseconds since epoch, measurements sorted by date
Measurement gaussianInterpol(int x, List<Measurement> measurements){
  double weightSum = 0;
  double meanSum = 0;
  for (final Measurement m in measurements) {
    final double weight = gaussian(
      x.toDouble(),
      mu: m.dateInMs.toDouble(),
      sigma: (m.isMeasured ? 4 : 2) * 24 * 3600 * 1000,
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
  if (measurements.length == 1)
    return Measurement(
      weight: measurements.first.weight,
      date: DateTime.fromMillisecondsSinceEpoch(x),
      isMeasured: false,
    );

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
    double extrapolationRange=7,
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
      for (int date=dateFrom; date < dateTo; date += extrapolationStepWidth)
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