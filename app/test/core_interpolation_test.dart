import 'package:trale/core/interpolation.dart';
import 'package:test/test.dart';

void main() {
  group('Test interpolation, increment, decrement', () {
    test('ensure interpolation strength is 1', () {
      expect(InterpolStrength.none.strengthInterpol, 1);
    });

    test('ensure measurement strength is 2', () {
      expect(InterpolStrength.none.strengthMeasurement , 2);
    });
  });
}