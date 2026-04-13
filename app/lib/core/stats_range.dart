import 'package:flutter/material.dart';

import 'package:trale/core/preferences.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

/// Enum with all available ranges used for the statistics page
enum StatsRange {
  /// all
  all,

  /// set date
  sinceTarget,

  /// year
  lastYear,

  /// custom
  custom,
}

/// extend stats range
extension StatsRangeExtension on StatsRange {
  /// get international name
  String nameLong(BuildContext context) => <StatsRange, String>{
    StatsRange.all: AppLocalizations.of(context)!.all,
    StatsRange.sinceTarget: AppLocalizations.of(context)!.sinceTarget,
    StatsRange.lastYear: AppLocalizations.of(context)!.lastYear,
    StatsRange.custom: AppLocalizations.of(context)!.custom,
  }[this]!;

  /// get international name
  ({DateTime? from, DateTime? to}) get dates {
    if (this == StatsRange.all) {
      return (from: null, to: null);
    } else if (this == StatsRange.sinceTarget) {
      final Preferences prefs = Preferences();
      final DateTime? setDate = prefs.userTargetWeightSetDate;
      return (from: setDate, to: null);
    } else if (this == StatsRange.lastYear) {
      return (
        from: DateTime.now().subtract(const Duration(days: 365)),
        to: DateTime.now(),
      );
    }
    // StatsRange.custom

    final Preferences prefs = Preferences();
    return (from: prefs.statsRangeFrom, to: prefs.statsRangeTo);
  }

  /// get string expression
  String get name => toString().split('.').last;
}

/// convert string to stats range
extension StatsRangeParsing on String {
  /// convert string to stats range
  StatsRange? toStatsRange() {
    for (final StatsRange range in StatsRange.values) {
      if (this == range.name) {
        return range;
      }
    }
    return null;
  }
}
