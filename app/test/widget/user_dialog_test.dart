import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/weight_goal.dart';
import 'package:trale/widget/user_dialog.dart';

import '../helpers/widget_test_helper.dart';

// The user dialog holds two groups of fields, which is more than a short
// screen has room for once the software keyboard is up. [AlertDialog] puts its
// content in a bare [Flexible], so without a scroll view of its own the
// content is handed a height it cannot meet and overflows — reported on
// issue #509.
void main() {
  late TraleNotifier notifier;

  setUp(() async {
    notifier = await setUpWidgetTestDependencies();
  });

  tearDown(resetWidgetTestDependencies);

  /// Opens the dialog on a screen the size of a small phone.
  Future<void> openDialog(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      buildTestApp(
        notifier: notifier,
        child: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => showUserDialog(context: context),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('the user dialog fits a small screen', (
    WidgetTester tester,
  ) async {
    await openDialog(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('the user dialog fits once the keyboard is up', (
    WidgetTester tester,
  ) async {
    await openDialog(tester);

    // The keyboard takes the bottom of the screen, and the dialog shrinks to
    // stay clear of it.
    tester.view.viewInsets = const FakeViewPadding(bottom: 1200);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the shrunken dialog scrolls down to the target weight', (
    WidgetTester tester,
  ) async {
    await openDialog(tester);

    tester.view.viewInsets = const FakeViewPadding(bottom: 1200);
    await tester.pumpAndSettle();

    final Finder scrollView = find
        .ancestor(
          of: find.byType(UserDetailsGroup),
          matching: find.byType(SingleChildScrollView),
        )
        .first;
    final double before = tester.getTopLeft(find.byType(UserDetailsGroup)).dy;

    await tester.drag(scrollView, const Offset(0, -120));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.byType(UserDetailsGroup)).dy,
      lessThan(before),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the maintain goal shows its range and no target date', (
    WidgetTester tester,
  ) async {
    notifier.targetWeightEnabled = true;
    notifier.userTargetWeight = 80;
    notifier.weightGoal = WeightGoal.maintain;

    await openDialog(tester);

    expect(find.text('80.0 kg ± 1%'), findsOneWidget);
    expect(find.text('Target date'), findsNothing);
  });

  testWidgets('a new target starts at the current weight', (
    WidgetTester tester,
  ) async {
    notifier = await setUpWidgetTestDependencies(
      measurements: dailyMeasurements((int daysAgo) => 76.3),
    );
    notifier.targetWeightEnabled = true;

    await openDialog(tester);
    await tester.ensureVisible(find.text('Add target weight'));
    await tester.tap(find.text('Add target weight'));
    await tester.pumpAndSettle();

    expect(find.text('76.3 kg'), findsOneWidget);
  });
}
