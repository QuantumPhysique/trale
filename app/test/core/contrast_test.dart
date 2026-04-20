import 'package:flutter_test/flutter_test.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/contrast.dart';

void main() {
  group('ContrastLevel', () {
    test('contrast values are correct', () {
      expect(ContrastLevel.normal.contrast, 0);
      expect(ContrastLevel.one.contrast, 0.1);
      expect(ContrastLevel.two.contrast, 0.2);
      expect(ContrastLevel.three.contrast, 0.3);
      expect(ContrastLevel.four.contrast, 0.4);
      expect(ContrastLevel.five.contrast, 0.5);
    });

    test('nameLong returns scaled string', () {
      expect(ContrastLevel.normal.nameLong, '0');
      expect(ContrastLevel.three.nameLong, '3');
      expect(ContrastLevel.five.nameLong, '5');
    });

    test('name returns enum value name', () {
      expect(ContrastLevel.normal.name, 'normal');
      expect(ContrastLevel.five.name, 'five');
    });

    test('idx returns correct index', () {
      for (int i = 0; i < ContrastLevel.values.length; i++) {
        expect(ContrastLevel.values[i].idx, i);
      }
    });
  });

  group('ContrastLevelParsing', () {
    test('valid string converts to ContrastLevel', () {
      expect('normal'.toContrastLevel(), ContrastLevel.normal);
      expect('one'.toContrastLevel(), ContrastLevel.one);
      expect('five'.toContrastLevel(), ContrastLevel.five);
    });

    test('invalid string returns null', () {
      expect('invalid'.toContrastLevel(), isNull);
      expect(''.toContrastLevel(), isNull);
    });
  });
}
