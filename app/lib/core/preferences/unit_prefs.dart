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

}
