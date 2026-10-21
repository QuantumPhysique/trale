import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:state_space/state_space.dart'
    show Observation, SmoothingResult, StructuralModel;

import 'package:trale/core/constants.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/smoothing.dart';
import 'package:trale/core/smoothing_summary.dart';
import 'package:trale/core/units.dart';

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
  bool get learnsSmoothing => true;

  @override
  Map<SmoothingMode, SmoothingState> get smoothingStates =>
      Preferences().smoothingStates;

  @override
  bool? get bodyGrowing => Preferences().bodyGrowing;

  /// What the smoothing learned from the diary, null before its first refit.
  SmoothingSummary? get smoothingSummary {
    final SmoothingMode? mode = leadingMode;
    final SmoothingState? state = mode == null
        ? null
        : Preferences().smoothingStates[mode];
    if (state == null || nDays == 0) {
      return null;
    }
    return SmoothingSummary(
      state: state,
      strength: interpolStrength,
      modeWeights: modeWeights,
      growing: bodyGrowing ?? false,
      daysPerWeek: 7 * isMeasurement.sum() / nDays,
      historyInDays: nDays,
    );
  }
}
