part of '../trale_notifier.dart';

/// Extension on [TraleNotifier] holding stats and date-format state.
///
/// [dateFormat], [dayFormat], [datePrintFormat] are delegated to
/// [QPDisplayStateExtension] on [QPNotifier].
extension StatsStateExtension on TraleNotifier {
  // ── Delegates to QPDisplayStateExtension ─────────────────────────────────

  /// Returns a locale-aware [DateFormat] for full dates.
  DateFormat dateFormat(BuildContext context) {
    final QPNotifier n = this;
    return n.dateFormat(context);
  }

  /// Returns a locale-aware [DateFormat] for day/month display.
  DateFormat dayFormat(BuildContext context) {
    final QPNotifier n = this;
    return n.dayFormat(context);
  }

  /// Current date print format preference.
  TraleDatePrintFormat get datePrintFormat {
    final QPNotifier n = this;
    return n.datePrintFormat;
  }

  /// Sets the date print format preference.
  set datePrintFormat(TraleDatePrintFormat value) {
    final QPNotifier n = this;
    n.datePrintFormat = value;
  }

  // ── Trale-specific stats state ────────────────────────────────────────────

  /// getter for stats range from date used for StatsRange.custom
  DateTime? get statsRangeFrom => _prefs.statsRangeFrom;

  /// setter for stats range from date used for StatsRange.custom
  set statsRangeFrom(DateTime? newDate) {
    if (statsRangeFrom != newDate) {
      _prefs.statsRangeFrom = newDate;
      MeasurementStats().reinit();
      notify;
    }
  }

  /// getter for stats range to date used for StatsRange.custom
  DateTime? get statsRangeTo => _prefs.statsRangeTo;

  /// setter for stats range to date used for StatsRange.custom
  set statsRangeTo(DateTime? newDate) {
    if (statsRangeTo != newDate) {
      _prefs.statsRangeTo = newDate;
      MeasurementStats().reinit();
      notify;
    }
  }

  /// getter for stats range mode
  StatsRange get statsRange => _prefs.statsRange;

  /// setter for stats range mode
  set statsRange(StatsRange newRange) {
    if (statsRange != newRange) {
      _prefs.statsRange = newRange;
      MeasurementStats().reinit();
      notify;
    }
  }

  /// getter for stats use interpolation
  bool get statsUseInterpolation => _prefs.statsUseInterpolation;

  /// setter for stats use interpolation
  set statsUseInterpolation(bool useInterpolation) {
    if (statsUseInterpolation != useInterpolation) {
      _prefs.statsUseInterpolation = useInterpolation;
      MeasurementStats().reinit();
      notify;
    }
  }
}
