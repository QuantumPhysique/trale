import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/printFormat.dart';

void main() {
  group('TraleDatePrintFormat', () {
    test('enum values exist', () {
      expect(TraleDatePrintFormat.values.length, 6);
      expect(TraleDatePrintFormat.values, contains(TraleDatePrintFormat.systemDefault));
      expect(TraleDatePrintFormat.values, contains(TraleDatePrintFormat.yyyyMMdd));
      expect(TraleDatePrintFormat.values, contains(TraleDatePrintFormat.ddMMyyyy));
      expect(TraleDatePrintFormat.values, contains(TraleDatePrintFormat.MMddyyyy));
      expect(TraleDatePrintFormat.values, contains(TraleDatePrintFormat.ddMMyyyyDot));
      expect(TraleDatePrintFormat.values, contains(TraleDatePrintFormat.iso8601));
    });
  });

  group('TraleDateFormatExtension', () {
    test('pattern returns correct values', () {
      expect(TraleDatePrintFormat.systemDefault.pattern, isNull);
      expect(TraleDatePrintFormat.yyyyMMdd.pattern, 'yyyy/MM/dd');
      expect(TraleDatePrintFormat.ddMMyyyy.pattern, 'dd/MM/yyyy');
      expect(TraleDatePrintFormat.MMddyyyy.pattern, 'MM/dd/yyyy');
      expect(TraleDatePrintFormat.ddMMyyyyDot.pattern, 'dd.MM.yyyy');
      expect(TraleDatePrintFormat.iso8601.pattern, 'yyyy-MM-dd');
    });

    test('patternShort returns correct values', () {
      expect(TraleDatePrintFormat.systemDefault.patternShort, isNull);
      expect(TraleDatePrintFormat.yyyyMMdd.patternShort, 'MM/dd');
      expect(TraleDatePrintFormat.ddMMyyyy.patternShort, 'dd/MM');
      expect(TraleDatePrintFormat.MMddyyyy.patternShort, 'MM/dd');
      expect(TraleDatePrintFormat.ddMMyyyyDot.patternShort, 'dd.MM');
      expect(TraleDatePrintFormat.iso8601.patternShort, 'MM-dd');
    });

    test('name returns correct string', () {
      expect(TraleDatePrintFormat.systemDefault.name, 'systemDefault');
      expect(TraleDatePrintFormat.yyyyMMdd.name, 'yyyyMMdd');
      expect(TraleDatePrintFormat.ddMMyyyy.name, 'ddMMyyyy');
      expect(TraleDatePrintFormat.MMddyyyy.name, 'MMddyyyy');
      expect(TraleDatePrintFormat.ddMMyyyyDot.name, 'ddMMyyyyDot');
      expect(TraleDatePrintFormat.iso8601.name, 'iso8601');
    });

    test('dateFormat returns DateFormat object', () {
      expect(TraleDatePrintFormat.yyyyMMdd.dateFormat.pattern, 'yyyy/MM/dd');
      expect(TraleDatePrintFormat.iso8601.dateFormat.pattern, 'yyyy-MM-dd');
    });

    test('dayFormat returns DateFormat object', () {
      expect(TraleDatePrintFormat.yyyyMMdd.dayFormat.pattern, 'MM/dd');
      expect(TraleDatePrintFormat.iso8601.dayFormat.pattern, 'MM-dd');
    });
  });

  group('TraleDateFormatParsing', () {
    test('toTraleDateFormat converts valid strings', () {
      expect('systemDefault'.toTraleDateFormat(), TraleDatePrintFormat.systemDefault);
      expect('yyyyMMdd'.toTraleDateFormat(), TraleDatePrintFormat.yyyyMMdd);
      expect('ddMMyyyy'.toTraleDateFormat(), TraleDatePrintFormat.ddMMyyyy);
      expect('MMddyyyy'.toTraleDateFormat(), TraleDatePrintFormat.MMddyyyy);
      expect('ddMMyyyyDot'.toTraleDateFormat(), TraleDatePrintFormat.ddMMyyyyDot);
      expect('iso8601'.toTraleDateFormat(), TraleDatePrintFormat.iso8601);
    });

    test('toTraleDateFormat returns null for invalid strings', () {
      expect('invalid'.toTraleDateFormat(), isNull);
      expect(''.toTraleDateFormat(), isNull);
      expect('YYYYMMDD'.toTraleDateFormat(), isNull);
    });
  });
}
