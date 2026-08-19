import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  Widget host({double value = 80.0}) => buildTestApp(
    notifier: notifier,
    child: RulerPicker(
      onValueChange: (num newValue) => reported.add(newValue.toDouble()),
      ticksPerStep: notifier.unit.ticksPerStep,
      value: value,
      height: 120,
    ),
  );

  // The bar is the first tile of the group, the ruler the second.
  ShapeBorder? barShape(WidgetTester tester) =>
      tester.widget<QPGroupedWidget>(find.byType(QPGroupedWidget).first).shape;

  Future<void> startTyping(WidgetTester tester) async {
    await tester.tap(find.text('80.0 kg'));
    await tester.pump();
  }

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
    final SizeTransition ruler = tester.widget<SizeTransition>(
      find.byType(SizeTransition),
    );
    expect(ruler.sizeFactor.value, 0);
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

  testWidgets('input is clamped and snapped onto the tick grid', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pump();
    await startTyping(tester);

    // 3 digits is all the formatter allows for kg, the rest is clamped.
    await tester.enterText(find.byType(TextField), '999');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(reported.last, closeTo(500, 0.001));
    expect(find.text('500.0 kg'), findsOneWidget);
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
    final SizeTransition ruler = tester.widget<SizeTransition>(
      find.byType(SizeTransition),
    );
    expect(ruler.sizeFactor.value, 1);
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
