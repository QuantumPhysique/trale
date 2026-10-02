import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/interpolation.dart';

void main() {
  group('InterpolStrength', () {
    test('bandwidthInDays values are correct', () {
      expect(InterpolStrength.none.bandwidthInDays, 2);
      expect(InterpolStrength.soft.bandwidthInDays, 2);
      expect(InterpolStrength.medium.bandwidthInDays, 4);
      expect(InterpolStrength.strong.bandwidthInDays, 7);
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
