import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:ml_linalg/linalg.dart';

import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/preferences.dart';

part 'interpolation_compute.dart';
part 'interpolation_base.dart';

/// class providing an API to handle interpolation of measurements
class MeasurementInterpolation
    extends MeasurementInterpolationBaseclass {
  /// singleton constructor
  factory MeasurementInterpolation() => _instance;

  /// single instance creation
  MeasurementInterpolation._internal();

  /// singleton instance
  static MeasurementInterpolation _instance =
      MeasurementInterpolation._internal();

  /// Replace the singleton instance for testing.
  @visibleForTesting
  static set testInstance(MeasurementInterpolation instance) =>
      _instance = instance;

  /// Reset the singleton instance after testing.
  @visibleForTesting
  static void resetInstance() {
    _instance = MeasurementInterpolation._internal();
  }

  /// get measurements
  @override
  MeasurementDatabase get db => MeasurementDatabase();

  /// SharedPreferences key for the interpolation cache
  static const String _cacheKey = 'interpolation_cache';

  /// Cache version — bump when the cached data format changes
  static const int _cacheVersion = 2;

  /// Flag to skip cache loading during reinit (force recompute)
  bool _skipCache = false;

  @override
  void init() {
    if (!_skipCache && _loadFromCache()) {
      return;
    }
    _skipCache = false;
    super.init();
    _saveToCache();
  }

  @override
  Future<void> reinitAsync() async {
    _skipCache = true;
    await super.reinitAsync();
    _saveToCache();
  }

  @override
  void reinit() {
    _skipCache = true;
    super.reinit();
  }

  /// Try to restore all interpolation vectors from
  /// SharedPreferences.
  /// Returns true if the cache was valid and successfully
  /// restored.
  bool _loadFromCache() {
    try {
      final String? cached =
          Preferences().prefs.getString(_cacheKey);
      if (cached == null) {
        return false;
      }

      final Map<String, dynamic> map =
          jsonDecode(cached) as Map<String, dynamic>;

      // Validate cache matches current state
      if (map['version'] != _cacheVersion) {
        return false;
      }
      if (map['nMeasurements'] != db.nMeasurements) {
        return false;
      }
      if (map['interpolStrength'] != interpolStrength.name) {
        return false;
      }

      if (db.nMeasurements == 0) {
        return false;
      }

      if (map['firstDateMs'] !=
          db.firstDate.millisecondsSinceEpoch) {
        return false;
      }
      if (map['lastDateMs'] !=
          db.lastDate.millisecondsSinceEpoch) {
        return false;
      }

      // Restore all vectors
      __dateTimes = (map['dateTimes'] as List<dynamic>)
          .map(
            (dynamic ms) =>
                DateTime.fromMillisecondsSinceEpoch(
                  (ms as num).toInt(),
                ),
          )
          .toList();
      __times = _vectorFromJson(map['times']);
      __isExtrapolated =
          _vectorFromJson(map['isExtrapolated']);
      __weights = _vectorFromJson(map['weights']);
      __isMeasurement =
          _vectorFromJson(map['isMeasurement']);
      __idxsMeasurements =
          (map['idxsMeasurements'] as List<dynamic>)
              .map((dynamic e) => (e as num).toInt())
              .toList();
      __timesMeasured =
          _vectorFromJson(map['timesMeasured']);
      __weightsMeasured =
          _vectorFromJson(map['weightsMeasured']);
      __weightsSmoothed =
          _vectorFromJson(map['weightsSmoothed']);
      __weightsLinExtrapol =
          _vectorFromJson(map['weightsLinExtrapol']);
      __weightsGaussianExtrapol = _vectorFromJson(
        map['weightsGaussianExtrapol'],
      );
      _weightsDisplay =
          _vectorFromJson(map['weightsDisplay']);
      _measurementsDisplay =
          _vectorFromJson(map['measurementsDisplay']);
      _isMeasurementDisplay =
          _vectorFromJson(map['isMeasurementDisplay']);
      _timesDisplay =
          _vectorFromJson(map['timesDisplay']);

      return true;
    } catch (e) {
      // Cache is corrupt or incompatible — fall back to fresh
      // computation
      return false;
    }
  }

  /// Persist all computed interpolation vectors to
  /// SharedPreferences.
  void _saveToCache() {
    try {
      if (db.nMeasurements == 0) {
        Preferences().prefs.remove(_cacheKey);
        return;
      }

      final Map<String, dynamic> map = <String, dynamic>{
        'version': _cacheVersion,
        'nMeasurements': db.nMeasurements,
        'interpolStrength': interpolStrength.name,
        'firstDateMs':
            db.firstDate.millisecondsSinceEpoch,
        'lastDateMs':
            db.lastDate.millisecondsSinceEpoch,
        'dateTimes': _dateTimes
            .map(
              (DateTime dt) => dt.millisecondsSinceEpoch,
            )
            .toList(),
        'times': _times.toList(),
        'isExtrapolated': _isExtrapolated.toList(),
        'weights': _weights.toList(),
        'isMeasurement': _isMeasurement.toList(),
        'idxsMeasurements': _idxsMeasurements,
        'timesMeasured': _timesMeasured.toList(),
        'weightsMeasured': _weightsMeasured.toList(),
        'weightsSmoothed': _weightsSmoothed.toList(),
        'weightsLinExtrapol':
            _weightsLinExtrapol.toList(),
        'weightsGaussianExtrapol':
            _weightsGaussianExtrapol.toList(),
        'weightsDisplay': weights.toList(),
        'measurementsDisplay': measurements.toList(),
        'isMeasurementDisplay': isMeasurement.toList(),
        'timesDisplay': times.toList(),
      };
      Preferences().prefs.setString(
        _cacheKey,
        jsonEncode(map),
      );
    } catch (e) {
      // Cache save failure is non-critical
    }
  }

  /// Deserialize a JSON list back into a Vector.
  static Vector _vectorFromJson(dynamic json) {
    if (json == null) {
      return Vector.empty();
    }
    final List<double> list = (json as List<dynamic>)
        .map((dynamic e) => (e as num).toDouble())
        .toList();
    return list.isEmpty
        ? Vector.empty()
        : Vector.fromList(
            list,
            dtype:
                MeasurementInterpolationBaseclass.dtype,
          );
  }
}
