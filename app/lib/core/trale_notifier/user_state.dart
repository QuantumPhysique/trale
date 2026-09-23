part of '../trale_notifier.dart';

/// Extension on [TraleNotifier] holding user body and weight state.
///
/// [firstDay] is delegated to [QPDisplayStateExtension] on [QPNotifier].
extension UserStateExtension on TraleNotifier {
  // ── Delegate to QPDisplayStateExtension ───────────────────────────────────

  /// Current first day of week preference.
  TraleFirstDay get firstDay {
    final QPNotifier n = this;
    return n.firstDay;
  }

  /// Sets the first day of week.
  set firstDay(TraleFirstDay value) {
    final QPNotifier n = this;
    n.firstDay = value;
  }

  // ── Trale-specific user state ─────────────────────────────────────────────

  /// getter
  TraleUnit get unit => _prefs.unit;

  /// setter
  set unit(TraleUnit newUnit) {
    if (unit != newUnit) {
      _prefs.unit = newUnit;
      notify;
    }
  }

  /// getter
  TraleUnitHeight get heightUnit => _prefs.heightUnit;

  /// setter
  set heightUnit(TraleUnitHeight newHeightUnit) {
    if (heightUnit != newHeightUnit) {
      _prefs.heightUnit = newHeightUnit;
      notify;
    }
  }

  /// getter
  TraleUnitPrecision get unitPrecision => _prefs.unitPrecision;

  /// setter
  set unitPrecision(TraleUnitPrecision newPrecision) {
    if (unitPrecision != newPrecision) {
      _prefs.unitPrecision = newPrecision;
      notify;
    }
  }

  /// getter
  String get userName => _prefs.userName;

  /// setter
  set userName(String newName) {
    if (userName != newName) {
      _prefs.userName = newName;
      notify;
    }
  }

  /// getter for target weight enabled
  bool get targetWeightEnabled => _prefs.targetWeightEnabled;

  /// setter for target weight enabled
  set targetWeightEnabled(bool enabled) {
    if (enabled != targetWeightEnabled) {
      _prefs.targetWeightEnabled = enabled;
      notify;
    }
  }

  /// getter – returns target weight only when the feature is enabled
  double? get effectiveTargetWeight =>
      targetWeightEnabled ? _prefs.userTargetWeight : null;

  /// getter
  double? get userTargetWeight => _prefs.userTargetWeight;

  /// setter
  set userTargetWeight(double? newWeight) {
    if (userTargetWeight != newWeight) {
      _prefs.userTargetWeight = newWeight;
      notify;
    }
  }

  /// getter
  WeightGoal get weightGoal => _prefs.weightGoal;

  /// setter
  set weightGoal(WeightGoal newGoal) {
    if (weightGoal != newGoal) {
      _prefs.weightGoal = newGoal;
      notify;
    }
  }

  /// getter for the tolerance in kg around the target of the maintain goal.
  /// Until one is saved it follows the default of the unit.
  double get targetWeightTolerance =>
      _prefs.targetWeightTolerance ?? unit.defaultTargetWeightTolerance;

  /// setter for the tolerance in kg around the target of the maintain goal
  set targetWeightTolerance(double newTolerance) {
    if (_prefs.targetWeightTolerance != newTolerance) {
      _prefs.targetWeightTolerance = newTolerance;
      notify;
    }
  }

  /// getter for the weights counting as on target, only when enabled
  TargetRange? get effectiveTargetRange {
    final double? targetWeight = effectiveTargetWeight;
    return targetWeight != null
        ? weightGoal.range(targetWeight, targetWeightTolerance)
        : null;
  }

  /// getter for the target date, only when enabled and the goal has one.
  /// The maintain goal keeps a stored date for switching back.
  DateTime? get effectiveTargetWeightDate =>
      targetWeightEnabled && weightGoal != WeightGoal.maintain
      ? userTargetWeightDate
      : null;

  /// getter for target weight date
  DateTime? get userTargetWeightDate => _prefs.userTargetWeightDate;

  /// setter for target weight date
  set userTargetWeightDate(DateTime? newDate) {
    if (userTargetWeightDate != newDate) {
      _prefs.userTargetWeightDate = newDate;
      notify;
    }
  }

  /// getter for date when target weight was set.
  /// Returns null if the stored date has no measurement (e.g. it was deleted).
  DateTime? get userTargetWeightSetDate {
    final DateTime? date = _prefs.userTargetWeightSetDate;
    if (date == null) {
      return null;
    }
    return MeasurementInterpolation().hasMeasurementOnDay(date) ? date : null;
  }

  /// setter for date when target weight was set
  set userTargetWeightSetDate(DateTime? newDate) {
    if (userTargetWeightSetDate != newDate) {
      _prefs.userTargetWeightSetDate = newDate;
      notify;
    }
  }

  /// getter for weight at time of setting target weight (in kg).
  /// Dynamically looks up the measurement on [userTargetWeightSetDate].
  /// Returns null if no set date or no measurement on that day.
  double? get userTargetWeightSetWeight {
    final DateTime? date = userTargetWeightSetDate;
    if (date == null) {
      return null;
    }
    return MeasurementInterpolation().measurementForDay(date);
  }

  /// get user height in [cm]
  double? get userHeight => _prefs.userHeight;

  /// set user height in [cm]
  set userHeight(double? newHeight) {
    if (userHeight != newHeight) {
      _prefs.userHeight = newHeight;
      notify;
    }
  }

  /// getter
  InterpolStrength get interpolStrength => _prefs.interpolStrength;

  /// setter
  set interpolStrength(InterpolStrength strength) {
    if (interpolStrength != strength) {
      _prefs.interpolStrength = strength;
      MeasurementDatabase().reinit();
      notify;
    }
  }

  /// getter
  bool get healthConnectEnabled => _prefs.healthConnectEnabled;

  /// setter
  set healthConnectEnabled(bool enabled) {
    if (healthConnectEnabled != enabled) {
      _prefs.healthConnectEnabled = enabled;
      notify;
    }
  }

  /// getter
  bool get healthConnectImportEnabled => _prefs.healthConnectImportEnabled;

  /// setter
  set healthConnectImportEnabled(bool enabled) {
    if (healthConnectImportEnabled != enabled) {
      _prefs.healthConnectImportEnabled = enabled;
      // The first full-history import runs from the settings page instead of
      // here: it has to ask for the history permission and report what it got,
      // and neither belongs in a setter.
      notify;
    }
  }

  /// getter
  bool get healthConnectExportEnabled => _prefs.healthConnectExportEnabled;

  /// setter
  set healthConnectExportEnabled(bool enabled) {
    if (healthConnectExportEnabled != enabled) {
      _prefs.healthConnectExportEnabled = enabled;
      notify;
    }
  }
}
