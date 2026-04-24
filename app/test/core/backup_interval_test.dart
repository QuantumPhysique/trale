import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/backup_interval.dart';

void main() {
  group('BackupInterval', () {
    test('inDays values are correct', () {
      expect(BackupInterval.never.inDays, -1);
      expect(BackupInterval.weekly.inDays, 7);
      expect(BackupInterval.biweekly.inDays, 14);
      expect(BackupInterval.monthly.inDays, 30);
      expect(BackupInterval.quarterly.inDays, 90);
    });

    test('name returns enum value name', () {
      expect(BackupInterval.never.name, 'never');
      expect(BackupInterval.weekly.name, 'weekly');
      expect(BackupInterval.biweekly.name, 'biweekly');
      expect(BackupInterval.monthly.name, 'monthly');
      expect(BackupInterval.quarterly.name, 'quarterly');
    });
  });

  group('BackupIntervalParsing', () {
    test('valid string converts to BackupInterval', () {
      expect('never'.toBackupInterval(), BackupInterval.never);
      expect('weekly'.toBackupInterval(), BackupInterval.weekly);
      expect('quarterly'.toBackupInterval(), BackupInterval.quarterly);
    });

    test('invalid string returns null', () {
      expect('invalid'.toBackupInterval(), isNull);
      expect(''.toBackupInterval(), isNull);
    });
  });
}
