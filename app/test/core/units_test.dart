import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/unit_precision.dart';
import 'package:trale/core/units.dart';

void main() {
  group('TraleUnit', () {
    test('scaling factors are correct', () {
      expect(TraleUnit.kg.scaling, 1);
      expect(TraleUnit.st.scaling, 6.35029318);
      expect(TraleUnit.lb.scaling, 0.45359237);
    });

    test('ticksPerStep values are correct', () {
      expect(TraleUnit.kg.ticksPerStep, 10);
      expect(TraleUnit.st.ticksPerStep, 20);
      expect(TraleUnit.lb.ticksPerStep, 10);
    });

    test('precision values are correct', () {
      expect(TraleUnit.kg.precision, 1);
      expect(TraleUnit.st.precision, 2);
      expect(TraleUnit.lb.precision, 1);
    });

    test('name returns enum value name', () {
      expect(TraleUnit.kg.name, 'kg');
      expect(TraleUnit.st.name, 'st');
      expect(TraleUnit.lb.name, 'lb');
    });
  });

  group('TraleUnit.doubleToPrecision', () {
    test('rounds to unit default ticks', () {
      // kg: ticksPerStep = 10, so rounds to 0.1
      const TraleUnitPrecision p = TraleUnitPrecision.unitDefault;
      expect(
        TraleUnit.kg.doubleToPrecision(70.15, p),
        closeTo(70.2, 0.001),
      );
      expect(
        TraleUnit.kg.doubleToPrecision(70.14, p),
        closeTo(70.1, 0.001),
      );
    });

    test('rounds with single precision (0.1)', () {
      expect(
        TraleUnit.kg.doubleToPrecision(70.15, TraleUnitPrecision.single),
        closeTo(70.2, 0.001),
      );
    });

    test('rounds with double precision (0.05)', () {
      const TraleUnitPrecision p = TraleUnitPrecision.double;
      expect(
        TraleUnit.kg.doubleToPrecision(70.13, p),
        closeTo(70.15, 0.001),
      );
      expect(
        TraleUnit.kg.doubleToPrecision(70.12, p),
        closeTo(70.10, 0.001),
      );
    });
  });

  group('TraleUnit.weightToString', () {
    test('kg weight with unit suffix', () {
      final String result =
          TraleUnit.kg.weightToString(70.0, TraleUnitPrecision.unitDefault);
      expect(result, '70.0 kg');
    });

    test('kg weight without unit suffix', () {
      final String result = TraleUnit.kg
          .weightToString(70.0, TraleUnitPrecision.unitDefault, showUnit: false);
      expect(result, '70.0');
    });

    test('converts kg to lb', () {
      // 1 lb = 0.45359237 kg, so 45.359237 kg = 100 lb
      final String result = TraleUnit.lb
          .weightToString(45.359237, TraleUnitPrecision.unitDefault);
      expect(result, '100.0 lb');
    });

    test('converts kg to st', () {
      // 1 st = 6.35029318 kg, so 63.5029318 kg = 10 st
      final String result = TraleUnit.st
          .weightToString(63.5029318, TraleUnitPrecision.unitDefault);
      expect(result, '10.00 st');
    });
  });

  group('TralUnitParsing', () {
    test('valid string converts to TraleUnit', () {
      expect('kg'.toTraleUnit(), TraleUnit.kg);
      expect('st'.toTraleUnit(), TraleUnit.st);
      expect('lb'.toTraleUnit(), TraleUnit.lb);
    });

    test('invalid string returns null', () {
      expect('invalid'.toTraleUnit(), isNull);
      expect(''.toTraleUnit(), isNull);
    });
  });

  group('TraleUnitHeight', () {
    test('label returns correct string', () {
      expect(TraleUnitHeight.metric.label, 'cm');
      expect(TraleUnitHeight.imperial.label, 'ft/in');
    });

    test('name returns enum value name', () {
      expect(TraleUnitHeight.metric.name, 'metric');
      expect(TraleUnitHeight.imperial.name, 'imperial');
    });
  });

  group('TraleUnitHeight.heightToString', () {
    test('metric returns cm integer', () {
      expect(TraleUnitHeight.metric.heightToString(175.0), '175');
      expect(TraleUnitHeight.metric.heightToString(180.5), '180');
    });

    test('imperial returns feet and inches', () {
      // 175 cm = 68.8976 inches = 5'9"
      expect(TraleUnitHeight.imperial.heightToString(175.0), '5\'9"');
    });

    test('imperial handles exact foot boundary', () {
      // 12 inches = 1 foot, so when inches rounds to 12
      // 182.88 cm = 72 inches = 6'0"
      expect(TraleUnitHeight.imperial.heightToString(182.88), '6\'0"');
    });
  });

  group('TraleUnitHeight.parseHeight', () {
    test('metric parses numeric string', () {
      expect(TraleUnitHeight.metric.parseHeight('175'), 175.0);
      expect(TraleUnitHeight.metric.parseHeight('180.5'), 180.5);
    });

    test('metric returns null for invalid input', () {
      expect(TraleUnitHeight.metric.parseHeight('abc'), isNull);
    });

    test('imperial parses various formats', () {
      // 5'11" format
      final double? h1 = TraleUnitHeight.imperial.parseHeight('5\'11"');
      expect(h1, closeTo((5 * 12 + 11) * 2.54, 0.01));

      // 5'11 format (no trailing quote)
      final double? h2 = TraleUnitHeight.imperial.parseHeight('5\'11');
      expect(h2, closeTo((5 * 12 + 11) * 2.54, 0.01));

      // 5 11 format (space separated)
      final double? h3 = TraleUnitHeight.imperial.parseHeight('5 11');
      expect(h3, closeTo((5 * 12 + 11) * 2.54, 0.01));
    });

    test('imperial rejects inches >= 12', () {
      expect(TraleUnitHeight.imperial.parseHeight('5\'12"'), isNull);
    });

    test('imperial returns null for invalid input', () {
      expect(TraleUnitHeight.imperial.parseHeight('abc'), isNull);
    });
  });

  group('TraleUnitHeightParsing', () {
    test('valid string converts to TraleUnitHeight', () {
      expect('metric'.toTraleUnitHeight(), TraleUnitHeight.metric);
      expect('imperial'.toTraleUnitHeight(), TraleUnitHeight.imperial);
    });

    test('invalid string returns null', () {
      expect('invalid'.toTraleUnitHeight(), isNull);
    });
  });

  group('round-trip conversions', () {
    test('kg weight converts and parses back', () {
      const double originalKg = 75.5;
      final String asString = TraleUnit.kg
          .weightToString(originalKg, TraleUnitPrecision.unitDefault,
              showUnit: false);
      final double parsed = double.parse(asString);
      expect(parsed, closeTo(originalKg, 0.1));
    });

    test('metric height round-trips', () {
      const double originalCm = 175.0;
      final String asString =
          TraleUnitHeight.metric.heightToString(originalCm);
      final double? parsed = TraleUnitHeight.metric.parseHeight(asString);
      expect(parsed, originalCm);
    });
  });
}
