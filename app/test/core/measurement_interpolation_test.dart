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

  for (final InterpolStrength strength in InterpolStrength.values) {
    test('a straight line is followed at strength ${strength.name}', () async {
      final MeasurementInterpolation ip = await interpolate(line(), strength);

      // Day 32 is two days into the projection.
      for (final int day in <int>[0, 15, 29, 32]) {
        final DateTime date = DateTime(2026, 1, 1 + day);
        expect(ip.interpolationForDay(date), closeTo(80 - 0.05 * day, 1e-6));
        expect(ip.slopeAtDay(date), closeTo(-0.05, 1e-6));
      }
    });
  }

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

  test('the slope of a noisy loss is found', () async {
    final MeasurementInterpolation ip = await interpolate(noisyDiary());

    expect(
      ip.slopeAtDay(DateTime.now().subtract(const Duration(days: 30))),
      closeTo(-0.03, 0.01),
    );
  });

  test('a single measurement gives a flat curve', () async {
    final MeasurementInterpolation ip = await interpolate(<Measurement>[
      Measurement(weight: 80, date: DateTime(2026, 1, 1, 8)),
    ]);

    expect(ip.weights.toList(), everyElement(80));
    expect(ip.slopeAtDay(DateTime(2026, 1, 1)), 0);
  });

  test('two days are joined by a straight line', () async {
    final MeasurementInterpolation ip = await interpolate(<Measurement>[
      Measurement(weight: 80, date: DateTime(2026, 1, 1, 8)),
      Measurement(weight: 79, date: DateTime(2026, 1, 21, 8)),
    ]);

    expect(ip.interpolationForDay(DateTime(2026, 1, 11)), closeTo(79.5, 1e-6));
    expect(ip.slopeAtDay(DateTime(2026, 1, 11)), closeTo(-0.05, 1e-6));
  });

  test('several measurements on a day count as their mean', () async {
    final MeasurementInterpolation ip = await interpolate(<Measurement>[
      ...line(),
      Measurement(weight: 81, date: DateTime(2026, 1, 11, 20)),
    ]);

    expect(
      ip.measurementForDay(DateTime(2026, 1, 11)),
      closeTo((79.5 + 81) / 2, 1e-9),
    );
  });

  test('strength none takes its slope from soft on the same day', () async {
    final List<Measurement> diary = noisyDiary();
    final List<DateTime> days = <DateTime>[
      for (int daysAgo = 0; daysAgo < 60; daysAgo += 5)
        DateTime.now().subtract(Duration(days: daysAgo)),
    ];
    final MeasurementInterpolation soft = await interpolate(
      diary,
      InterpolStrength.soft,
    );
    final List<double> slopes = <double>[
      for (final DateTime day in days) soft.slopeAtDay(day),
    ];

    final MeasurementInterpolation none = await interpolate(
      diary,
      InterpolStrength.none,
    );

    for (int i = 0; i < days.length; i++) {
      expect(none.slopeAtDay(days[i]), closeTo(slopes[i], 1e-12));
    }
  });

  test('identical readings across a long gap stay finite', () async {
    final MeasurementInterpolation ip = await interpolate(<Measurement>[
      for (int day = 0; day < 10; day++)
        Measurement(weight: 80, date: DateTime(2025, 1, 1 + day, 8)),
      for (int day = 0; day < 10; day++)
        Measurement(weight: 80, date: DateTime(2025, 7, 20 + day, 8)),
    ]);

    expect(ip.weights.toList(), everyElement(closeTo(80, 1e-6)));
  });

  for (final InterpolStrength strength in <InterpolStrength>[
    InterpolStrength.medium,
    InterpolStrength.none,
  ]) {
    test('init and reinitAsync agree at strength ${strength.name}', () async {
      final MeasurementInterpolation ip = await interpolate(
        noisyDiary(),
        strength,
      );
      final List<double> weights = ip.weights.toList();
      final double slope = ip.slopeAtDay(DateTime.now());

      await ip.reinitAsync();

      expect(ip.weights.toList(), weights);
      expect(ip.slopeAtDay(DateTime.now()), slope);
    });
  }

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
