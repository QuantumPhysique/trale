import 'package:flutter/foundation.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:state_space/state_space.dart'
    show Bands, Observation, SmoothingResult, StructuralModel;

import 'package:trale/core/auto_strength.dart';
import 'package:trale/core/constants.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/preferences.dart';

part 'interpolation_compute.dart';
part 'interpolation_base.dart';

/// class providing an API to handle interpolation of measurements
class MeasurementInterpolation extends MeasurementInterpolationBaseclass {
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

  @override
  bool get learnsAutoStrength => true;

  /// Replays the automatic strength over the diary as it grew, in the
  /// background.
  Future<AutoStrengthSummary> autoStrengthSummary() =>
      compute(_summarizeAutoStrength, _payload(mayTryAutoStrength: false));
}
