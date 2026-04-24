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

  /// Waits for the app to fully reach the Home screen (NavigationBar visible).
  ///
  /// `pumpAndSettle()` alone is insufficient here because the Splash screen
  /// awaits Hive I/O on a platform channel.  While that I/O is in flight the
  /// Flutter frame pipeline is idle, so `pumpAndSettle` returns "settled"
  /// before the navigation to Home has occurred.  Instead we poll by pumping
  /// small increments and checking for the NavigationBar on each iteration.
  Future<void> waitForApp(WidgetTester tester) async {
    const Duration pollInterval = Duration(milliseconds: 200);
    const Duration timeout = Duration(seconds: 30);
    final DateTime deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(pollInterval);
      if (find.byType(NavigationBar).evaluate().isNotEmpty) {
        return;
      }
    }
  }

  bool _surfaceConverted = false;

  /// Takes a named PNG screenshot via the test driver.
  ///
  /// [convertFlutterSurfaceToImage] must be called exactly once before the
  /// first [takeScreenshot] call when running under `flutter drive`.
  Future<void> screenshot(WidgetTester tester, String name) async {
    if (!_surfaceConverted) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();
      _surfaceConverted = true;
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
      await waitForApp(tester);
      // Allow addPostFrameCallback in Home.initState to fire.  That callback
      // shows the first-launch changelog ModalBottomSheet when the app was
      // freshly installed (lastBuildNumber == 0 on a clean CI emulator).
      // Use a bounded pump instead of pumpAndSettle: the home screen has
      // ongoing animations (chart, etc.) that never fully settle.
      await tester.pump(const Duration(milliseconds: 500));

      // Dismiss the changelog bottom sheet if it was shown on first launch.
      // The sheet snaps to 50 % of screen height, so tapping at y=50 hits
      // the modal barrier above it and closes the sheet.
      if (find.byType(BottomSheet).evaluate().isNotEmpty) {
        await tester.tapAt(const Offset(200, 50));
        await tester.pump(const Duration(milliseconds: 500));
      }

      // ── 1. Home screen ─────────────────────────────────────────────────
      // The NavigationBar at the bottom is the structural landmark we key on.
      expect(find.byType(NavigationBar), findsOneWidget);

      // ── 2. Count measurements before adding ─────────────────────────────
      // Navigate to Measurements tab to capture the current count so we can
      // verify +1 after the insert.
      await tester.tap(find.text('Measurements'));
      await tester.pump(const Duration(milliseconds: 500));
      final int countBefore = find.byType(WeightListTile).evaluate().length;

      // Return to Home before opening the FAB dialog.
      await tester.tap(find.text('Home'));
      await tester.pump(const Duration(milliseconds: 500));

      // ── 3. Open the add-weight dialog ───────────────────────────────────
      // The FAB tooltip matches l10n.addWeight ("Enter your weight" in EN).
      final Finder fab = find.byTooltip('Enter your weight');
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pump(const Duration(milliseconds: 500));

      // Verify the dialog opened: title and Save button visible.
      expect(find.text('Enter your weight'), findsAtLeastNWidgets(1));
      expect(find.text('Save'), findsOneWidget);

      // ── 4. Save the default weight ──────────────────────────────────────
      // Tapping Save inserts a measurement and always closes the dialog
      // (Navigator.pop(context, wasInserted) is always called).
      await tester.tap(find.text('Save'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(NavigationBar), findsOneWidget);

      // ── 5. Verify measurement appeared in the list ──────────────────────
      await tester.tap(find.text('Measurements'));
      await tester.pump(const Duration(milliseconds: 500));

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
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(NavigationBar), findsOneWidget);

      // ── Screenshots ────────────────────────────────────────────────────
      // IMPORTANT: convertFlutterSurfaceToImage() (called on the first
      // screenshot) adds an IgnorePointer to the root widget tree, which
      // breaks all subsequent pointer events.  Screenshots must therefore be
      // taken AFTER all interactions and assertions are complete.
      // We are currently on the Achievements tab; capture it first, then
      // navigate to the remaining tabs for their screenshots.
      await screenshot(tester, '03_achievements_tab');

      await tester.tap(find.text('Measurements'));
      await tester.pump(const Duration(milliseconds: 500));
      await screenshot(tester, '04_measurements_tab');

      await tester.tap(find.text('Home'));
      await tester.pump(const Duration(milliseconds: 500));
      await screenshot(tester, '05_home_tab');
    });
  });
}
