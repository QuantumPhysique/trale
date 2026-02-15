// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

/// Extension for converting [Duration] to human-readable strings.
extension StringExtension on Duration {
  /// convert Duration to a string

  String durationToString(BuildContext context) {
    final int days = inDays;
    if (days == -1) {
      return '🥳';
    } else if (days < 28) {
      return '$days ${AppLocalizations.of(context)!.days}';
    } else if (days < 12 * 7) {
      final int weeks = (days / 7).round();
      return '$weeks ${AppLocalizations.of(context)!.weeks}';
    } else if (days <= 365 * 4) {
      final int months = (days / 30).round();
      return '$months ${AppLocalizations.of(context)!.months}';
    } else {
      final int years = (days / 365).round();
      return '$years ${AppLocalizations.of(context)!.years}';
    }
  }
}
