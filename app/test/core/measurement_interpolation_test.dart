import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/preferences.dart';

import '../helpers/widget_test_helper.dart';

/// Sixty days of a slow loss with day-to-day noise, one reading a day and a
/// few days skipped, up to today.
List<Measurement> noisyDiary() {
  final Random random = Random(7);
  final DateTime now = DateTime.now();
  return <Measurement>[
    for (int daysAgo = 0; daysAgo < 60; daysAgo++)
      if (daysAgo % 9 != 4)
        Measurement(
          weight: 80 + 0.03 * daysAgo + 0.4 * (random.nextDouble() - 0.5),
          date: now.subtract(Duration(days: daysAgo)),
        ),
  ];
}

void main() {
  tearDown(resetWidgetTestDependencies);

  for (final InterpolStrength strength in <InterpolStrength>[
    InterpolStrength.medium,
    InterpolStrength.none,
  ]) {
    test('init and reinitAsync agree at strength ${strength.name}', () async {
      await setUpWidgetTestDependencies(measurements: noisyDiary());
      Preferences().interpolStrength = strength;
      MeasurementInterpolation.resetInstance();
      final MeasurementInterpolation ip = MeasurementInterpolation();
      final List<double> weights = ip.weights.toList();
      final double slope = ip.slopeAtDay(DateTime.now());

      await ip.reinitAsync();

      expect(ip.weights.toList(), weights);
      expect(ip.slopeAtDay(DateTime.now()), slope);
    });
  }

  test('the grid keeps a last day read earlier in the day', () async {
    final DateTime first = DateTime(2026, 3, 1, 20);
    final DateTime last = DateTime(2026, 3, 21, 8);
    await setUpWidgetTestDependencies(
      measurements: <Measurement>[
        Measurement(weight: 80, date: first),
        Measurement(weight: 79, date: last),
      ],
    );
    final MeasurementInterpolation ip = MeasurementInterpolation();

    expect(ip.nDays, 21);
    expect(
      ip.interpolationForDay(last.add(const Duration(days: 7))),
      isNotNull,
    );
  });
}
