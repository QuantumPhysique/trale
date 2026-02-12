import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/contrast.dart';

void main() {
  group('ContrastLevel', () {
    test('enum values exist', () {
      expect(ContrastLevel.values.length, 6);
      expect(ContrastLevel.values, contains(ContrastLevel.normal));
      expect(ContrastLevel.values, contains(ContrastLevel.one));
      expect(ContrastLevel.values, contains(ContrastLevel.two));
      expect(ContrastLevel.values, contains(ContrastLevel.three));
      expect(ContrastLevel.values, contains(ContrastLevel.four));
      expect(ContrastLevel.values, contains(ContrastLevel.five));
    });
  });

  group('ContrastLevelExtension', () {
    test('contrast returns correct values', () {
      expect(ContrastLevel.normal.contrast, 0.0);
      expect(ContrastLevel.one.contrast, 0.1);
      expect(ContrastLevel.two.contrast, 0.2);
      expect(ContrastLevel.three.contrast, 0.3);
      expect(ContrastLevel.four.contrast, 0.4);
      expect(ContrastLevel.five.contrast, 0.5);
    });

    test('nameLong returns correct string', () {
      expect(ContrastLevel.normal.nameLong, '0');
      expect(ContrastLevel.one.nameLong, '1');
      expect(ContrastLevel.two.nameLong, '2');
      expect(ContrastLevel.three.nameLong, '3');
      expect(ContrastLevel.four.nameLong, '4');
      expect(ContrastLevel.five.nameLong, '5');
    });

    test('name returns correct string', () {
      expect(ContrastLevel.normal.name, 'normal');
      expect(ContrastLevel.one.name, 'one');
      expect(ContrastLevel.two.name, 'two');
      expect(ContrastLevel.three.name, 'three');
      expect(ContrastLevel.four.name, 'four');
      expect(ContrastLevel.five.name, 'five');
    });

    test('idx returns correct index', () {
      expect(ContrastLevel.normal.idx, 0);
      expect(ContrastLevel.one.idx, 1);
      expect(ContrastLevel.two.idx, 2);
      expect(ContrastLevel.three.idx, 3);
      expect(ContrastLevel.four.idx, 4);
      expect(ContrastLevel.five.idx, 5);
    });
  });

  group('ContrastLevelParsing', () {
    test('toContrastLevel converts valid strings', () {
      expect('normal'.toContrastLevel(), ContrastLevel.normal);
      expect('one'.toContrastLevel(), ContrastLevel.one);
      expect('two'.toContrastLevel(), ContrastLevel.two);
      expect('three'.toContrastLevel(), ContrastLevel.three);
      expect('four'.toContrastLevel(), ContrastLevel.four);
      expect('five'.toContrastLevel(), ContrastLevel.five);
    });

    test('toContrastLevel returns null for invalid strings', () {
      expect('invalid'.toContrastLevel(), isNull);
      expect(''.toContrastLevel(), isNull);
      expect('ONE'.toContrastLevel(), isNull);
    });
  });
}
