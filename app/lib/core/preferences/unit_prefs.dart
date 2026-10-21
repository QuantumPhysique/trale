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

  /// The amplitudes and the scale error learned from the user's diary, for
  /// each mode refitted so far.
  Map<SmoothingMode, SmoothingState> get smoothingStates {
    final Map<String, dynamic> stored =
        jsonDecode(prefs.getString('smoothingStates')!) as Map<String, dynamic>;
    return <SmoothingMode, SmoothingState>{
      for (final MapEntry<String, dynamic> entry in stored.entries)
        SmoothingMode.values.byName(
          entry.key,
        ): SmoothingState.fromList(<double>[
          for (final dynamic value in entry.value as List<dynamic>)
            (value as num).toDouble(),
        ]),
    };
  }

  /// set the amplitudes and the scale error learned from the user's diary
  set smoothingStates(Map<SmoothingMode, SmoothingState> states) =>
      prefs.setString(
        'smoothingStates',
        jsonEncode(<String, List<double>>{
          for (final MapEntry<SmoothingMode, SmoothingState> entry
              in states.entries)
            entry.key.name: entry.value.toList(),
        }),
      );

  /// Whether the body is still growing, null while the readings may decide.
  bool? get bodyGrowing => prefs.getBool('bodyGrowing');

  /// set whether the body is still growing
  set bodyGrowing(bool? growing) => growing == null
      ? prefs.remove('bodyGrowing')
      : prefs.setBool('bodyGrowing', growing);

  /// Days with measurements at the last refit of [smoothingStates].
  int get smoothingFittedDays => prefs.getInt('smoothingFittedDays')!;

  /// set the days with measurements at the last refit
  set smoothingFittedDays(int days) =>
      prefs.setInt('smoothingFittedDays', days);
}
