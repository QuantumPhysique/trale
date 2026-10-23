import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/constants.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/smoothing.dart';

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

/// Thirty mornings on the line 80 kg - 0.05 kg/day, from 2026-01-01.
List<Measurement> line() => <Measurement>[
  for (int day = 0; day < 30; day++)
    Measurement(weight: 80 - 0.05 * day, date: DateTime(2026, 1, 1 + day, 8)),
];

/// A standard normal draw from [random].
double gaussian(Random random) =>
    sqrt(-2 * log(1 - random.nextDouble())) * cos(2 * pi * random.nextDouble());

/// A year of mornings at 80 kg with water of [water] times the weight,
/// relaxing over a day, a scale error of 0.05 kg and rounding to 0.1 kg, from
/// 2026-01-01.
List<Measurement> waterDiary(double water) {
  final Random random = Random(5);
  final double keep = exp(-1);
  double level = water * 80 * gaussian(random);
  final List<Measurement> measurements = <Measurement>[];
  for (int day = 0; day < 365; day++) {
    final double reading = 80 + level + 0.05 * gaussian(random);
    measurements.add(
      Measurement(
        weight: (reading * 10).round() / 10,
        date: DateTime(2026, 1, 1 + day, 8),
      ),
    );
    level =
        keep * level + water * 80 * sqrt(1 - keep * keep) * gaussian(random);
  }
  return measurements;
}

/// The interpolation of [measurements] at [strength].
Future<MeasurementInterpolation> interpolate(
  List<Measurement> measurements, [
  InterpolStrength strength = InterpolStrength.medium,
]) async {
  await setUpWidgetTestDependencies(measurements: measurements);
  Preferences().interpolStrength = strength;
  MeasurementInterpolation.resetInstance();
  return MeasurementInterpolation();
}

/// Sum of the squared second differences of the displayed curve.
double roughness(MeasurementInterpolation ip) {
  final List<double> w = ip.weights.toList();
  double sum = 0;
  for (int i = 1; i < w.length - 1; i++) {
    sum += pow(w[i + 1] - 2 * w[i] + w[i - 1], 2);
  }
  return sum;
}

void main() {
  tearDown(resetWidgetTestDependencies);

  test('a straight line is followed', () async {
    final MeasurementInterpolation ip = await interpolate(line());

    // The slope's pull towards zero bends the ends by about 0.03 kg.
    for (int day = 0; day < 30; day++) {
      expect(
        ip.interpolationForDay(DateTime(2026, 1, 1 + day)),
        closeTo(80 - 0.05 * day, 0.04),
      );
    }
  });

  test('the projection levels off', () async {
    final MeasurementInterpolation ip = await interpolate(line());
    final DateTime last = DateTime(2026, 1, 30);
    final DateTime week = DateTime(2026, 2, 6);

    expect(ip.slopeAtDay(week).abs(), lessThan(ip.slopeAtDay(last).abs()));
    expect(
      ip.interpolationForDay(week)!,
      greaterThan(ip.interpolationForDay(last)! - 7 * 0.05),
    );
  });

  test('a stronger strength gives a smoother curve', () async {
    final List<double> roughnesses = <double>[
      for (final InterpolStrength strength in <InterpolStrength>[
        InterpolStrength.soft,
        InterpolStrength.medium,
        InterpolStrength.strong,
      ])
        roughness(await interpolate(noisyDiary(), strength)),
    ];

    expect(roughnesses[0], greaterThan(roughnesses[1]));
    expect(roughnesses[1], greaterThan(roughnesses[2]));
  });

  test(
    'a year of readings learns its water and no week-scale changes',
    () async {
      final MeasurementInterpolation ip = await interpolate(waterDiary(0.006));
      await ip.reinitAsync();
      final SmoothingState learned = Preferences().smoothingState!;

      expect(learned.waterAmplitude / 0.006, inInclusiveRange(0.8, 1.2));
      expect(learned.weekAmplitude, lessThan(amplitudePriorCentre));
    },
  );

  test('the grid keeps a last day read earlier in the day', () async {
    final DateTime last = DateTime(2026, 3, 21, 8);
    final MeasurementInterpolation ip = await interpolate(<Measurement>[
      Measurement(weight: 80, date: DateTime(2026, 3, 1, 20)),
      Measurement(weight: 79, date: last),
    ]);

    expect(ip.nDays, 21);
    expect(
      ip.interpolationForDay(last.add(const Duration(days: 7))),
      isNotNull,
    );
  });
}
