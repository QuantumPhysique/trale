import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trale/core/measurement_stats.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/weight_goal.dart';
import 'package:trale/widget/stats_widgets.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  tearDown(resetWidgetTestDependencies);

  /// Shows the hero card for a maintain goal of 75 kg ± 1%.
  Future<void> pumpMaintainCard(
    WidgetTester tester,
    double Function(int daysAgo) weightAt, {
    int days = 20,
  }) async {
    final TraleNotifier notifier = await setUpWidgetTestDependencies(
      measurements: dailyMeasurements(weightAt, days: days),
    );
    notifier.targetWeightEnabled = true;
    notifier.userTargetWeight = 75;
    notifier.weightGoal = WeightGoal.maintain;

    await tester.pumpWidget(
      buildTestApp(
        notifier: notifier,
        child: Builder(
          builder: (BuildContext context) => SizedBox(
            width: 400,
            height: 150,
            child: reachingTargetWeightCard(
              context: context,
              stats: MeasurementStats(),
            ),
          ),
        ),
      ),
    );
    await pumpUntilSettled(tester);
  }

  testWidgets('inside the range it counts the days spent there', (
    WidgetTester tester,
  ) async {
    await pumpMaintainCard(tester, (int daysAgo) => 75);

    expect(find.text('20'), findsOneWidget);
    expect(find.text('days holding your weight steady'), findsOneWidget);
  });

  testWidgets('a streak of four weeks or more is praised', (
    WidgetTester tester,
  ) async {
    await pumpMaintainCard(tester, (int daysAgo) => 75, days: 42);

    expect(find.text('6'), findsOneWidget);
    expect(
      find.text('weeks and still holding your weight steady'),
      findsOneWidget,
    );
  });

  testWidgets('above the range and falling it counts the way back', (
    WidgetTester tester,
  ) async {
    await pumpMaintainCard(tester, (int daysAgo) => 78 + 0.1 * daysAgo);

    // The smoothed trend lags behind the ramp, so the count may be in weeks.
    expect(
      find.textContaining('left to get back into your range'),
      findsOneWidget,
    );
  });

  testWidgets('above the range and rising it shows no way back', (
    WidgetTester tester,
  ) async {
    await pumpMaintainCard(tester, (int daysAgo) => 78 - 0.1 * daysAgo);

    expect(find.text('--'), findsOneWidget);
    expect(find.text('outside your target range'), findsOneWidget);
  });
}
