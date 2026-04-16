import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/measurement_stats.dart';
import 'package:trale/core/preferences.dart';

/// Lightweight service locator that centralises access to app singletons.
///
/// ### Production
/// All singletons initialise themselves lazily on first access.  The
/// canonical initialisation order (enforced in `main.dart`) is:
///   1. [Preferences]
///   2. [MeasurementDatabase]
///   3. [MeasurementInterpolation]
///   4. [MeasurementStats]
///
/// ### Testing
/// In `setUp`, call [registerForTesting] to inject fakes for only the
/// singletons your test cares about.  In `tearDown`, call [reset] to
/// restore the default production instances.
///
/// ```dart
/// setUp(() {
///   ServiceLocator.registerForTesting(prefs: myFakePrefs);
/// });
/// tearDown(ServiceLocator.reset);
/// ```
class ServiceLocator {
  ServiceLocator._();

  /// Register test doubles for individual singletons.
  ///
  /// Any argument left `null` keeps the current singleton untouched.
  static void registerForTesting({
    Preferences? prefs,
    MeasurementDatabase? db,
    MeasurementInterpolation? interpolation,
    MeasurementStats? stats,
  }) {
    if (prefs != null) {
      Preferences.testInstance = prefs;
    }
    if (db != null) {
      MeasurementDatabase.testInstance = db;
    }
    if (interpolation != null) {
      MeasurementInterpolation.testInstance = interpolation;
    }
    if (stats != null) {
      MeasurementStats.testInstance = stats;
    }
  }

  /// Reset all singletons to their default production instances.
  static void reset() {
    Preferences.resetInstance();
    MeasurementDatabase.resetInstance();
    MeasurementInterpolation.resetInstance();
    MeasurementStats.resetInstance();
  }
}
