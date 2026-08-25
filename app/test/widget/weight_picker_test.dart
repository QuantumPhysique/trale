import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:quantumphysique/quantumphysique.dart';
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

  // The bar is the first tile of the group, the ruler the second.
  ShapeBorder? barShape(WidgetTester tester) =>
      tester.widget<QPGroupedWidget>(find.byType(QPGroupedWidget).first).shape;

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

  /// The colour an [Icon] actually paints with, wherever it came from.
  ///
  /// Reading it off the rendered glyph rather than off the [PPIcon] widget is
  /// what makes this catch an explicit colour shadowing the [IconTheme] that
  /// [IconButton] uses to express its disabled state.
  Color glyphColor(WidgetTester tester, IconData icon) => tester
      .widget<RichText>(
        find.descendant(of: stepper(icon), matching: find.byType(RichText)),
      )
      .text
      .style!
      .color!;

  testWidgets('shows the value and no text field by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pump();

    expect(find.text('80.0 kg'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('tapping the value opens a text field and collapses the ruler', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pump();
    await startTyping(tester);

    expect(find.byType(TextField), findsOneWidget);

    // The ruler stays in the tree but is clipped away, freeing the space
    // the software keyboard needs.
    await tester.pumpAndSettle();
    expect(rulerFactor(tester), 0);
    expect(find.byType(ListView), findsOneWidget);
  });

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

  testWidgets('input above the field width is kept, not capped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pump();
    await startTyping(tester);

    // The ruler scrolls past any weight, so typing is only limited by the
    // three integer digits the kg field holds — not by a value ceiling.
    await tester.enterText(find.byType(TextField), '999');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(reported.last, closeTo(999, 0.001));
    expect(find.text('999.0 kg'), findsOneWidget);
  });

  testWidgets('the plus stepper never runs out of ruler', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host(value: 999));
    await tester.pump();

    expect(
      tester.widget<IconButton>(stepper(PhosphorIconsRegular.plus)).onPressed,
      isNotNull,
    );
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

  testWidgets('touching the ruler commits and restores it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pump();
    await startTyping(tester);

    await tester.enterText(find.byType(TextField), '75.4');
    await tester.pump();

    await tester.tap(find.byType(ListView), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('75.4 kg'), findsOneWidget);
    expect(rulerFactor(tester), 1);
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

  testWidgets('the steppers collapse together with the ruler', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pump();

    expect(stepper(PhosphorIconsRegular.plus), findsOneWidget);

    await startTyping(tester);
    await tester.pumpAndSettle();

    final SizeTransition steppers = tester.widget<SizeTransition>(
      find.byType(SizeTransition).last,
    );
    expect(steppers.sizeFactor.value, 0);
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

  testWidgets('the disabled stepper is dimmed, not just inert', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host(value: 0));
    await tester.pump();

    final Color minus = glyphColor(tester, PhosphorIconsRegular.minus);
    final Color plus = glyphColor(tester, PhosphorIconsRegular.plus);

    expect(
      tester.widget<IconButton>(stepper(PhosphorIconsRegular.minus)).onPressed,
      isNull,
    );
    expect(minus.a, lessThan(plus.a));
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

  testWidgets('the bar morphs into a pill while typing and back after', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pump();

    final ShapeBorder? resting = barShape(tester);
    expect(resting, isNotNull);

    await startTyping(tester);
    await tester.pumpAndSettle();

    // Standing alone above the collapsed ruler, the bar is a pill.
    expect(
      barShape(tester),
      ShapeBorder.lerp(const StadiumBorder(), QPLayout.innerBorderShape, 0),
    );

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(barShape(tester), resting);
  });
}
