import 'dart:math' as math;

import 'package:ml_linalg/linalg.dart';

import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/preferences.dart';


/// class providing an API to handle interpolation of measurements
class MeasurementInterpolation {
  /// singleton constructor
  factory MeasurementInterpolation() => _instance;

  /// single instance creation
  MeasurementInterpolation._internal();

  /// singleton instance
  static final MeasurementInterpolation _instance =
    MeasurementInterpolation._internal();

  /// get measurements
  MeasurementDatabase get db => MeasurementDatabase();

  /// get interpolation strength values
  InterpolStrength get interpolStrength => Preferences().interpolStrength;

  /// re initialize database
  void reinit() {
    _times = null;
    _times_measured = null;
    _timesDisplay = null;
    _weights_measured = null;
    _weights = null;
    _weightsDisplay = null;
    _isNoMeasurement = null;
    _isNotExtrapolated = null;
    _sigma = null;
    _weightsLinExtrapol = null;
    _weightsSmoothed = null;
    _weightsGaussianExtrapol = null;

    // recalculate all vectors
    init();
  }

  /// initialize database
  void init() {
    times;
    weights;
    weightsDisplay;
  }

  /// data type of vectors
  static const DType dtype = DType.float64;

  /// length of vectors
  int get N => times.length;

  Vector? _times;
  /// get vector containing the times given in [ms since epoch]
  Vector get times => _times ??= _createTimes();

  /// get linearly interpolated and sorted list of daily-averaged measurements
  Vector _createTimes() {
    if (db.nMeasurements == 0) {
      _isExtrapolated = Vector.empty();
      return Vector.empty();
    }

    final int dateFrom = db.sortedMeasurements.last.measurement.dayInMs
      - _dayInMs * _offsetInDays;
    final int dateTo = db.sortedMeasurements.first.measurement.dayInMs
      + _dayInMs * _offsetInDays;

    // set isExtrapolated
    _isExtrapolated = Vector.fromList(<int>[
      for (int date = dateFrom; date <= dateTo; date += _dayInMs)
        (
          (date < db.sortedMeasurements.last.measurement.dayInMs) ||
          (date > db.sortedMeasurements.first.measurement.dayInMs)
        ) ? 1 : 0
    ]);

    return Vector.fromList(<int>[
      for (int date = dateFrom; date <= dateTo; date += _dayInMs)
        date
    ], dtype: dtype);
  }

  Vector? _times_measured;
  /// get vector containing the times of the measurements
  Vector get times_measured => _times_measured ?? _createTimesMeasured();
  /// create vector of all measurements time stamps
  Vector _createTimesMeasured() {
    return Vector.fromList(<int>[
      for (final SortedMeasurement ms in db.sortedMeasurements.reversed)
        ms.measurement.dateInMs
    ], dtype: dtype);
  }

  Vector? _weights_measured;
  /// get vector containing the weights of the measurements [kg]
  Vector get weights_measured => _weights_measured ?? _createWeightsMeasured();
  /// create vector of all measurements weights
  Vector _createWeightsMeasured() {
    return Vector.fromList(<double>[
      for (final SortedMeasurement ms in db.sortedMeasurements.reversed)
        ms.measurement.weight
    ], dtype: dtype);
  }

  Vector? _weights;
  /// get vector containing the measurements corresponding to self.times
  Vector get weights => _weights ?? _createWeights();
  /// get linearly interpolated and sorted list of daily-averaged measurements
  Vector _createWeights() {
    if (db.nMeasurements == 0) {
      _isMeasurement = Vector.empty();
      _idxsMeasurements = <int>[];
      return Vector.empty();
    }
    final List<double> ms = Vector.zero(N).toList();
    final List<double> counts = Vector.zero(N).toList();
    final List<int> idxMs = <int>[];

    int idx = 0;
    for (final SortedMeasurement m in db.sortedMeasurements.reversed) {
      while (
        ! m.measurement.date.sameDay(
          DateTime.fromMillisecondsSinceEpoch(
            times[idx].toInt(),
          )
        )
      ) {
        idx += 1;
      }
      ms[idx] += m.measurement.weight;
      counts[idx] += 1;
      if (counts[idx] == 1) {
        idxMs.add(idx);
      }
    }

    // set isMeasurement
    _isMeasurement = Vector.fromList(counts, dtype: dtype) / Vector.fromList(
        counts
    ).mapToVector((double val) => val == 0 ? 1 : val);

    _idxsMeasurements = idxMs;

    return Vector.fromList(ms, dtype: dtype) / Vector.fromList(
      counts
    ).mapToVector((double val) => val == 0 ? 1 : val);
  }

  late Vector _isMeasurement;
  /// get vector containing 1 if measurement else 0
  Vector get isMeasurement => _isMeasurement;

  Vector? _isNoMeasurement;
  /// get vector containing 0 if measurement else 1
  Vector get isNoMeasurement => _isNoMeasurement ?? (isMeasurement - 1).abs();

