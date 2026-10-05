import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/unit_precision.dart';
import 'package:trale/core/weight_goal.dart';
import 'package:trale/widget/add_weight_dialog.dart';

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

  Future<void> openTargetWeightDialog(
    WidgetTester tester, {
    double weight = 80,
  }) async {
    await tester.pumpWidget(
      buildTestApp(
        notifier: notifier,
        child: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () =>
                showTargetWeightDialog(context: context, weight: weight),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

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

  Future<void> tapInDialog(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  // Without a height the floor is 50 kg: the centre passes, its range not.
  testWidgets('the whole maintain range has to stay above the floor', (
    WidgetTester tester,
  ) async {
    await openTargetWeightDialog(tester, weight: 50.5);

    await tapInDialog(tester, find.byTooltip('Maintain weight'));
    await tapInDialog(tester, find.text('Save'));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(notifier.userTargetWeight, isNull);
    expect(notifier.weightGoal, WeightGoal.lose);
  });

  testWidgets('saving an unchanged target keeps the start of the goal', (
    WidgetTester tester,
  ) async {
    final DateTime start = DateTime(2026, 1, 1);
    // The notifier only knows a start date that has a measurement.
    notifier = await setUpWidgetTestDependencies(
      measurements: <Measurement>[Measurement(weight: 82, date: start)],
    );
    notifier.userTargetWeight = 80;
    notifier.userTargetWeightSetDate = start;

    await openTargetWeightDialog(tester);
    await tapInDialog(tester, find.text('Save'));

    expect(notifier.userTargetWeightSetDate, start);
  });
}
