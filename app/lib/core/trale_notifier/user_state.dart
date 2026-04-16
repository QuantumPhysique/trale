part of '../trale_notifier.dart';

/// Extension on [TraleNotifier] holding user body and weight state.
extension UserStateExtension on TraleNotifier {
  /// getter
  TraleUnit get unit => prefs.unit;

  /// setter
  set unit(TraleUnit newUnit) {
    if (unit != newUnit) {
      prefs.unit = newUnit;
      notify;
    }
  }

  /// getter
  TraleUnitHeight get heightUnit => prefs.heightUnit;

  /// setter
  set heightUnit(TraleUnitHeight newHeightUnit) {
    if (heightUnit != newHeightUnit) {
      prefs.heightUnit = newHeightUnit;
      notify;
    }
  }

  /// getter
  TraleUnitPrecision get unitPrecision => prefs.unitPrecision;

  /// setter
  set unitPrecision(TraleUnitPrecision newPrecision) {
    if (unitPrecision != newPrecision) {
      prefs.unitPrecision = newPrecision;
      notify;
    }
  }

  /// getter
  String get userName => prefs.userName;

  /// setter
  set userName(String newName) {
    if (userName != newName) {
      prefs.userName = newName;
      notify;
    }
  }

  /// getter for target weight enabled
  bool get targetWeightEnabled => prefs.targetWeightEnabled;

  /// setter for target weight enabled
  set targetWeightEnabled(bool enabled) {
    if (enabled != targetWeightEnabled) {
      prefs.targetWeightEnabled = enabled;
      notify;
    }
  }

  /// getter – returns target weight only when the feature is enabled
  double? get effectiveTargetWeight =>
      targetWeightEnabled ? prefs.userTargetWeight : null;

  /// getter
  double? get userTargetWeight => prefs.userTargetWeight;

  /// setter
  set userTargetWeight(double? newWeight) {
    if (userTargetWeight != newWeight) {
      prefs.userTargetWeight = newWeight;
      notify;
    }
  }

  /// getter for target weight date
  DateTime? get userTargetWeightDate => prefs.userTargetWeightDate;

  /// setter for target weight date
  set userTargetWeightDate(DateTime? newDate) {
    if (userTargetWeightDate != newDate) {
      prefs.userTargetWeightDate = newDate;
      notify;
    }
  }

  /// getter for date when target weight was set.
  /// Returns null if the stored date has no measurement (e.g. it was deleted).
  DateTime? get userTargetWeightSetDate {
    final DateTime? date = prefs.userTargetWeightSetDate;
    if (date == null) {
      return null;
    }
    return MeasurementInterpolation().hasMeasurementOnDay(date) ? date : null;
  }

  /// setter for date when target weight was set
  set userTargetWeightSetDate(DateTime? newDate) {
    if (userTargetWeightSetDate != newDate) {
      prefs.userTargetWeightSetDate = newDate;
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
  double? get userHeight => prefs.userHeight;

  /// set user height in [cm]
  set userHeight(double? newHeight) {
    if (userHeight != newHeight) {
      prefs.userHeight = newHeight;
      notify;
    }
  }

  /// getter
  InterpolStrength get interpolStrength => prefs.interpolStrength;

  /// setter
  set interpolStrength(InterpolStrength strength) {
    if (interpolStrength != strength) {
      prefs.interpolStrength = strength;
      MeasurementDatabase().reinit();
      notify;
    }
  }

  /// getter
  TraleFirstDay get firstDay => prefs.firstDay;

  /// setter
  set firstDay(TraleFirstDay newFirstDay) {
    if (firstDay != newFirstDay) {
      prefs.firstDay = newFirstDay;
      notify;
    }
  }

  /// getter
  bool get looseWeight => prefs.looseWeight;

  /// setter
  set looseWeight(bool loose) {
    if (loose != looseWeight) {
      prefs.looseWeight = loose;
      notify;
    }
  }
}
