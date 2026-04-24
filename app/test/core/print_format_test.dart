import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/print_format.dart';

void main() {
  group('TraleDatePrintFormat', () {
    test('pattern values are correct', () {
      expect(TraleDatePrintFormat.systemDefault.pattern, isNull);
      expect(TraleDatePrintFormat.yyyyMMdd.pattern, 'yyyy/MM/dd');
      expect(TraleDatePrintFormat.ddMMyyyy.pattern, 'dd/MM/yyyy');
      expect(TraleDatePrintFormat.MMddyyyy.pattern, 'MM/dd/yyyy');
      expect(TraleDatePrintFormat.ddMMyyyyDot.pattern, 'dd.MM.yyyy');
      expect(TraleDatePrintFormat.iso8601.pattern, 'yyyy-MM-dd');
    });

    test('patternShort values are correct', () {
      expect(TraleDatePrintFormat.systemDefault.patternShort, isNull);
      expect(TraleDatePrintFormat.yyyyMMdd.patternShort, 'MM/dd');
      expect(TraleDatePrintFormat.ddMMyyyy.patternShort, 'dd/MM');
      expect(TraleDatePrintFormat.MMddyyyy.patternShort, 'MM/dd');
      expect(TraleDatePrintFormat.ddMMyyyyDot.patternShort, 'dd.MM');
      expect(TraleDatePrintFormat.iso8601.patternShort, 'MM-dd');
    });

    test('dateFormat returns DateFormat with correct pattern', () {
      final DateFormat fmt = TraleDatePrintFormat.iso8601.dateFormat;
      final DateTime testDate = DateTime(2024, 10, 26);
      expect(fmt.format(testDate), '2024-10-26');
    });

    test('dayFormat returns DateFormat without year', () {
      final DateFormat fmt = TraleDatePrintFormat.ddMMyyyyDot.dayFormat;
      final DateTime testDate = DateTime(2024, 10, 26);
      expect(fmt.format(testDate), '26.10');
    });

    test('name returns enum value name', () {
      expect(TraleDatePrintFormat.systemDefault.name, 'systemDefault');
      expect(TraleDatePrintFormat.iso8601.name, 'iso8601');
    });
  });

  group('TraleDateFormatParsing', () {
    test('valid string converts to TraleDatePrintFormat', () {
      expect(
        'systemDefault'.toTraleDateFormat(),
        TraleDatePrintFormat.systemDefault,
      );
      expect('iso8601'.toTraleDateFormat(), TraleDatePrintFormat.iso8601);
      expect('ddMMyyyy'.toTraleDateFormat(), TraleDatePrintFormat.ddMMyyyy);
    });

    test('invalid string returns null', () {
      expect('invalid'.toTraleDateFormat(), isNull);
      expect(''.toTraleDateFormat(), isNull);
    });
  });
}
