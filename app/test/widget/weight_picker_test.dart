import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/widget/weight_picker.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  late TraleNotifier notifier;
  late List<double> reported;

  setUp(() async {
    notifier = await setUpWidgetTestDependencies();
    reported = <double>[];
  });

  tearDown(resetWidgetTestDependencies);

  Widget host({double value = 80.0, int? ticksPerStep}) => buildTestApp(
    notifier: notifier,
    child: RulerPicker(
      onValueChange: (num newValue) => reported.add(newValue.toDouble()),
      ticksPerStep: ticksPerStep ?? notifier.unit.ticksPerStep,
      value: value,
      height: 120,
    ),
  );

  // The ruler collapses first, the stepper row below it second.
  double rulerFactor(WidgetTester tester) => tester
      .widget<SizeTransition>(find.byType(SizeTransition).first)
      .sizeFactor
      .value;

  Finder stepper(IconData icon) => find.widgetWithIcon(IconButton, icon);

  Future<void> startTyping(
    WidgetTester tester, {
    String label = '80.0 kg',
  }) async {
    await tester.tap(find.text(label));
    await tester.pump();
  }

  testWidgets('typed input is reported while typing and on submit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pump();
    await startTyping(tester);

    await tester.enterText(find.byType(TextField), '75.4');
    await tester.pump();
    // Reported without waiting for the commit, so that saving with the
    // keyboard still open stores what the field shows.
    expect(reported.last, closeTo(75.4, 0.001));

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('75.4 kg'), findsOneWidget);
    expect(reported.last, closeTo(75.4, 0.001));
  });

  testWidgets('more decimals than the unit allows are rejected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pump();
    await startTyping(tester);

    // kg shows one decimal, so a second one must not be accepted.
    await tester.enterText(find.byType(TextField), '75.44');
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '80.0',
    );
  });

  testWidgets('closing the keyboard commits and restores the ruler', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host());
    await tester.pump();
    await startTyping(tester);

    // The keyboard coming up is all Flutter sees of the back button that
    // closes it again, so both steps are faked through the view insets.
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    await tester.enterText(find.byType(TextField), '75.4');
    await tester.pump();

    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('75.4 kg'), findsOneWidget);
    expect(rulerFactor(tester), 1);
  });

  testWidgets('the steppers move the value by a single tick', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pump();

    await tester.tap(stepper(PhosphorIconsRegular.plus));
    await tester.pumpAndSettle();

    expect(find.text('80.1 kg'), findsOneWidget);
    expect(reported.last, closeTo(80.1, 0.001));

    await tester.tap(stepper(PhosphorIconsRegular.minus));
    await tester.tap(stepper(PhosphorIconsRegular.minus));
    await tester.pumpAndSettle();

    // Taps faster than the scroll animation still add up exactly.
    expect(find.text('79.9 kg'), findsOneWidget);
    expect(reported.last, closeTo(79.9, 0.001));
  });

  testWidgets('the minus stepper stops at the lower end of the ruler', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host(value: 0));
    await tester.pump();

    expect(
      tester.widget<IconButton>(stepper(PhosphorIconsRegular.minus)).onPressed,
      isNull,
    );
    expect(
      tester.widget<IconButton>(stepper(PhosphorIconsRegular.plus)).onPressed,
      isNotNull,
    );
  });

  testWidgets('a finer ruler grid accepts a second decimal', (
    WidgetTester tester,
  ) async {
    // 0.05 steps: the field must offer exactly the precision the ruler can
    // show, not the one the unit defaults to.
    await tester.pumpWidget(host(ticksPerStep: 20));
    await tester.pump();
    await startTyping(tester, label: '80.00 kg');

    await tester.enterText(find.byType(TextField), '75.15');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(reported.last, closeTo(75.15, 0.001));
    expect(find.text('75.15 kg'), findsOneWidget);
  });
}
