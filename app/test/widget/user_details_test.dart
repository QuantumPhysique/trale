import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/widget/user_dialog.dart';

import '../helpers/widget_test_helper.dart';

// The height field writes every keystroke straight into the notifier, so the
// settings page around it rebuilds mid-word. Keying the field on the value it
// is editing therefore tore it down on every digit — see issue #509.
void main() {
  late TraleNotifier notifier;

  setUp(() async {
    notifier = await setUpWidgetTestDependencies();
  });

  tearDown(resetWidgetTestDependencies);

  /// Hosts the group in a subtree that rebuilds on every notification, the way
  /// the personalization page does.
  Future<void> pumpGroup(WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(
        notifier: notifier,
        child: Consumer<TraleNotifier>(
          builder: (BuildContext context, TraleNotifier notifier, _) =>
              UserDetailsGroup(notifier: notifier, onRefresh: () {}),
        ),
      ),
    );
    await tester.pump();
  }

  Finder heightField() => find.byType(TextFormField).at(1);

  /// Text currently shown in the height field.
  String heightText(WidgetTester tester) => tester
      .widget<EditableText>(
        find.descendant(of: heightField(), matching: find.byType(EditableText)),
      )
      .controller
      .text;

  testWidgets('the height field keeps focus while a metric height is typed', (
    WidgetTester tester,
  ) async {
    notifier.heightUnit = TraleUnitHeight.metric;
    await pumpGroup(tester);

    await tester.tap(heightField());
    await tester.pump();
    final FocusNode? focused = primaryFocus;
    expect(focused, isNotNull);

    // Type digit by digit through the platform channel rather than
    // `enterText`, which would re-focus the field and hide the very teardown
    // this guards against.
    for (final String value in <String>['1', '18', '180']) {
      tester.testTextInput.enterText(value);
      await tester.pump();
    }

    expect(primaryFocus, same(focused));
    expect(notifier.userHeight, 180);
    expect(heightText(tester), '180');
  });

  testWidgets('the height field keeps focus while a ft/in height is typed', (
    WidgetTester tester,
  ) async {
    notifier.heightUnit = TraleUnitHeight.imperial;
    await pumpGroup(tester);

    await tester.tap(heightField());
    await tester.pump();
    final FocusNode? focused = primaryFocus;
    expect(focused, isNotNull);

    for (final String value in <String>['5', "5'", "5'1", "5'11"]) {
      tester.testTextInput.enterText(value);
      await tester.pump();
    }

    expect(primaryFocus, same(focused));
    expect(notifier.userHeight, closeTo(180.34, 0.01));
    expect(heightText(tester), "5'11");
  });

  testWidgets('switching the height unit reformats the field', (
    WidgetTester tester,
  ) async {
    notifier.heightUnit = TraleUnitHeight.metric;
    notifier.userHeight = 180;
    await pumpGroup(tester);

    expect(heightText(tester), '180');

    notifier.heightUnit = TraleUnitHeight.imperial;
    await tester.pump();

    expect(heightText(tester), '''5'11"''');
  });

  testWidgets('typing a name does not disturb the height field', (
    WidgetTester tester,
  ) async {
    notifier.heightUnit = TraleUnitHeight.metric;
    notifier.userHeight = 180;
    await pumpGroup(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Alice');
    await tester.pump();

    expect(notifier.userName, 'Alice');
    expect(heightText(tester), '180');
  });
}
