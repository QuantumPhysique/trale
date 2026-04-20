import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/backup_interval.dart';
import 'package:trale/core/first_day.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/measurement_stats.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/print_format.dart';
import 'package:trale/core/stats_range.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/unit_precision.dart';
import 'package:trale/core/units.dart';
import 'package:trale/core/zoom_level.dart';

part 'trale_notifier/theme_state.dart';
part 'trale_notifier/user_state.dart';
part 'trale_notifier/stats_state.dart';
part 'trale_notifier/backup_state.dart';
part 'trale_notifier/reminder_state.dart';
part 'trale_notifier/ui_state.dart';

/// App-level ChangeNotifier extending [QPNotifier] with trale-specific state.
class TraleNotifier extends QPNotifier {
  /// Creates the notifier, initialising [QPNotifier] with [Preferences].
  TraleNotifier() : super(Preferences());

  /// Typed access to trale's own [Preferences] subclass.
  Preferences get _prefs => prefs as Preferences;

  @override
  Color get seedColor {
    final TraleCustomTheme t =
        _prefs.themeName.toTraleCustomTheme() ?? TraleCustomTheme.water;
    return t == TraleCustomTheme.system ? systemSeedColor : t.seed;
  }

  @override
  Future<void> factoryReset() async {
    await super.factoryReset();
    await MeasurementDatabase().deleteAllMeasurements();
  }
}
