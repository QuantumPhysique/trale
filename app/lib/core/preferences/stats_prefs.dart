part of '../preferences.dart';

/// Extension grouping stats_prefs settings on [Preferences].
extension StatsPrefsExtension on Preferences {
  /// Get stats use interpolation
  bool get statsUseInterpolation => prefs.getBool('statsUseInterpolation')!;

  /// Set stats use interpolation
  set statsUseInterpolation(bool useInterpolation) =>
      prefs.setBool('statsUseInterpolation', useInterpolation);

  /// Get statsRangeFrom
  DateTime? get statsRangeFrom {
    final DateTime parsed = DateTime.parse(prefs.getString('statsRangeFrom')!);
    return parsed.millisecondsSinceEpoch == 0 ? null : parsed;
  }

  /// Set statsRangeFrom
  set statsRangeFrom(DateTime? date) => prefs.setString(
    'statsRangeFrom',
    (date ?? DateTime.fromMillisecondsSinceEpoch(0)).toIso8601String(),
  );

  /// Get statsRangeTo
  DateTime? get statsRangeTo {
    final DateTime parsed = DateTime.parse(prefs.getString('statsRangeTo')!);
    return parsed.millisecondsSinceEpoch == 0 ? null : parsed;
  }

  /// Set statsRangeTo
  set statsRangeTo(DateTime? date) => prefs.setString(
    'statsRangeTo',
    (date ?? DateTime.fromMillisecondsSinceEpoch(0)).toIso8601String(),
  );
}
