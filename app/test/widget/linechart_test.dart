import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:trale/core/interpolation_preview.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/core/zoom_level.dart';
import 'package:trale/widget/linechart.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  late TraleNotifier notifier;

  setUp(() async {
    notifier = await setUpWidgetTestDependencies(
      measurements: dailyMeasurements((_) => 80, days: 90),
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
  // With a long history the preview of the own data was squeezed into the
  // full range, hiding what a change of the strength does (#512).
  testWidgets('a preview of the own data follows the zoom window', (
    WidgetTester tester,
  ) async {
    Preferences().zoomLevel = ZoomLevel.one;
    await tester.pumpWidget(
      buildTestApp(
        notifier: notifier,
        child: CustomLineChart(
          loadedFirst: false,
          ip: MeasurementInterpolation(),
          isPreview: true,
        ),
      ),
    );
    await tester.pump();

    final LineChart chart = tester.widget<LineChart>(find.byType(LineChart));
    expect(chart.data.minX, ZoomLevel.one.minX);
    expect(chart.data.maxX, ZoomLevel.one.maxX);
  });

  testWidgets('a preview of the sample data shows all of it', (
    WidgetTester tester,
  ) async {
    Preferences().zoomLevel = ZoomLevel.one;
    final PreviewInterpolation ip = PreviewInterpolation();
    await tester.pumpWidget(
      buildTestApp(
        notifier: notifier,
        child: CustomLineChart(loadedFirst: false, ip: ip, isPreview: true),
      ),
    );
    await tester.pump();

    final Vector times = ip.times;
    final LineChart chart = tester.widget<LineChart>(find.byType(LineChart));
    expect(chart.data.minX, times.first);
    expect(chart.data.maxX, times.last);
  });
}
