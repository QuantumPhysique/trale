part of '../preferences.dart';

/// Extension grouping backup_prefs settings on [Preferences].
extension BackupPrefsExtension on Preferences {
  /// get backup frequency
  BackupInterval get backupInterval =>
      prefs.getString('backupInterval')!.toBackupInterval()!;

  /// set backup frequency
  set backupInterval(BackupInterval interval) =>
      prefs.setString('backupInterval', interval.name);

  /// get last backup date
  DateTime? get latestBackupDate {
    final DateTime latestBackup = DateTime.parse(
      prefs.getString('latestBackupDate')!,
    );
    return latestBackup == defaultLatestBackupDate ? null : latestBackup;
  }

  /// set latest backup date
  set latestBackupDate(DateTime? date) => prefs.setString(
    'latestBackupDate',
    (date ?? defaultLatestBackupDate).toString(),
  );

  /// get last backup date
  DateTime? get latestBackupReminderDate {
    final DateTime latestBackupReminder = DateTime.parse(
      prefs.getString('latestBackupReminderDate')!,
    );
    return latestBackupReminder == defaultLatestBackupReminderDate
        ? null
        : latestBackupReminder;
  }

  /// set latest backup date
  set latestBackupReminderDate(DateTime? date) => prefs.setString(
    'latestBackupReminderDate',
    (date ?? defaultLatestBackupReminderDate).toString(),
  );

}
