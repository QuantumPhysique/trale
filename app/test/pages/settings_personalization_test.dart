import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/chart_mode.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/pages/settings_personalization.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  late TraleNotifier notifier;

  setUp(() async {
    notifier = await setUpWidgetTestDependencies();
  });

  tearDown(resetWidgetTestDependencies);

  testWidgets('choosing the scientific chart sets the mode', (
    WidgetTester tester,
  ) async {
    // Tall enough for the whole page, which scrolls with snapping.
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      buildTestApp(
        notifier: notifier,
        child: const PersonalizationSettingsPage(),
      ),
    );
    await pumpUntilSettled(tester);

    await tester.tap(find.text('Scientific'));
    await tester.pump();

    expect(notifier.chartMode, ChartMode.scientific);
  });

  group('with my data', () {
    setUp(() async {
      final DateTime now = DateTime.now();
      notifier = await setUpWidgetTestDependencies(
        measurements: <Measurement>[
          for (int daysAgo = 0; daysAgo < 30; daysAgo++)
            Measurement(
              weight: 80.0 + daysAgo % 3,
              date: now.subtract(Duration(days: daysAgo)),
            ),
        ],
      );
    });

    // A new strength is computed in the background, after the page was
    // rebuilt for it, so the chart kept the previous strength's curve.
    testWidgets('the chart follows a new strength', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        buildTestApp(
          notifier: notifier,
          child: const PersonalizationSettingsPage(),
        ),
      );
      await pumpUntilSettled(tester);
      await tester.tap(find.text('Show my data'));
      await tester.pump();

      // What MeasurementDatabase.reinit does for a new strength, without
      // reloading the measurements from Hive.
      await tester.runAsync(() async {
        Preferences().interpolStrength = InterpolStrength.strong;
        await MeasurementInterpolation().reinitAsync();
      });
      MeasurementDatabase().fireStream();
      await tester.pump();

      final LineChart chart = tester.widget<LineChart>(find.byType(LineChart));
      final List<FlSpot> spots = chart.data.lineBarsData.first.spots;
      expect(<double>[
        for (final FlSpot spot in spots) spot.y,
      ], MeasurementInterpolation().weights.toList().sublist(0, spots.length));
    });
  });
}
