import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/measurement_stats.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/weight_goal.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  tearDown(resetWidgetTestDependencies);

  group('MeasurementStats.daysInTargetRange', () {
    test('counts back only to the day the trend entered the range', () async {
      await setUpWidgetTestDependencies(
        measurements: dailyMeasurements(
          (int daysAgo) => daysAgo < 10 ? 75 : 80,
        ),
      );
      // Unsmoothed, so that the trend steps into the range on a known day.
      Preferences().interpolStrength = InterpolStrength.none;
      MeasurementInterpolation.resetInstance();

      expect(
        MeasurementStats().daysInTargetRange(WeightGoal.maintain.range(75)),
        10,
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
