import 'package:material_ui/material_ui.dart';
import 'package:trale/core/smoothing.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

/// Enum with all available interpolation functions
enum InterpolStrength {
  /// none
  none,

  /// [SmoothingMode.maintenance]
  maintenance,

  /// [SmoothingMode.textbook]
  textbook,

  /// [SmoothingMode.ambitious]
  ambitious,

  /// [SmoothingMode.aggressive]
  aggressive,

  /// the mixture of all modes that fits the recent readings best
  auto,
}

/// extend interpolation strength
extension InterpolStrengthExtension on InterpolStrength {
  /// The modes the curve is drawn from. `none` draws straight lines and takes
  /// its rates from textbook.
  List<SmoothingMode> get modes => <InterpolStrength, List<SmoothingMode>>{
    InterpolStrength.none: <SmoothingMode>[SmoothingMode.textbook],
    InterpolStrength.maintenance: <SmoothingMode>[SmoothingMode.maintenance],
    InterpolStrength.textbook: <SmoothingMode>[SmoothingMode.textbook],
    InterpolStrength.ambitious: <SmoothingMode>[SmoothingMode.ambitious],
    InterpolStrength.aggressive: <SmoothingMode>[SmoothingMode.aggressive],
    InterpolStrength.auto: SmoothingMode.values,
  }[this]!;

  /// get international name
  String nameLong(BuildContext context) => <InterpolStrength, String>{
    InterpolStrength.none: AppLocalizations.of(context)!.none,
    InterpolStrength.maintenance: AppLocalizations.of(
      context,
    )!.strengthMaintenance,
    InterpolStrength.textbook: AppLocalizations.of(context)!.strengthTextbook,
    InterpolStrength.ambitious: AppLocalizations.of(context)!.strengthAmbitious,
    InterpolStrength.aggressive: AppLocalizations.of(
      context,
    )!.strengthAggressive,
    InterpolStrength.auto: AppLocalizations.of(context)!.strengthAuto,
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

/// The strength of each [SmoothingMode].
extension SmoothingModeStrength on SmoothingMode {
  /// The strength that draws the curve with this mode alone.
  InterpolStrength get strength => <SmoothingMode, InterpolStrength>{
    SmoothingMode.maintenance: InterpolStrength.maintenance,
    SmoothingMode.textbook: InterpolStrength.textbook,
    SmoothingMode.ambitious: InterpolStrength.ambitious,
    SmoothingMode.aggressive: InterpolStrength.aggressive,
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
