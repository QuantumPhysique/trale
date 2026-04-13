import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/first_day.dart';

void main() {
  group('TraleFirstDay', () {
    test('asDateTimeWeekday returns correct values', () {
      expect(TraleFirstDay.Default.asDateTimeWeekday, isNull);
      expect(TraleFirstDay.monday.asDateTimeWeekday, DateTime.monday);
      expect(TraleFirstDay.tuesday.asDateTimeWeekday, DateTime.tuesday);
      expect(TraleFirstDay.saturday.asDateTimeWeekday, DateTime.saturday);
      expect(TraleFirstDay.sunday.asDateTimeWeekday, DateTime.sunday);
    });

    test('fromDateTimeWeekday round-trips', () {
      expect(
        TraleFirstDayExtension.fromDateTimeWeekday(DateTime.monday),
        TraleFirstDay.monday,
      );
      expect(
        TraleFirstDayExtension.fromDateTimeWeekday(DateTime.sunday),
        TraleFirstDay.sunday,
      );
      expect(
        TraleFirstDayExtension.fromDateTimeWeekday(DateTime.saturday),
        TraleFirstDay.saturday,
      );
    });
  });

  group('TraleFirstDayParsing', () {
    test('valid string converts to TraleFirstDay', () {
      expect('Default'.toTraleFirstDay(), TraleFirstDay.Default);
      expect('monday'.toTraleFirstDay(), TraleFirstDay.monday);
      expect('sunday'.toTraleFirstDay(), TraleFirstDay.sunday);
    });

    test('invalid string returns null', () {
      expect('invalid'.toTraleFirstDay(), isNull);
      expect(''.toTraleFirstDay(), isNull);
    });
  });
}
