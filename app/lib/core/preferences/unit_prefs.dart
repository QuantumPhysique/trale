part of '../preferences.dart';

/// Extension grouping unit_prefs settings on [Preferences].
extension UnitPrefsExtension on Preferences {
  /// get unit mode
  TraleUnit get unit => prefs.getString('unit')!.toTraleUnit()!;

  /// set unit mode
  set unit(TraleUnit unit) => prefs.setString('unit', unit.name);

  /// get unit precision
  TraleUnitPrecision get unitPrecision =>
      prefs.getString('unitPrecision')!.toTraleUnitPrecision()!;

  /// set unit mode
  set unitPrecision(TraleUnitPrecision precision) =>
      prefs.setString('unitPrecision', precision.name);

  /// get height unit mode
  TraleUnitHeight get heightUnit =>
      prefs.getString('heightUnit')!.toTraleUnitHeight()!;

  /// set height unit mode
  set heightUnit(TraleUnitHeight heightUnit) =>
      prefs.setString('heightUnit', heightUnit.name);

  /// get interpolation strength mode
  InterpolStrength get interpolStrength =>
      prefs.getString('interpolStrength')!.toInterpolStrength()!;

  /// set interpolation strength mode
  set interpolStrength(InterpolStrength strength) =>
      prefs.setString('interpolStrength', strength.name);

  /// The amplitudes and the scale error learned from the user's diary, null
  /// before the first refit.
  SmoothingState? get smoothingState {
    final double week = prefs.getDouble('smoothingWeekAmplitude')!;
    if (week < 0) {
      return null;
    }
    return SmoothingState(
      weekAmplitude: week,
      waterAmplitude: prefs.getDouble('smoothingWaterAmplitude')!,
      scaleErrorKg: prefs.getDouble('smoothingScaleErrorKg')!,
      growthFactor: prefs.getDouble('smoothingGrowthFactor')!,
    );
  }

  /// set the amplitudes and the scale error learned from the user's diary
  set smoothingState(SmoothingState? state) {
    prefs.setDouble('smoothingWeekAmplitude', state?.weekAmplitude ?? -1);
    prefs.setDouble('smoothingWaterAmplitude', state?.waterAmplitude ?? -1);
    prefs.setDouble('smoothingScaleErrorKg', state?.scaleErrorKg ?? -1);
    prefs.setDouble('smoothingGrowthFactor', state?.growthFactor ?? -1);
  }

  /// Whether the body is still growing, null while the readings may decide.
  bool? get bodyGrowing => prefs.getBool('bodyGrowing');

  /// set whether the body is still growing
  set bodyGrowing(bool? growing) => growing == null
      ? prefs.remove('bodyGrowing')
      : prefs.setBool('bodyGrowing', growing);

  /// Days with measurements at the last refit of [smoothingState].
  int get smoothingFittedDays => prefs.getInt('smoothingFittedDays')!;

  /// set the days with measurements at the last refit
  set smoothingFittedDays(int days) =>
      prefs.setInt('smoothingFittedDays', days);
}
