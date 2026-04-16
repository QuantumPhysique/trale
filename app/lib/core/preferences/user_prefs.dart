part of '../preferences.dart';

/// Extension grouping user_prefs settings on [Preferences].
extension UserPrefsExtension on Preferences {
  /// set user name
  set userName(String name) => prefs.setString('userName', name);

  /// get user name
  String get userName => prefs.getString('userName')!;

  /// set user height in cm
  set userHeight(double? height) {
    assert(
      height == null || (height.isFinite && height > 0),
      'userHeight must be null or a positive finite number',
    );
    prefs.setDouble('userHeight', height ?? -1);
  }

  /// get user height in cm
  double? get userHeight => prefs.getDouble('userHeight')! > 0
      ? prefs.getDouble('userHeight')!
      : null;

  /// Get target weight enabled
  bool get targetWeightEnabled => prefs.getBool('targetWeightEnabled')!;

  /// Set target weight enabled
  set targetWeightEnabled(bool enabled) =>
      prefs.setBool('targetWeightEnabled', enabled);

  /// set user target weight
  set userTargetWeight(double? weight) {
    assert(
      weight == null || (weight.isFinite && weight > 0),
      'userTargetWeight must be null or a positive finite number',
    );
    prefs.setDouble('userTargetWeight', weight ?? -1);
  }

  /// get user target weight
  double? get userTargetWeight => prefs.getDouble('userTargetWeight')! > 0
      ? prefs.getDouble('userTargetWeight')!
      : null;

  /// set user target weight date (when to reach target)
  set userTargetWeightDate(DateTime? date) => prefs.setString(
    'userTargetWeightDate',
    (date ?? DateTime.fromMillisecondsSinceEpoch(0)).toIso8601String(),
  );

  /// get user target weight date
  DateTime? get userTargetWeightDate {
    final String raw = prefs.getString('userTargetWeightDate') ?? '';
    if (raw.isEmpty) {
      return null;
    }
    final DateTime parsed = DateTime.parse(raw);
    return parsed.millisecondsSinceEpoch == 0 ? null : parsed;
  }

  /// set date when user set the target weight
  set userTargetWeightSetDate(DateTime? date) => prefs.setString(
    'userTargetWeightSetDate',
    (date ?? DateTime.fromMillisecondsSinceEpoch(0)).toIso8601String(),
  );

  /// get date when user set the target weight
  DateTime? get userTargetWeightSetDate {
    final String raw = prefs.getString('userTargetWeightSetDate') ?? '';
    if (raw.isEmpty) {
      return null;
    }
    final DateTime parsed = DateTime.parse(raw);
    return parsed.millisecondsSinceEpoch == 0 ? null : parsed;
  }
}
