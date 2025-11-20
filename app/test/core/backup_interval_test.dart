import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/backupInterval.dart';

void main() {
  group('BackupInterval', () {
    test('enum values exist', () {
      expect(BackupInterval.values.length, 5);
      expect(BackupInterval.values, contains(BackupInterval.never));
      expect(BackupInterval.values, contains(BackupInterval.weekly));
      expect(BackupInterval.values, contains(BackupInterval.biweekly));
      expect(BackupInterval.values, contains(BackupInterval.monthly));
      expect(BackupInterval.values, contains(BackupInterval.quarterly));
    });
  });

  group('BackupIntervalExtension', () {
    test('inDays returns correct values', () {
      expect(BackupInterval.never.inDays, -1);
      expect(BackupInterval.weekly.inDays, 7);
      expect(BackupInterval.biweekly.inDays, 14);
      expect(BackupInterval.monthly.inDays, 30);
      expect(BackupInterval.quarterly.inDays, 90);
    });

    test('name returns correct string', () {
      expect(BackupInterval.never.name, 'never');
      expect(BackupInterval.weekly.name, 'weekly');
      expect(BackupInterval.biweekly.name, 'biweekly');
      expect(BackupInterval.monthly.name, 'monthly');
      expect(BackupInterval.quarterly.name, 'quarterly');
    });
  });

  group('BackupIntervalParsing', () {
    test('toBackupInterval converts valid strings', () {
      expect('never'.toBackupInterval(), BackupInterval.never);
      expect('weekly'.toBackupInterval(), BackupInterval.weekly);
      expect('biweekly'.toBackupInterval(), BackupInterval.biweekly);
      expect('monthly'.toBackupInterval(), BackupInterval.monthly);
      expect('quarterly'.toBackupInterval(), BackupInterval.quarterly);
    });

    test('toBackupInterval returns null for invalid strings', () {
      expect('invalid'.toBackupInterval(), isNull);
      expect(''.toBackupInterval(), isNull);
      expect('WEEKLY'.toBackupInterval(), isNull);
    });
  });
}
