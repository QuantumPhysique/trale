import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
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

/// [days] mornings around 80 kg with normally distributed noise of 0.3 kg,
/// from 2026-01-01, leaving out the days in [skip].
List<Measurement> gaussianDiary({
  int days = 200,
  Set<int> skip = const <int>{},
}) {
  final Random random = Random(3);
  return <Measurement>[
    for (int day = 0; day < days; day++)
      if (!skip.contains(day))
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

/// Width of the band on [day].
double bandWidth(MeasurementInterpolation ip, DateTime day) {
  final int idx = ip.indexForDay(day)!;
  return ip.bandUpper[idx] - ip.bandLower[idx];
}

/// Computed from scratch on the current database and strength.
class FreshInterpolation extends MeasurementInterpolationBaseclass {
  @override
  MeasurementDatabaseBaseclass get db => MeasurementDatabase();
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

  for (final InterpolStrength strength in InterpolStrength.values) {
    test('a straight line is followed at strength ${strength.name}', () async {
      final MeasurementInterpolation ip = await interpolate(line(), strength);

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
  }

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

    expect(ip.weights.toList(), everyElement(closeTo(80, 1e-9)));
    expect(ip.slopeAtDay(DateTime(2026, 1, 1)), closeTo(0, 1e-9));
  });

  test('two days are joined by a curve between them', () async {
    final MeasurementInterpolation ip = await interpolate(<Measurement>[
      Measurement(weight: 80, date: DateTime(2026, 1, 1, 8)),
      Measurement(weight: 79, date: DateTime(2026, 1, 21, 8)),
    ]);

    expect(ip.interpolationForDay(DateTime(2026, 1, 11)), closeTo(79.5, 1e-6));
    expect(ip.slopeAtDay(DateTime(2026, 1, 11)), closeTo(-0.05, 0.002));
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

  test('the band widens over a gap', () async {
    final MeasurementInterpolation ip = await interpolate(
      gaussianDiary(skip: <int>{for (int day = 80; day < 110; day++) day}),
    );

    expect(
      bandWidth(ip, DateTime(2026, 1, 1 + 95)),
      greaterThan(bandWidth(ip, DateTime(2026, 1, 1 + 40))),
    );
  });

  test('the band contains the curve', () async {
    final MeasurementInterpolation ip = await interpolate(gaussianDiary());

    for (int i = 0; i < ip.weights.length; i++) {
      expect(ip.weights[i], inInclusiveRange(ip.bandLower[i], ip.bandUpper[i]));
    }
  });

  test('there is no band below seven days or without smoothing', () async {
    final MeasurementInterpolation short = await interpolate(
      gaussianDiary(days: 6),
    );
    expect(short.hasBand, isFalse);

    final MeasurementInterpolation none = await interpolate(
      gaussianDiary(),
      InterpolStrength.none,
    );
    expect(none.hasBand, isFalse);
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

  test('the previous curve stays readable while it is recomputed', () async {
    final MeasurementInterpolation ip = await interpolate(noisyDiary());
    final List<double> weights = ip.weights.toList();
    final double slope = ip.slopeAtDay(DateTime.now());

    final Future<void> recompute = ip.reinitAsync();

    expect(ip.weights.toList(), weights);
    expect(ip.slopeAtDay(DateTime.now()), slope);
    await recompute;
  });

  test('a newer recompute wins over an older one', () async {
    final MeasurementInterpolation ip = await interpolate(noisyDiary());

    final Future<void> older = ip.reinitAsync();
    Preferences().interpolStrength = InterpolStrength.strong;
    final Future<void> newer = ip.reinitAsync();
    await Future.wait(<Future<void>>[older, newer]);

    expect(ip.weights.toList(), FreshInterpolation().weights.toList());
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
