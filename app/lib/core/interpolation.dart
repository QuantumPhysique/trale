import 'package:flutter/material.dart';
import 'package:trale/core/icons.dart';
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
  /// get the interpolation strength of measurements [days]
  double get strengthMeasurement => <InterpolStrength, double>{
      InterpolStrength.none: 2,
      InterpolStrength.soft: 2,
      InterpolStrength.medium: 4,
      InterpolStrength.strong: 7,
    }[this]!;

  /// get the interpolation strength of measurements [days]
  double get strengthInterpol => strengthMeasurement / 2;

  /// get the ratio how much the measurements are weighted more than interpols
  double get weight => 2;

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

  int get idx {
    for (int i=0; i<InterpolStrength.values.length; i++) {
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