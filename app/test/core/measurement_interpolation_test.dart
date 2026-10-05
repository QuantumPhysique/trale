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

/// Thirty mornings on the line 80 kg - 0.05 kg/day, from 2026-01-01.
List<Measurement> line() => <Measurement>[
  for (int day = 0; day < 30; day++)
    Measurement(weight: 80 - 0.05 * day, date: DateTime(2026, 1, 1 + day, 8)),
];

/// Two hundred mornings around 80 kg with normally distributed noise of
/// 0.3 kg, from 2026-01-01.
List<Measurement> gaussianDiary() {
  final Random random = Random(3);
  return <Measurement>[
    for (int day = 0; day < 200; day++)
      Measurement(
        weight:
            80 +
            0.3 *
                sqrt(-2 * log(1 - random.nextDouble())) *
                cos(2 * pi * random.nextDouble()),
        date: DateTime(2026, 1, 1 + day, 8),
      ),
  ];
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

    for (int day = 0; day < 30; day++) {
      expect(
        ip.interpolationForDay(DateTime(2026, 1, 1 + day)),
        closeTo(80 - 0.05 * day, 0.03),
      );
    }
    expect(ip.slopeAtDay(DateTime(2026, 1, 16)), closeTo(-0.05, 0.001));
    // The damping pulls a steady rate to about 92 % at the last reading.
    expect(
      ip.slopeAtDay(DateTime(2026, 1, 30)) / -0.05,
      inInclusiveRange(0.88, 0.96),
    );
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

  test('the band holds about 95 of 100 measurements', () async {
    final MeasurementInterpolation ip = await interpolate(gaussianDiary());
    int inside = 0;
    int count = 0;
    for (int i = 0; i < ip.times.length; i++) {
      if (ip.isMeasurement[i] == 1) {
        count++;
        if (ip.measurements[i] >= ip.bandLower[i] &&
            ip.measurements[i] <= ip.bandUpper[i]) {
          inside++;
        }
      }
    }

    expect(inside / count, inInclusiveRange(0.9, 0.99));
  });

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
