import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trale/core/icons.dart';


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
      InterpolStrength.none: 0.01,
      InterpolStrength.soft: 2,
      InterpolStrength.medium: 4,
      InterpolStrength.strong: 7,
    }[this]!;

  /// get the interpolation strength of measurements [days]
  double get strengthInterpol => <InterpolStrength, double>{
    InterpolStrength.none: 0,
    InterpolStrength.soft: 1,
    InterpolStrength.medium: 2,
    InterpolStrength.strong: 3,
  }[this]!;

  /// get the ratio how much the measurements are weighted more than interpols
  double get weight => <InterpolStrength, double>{
    InterpolStrength.none: 1,
    InterpolStrength.soft: 10,
    InterpolStrength.medium: 5,
    InterpolStrength.strong: 3,
  }[this]!;

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
