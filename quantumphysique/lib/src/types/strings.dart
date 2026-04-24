/// All user-visible strings owned by the QP package.
library;

import 'package:flutter/foundation.dart';

/// An immutable bag of all user-visible strings owned by the QP package.
///
/// Apps construct an instance from their own l10n system and pass it to
/// QP widgets and pages.  There is no [BuildContext] dependency inside QP
/// itself — the caller is responsible for rebuilding this object when the
/// locale changes.
///
/// ```dart
/// QPStrings qpStringsFromL10n(AppLocalizations l) => QPStrings(
///   defaultLangLabel: l.qpDefaultLangLabel,
///   language: l.qpLanguage,
///   // …
/// );
/// ```
@immutable
class QPStrings {
  /// Creates a [QPStrings] instance with all required string fields.
  const QPStrings({
    // Language
    required this.defaultLangLabel,
    required this.language,
    required this.languageSubtitle,
    required this.translate,
    required this.translateSubtitle,
    // Theme
    required this.theme,
    required this.themeSubtitle,
    required this.darkMode,
    required this.darkModeAuto,
    required this.darkModeLight,
    required this.darkModeDark,
    required this.amoled,
    required this.amoledSubtitle,
    required this.highContrast,
    required this.themePalette,
    required this.schemeVariant,
    // Notifications
    required this.reminderTitle,
    required this.reminderSubtitle,
    required this.reminderEnabled,
    required this.reminderDays,
    required this.reminderTime,
    // First day
    required this.firstDayOfWeek,
    required this.firstDayDefault,
    // Date format
    required this.dateFormat,
    // Changelog
    required this.changelogTitle,
    // Settings overview
    required this.settings,
    required this.customization,
    required this.notifications,
  });

  // ── Language ─────────────────────────────────────────────────────────────

  /// Label for the system-default language option.
  final String defaultLangLabel;

  /// Settings tile title for language selection.
  final String language;

  /// Settings tile subtitle for language selection.
  final String languageSubtitle;

  /// Settings tile title for translation call-to-action.
  final String translate;

  /// Settings tile subtitle for translation call-to-action.
  final String translateSubtitle;

  // ── Theme ─────────────────────────────────────────────────────────────────

  /// Settings tile title for theme.
  final String theme;

  /// Settings tile subtitle for theme.
  final String themeSubtitle;

  /// Settings tile title for dark mode.
  final String darkMode;

  /// Label for the automatic dark-mode option.
  final String darkModeAuto;

  /// Label for the light-mode option.
  final String darkModeLight;

  /// Label for the dark-mode option.
  final String darkModeDark;

  /// Settings tile title for AMOLED (true black) option.
  final String amoled;

  /// Settings tile subtitle for AMOLED option.
  final String amoledSubtitle;

  /// Settings tile title for high-contrast option.
  final String highContrast;

  /// Settings tile title for colour palette.
  final String themePalette;

  /// Settings tile title for colour scheme variant.
  final String schemeVariant;

  // ── Notifications ─────────────────────────────────────────────────────────

  /// Settings section title for reminders.
  final String reminderTitle;

  /// Settings section subtitle for reminders.
  final String reminderSubtitle;

  /// Settings tile title for enable-reminders toggle.
  final String reminderEnabled;

  /// Settings tile title for reminder day selection.
  final String reminderDays;

  /// Settings tile title for reminder time selection.
  final String reminderTime;

  // ── First day ─────────────────────────────────────────────────────────────

  /// Settings tile title for first-day-of-week.
  final String firstDayOfWeek;

  /// Label for the locale-default first-day option.
  final String firstDayDefault;

  // ── Date format ───────────────────────────────────────────────────────────

  /// Settings tile title for date format.
  final String dateFormat;

  // ── Changelog ─────────────────────────────────────────────────────────────

  /// Title shown at the top of the changelog sheet.
  final String changelogTitle;

  // ── Settings overview ────────────────────────────────────────────────────

  /// Page / nav-bar label for settings.
  final String settings;

  /// Settings group title for customization options.
  final String customization;

  /// Settings group title for notifications.
  final String notifications;
}
