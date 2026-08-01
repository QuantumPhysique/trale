// Screenshot tour: captures every marketing screen across a set of themes in
// both light and dark mode.  Each theme is fronted by its own demo persona
// (see screenshot_data.dart) so the shots cover losing, keeping and gaining
// weight rather than four recolourings of the same curve.
//
// Run via `make screenshots` (from app/), or directly:
//   flutter drive \
//     --driver=test_driver/screenshot_driver.dart \
//     --target=integration_test/screenshots_test.dart \
//     --device-id=<device-id> \
//     --dart-define=SCREENSHOT_THEMES=water,berry,forest,amber
//
// PNGs land in the repo-root screenshots/ directory as
// `<theme>/<light|dark>/<NN_screen>.png`; the driver turns the slashes in each
// screenshot name into directories.
//
// NOTE ON POINTER EVENTS:
//   binding.convertFlutterSurfaceToImage() is one-way inside a single
//   testWidgets body — the binding only reverts it in its own tearDown — and it
//   breaks subsequent taps (see integration_test/smoke_test.dart).  This tour
//   therefore never taps: themes are switched through TraleNotifier, tabs
//   through the shared TabController, and every page and dialog is opened by
//   calling Navigator/showDialog directly.
//
// The cached Home BuildContext is used deliberately across the whole tour: the
// Element stays mounted for the entire run, so the async-gap lint does not
// apply here.
// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/main.dart' as app;
import 'package:trale/pages/settings_overview.dart';
import 'package:trale/pages/settings_personalization.dart';
import 'package:trale/pages/settings_reminder.dart';
import 'package:trale/pages/settings_theme.dart';
import 'package:trale/widget/add_weight_dialog.dart';
import 'package:trale/widget/user_dialog.dart';

import 'screenshot_data.dart';

/// Comma-separated palette names to sweep, overridable with
/// `--dart-define=SCREENSHOT_THEMES=...`.
///
/// [QPCustomTheme.system] is deliberately not a sensible entry: it resolves to
/// the device's dynamic colour (or black), which is not reproducible.
const String _themeNames = String.fromEnvironment(
  'SCREENSHOT_THEMES',
  defaultValue: 'water,berry,forest,amber',
);

