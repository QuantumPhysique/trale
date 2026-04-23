import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/measurement_stats.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Per-test singleton injection
// ---------------------------------------------------------------------------

/// Injects mock singletons and returns a fresh [TraleNotifier].
///
/// Call from [setUp]; call [resetWidgetTestDependencies] in [tearDown].
///
/// Optional [measurements] are backed by an in-memory list so that widgets
/// reading [MeasurementDatabase] see the expected data — no Hive required.
Future<TraleNotifier> setUpWidgetTestDependencies({
  List<Measurement> measurements = const <Measurement>[],
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences mockPrefs = await SharedPreferences.getInstance();
  final Preferences testPrefs = Preferences.forTesting(mockPrefs);
  Preferences.testInstance = testPrefs;

  MeasurementDatabase.testInstance = MeasurementDatabase.forTestingWithData(
    measurements,
  );
  // Reset derived singletons so they pick up the new DB instance.
  MeasurementInterpolation.resetInstance();
  MeasurementStats.resetInstance();

  return TraleNotifier();
}

/// Cleans up all widget-test singletons without touching Hive.
///
/// Call from [tearDown] instead of [ServiceLocator.reset].
void resetWidgetTestDependencies() {
  // Put an empty in-memory DB in place BEFORE resetting interpolation so that
  // its constructor-time init() call never falls through to a real Hive box.
  MeasurementDatabase.testInstance = MeasurementDatabase.forTestingWithData();
  MeasurementInterpolation.resetInstance();
  MeasurementStats.resetInstance();
  Preferences.resetInstance();
  MeasurementDatabase.resetInstance();
}

// ---------------------------------------------------------------------------
// Pump helpers
// ---------------------------------------------------------------------------

/// Builds the first frame, then advances the fake clock in two passes to
/// handle cascading timer creation.
///
/// **Pass 1** (`pump(drainDuration)`): fires all first-wave timers (animation
/// delays, banner timer, `_weightLostDelayTimer`, etc.) and renders the
/// resulting frame.  Newly mounted widgets (e.g. weight-lost card) may create
/// zero-duration timers *during* this frame; those are not yet fired.
///
/// **Pass 2** (`pump(drainDuration)`): fires those cascaded zero-duration
/// timers and advances past any new animations they start.
///
/// A final `pump()` flushes post-frame callbacks.
///
/// The default `drainDuration` of 5 s is longer than any known first-wave
/// timer in the app (longest: StatsScreen banner at 3 s).
///
/// NOTE: `pumpAndSettle` is intentionally NOT used. The stats/overview screens
/// contain a `StreamBuilder`/`Provider` that keeps scheduling frames, so
/// `pumpAndSettle` would never converge.
Future<void> pumpUntilSettled(
  WidgetTester tester, {
  Duration drainDuration = const Duration(seconds: 5),
}) async {
  await tester.pump(); // initial build
  await tester.pump(drainDuration); // first-wave timers
  await tester.pump(drainDuration); // second-wave (cascade) timers
  await tester.pump(); // flush post-frame callbacks
}

// ---------------------------------------------------------------------------
// Widget wrapper
// ---------------------------------------------------------------------------

/// Wraps [child] in a [MaterialApp] with [notifier] in the Provider tree and
/// English localizations.
Widget buildTestApp({required Widget child, required TraleNotifier notifier}) {
  return ChangeNotifierProvider<TraleNotifier>.value(
    value: notifier,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}
