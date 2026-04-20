import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/unit_precision.dart';

void main() {
  group('TraleUnitPrecision', () {
    test('ticksPerStep values are correct', () {
      expect(TraleUnitPrecision.unitDefault.ticksPerStep, isNull);
      expect(TraleUnitPrecision.single.ticksPerStep, 10);
      expect(TraleUnitPrecision.double.ticksPerStep, 20);
    });

    test('precision values are correct', () {
      expect(TraleUnitPrecision.unitDefault.precision, isNull);
      expect(TraleUnitPrecision.single.precision, 1);
      expect(TraleUnitPrecision.double.precision, 2);
    });

    test('name returns enum value name', () {
      expect(TraleUnitPrecision.unitDefault.name, 'unitDefault');
      expect(TraleUnitPrecision.single.name, 'single');
      expect(TraleUnitPrecision.double.name, 'double');
    });

    test('settingsName returns display string', () {
      expect(TraleUnitPrecision.unitDefault.settingsName, isNull);
      expect(TraleUnitPrecision.single.settingsName, '0.1');
      expect(TraleUnitPrecision.double.settingsName, '0.05');
    });
  });

  group('TralUnitPrecisionParsing', () {
    test('valid string converts to TraleUnitPrecision', () {
      expect(
        'unitDefault'.toTraleUnitPrecision(),
        TraleUnitPrecision.unitDefault,
      );
      expect('single'.toTraleUnitPrecision(), TraleUnitPrecision.single);
      expect('double'.toTraleUnitPrecision(), TraleUnitPrecision.double);
    });

    test('invalid string returns null', () {
      expect('invalid'.toTraleUnitPrecision(), isNull);
      expect(''.toTraleUnitPrecision(), isNull);
    });
  });
}
