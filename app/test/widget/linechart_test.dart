import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/widget/linechart.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  late TraleNotifier notifier;

  setUp(() async {
    final DateTime now = DateTime.now();
    notifier = await setUpWidgetTestDependencies(
      measurements: <Measurement>[
        for (int daysAgo = 0; daysAgo < 30; daysAgo++)
          Measurement(weight: 80, date: now.subtract(Duration(days: daysAgo))),
      ],
    );
  });

  tearDown(resetWidgetTestDependencies);

  // The chart is only rebuilt by new measurements, so it kept plotting the
  // old unit until the overview happened to be built again.
  testWidgets('the chart follows a change of the unit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        notifier: notifier,
        child: CustomLineChart(
          loadedFirst: false,
          ip: MeasurementInterpolation(),
        ),
      ),
    );
    await tester.pump();

    notifier.unit = TraleUnit.lb;
    await tester.pump();

    final LineChart chart = tester.widget<LineChart>(find.byType(LineChart));
    expect(
      chart.data.lineBarsData.first.spots.first.y,
      closeTo(80 / TraleUnit.lb.scaling, 0.01),
    );
  });
}
