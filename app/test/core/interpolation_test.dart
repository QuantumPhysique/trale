import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/interpolation.dart';

void main() {
  group('InterpolStrength', () {
    test('enum values exist', () {
      expect(InterpolStrength.values.length, 4);
      expect(InterpolStrength.values, contains(InterpolStrength.none));
      expect(InterpolStrength.values, contains(InterpolStrength.soft));
      expect(InterpolStrength.values, contains(InterpolStrength.medium));
      expect(InterpolStrength.values, contains(InterpolStrength.strong));
    });
  });

  group('InterpolStrengthExtension', () {
    test('strengthMeasurement returns correct values', () {
      expect(InterpolStrength.none.strengthMeasurement, 2.0);
      expect(InterpolStrength.soft.strengthMeasurement, 2.0);
      expect(InterpolStrength.medium.strengthMeasurement, 4.0);
      expect(InterpolStrength.strong.strengthMeasurement, 7.0);
    });

    test('strengthInterpol returns half of strengthMeasurement', () {
      expect(InterpolStrength.none.strengthInterpol, 1.0);
      expect(InterpolStrength.soft.strengthInterpol, 1.0);
      expect(InterpolStrength.medium.strengthInterpol, 2.0);
      expect(InterpolStrength.strong.strengthInterpol, 3.5);
    });

    test('weight returns correct value', () {
      expect(InterpolStrength.none.weight, 2.0);
      expect(InterpolStrength.soft.weight, 2.0);
      expect(InterpolStrength.medium.weight, 2.0);
      expect(InterpolStrength.strong.weight, 2.0);
    });

    test('name returns correct string', () {
      expect(InterpolStrength.none.name, 'none');
      expect(InterpolStrength.soft.name, 'soft');
      expect(InterpolStrength.medium.name, 'medium');
      expect(InterpolStrength.strong.name, 'strong');
    });

    test('idx returns correct index', () {
      expect(InterpolStrength.none.idx, 0);
      expect(InterpolStrength.soft.idx, 1);
      expect(InterpolStrength.medium.idx, 2);
      expect(InterpolStrength.strong.idx, 3);
    });
  });

  group('InterpolStrengthParsing', () {
    test('toInterpolStrength converts valid strings', () {
      expect('none'.toInterpolStrength(), InterpolStrength.none);
      expect('soft'.toInterpolStrength(), InterpolStrength.soft);
      expect('medium'.toInterpolStrength(), InterpolStrength.medium);
      expect('strong'.toInterpolStrength(), InterpolStrength.strong);
    });

    test('toInterpolStrength returns null for invalid strings', () {
      expect('invalid'.toInterpolStrength(), isNull);
      expect(''.toInterpolStrength(), isNull);
      expect('SOFT'.toInterpolStrength(), isNull);
    });
  });
}