  late List<int> _idxsMeasurements;
  /// get List holding indices to all measurements
  List<int> get idxsMeasurements => _idxsMeasurements;

  late Vector _isExtrapolated;
  /// get vector containing 0 if values are outside of measurement range else 1
  Vector get isExtrapolated => _isExtrapolated;

  Vector? _isNotExtrapolated;

  /// get vector containing 1 if values withing measurement range else 0
  Vector get isNotExtrapolated => _isNotExtrapolated ??
    isExtrapolated.mapToVector((double val) => val == 0 ? 1 : 0);

  Vector? _sigma;

  /// get vector containing sigma depending if measurement or not [ms]
  Vector get sigma => _sigma ?? (
    isMeasurement * interpolStrength.strengthMeasurement +
    isNoMeasurement * interpolStrength.strengthInterpol
  ) * _dayInMs;

  /// estimate weights of gaussian at time t with std sigma
  Vector gaussianWeights(double t, Vector ms) {
    final Vector norm = (sigma * math.sqrt(2 * math.pi)).pow(-1);
    final Vector gaussianWeights = (
        (times - t).pow(2) / (sigma.pow(2) * -2)
    ).exp() * norm * (
      isMeasurement * interpolStrength.weight + isNoMeasurement
    );
    final Vector mask = ms.mapToVector(
      (double val) => val > 0 ? 1 : 0
    );

    return (gaussianWeights * mask) / (gaussianWeights * mask).sum();
  }

  /// take mean of Vector ws weighted with Gaussian N(t, sigma)
  double gaussianMean(double t, Vector ms) =>
    gaussianWeights(t, ms).dot(ms);

  Vector? _weightsSmoothed;
  /// get vector containing the Gaussian smoothed measurements
  Vector get weightsSmoothed => _weightsSmoothed ??
    _gaussianInterpolation(
      _linearExtrapolation(
        _linearInterpolation(weights)
      )
    ) * isMeasurement;  // set all non Measurements to zero.

  Vector? _weightsLinExtrapol;
  /// get vector containing the weights with linear interpolated missing values
  Vector get weightsLinExtrapol => _weightsLinExtrapol ??
    _linearExtrapolation(
    _linearInterpolation(weightsSmoothed)
    );

  Vector? _weightsGaussianExtrapol;
  /// get vector containing the weights with linear interpolated missing values
  Vector get weightsGaussianExtrapol => _weightsGaussianExtrapol ??
    _gaussianInterpolation(weightsLinExtrapol);

  Vector? _weightsDisplay;
  /// get vector containing the weights to display
  Vector get weightsDisplay => _weightsDisplay ?? _createWeightsDisplay();

  Vector _createWeightsDisplay() {
      if (interpolStrength == InterpolStrength.none) {
        final Vector weightsLinear = _linearInterpolation(weights);
        return Vector.fromList([
          for (
            int idx=_offsetInDays;
            idx < N - _offsetInDays + _offsetInDaysShown;
            idx++
          )
            idx <= N - _offsetInDays - 1
              ? weightsLinear.elementAt(idx)
              : weightsLinear.elementAt(N - _offsetInDays - 1)
                + finalChangeRate * (idx - N + _offsetInDays + 1)
        ]);
      }
      return Vector.fromList([
        for (
          int idx=_offsetInDays - _offsetInDaysShown;
          idx < N - _offsetInDays + _offsetInDaysShown;
          idx++
        )
          weightsGaussianExtrapol.elementAt(idx)
      ]);
  }


  Vector? _timesDisplay;
  /// get vector containing the weights to display
  Vector get timesDisplay => _timesDisplay ??
    Vector.fromList([
      for (
        int idx=(interpolStrength == InterpolStrength.none)
          ? _offsetInDays
          : _offsetInDays - _offsetInDaysShown;
        idx < N - _offsetInDays + _offsetInDaysShown;
        idx++
      )
        times.elementAt(idx)
    ]);

  /// add linear interpolation to measurements
  Vector _linearExtrapolation(Vector weights) {
    final List<double> weightsList = weights.toList();
    int idxFrom, idxTo;

    if (db.nMeasurements == 0) {
      return Vector.empty();
    } else if (idxsMeasurements.length == 1) {
      return Vector.filled(N, weights[idxsMeasurements[0]]);
    }

    // add
    final int lastIdx = idxsMeasurements.last;
    final int firstIdx = idxsMeasurements.first;

    final Vector initialExtrapolation = _linearRegression(
      weights,
      times[firstIdx],
      Vector.fromList(<double>[
        for (int idx=0; idx < firstIdx; idx++)
          times[idx]
      ]),
    );

    final Vector finalExtrapolation = _linearRegression(
      weights,
      times[lastIdx],
      Vector.fromList(<double>[
        for (int idx=lastIdx + 1; idx < N; idx++)
          times[idx]
      ]),
    );

    for (int idx=0; idx < _offsetInDays; idx++) {
      weightsList[idx] = initialExtrapolation[idx];
      weightsList[lastIdx + 1 + idx] = finalExtrapolation[idx];
    }

    return Vector.fromList(weightsList, dtype: dtype);
  }

