import 'package:material_ui/material_ui.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

/// Extension for converting [Duration] to human-readable strings.
extension StringExtension on Duration {
  /// convert Duration to a string

  String durationToString(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final int days = inDays;
    if (days == -1) {
      return '🥳';
    } else if (days < 28) {
      return '$days ${l10n.dayUnit(count: days)}';
    } else if (days < 12 * 7) {
      final int weeks = (days / 7).round();
      return '$weeks ${l10n.weekUnit(count: weeks)}';
    } else if (days <= 365 * 4) {
      final int months = (days / 30).round();
      return '$months ${l10n.monthUnit(count: months)}';
    } else {
      final int years = (days / 365).round();
      return '$years ${l10n.yearUnit(count: years)}';
    }
  }

  /// Converts duration to a streak string with optional label.
  String streakToStringDays(BuildContext context, {bool addLabel = true}) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final int days = inDays;
    if (!addLabel) {
      if (days == 0) {
        return '-';
      }
      return '$days';
    }
    return '$days ${l10n.dayUnit(count: days)}';
  }
}
