import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_stats.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/weight_goal.dart';

import '../helpers/widget_test_helper.dart';

/// One measurement per day up to today, [weightAt] days ago.
List<Measurement> dailyMeasurements(
  double Function(int daysAgo) weightAt, {
  int days = 30,
}) {
  final DateTime now = DateTime.now();
  return <Measurement>[
    for (int daysAgo = 0; daysAgo < days; daysAgo++)
      Measurement(
        weight: weightAt(daysAgo),
        date: now.subtract(Duration(days: daysAgo)),
      ),
  ];
}

void main() {
  tearDown(resetWidgetTestDependencies);

  group('MeasurementStats.daysInTargetRange', () {
    test('counts every day the trend stayed within the range', () async {
      await setUpWidgetTestDependencies(
        measurements: dailyMeasurements((int daysAgo) => 75),
      );

      expect(
        MeasurementStats().daysInTargetRange(WeightGoal.maintain.range(75)),
        30,
      );
    });

    test('is zero while the trend is outside the range', () async {
      await setUpWidgetTestDependencies(
        measurements: dailyMeasurements((int daysAgo) => 80),
      );

      expect(
        MeasurementStats().daysInTargetRange(WeightGoal.maintain.range(75)),
        0,
      );
    });
  });

  test('the maintain goal ignores a stored target date', () async {
    final TraleNotifier notifier = await setUpWidgetTestDependencies(
      measurements: dailyMeasurements((int daysAgo) => 80 + 0.1 * daysAgo),
    );
    final DateTime now = DateTime.now();
    notifier.targetWeightEnabled = true;
    notifier.userTargetWeight = 70;
    notifier.userTargetWeightSetDate = now.subtract(const Duration(days: 20));
    notifier.userTargetWeightDate = now.add(const Duration(days: 60));

    // The lose goal follows the line from the set date to the target date.
    expect(MeasurementStats().referenceAtDay(now), isNot(closeTo(70, 0.01)));

    notifier.weightGoal = WeightGoal.maintain;

    expect(MeasurementStats().referenceAtDay(now), closeTo(70, 0.01));
  });
}
