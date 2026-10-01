import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_interpolation.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  tearDown(resetWidgetTestDependencies);

  test('the grid keeps a last day read earlier in the day', () async {
    final DateTime first = DateTime(2026, 3, 1, 20);
    final DateTime last = DateTime(2026, 3, 21, 8);
    await setUpWidgetTestDependencies(
      measurements: <Measurement>[
        Measurement(weight: 80, date: first),
        Measurement(weight: 79, date: last),
      ],
    );
    final MeasurementInterpolation ip = MeasurementInterpolation();

    expect(ip.nDays, 21);
    expect(
      ip.interpolationForDay(last.add(const Duration(days: 7))),
      isNotNull,
    );
  });
}
