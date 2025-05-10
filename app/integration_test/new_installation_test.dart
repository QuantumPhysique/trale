import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trale/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Onboarding and add measurement', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Go through onboarding screens
    for (int i = 0; i < 3; i++) { // Adjust for your onboarding steps
      final Finder nextButton = find.text('Next');
      if (await tester.pumpAndSettle() > 0 && tester.any(nextButton)) {
        await tester.tap(nextButton);
        await tester.pumpAndSettle();
      }
    }
    final Finder doneButton = find.text('Done');
    if (tester.any(doneButton)) {
      await tester.tap(doneButton);
      await tester.pumpAndSettle();
    }

    // Add a measurement
    final Finder addButton = find.byIcon(PhosphorIconsRegular.plus);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    final Finder saveButton = find.byIcon(PhosphorIconsRegular.floppyDiskBack);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // go to measurement tab
    final Finder measurementTabButton = find.byIcon(PhosphorIconsDuotone.archive);
    await tester.tap(measurementTabButton);
    await tester.pumpAndSettle();

    // Check if measurement appears
    expect(find.text('70'), findsOneWidget);
  });
}