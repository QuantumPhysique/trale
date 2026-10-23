import 'package:material_ui/material_ui.dart';
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
  /// Standard deviation of the tissue trend's slope at [strengthReferenceKg],
  /// as a fraction of body weight per day: 0.10, 0.08 and 0.06 kg/day at
  /// 83 kg. `none` draws straight lines and takes its rates from medium.
  double get slopeSd => <InterpolStrength, double>{
    InterpolStrength.none: 0.00096,
    InterpolStrength.soft: 0.0012,
    InterpolStrength.medium: 0.00096,
    InterpolStrength.strong: 0.00072,
  }[this]!;

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
