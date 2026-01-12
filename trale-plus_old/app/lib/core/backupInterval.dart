import 'package:flutter/material.dart';
import 'package:trale/l10n-gen/app_localizations.dart';


/// Enum with all available backup intervals
enum BackupInterval {
  /// never
  never,
  /// weekly
  weekly,
  /// bi-weekly
  biweekly,
  /// monthly
  monthly,
  /// quarterly
  quarterly,
}

/// extend interpolation strength
extension BackupIntervalExtension on BackupInterval {
  /// get the length [days]
  int get inDays => <BackupInterval, int>{
      BackupInterval.never: -1,
      BackupInterval.weekly: 7,
      BackupInterval.biweekly: 14,
      BackupInterval.monthly: 30,
      BackupInterval.quarterly: 90,
    }[this]!;

  /// get international name
  String nameLong (BuildContext context) => <BackupInterval, String>{
      BackupInterval.never: AppLocalizations.of(context)!.never,
      BackupInterval.weekly: AppLocalizations.of(context)!.weekly,
      BackupInterval.biweekly: AppLocalizations.of(context)!.biweekly,
      BackupInterval.monthly: AppLocalizations.of(context)!.monthly,
      BackupInterval.quarterly: AppLocalizations.of(context)!.quarterly,
    }[this]!;

  /// get string expression
  String get name => toString().split('.').last;
}

/// convert string to interpolation strength
extension BackupIntervalParsing on String {
  /// convert string to interpolation strength
  BackupInterval? toBackupInterval() {
    for (final BackupInterval interval in BackupInterval.values) {
      if (this == interval.name) {
        return interval;
      }
    }
    return null;
  }
}
