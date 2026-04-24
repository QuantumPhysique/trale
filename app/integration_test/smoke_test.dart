// Integration tests: smoke flow on a real Android device or emulator.
//
// Run via flutter drive (from app/):
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/smoke_test.dart \
//     --device-id=<device-id>
//
// Screenshots are saved to app/screenshots/ by the driver and uploaded as
// CI artifacts so they can be inspected after each run.
//
// In CI the emulator is started by reactivecircus/android-emulator-runner with
// a fresh data partition, so Hive contains no prior measurements.
//
// NOTE ON REPRODUCIBILITY:
//   The "add measurement" test inserts a record with DateTime.now().  On the
//   CI emulator this is always a clean state.  The test does NOT mock the clock
//   because (a) integration tests run against the real app binary, and (b) each
//   CI run starts with a wiped emulator.  If you re-run on a real device with
//   existing data the test still passes: a new timestamp is used every time.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trale/main.dart' as app;
import 'package:trale/widget/weight_list_tile.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Polls the widget tree until [finder] finds at least one widget.
  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    const Duration pollInterval = Duration(milliseconds: 200);
    final DateTime deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump();
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      // Future.delayed is required in integration tests to yield real time
      await Future<void>.delayed(pollInterval);
    }
    throw StateError(
      'Timeout waiting for finder: ${finder.describeMatch(Plurality.one)}',
    );
  }

  /// Polls the widget tree until [finder] finds zero widgets.
  Future<void> waitForAbsent(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    const Duration pollInterval = Duration(milliseconds: 200);
    final DateTime deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump();
      if (finder.evaluate().isEmpty) {
        return;
      }
      await Future<void>.delayed(pollInterval);
    }
    throw StateError(
      'Timeout waiting for finder to disappear: '
      '${finder.describeMatch(Plurality.one)}',
    );
  }

  bool surfaceConverted = false;

  /// Takes a named PNG screenshot via the test driver.
  ///
  /// [convertFlutterSurfaceToImage] must be called exactly once before the
  /// first [takeScreenshot] call when running under `flutter drive`.
  Future<void> screenshot(WidgetTester tester, String name) async {
    if (!surfaceConverted) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();
      surfaceConverted = true;
    }
    await binding.takeScreenshot(name);
  }

  // -------------------------------------------------------------------------
  // Tests
  // -------------------------------------------------------------------------

  group('Smoke flow', () {
    // Each testWidgets in an integration test runs in the same isolate. Hive
    // is opened once by app.main() in the first test; subsequent tests reuse
    // the already-open box.  Therefore we run all steps in a single test to
    // keep the flow sequential and the state predictable.
    testWidgets('launch → add measurement → verify in list → navigate tabs', (
      WidgetTester tester,
    ) async {
      app.main();

      // Wait for the home screen to finish loading
      await waitFor(tester, find.byType(NavigationBar));

      // Wait briefly in case the first-launch ModalBottomSheet is animating in.
      // Because it might NOT appear on subsequent runs, we can't use waitFor
      // here.
      await Future<void>.delayed(const Duration(seconds: 2));
      await tester.pump();

      // Dismiss the changelog bottom sheet if it was shown on first launch.
      // The sheet snaps to 50 % of screen height, so tapping at y=50 hits
      // the modal barrier above it and closes the sheet.
      if (tester.any(find.byType(BottomSheet))) {
        await tester.tapAt(const Offset(200.0, 50.0));
        await waitForAbsent(tester, find.byType(BottomSheet));
      }

      // ── 1. Home screen ─────────────────────────────────────────────────
      expect(find.byType(NavigationBar), findsOneWidget);

      // ── 2. Count measurements before adding ─────────────────────────────
      // Navigate to Measurements tab to capture the current count so we can
      // verify +1 after the insert.
      await tester.tap(find.text('Measurements'));
      await waitFor(tester, find.byType(WeightListTile));

      final int countBefore = find.byType(WeightListTile).evaluate().length;

      // Return to Home before opening the FAB dialog.
      await tester.tap(find.text('Home'));
      await waitFor(tester, find.byTooltip('Enter your weight'));

      // ── 3. Open the add-weight dialog ───────────────────────────────────
      // The FAB tooltip matches l10n.addWeight ("Enter your weight" in EN).
      final Finder fab = find.byTooltip('Enter your weight');
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await waitFor(tester, find.text('Save'));

      // Verify the dialog opened: title and Save button visible.
      expect(find.text('Enter your weight'), findsAtLeastNWidgets(1));
      expect(find.text('Save'), findsOneWidget);

      // ── 4. Save the default weight ──────────────────────────────────────
      // Tapping Save inserts a measurement and always closes the dialog
      // (Navigator.pop(context, wasInserted) is always called).
      await tester.tap(find.text('Save'));
      await waitForAbsent(tester, find.text('Save'));

      expect(find.byType(NavigationBar), findsOneWidget);

      // ── 5. Verify measurement appeared in the list ──────────────────────
      await tester.tap(find.text('Measurements'));
      await waitFor(tester, find.byType(WeightListTile));

      // The list must have grown by exactly one entry.
      expect(
        find.byType(WeightListTile),
        findsNWidgets(countBefore + 1),
        reason:
            'A new WeightListTile should appear after inserting a '
            'measurement.',
      );

      // ── 6. Navigate to Achievements tab ─────────────────────────────────
      await tester.tap(find.text('Achievements'));
      await waitFor(tester, find.text('Achievements'));

      expect(find.byType(NavigationBar), findsOneWidget);

      // ── Screenshots ────────────────────────────────────────────────────
      // We use short fixed delays here just to let the visual page-slide
      // transitions settle completely before capturing the image.

      await Future<void>.delayed(const Duration(seconds: 2));
      await tester.pump();
      await screenshot(tester, '03_achievements_tab');

      await tester.tap(find.text('Measurements'));
      await Future<void>.delayed(const Duration(seconds: 2));
      await tester.pump();
      await screenshot(tester, '04_measurements_tab');

      await tester.tap(find.text('Home'));
      await Future<void>.delayed(const Duration(seconds: 2));
      await tester.pump();
      await screenshot(tester, '05_home_tab');
    });
  });
}
