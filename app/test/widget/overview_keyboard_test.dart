import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/pages/overview.dart';

import '../helpers/widget_test_helper.dart';

// The overview tab sizes itself to the viewport, so it cannot survive being
// squeezed. Dialogs opening the software keyboard on top of the home page
// used to do exactly that, which is why the home scaffold sets
// `resizeToAvoidBottomInset: false` — mirrored by the scaffold below.
void main() {
  late TraleNotifier notifier;

  setUp(() async {
    notifier = await setUpWidgetTestDependencies(
      measurements: <Measurement>[
        Measurement(weight: 80, date: DateTime(2026, 8, 1)),
        Measurement(weight: 79.5, date: DateTime(2026, 8, 8)),
        Measurement(weight: 79, date: DateTime(2026, 8, 15)),
      ],
    );
  });

  tearDown(resetWidgetTestDependencies);

  testWidgets('overview is not squeezed by the software keyboard', (
    WidgetTester tester,
  ) async {
    // At test font metrics the stats cards wobble a few pixels horizontally,
    // which has nothing to do with what this test guards. Tolerate exactly
    // that and keep failing on everything else, rather than swallowing every
    // error the frame produces.
    final List<FlutterErrorDetails> caught = <FlutterErrorDetails>[];
    final FlutterExceptionHandler? previousOnError = FlutterError.onError;
    FlutterError.onError = caught.add;
    addTearDown(() => FlutterError.onError = previousOnError);

    bool isHorizontalOverflow(FlutterErrorDetails details) {
      final String message = details.exceptionAsString();
      return message.contains('overflowed') &&
          (message.contains('on the right') || message.contains('on the left'));
    }

    List<String> unexpectedErrors() => caught
        .where((FlutterErrorDetails d) => !isHorizontalOverflow(d))
        .map((FlutterErrorDetails d) => d.exceptionAsString())
        .toList();

    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360 * 3, 780 * 3);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<TraleNotifier>.value(
        value: notifier,
        child: ChangeNotifierProvider<QPNotifier?>.value(
          value: notifier,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              resizeToAvoidBottomInset: false,
              body: OverviewScreen(),
            ),
          ),
        ),
      ),
    );
    await pumpUntilSettled(tester);
    expect(unexpectedErrors(), isEmpty);

    final double heightWithoutKeyboard = tester
        .getSize(find.byType(OverviewScreen))
        .height;

    tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 3);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The invariant: the keyboard must not take any height away from the
    // body. A shrinking body used to overflow the overview column instead.
    expect(
      tester.getSize(find.byType(OverviewScreen)).height,
      heightWithoutKeyboard,
    );
    expect(unexpectedErrors(), isEmpty);
  });
}
