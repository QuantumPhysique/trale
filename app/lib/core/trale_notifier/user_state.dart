part of '../trale_notifier.dart';

/// Extension on [TraleNotifier] holding user body and weight state.
///
/// [firstDay] is delegated to [QPDisplayStateExtension] on [QPNotifier].
/// [looseWeight] has been moved to [UiStateExtension].
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
}
