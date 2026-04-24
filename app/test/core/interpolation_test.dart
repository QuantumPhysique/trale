import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/interpolation.dart';

void main() {
  group('InterpolStrength', () {
    test('strengthMeasurement values are correct', () {
      expect(InterpolStrength.none.strengthMeasurement, 2);
      expect(InterpolStrength.soft.strengthMeasurement, 2);
      expect(InterpolStrength.medium.strengthMeasurement, 4);
      expect(InterpolStrength.strong.strengthMeasurement, 7);
    });

    test('strengthInterpol is half of strengthMeasurement', () {
      for (final InterpolStrength s in InterpolStrength.values) {
        expect(s.strengthInterpol, s.strengthMeasurement / 2);
      }
    });

    test('weight is always 2', () {
      for (final InterpolStrength s in InterpolStrength.values) {
        expect(s.weight, 2);
      }
    });

    test('name returns enum value name', () {
      expect(InterpolStrength.none.name, 'none');
      expect(InterpolStrength.soft.name, 'soft');
      expect(InterpolStrength.medium.name, 'medium');
      expect(InterpolStrength.strong.name, 'strong');
    });

    test('idx returns correct index', () {
      for (int i = 0; i < InterpolStrength.values.length; i++) {
        expect(InterpolStrength.values[i].idx, i);
      }
    });
  });

  group('InterpolStrengthParsing', () {
    test('valid string converts to InterpolStrength', () {
      expect('none'.toInterpolStrength(), InterpolStrength.none);
      expect('soft'.toInterpolStrength(), InterpolStrength.soft);
      expect('medium'.toInterpolStrength(), InterpolStrength.medium);
      expect('strong'.toInterpolStrength(), InterpolStrength.strong);
    });

    test('invalid string returns null', () {
      expect('invalid'.toInterpolStrength(), isNull);
      expect(''.toInterpolStrength(), isNull);
    });
  });
}
