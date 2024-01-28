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
    _times_measured = null;
    _sigma = null;
    _weights_measured = null;
    _weightsLinInterpol = null;
    _weightsSmoothed = null;

    // recalculate all vectors
    init();
  }

  /// initialize database
  void init() {
    times;
    weights;
    isNoMeasurement;
    weightsSmoothed;
    weightsLinInterpol;
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
      for (int date = dateFrom; date < dateTo; date += _dayInMs)
        (
          (date < db.sortedMeasurements.last.measurement.dayInMs) ||
          (date > db.sortedMeasurements.first.measurement.dayInMs)
        ) ? 1 : 0
    ]);

    return Vector.fromList(<int>[
      for (int date = dateFrom; date < dateTo; date += _dayInMs)
        date
    ], dtype: dtype);
  }

  Vector? _times_measured;
  /// get vector containing the times of the measurements
  Vector get times_measured => _times_measured ?? _createTimesMeasured();
  /// create vector of all measurements time stamps
  Vector _createTimesMeasured() {
    return Vector.fromList(<int>[
      for (final SortedMeasurement ms in db.sortedMeasurements)
        ms.measurement.dateInMs
    ], dtype: dtype);
  }

  Vector? _weights_measured;
  /// get vector containing the weights of the measurements [kg]
  Vector get weights_measured => _weights_measured ?? _createWeightsMeasured();
  /// create vector of all measurements weights
  Vector _createWeightsMeasured() {
    return Vector.fromList(<double>[
      for (final SortedMeasurement ms in db.sortedMeasurements)
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
  Vector gaussianWeights(double t, Vector ms) {
    final Vector norm = (sigma * math.sqrt(2 * math.pi)).pow(-1);
    final Vector gaussianWeights = (
        (times - t).pow(2) / (sigma.pow(2) * -2)
    ).exp() * norm;
    final Vector mask = ms.mapToVector(
      (double val) => val > 0 ? 1 : 0
    );
    return gaussianWeights / (mask * gaussianWeights).sum();
  }

  /// take mean of Vector ws weighted with Gaussian N(t, sigma)
  double gaussianMean(double t, Vector ms) =>
    (gaussianWeights(t, ms) * ms).sum();

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
    ], dtype: dtype,
  );

  Vector? _weightsLinInterpol;
  /// get vector containing the weights with linear interpolated missing values
  Vector get weightsLinInterpol => _weightsLinInterpol ??
    _createLinInterpol();

  /// get linearly interpolated and sorted list of daily-averaged measurements
  Vector _createLinInterpol() {
    final List<double> msInterpol = weightsSmoothed.toList();

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
          msInterpol[idxTo] - msInterpol[idxFrom]
        ) / (
          times[idxTo] - times[idxFrom]
        );
        for (int idxJ = idxFrom + 1; idxJ < idxTo; idxJ++) {
          msInterpol[idxJ] = msInterpol[idxFrom] + changeRate * (
            times[idxJ] - times[idxFrom]
          );
        }
      }
    }
    return Vector.fromList(msInterpol, dtype: dtype);
  }

  /// offset of day in interpolation
  static const int _offsetInDays = 7;
  /// 24h given in [ms]
  static const int _dayInMs = 24 * 3600 * 1000;
}