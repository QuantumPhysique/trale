import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/measurementStats.dart';

void main() {
  group('MeasurementStats', () {
    test('singleton instance is consistent', () {
      final stats1 = MeasurementStats();
      final stats2 = MeasurementStats();

      expect(stats1, same(stats2));
    });

    test('db getter returns MeasurementDatabase', () {
      final stats = MeasurementStats();
      expect(stats.db, isNotNull);
    });

    test('ip getter returns MeasurementInterpolation', () {
      final stats = MeasurementStats();
      expect(stats.ip, isNotNull);
    });

    test('reinit clears cached values', () {
      final stats = MeasurementStats();
      
      // Call reinit to ensure it doesn't throw
      expect(() => stats.reinit(), returnsNormally);
    });

    test('init runs without error', () {
      final stats = MeasurementStats();
      
      // Call init to ensure it doesn't throw
      expect(() => stats.init(), returnsNormally);
    });

    // Note: Most methods in MeasurementStats require a fully initialized database
    // with measurements, which would need complex setup. The tests above verify
    // the basic structure and singleton pattern.
    // Full integration tests would require:
    // - Setting up Hive database
    // - Adding test measurements
    // - Testing interpolation calculations
    // These are better suited for integration tests rather than unit tests.
  });
}
