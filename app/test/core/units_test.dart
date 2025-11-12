import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/units.dart';
import 'package:trale/core/measurement.dart';

void main() {
  group('TraleUnit', () {
    test('enum values exist', () {
      expect(TraleUnit.values.length, 3);
      expect(TraleUnit.values, contains(TraleUnit.kg));
      expect(TraleUnit.values, contains(TraleUnit.st));
      expect(TraleUnit.values, contains(TraleUnit.lb));
    });
  });

  group('TraleUnitExtension', () {
    test('scaling returns correct values', () {
      expect(TraleUnit.kg.scaling, 1.0);
      expect(TraleUnit.st.scaling, 6.35029318);
      expect(TraleUnit.lb.scaling, 0.45359237);
    });

    test('ticksPerStep returns correct values', () {
      expect(TraleUnit.kg.ticksPerStep, 10);
      expect(TraleUnit.st.ticksPerStep, 20);
      expect(TraleUnit.lb.ticksPerStep, 10);
    });

    test('precision returns correct values', () {
      expect(TraleUnit.kg.precision, 1);
      expect(TraleUnit.st.precision, 2);
      expect(TraleUnit.lb.precision, 1);
    });

    test('name returns correct string', () {
      expect(TraleUnit.kg.name, 'kg');
      expect(TraleUnit.st.name, 'st');
      expect(TraleUnit.lb.name, 'lb');
    });

    test('doubleToPrecision rounds correctly', () {
      expect(TraleUnit.kg.doubleToPrecision(1.234), 1.2);
      expect(TraleUnit.kg.doubleToPrecision(1.26), 1.3);
      expect(TraleUnit.st.doubleToPrecision(1.234), 1.25);
      expect(TraleUnit.lb.doubleToPrecision(1.234), 1.2);
    });

    test('weightToString converts weight correctly', () {
      expect(TraleUnit.kg.weightToString(70.5), '70.5 kg');
      expect(TraleUnit.kg.weightToString(70.5, showUnit: false), '70.5');
      expect(TraleUnit.lb.weightToString(155.5), '155.5 lb');
      expect(TraleUnit.lb.weightToString(155.5, showUnit: false), '155.5');
    });

    test('measurementToString converts measurement correctly', () {
      final measurement = Measurement(
        weight: 70.0,
        date: DateTime(2024, 1, 1),
      );
      expect(TraleUnit.kg.measurementToString(measurement), '70.0 kg');
      expect(TraleUnit.kg.measurementToString(measurement, showUnit: false), '70.0');
    });
  });

  group('TralUnitParsing', () {
    test('toTraleUnit converts valid strings', () {
      expect('kg'.toTraleUnit(), TraleUnit.kg);
      expect('st'.toTraleUnit(), TraleUnit.st);
      expect('lb'.toTraleUnit(), TraleUnit.lb);
    });

    test('toTraleUnit returns null for invalid strings', () {
      expect('invalid'.toTraleUnit(), isNull);
      expect(''.toTraleUnit(), isNull);
      expect('KG'.toTraleUnit(), isNull);
    });
  });
}
