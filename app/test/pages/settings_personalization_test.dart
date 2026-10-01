import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/chart_mode.dart';
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
}