/// Parses [_themeNames], skipping unknown entries.
List<QPCustomTheme> _parseThemes() {
  final List<QPCustomTheme> themes = <QPCustomTheme>[];
  for (final String name in _themeNames.split(',')) {
    final QPCustomTheme? theme = name.trim().toQPCustomTheme();
    if (theme != null && theme != QPCustomTheme.system) {
      themes.add(theme);
    }
  }
  return themes.isEmpty ? <QPCustomTheme>[QPCustomTheme.water] : themes;
}

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final List<QPCustomTheme> themes = _parseThemes();

  /// Waits for the app to fully reach the Home screen (NavigationBar visible).
  ///
  /// `pumpAndSettle()` is unusable here: the Splash screen awaits Hive I/O on a
  /// platform channel (the frame pipeline is idle meanwhile, so pumpAndSettle
  /// returns early) and the Home screen never settles because of the chart
  /// animations.
  Future<void> waitForApp(WidgetTester tester) async {
    const Duration pollInterval = Duration(milliseconds: 200);
    const Duration timeout = Duration(seconds: 60);
    final DateTime deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(pollInterval);
      if (find.byType(NavigationBar).evaluate().isNotEmpty) {
        return;
      }
    }
  }

  testWidgets(
    'capture screenshots for every theme in light and dark',
    (WidgetTester tester) async {
      // Must happen before app.main(): Preferences() is constructed as part of
      // TraleNotifier() inside runApp().  This swaps in an in-memory store, so
      // the run is reproducible and the device's real settings stay untouched.
      SharedPreferences.setMockInitialValues(
        demoPrefs(
          persona: demoPersonas.first,
          themeName: themes.first.name,
          nightMode: 'off',
        ),
      );

      app.main();
      await waitForApp(tester);
      await tester.pump(const Duration(seconds: 5));

      // Belt and braces: the changelog sheet should be suppressed by
      // qp_showChangelog/qp_lastBuildNumber, but taps still work at this point.
      if (find.byType(BottomSheet).evaluate().isNotEmpty) {
        await tester.tapAt(const Offset(200, 50));
        await tester.pump(const Duration(seconds: 3));
      }

      // Cache the handles the tour drives.  Both survive theme rebuilds: the
      // Element identity is stable and QPHomePage keeps its TabController in a
      // `late final` State field.
      final BuildContext ctx = tester.element(find.byType(QPHomePage));
      final TraleNotifier notifier = Provider.of<TraleNotifier>(
        ctx,
        listen: false,
      );
      final TabController tabs = tester
          .widget<TabBarView>(find.byType(TabBarView))
          .controller!;

      /// Replaces the database content and user profile with [persona]'s.
      ///
      /// insertMeasurementList dedups, inserts in bulk and calls reinit() once
      /// — unlike insertMeasurement it triggers no notification or Health
      /// Connect side effects.  The target weight has to be applied after
      /// seeding: the set-date getter returns null unless that day actually
      /// carries a measurement, and the chart only draws its three-segment
      /// target ramp when it resolves.
      Future<void> applyPersona(DemoPersona persona) async {
        final List<Measurement> demo = persona.measurements();
        await MeasurementDatabase().deleteAllMeasurements();
        await MeasurementDatabase().insertMeasurementList(demo);
        await tester.pump(const Duration(seconds: 5));

        notifier
          ..userName = persona.name
          ..userHeight = persona.height
          ..looseWeight = persona.losesWeight
          ..targetWeightEnabled = true
          ..userTargetWeight = persona.targetWeight
          ..userTargetWeightDate = persona.targetDate()
          ..userTargetWeightSetDate = persona.targetSetDate(demo);
        await tester.pump(const Duration(seconds: 5));
      }

      await applyPersona(demoPersonas.first);

      /// Runs [action], lets the engine free-run for [wait], then repaints.
      ///
      /// Two frame sources have to be combined here:
      ///  * Entrance animations only advance while the real vsync drives the
      ///    pipeline, which is what [WidgetTester.runAsync] restores — under
      ///    plain `tester.pump()` they stay stuck at opacity 0.
      ///  * Only framework-driven pumps composite a new frame into the
      ///    FlutterImageView that `convertFlutterSurfaceToImage` installs;
      ///    without them every screenshot returns the same stale image.
      Future<void> live(Duration wait, [VoidCallback? action]) async {
        await tester.runAsync(() async {
          action?.call();
          await Future<void>.delayed(wait);
        });
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump(const Duration(milliseconds: 250));
      }

      // Warm-up sweep over all three tabs.
      //
      // A tab's entrance animations (QPAnimateInEffect, bento cards) start on
      // a ticker that is still muted when the page is first mounted, and only
      // resume once the tab has been left again — so a tab captured on its
      // very first visit comes out blank.  Mounting each tab once here means
      // every capture below is a second visit, with the animations already
      // resolved.
      for (final int i in <int>[1, 2, 0]) {
        await live(const Duration(seconds: 3), () => tabs.animateTo(i));
      }

      // From here on: no taps (see the note at the top of this file).
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();

      /// Settles the UI as far as it will go, then captures [name].
      Future<void> shoot(String name) async {
        await live(const Duration(seconds: 1));
        await binding.takeScreenshot(name);
      }

      /// Switches to the home tab at [index] and captures it.
      ///
      /// Uses animateTo rather than assigning `index`: the tab content relies
      /// on the TabController animation sweeping through intermediate values
      /// to trigger its entrance animations, which an instant jump skips.
      Future<void> captureTab(String name, int index) async {
        await live(const Duration(seconds: 3), () => tabs.animateTo(index));
        await shoot(name);
      }

      /// Pushes [page], captures it, then pops back to Home.
      Future<void> capturePage(String name, Widget page) async {
        await live(
          const Duration(seconds: 3),
          () => unawaited(
            Navigator.of(
              ctx,
            ).push<void>(MaterialPageRoute<void>(builder: (_) => page)),
          ),
        );
        await shoot(name);
        await live(const Duration(seconds: 2), () => Navigator.of(ctx).pop());
      }

      /// Opens a dialog via [open], captures it, then dismisses it.
      ///
      /// Both dialogs are shown with the default `useRootNavigator: true` and
      /// are popped with `false` so no measurement is written.
      Future<void> captureDialog(
        String name,
        Future<bool> Function() open,
      ) async {
        await live(const Duration(seconds: 3), () => unawaited(open()));
        await shoot(name);
        await live(
          const Duration(seconds: 2),
          () => Navigator.of(ctx, rootNavigator: true).pop(false),
        );
      }

      for (int i = 0; i < themes.length; i++) {
        final QPCustomTheme theme = themes[i];

        // Each theme gets its own persona, cycling when more themes than
        // personas are requested.  Re-applying the first persona on the first
        // pass is redundant but keeps every iteration identical.
        await applyPersona(demoPersonas[i % demoPersonas.length]);

        for (final ThemeMode mode in <ThemeMode>[
          ThemeMode.light,
          ThemeMode.dark,
        ]) {
          await live(const Duration(seconds: 3), () {
            notifier.theme = theme;
            notifier.themeMode = mode;
          });

          final String dir =
              '${theme.name}/${mode == ThemeMode.dark ? 'dark' : 'light'}';

          await captureTab('$dir/01_home', 0);
          await captureTab('$dir/02_stats', 1);
          await captureTab('$dir/03_measurements', 2);

          // Dialogs and settings pages are opened from the Home tab.
          await live(const Duration(seconds: 2), () => tabs.animateTo(0));

          await captureDialog(
            '$dir/04_add_weight',
            () => showAddWeightDialog(
              context: ctx,
              weight: MeasurementDatabase().latestMeasurement.weight,
              date: DateTime.now(),
            ),
          );
          await captureDialog(
            '$dir/05_user',
            () => showUserDialog(context: ctx),
          );

          await capturePage('$dir/06_settings', const SettingsOverviewPage());
          await capturePage('$dir/07_theme', const ThemeSettingsPage());
          await capturePage(
            '$dir/08_personalization',
            const PersonalizationSettingsPage(),
          );
          await capturePage('$dir/09_reminder', const ReminderSettingsPage());
        }
      }
    },
    timeout: const Timeout(Duration(minutes: 45)),
  );
}
