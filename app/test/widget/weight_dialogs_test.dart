import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/unit_precision.dart';
import 'package:trale/widget/add_weight_dialog.dart';
import 'package:trale/widget/weight_picker.dart';

import '../helpers/widget_test_helper.dart';

// The target weight dialog shows the same ruler as the add weight dialog and
// had no coverage of its own, which is how it came to hand that ruler a
// different tick grid than the precision setting asks for.
void main() {
  late TraleNotifier notifier;

  setUp(() async {
    notifier = await setUpWidgetTestDependencies();
  });

  tearDown(resetWidgetTestDependencies);

  Future<void> openTargetWeightDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(
        notifier: notifier,
        child: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () =>
                showTargetWeightDialog(context: context, weight: 80),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('the target weight dialog carries the ruler and its steppers', (
    WidgetTester tester,
  ) async {
    await openTargetWeightDialog(tester);

    expect(find.byType(RulerPicker), findsOneWidget);
    expect(
      find.widgetWithIcon(IconButton, PhosphorIconsRegular.minus),
      findsOneWidget,
    );
    expect(
      find.widgetWithIcon(IconButton, PhosphorIconsRegular.plus),
      findsOneWidget,
    );
  });

  testWidgets('the target weight ruler follows the precision setting', (
    WidgetTester tester,
  ) async {
    notifier.unitPrecision = TraleUnitPrecision.double;
    await openTargetWeightDialog(tester);

    // At 0.05 precision the bar shows two decimals, so a typed 75.15 has to
    // survive: with the coarser default grid it used to snap to 75.20.
    await tester.tap(find.text('80.00 kg'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '75.15');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('75.15 kg'), findsOneWidget);
  });

  // Smoke test only: this path does not reproduce the teardown ordering the
  // `mounted` guards in the picker defend against, because the test binding
  // releases the focus before the route is torn down. It still covers
  // dismissing the dialog with a half-typed value in it.
  testWidgets('the target weight dialog closes cleanly while typing', (
    WidgetTester tester,
  ) async {
    await openTargetWeightDialog(tester);

    await tester.tap(find.text('80.0 kg'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '75.4');
    await tester.pump();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(RulerPicker), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
