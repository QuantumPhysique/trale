import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trale/core/trale_notifier.dart';
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
