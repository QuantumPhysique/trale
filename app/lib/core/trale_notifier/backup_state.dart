part of '../trale_notifier.dart';

/// Extension on [TraleNotifier] holding backup state.
extension BackupStateExtension on TraleNotifier {
  /// get backup frequency
  BackupInterval get backupInterval => prefs.backupInterval;

  /// setter backup frequency
  set backupInterval(BackupInterval newInterval) {
    if (backupInterval != newInterval) {
      prefs.backupInterval = newInterval;
      notify;
    }
  }

  /// get latest backup date
  DateTime? get latestBackupDate => prefs.latestBackupDate;

  /// set latest backup date
  set latestBackupDate(DateTime? newDate) {
    if (latestBackupDate != newDate) {
      prefs.latestBackupDate = newDate;
      notify;
    }
  }

  /// get next backup date
  DateTime? get nextBackupDate {
    if (backupInterval == BackupInterval.never) {
      return null;
    }
    if (latestBackupDate == null) {
      return DateTime.now();
    }
    final DateTime nextBackup = latestBackupDate!.add(
      Duration(days: backupInterval.inDays),
    );
    return nextBackup.isBefore(DateTime.now()) ? DateTime.now() : nextBackup;
  }

  /// get latest backup reminder date
  DateTime? get latestBackupReminderDate => prefs.latestBackupReminderDate;

  /// set latest backup reminder date
  set latestBackupReminderDate(DateTime? newDate) {
    if (latestBackupReminderDate != newDate) {
      prefs.latestBackupReminderDate = newDate;
      notify;
    }
  }

  /// whether a backup reminder should be shown
  bool get showBackupReminder {
    return backupInterval != BackupInterval.never &&
        nextBackupDate!.difference(DateTime.now()).inDays == 0 &&
        (latestBackupReminderDate == null ||
            latestBackupReminderDate!.difference(DateTime.now()).inDays < 0) &&
        MeasurementDatabase().measurements.length > 5;
  }
}