  /// Estimate linear regression for time ts with Gaussian weights relative to
  /// tRef
  Vector _linearRegression(Vector weights, double tRef, Vector ts) {
    final Vector gsWeights = gaussianWeights(tRef, weights);
    final double meanWeight = gsWeights.dot(weights);
    final double meanTime = gsWeights.dot(times);
    final double meanChange = gsWeights.dot(
        (weights - meanWeight) * times
    ) / gsWeights.dot(
        (times - meanTime) * times
    );
    final double intercept = meanWeight - meanChange * meanTime;

    return Vector.fromList(<double>[
      for (final double t in ts)
        meanChange * t + intercept < 0
          ? 0
          : meanChange * t + intercept
    ], dtype: dtype);
  }

  /// add linear interpolation to measurements
  Vector _linearInterpolation(Vector weights) {
    final List<double> weightsList = weights.toList();
    int idxFrom, idxTo;
    double changeRate;

    if (db.nMeasurements == 0) {
      return Vector.empty();
    } else if (idxsMeasurements.length == 1) {
      return Vector.filled(N, weights[idxsMeasurements[0]]);
    }

    // loop over all unique measurements
    for (int idx = 0; idx < idxsMeasurements.length - 1; idx++) {
      // interpolate between measurements idxs_i and idx_j
      idxFrom = idxsMeasurements[idx];
      idxTo = idxsMeasurements[idx + 1];
      if (idxFrom + 1 < idxTo) {
        // estimate change rate
        changeRate = _linearChangeRate(idxFrom, idxTo, weights);
        for (int idxJ = idxFrom + 1; idxJ < idxTo; idxJ++) {
          weightsList[idxJ] = weightsList[idxFrom] + changeRate * (
              idxJ - idxFrom
          );
        }
      }
    }
    return Vector.fromList(weightsList, dtype: dtype);
  }

  /// estimate linear change rate between two measurements in [kg/steps]
  double _linearChangeRate(int idxFrom, int idxTo, Vector weights) =>
    weights.isNotEmpty
    ? (weights[idxTo] - weights[idxFrom]) / (idxTo - idxFrom)
    : 0;

  /// smooth weights with Gaussian kernel
  Vector _gaussianInterpolation(Vector weights) => Vector.fromList(
      <double>[
        for (int idx = 0; idx < N; idx++)
          (weights[idx] != 0)
            ? gaussianMean(
                times[idx],
                weights,
              )
            : 0
      ], dtype: dtype,
    );


  // FROM HERE ON STATS OF INTERPOLATION

  /// get time span between first and last measurement
  Duration get measurementDuration => times_measured.isNotEmpty
    ? Duration(
        milliseconds: (times_measured.last - times_measured.first).round(),
      )
    : Duration.zero;


  /// return difference of Gaussian smoothed weights
  double? deltaWeightLastNDays (int nDays) {
    if (N - 2 * _offsetInDays < nDays) {
      return null;
    }
    return weightsGaussianExtrapol[N - 1 - _offsetInDays] -
    weightsGaussianExtrapol[N - 1 - _offsetInDays - nDays];
  }

  /// get weight change [kg] within last month from last measurement
  double? get deltaWeightLastYear => deltaWeightLastNDays(365);

  /// get weight change [kg] within last month from last measurement
  double? get deltaWeightLastMonth => deltaWeightLastNDays(30);

  /// get weight change [kg] within last week from last measurement
  double? get deltaWeightLastWeek => deltaWeightLastNDays(7);

  /// final change Rate
  double get finalChangeRate => _linearChangeRate(
    N - 1 - _offsetInDays,
    N - 1 - _offsetInDaysShown,
    weightsGaussianExtrapol,
  );

  /// get time of reaching target weight in kg
  Duration? timeOfTargetWeight(double? targetWeight) {
    if ((targetWeight == null) || (db.nMeasurements < 2)){
      return null;
    }

    final int idxLast = idxsMeasurements.last;
    final double slope = finalChangeRate;

    // Crossing is in the past
    if (slope * (weightsDisplay[idxLast] - targetWeight) >= 0) {
      return null;
    }

    // in ms from last measurement
    final int remainingTime = (
        (targetWeight - weightsDisplay[idxLast]) / slope
    ).round();
    return Duration(days: remainingTime);
  }

  /// offset of day in interpolation
  static const int _offsetInDays = 21;

  /// offset of day in interpolation shown
  static const int _offsetInDaysShown = 7;

  /// 24h given in [ms]
  static const int _dayInMs = 24 * 3600 * 1000;
}
