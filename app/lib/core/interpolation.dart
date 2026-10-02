import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:trale/core/constants.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

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
  /// Bandwidth of the smoothing in days; `none` takes its slope from `soft`.
  double get bandwidthInDays => <InterpolStrength, double>{
    InterpolStrength.none: 2,
    InterpolStrength.soft: 2,
    InterpolStrength.medium: 4,
    InterpolStrength.strong: 7,
  }[this]!;

  /// Variance ratio of the trend per day³ that smooths like a kernel of
  /// [bandwidthInDays] (Silverman 1984).
  double get processVariance => math.pow(bandwidthInDays, -4).toDouble();

  /// Time scale in days over which the trend's rate of change fades.
  double get timeScaleInDays => trendTimeScaleInBandwidths * bandwidthInDays;

  /// get international name
  String nameLong(BuildContext context) => <InterpolStrength, String>{
    InterpolStrength.none: AppLocalizations.of(context)!.none,
    InterpolStrength.soft: AppLocalizations.of(context)!.soft,
    InterpolStrength.medium: AppLocalizations.of(context)!.medium,
    InterpolStrength.strong: AppLocalizations.of(context)!.strong,
  }[this]!;

  /// get string expression
  String get name => toString().split('.').last;

  /// Index of this interpolation strength in the enum values.
  int get idx {
    for (int i = 0; i < InterpolStrength.values.length; i++) {
      if (InterpolStrength.values[i] == this) {
        return i;
      }
    }
    return -1;
  }
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
