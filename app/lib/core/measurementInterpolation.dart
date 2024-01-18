import 'dart:async';
import 'dart:math' as math;

import 'package:ml_linalg/linalg.dart';

import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/traleNotifier.dart';


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
  InterpolStrength interpolStrength = Preferences().interpolStrength;

  /// broadcast stream to track change of db
  final StreamController<List<Measurement>> _streamController =
    StreamController<List<Measurement>>.broadcast();

  /// get broadcast stream to track change of db
  StreamController<List<Measurement>> get streamController => _streamController;

  /// re initialize database
  void reinit() {
    _times = null;
    _weights = null;
    _isNoMeasurement = null;
    _isNotExtrapolated = null;

    // recalculate all vectors
    init();

    // fire stream
    TraleNotifier().notify;
  }

  /// initialize database
  void init() {
    times;
    weights;
    isNoMeasurement;
  }

  /// length of vectors
  int get N => times.length;

  Vector? _times;
  /// get vector containing the times given in [ms since epoche]
  Vector get times => _times ??= _createTimes();

  /// get linearly interpolated and sorted list of daily-averaged measurements
  Vector _createTimes() {
    final int dateFrom = db.sortedMeasurements.last.measurement.dateInMs
      - _dayInMs * _offsetInDays;
    final int dateTo = db.sortedMeasurements.first.measurement.dateInMs
      + _dayInMs * _offsetInDays;

    // set isExtrapolated
    _isExtrapolated = Vector.fromList(<int>[
      for (int date = dateFrom; date < dateTo; date += _dayInMs)
        (
          (date < db.sortedMeasurements.last.measurement.dateInMs) ||
          (date > db.sortedMeasurements.first.measurement.dateInMs)
        ) ? 1 : 0
    ]);

    return Vector.fromList(<int>[
      for (int date = dateFrom; date < dateTo; date += _dayInMs)
        date
    ]);
  }

  Vector? _weights;
  /// get vector containing the measurements corresponding to self.times
  Vector get weights => _weights ??= _createWeights();

  /// get linearly interpolated and sorted list of daily-averaged measurements
  Vector _createWeights() {
    final List<double> ms = Vector.zero(N).toList();
    final List<double> counts = Vector.zero(N).toList();
    final List<int> idx_ms = <int>[];

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
        idx_ms.add(idx);
      }
    }

    // set isMeasurement
    _isMeasurement = Vector.fromList(counts) / Vector.fromList(
        counts
    ).mapToVector((double val) => val == 0 ? 1 : val);

    _idxsMeasurements = idx_ms;

    return Vector.fromList(ms) / Vector.fromList(
      counts
    ).mapToVector((double val) => val == 0 ? 1 : val);
  }

  late Vector _isMeasurement;
  /// get vector containing 1 if measurement else 0
  Vector get isMeasurement => _isMeasurement;

  Vector? _isNoMeasurement;
  /// get vector containing 0 if measurement else 1
  Vector get isNoMeasurement => _isNoMeasurement ??
    isMeasurement.mapToVector((double val) => val == 0 ? 1 : 0);

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

  /// get vector containing sigma depending if measurement or not
  Vector get sigma => _sigma ?? (
    isMeasurement * interpolStrength.strengthMeasurement +
    isNoMeasurement * interpolStrength.strengthInterpol
  ) * _dayInMs;

  /// estimate weights of gaussian at time t with std sigma
  Vector gaussianWeights(double t) {
    final Vector norm = (sigma *math.sqrt(2 * math.pi)).pow(-1);
    final Vector gaussianWeights = (
        (times - t).pow(2) / (sigma.pow(2) * -2)
    ).exp() * norm;
    return gaussianWeights / gaussianWeights.sum();
  }

  /// take mean of Vector ws weighted with Gaussian N(t, sigma)
  double gaussianMean(double t, Vector ws) =>
    (gaussianWeights(t) * ws).sum();

  Vector? _weightsSmoothed;
  /// get vector containing the Gaussian smoothed measurements
  Vector get weightsSmoothed => _weightsSmoothed ?? _createSmoothedWeights();

  /// get linearly interpolated and sorted list of daily-averaged measurements
  Vector _createSmoothedWeights() => Vector.fromList(
    <double>[
      for (int idx = 0; idx < N; idx++)
        (isMeasurement[idx] == 1)
          ? gaussianMean(
              times[idx],
              weights,
            )
          : 0
    ]
  );

  Vector? _weightsLinInterpol;
  /// get vector containing the weights with linear interpolated missing values
  Vector get weightsLinInterpol => _weightsLinInterpol ??
    _createLinInterpol();

  /// get linearly interpolated and sorted list of daily-averaged measurements
  Vector _createLinInterpol() {
    final List<double> ms_interpol = weights.toList();

    int idxFrom, idxTo;
    double changeRate;

    // loop over all unique measurements
    for (int idx = 0; idx < idxsMeasurements.length - 1; idx++) {
      // interpolate between measurements idxs_i and idx_j
      idxFrom = idxsMeasurements[idx];
      idxTo = idxsMeasurements[idx + 1];
      if (idxFrom + 1 < idxTo) {
        // estimate change rate
        changeRate = (
          weights[idxTo] - weights[idxFrom]
        ) / (
          times[idxTo] - times[idxFrom]
        );
        for (int idx_j = idxFrom + 1; idx_j < idxTo; idx_j++) {
          ms_interpol[idx_j] = weights[idxFrom] + changeRate * (
            times[idx_j] * times[idxFrom]
          );
        }
      }
    }
    return Vector.fromList(ms_interpol);
  }

  /// offset of day in interpolation
  static const int _offsetInDays = 7;
  /// 24h given in [ms]
  static const int _dayInMs = 24 * 3600 * 1000;
}