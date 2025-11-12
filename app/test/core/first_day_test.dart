import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/firstDay.dart';

void main() {
  group('TraleFirstDay', () {
    test('enum values exist', () {
      expect(TraleFirstDay.values.length, 5);
      expect(TraleFirstDay.values, contains(TraleFirstDay.Default));
      expect(TraleFirstDay.values, contains(TraleFirstDay.monday));
      expect(TraleFirstDay.values, contains(TraleFirstDay.tuesday));
      expect(TraleFirstDay.values, contains(TraleFirstDay.saturday));
      expect(TraleFirstDay.values, contains(TraleFirstDay.sunday));
    });
  });

  group('TraleFirstDayExtension', () {
    test('asDateTimeWeekday returns correct values', () {
      expect(TraleFirstDay.Default.asDateTimeWeekday, isNull);
      expect(TraleFirstDay.monday.asDateTimeWeekday, DateTime.monday);
      expect(TraleFirstDay.tuesday.asDateTimeWeekday, DateTime.tuesday);
      expect(TraleFirstDay.saturday.asDateTimeWeekday, DateTime.saturday);
      expect(TraleFirstDay.sunday.asDateTimeWeekday, DateTime.sunday);
    });

    test('fromDateTimeWeekday converts weekday to enum', () {
      expect(
        TraleFirstDayExtension.fromDateTimeWeekday(DateTime.monday),
        TraleFirstDay.monday,
      );
      expect(
        TraleFirstDayExtension.fromDateTimeWeekday(DateTime.tuesday),
        TraleFirstDay.tuesday,
      );
      expect(
        TraleFirstDayExtension.fromDateTimeWeekday(DateTime.saturday),
        TraleFirstDay.saturday,
      );
      expect(
        TraleFirstDayExtension.fromDateTimeWeekday(DateTime.sunday),
        TraleFirstDay.sunday,
      );
    });

    test('fromDateTimeWeekday returns default for unmapped weekday', () {
      // Wednesday is not in the mapping, should return default (sunday)
      expect(
        TraleFirstDayExtension.fromDateTimeWeekday(DateTime.wednesday),
        TraleFirstDay.sunday,
      );
    });

    test('loadLocalizedNames loads without error', () async {
      await TraleFirstDayExtension.loadLocalizedNames('en_US');
      // If no exception is thrown, the test passes
      expect(true, isTrue);
    });

    test('getLocalizedName returns name after loading', () async {
      await TraleFirstDayExtension.loadLocalizedNames('en_US');
      final String name = TraleFirstDayExtension.getLocalizedName(
        TraleFirstDay.monday,
        'en_US',
      );
      expect(name, isNotEmpty);
    });

    test('getLocalizedName returns Default for unloaded locale', () {
      final String name = TraleFirstDayExtension.getLocalizedName(
        TraleFirstDay.monday,
        'unloaded_locale',
      );
      expect(name, 'Default');
    });
  });

  group('TraleFirstDayParsing', () {
    test('toTraleFirstDay converts valid strings', () {
      expect('Default'.toTraleFirstDay(), TraleFirstDay.Default);
      expect('monday'.toTraleFirstDay(), TraleFirstDay.monday);
      expect('tuesday'.toTraleFirstDay(), TraleFirstDay.tuesday);
      expect('saturday'.toTraleFirstDay(), TraleFirstDay.saturday);
      expect('sunday'.toTraleFirstDay(), TraleFirstDay.sunday);
    });

    test('toTraleFirstDay returns null for invalid strings', () {
      expect('invalid'.toTraleFirstDay(), isNull);
      expect(''.toTraleFirstDay(), isNull);
      expect('MONDAY'.toTraleFirstDay(), isNull);
    });
  });
}
