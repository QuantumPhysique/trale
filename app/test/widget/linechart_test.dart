import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/chart_mode.dart';
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

  Future<LineChartData> pumpChart(WidgetTester tester) async {
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
    return tester.widget<LineChart>(find.byType(LineChart)).data;
  }

  testWidgets('the simple chart shades the area under the curve', (
    WidgetTester tester,
  ) async {
    final LineChartData data = await pumpChart(tester);

    expect(data.lineBarsData.first.belowBarData.show, isTrue);
    expect(data.lineBarsData.first.color, Colors.transparent);
    expect(data.betweenBarsData, isEmpty);
  });

  testWidgets('the scientific chart draws the line and the band', (
    WidgetTester tester,
  ) async {
    notifier.chartMode = ChartMode.scientific;

    final LineChartData data = await pumpChart(tester);

    expect(data.lineBarsData.first.belowBarData.show, isFalse);
    expect(data.lineBarsData.first.color, isNot(Colors.transparent));
    expect(data.betweenBarsData, hasLength(1));
  });

  testWidgets('the scientific chart makes room for the band', (
    WidgetTester tester,
  ) async {
    // Ten days, a sixty-day gap, ten days: the band bulges in the gap.
    final DateTime now = DateTime.now();
    notifier = await setUpWidgetTestDependencies(
      measurements: <Measurement>[
        for (int daysAgo = 0; daysAgo < 80; daysAgo++)
          if (daysAgo < 10 || daysAgo >= 70)
            Measurement(
              weight: daysAgo.isEven ? 80.3 : 79.7,
              date: now.subtract(Duration(days: daysAgo)),
            ),
      ],
    );
    notifier.chartMode = ChartMode.scientific;

    final LineChartData data = await pumpChart(tester);
    final List<FlSpot> lower =
        data.lineBarsData[data.betweenBarsData.single.fromIndex].spots;
    final List<FlSpot> upper =
        data.lineBarsData[data.betweenBarsData.single.toIndex].spots;
    final double from = now
        .subtract(const Duration(days: 79))
        .millisecondsSinceEpoch
        .toDouble();
    final double to = now.millisecondsSinceEpoch.toDouble();
    bool inData(FlSpot spot) => spot.x >= from && spot.x <= to;

    expect(
      data.minY,
      lessThanOrEqualTo(lower.where(inData).map((FlSpot e) => e.y).reduce(min)),
    );
    expect(
      data.maxY,
      greaterThanOrEqualTo(
        upper.where(inData).map((FlSpot e) => e.y).reduce(max),
      ),
    );
  });

  testWidgets('the chart follows a change of the mode', (
    WidgetTester tester,
  ) async {
    await pumpChart(tester);

    notifier.chartMode = ChartMode.scientific;
    await tester.pump();

    final LineChart chart = tester.widget<LineChart>(find.byType(LineChart));
    expect(chart.data.betweenBarsData, hasLength(1));
  });

  group('chartYRange', () {
    test('pads both sides by a fifth of the span', () {
      final ({double minY, double maxY}) range = chartYRange(<double>[80, 85]);

      expect(range.minY, closeTo(79, 1e-9));
      expect(range.maxY, closeTo(86, 1e-9));
    });

    test('centres a narrow span in the minimum window', () {
      final ({double minY, double maxY}) range = chartYRange(<double>[
        80,
        80.4,
      ]);

      expect(range.minY, closeTo(79.2, 1e-9));
      expect(range.maxY, closeTo(81.2, 1e-9));
    });
  });
}
