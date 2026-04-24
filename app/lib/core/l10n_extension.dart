import 'package:flutter/widgets.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

export 'package:trale/l10n-gen/app_localizations.dart';

/// Convenience extension on [BuildContext] for accessing [AppLocalizations].
///
/// Use `context.l10n.someKey` instead of
/// `AppLocalizations.of(context)!.someKey`.
extension AppLocalizationsX on BuildContext {
  /// Returns the [AppLocalizations] instance for this [BuildContext].
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Builds a [QPStrings] instance from [AppLocalizations].
///
/// Call this wherever you need to pass [QPStrings] to a QP widget or page.
QPStrings qpStringsFromL10n(AppLocalizations l) => QPStrings(
  defaultLangLabel: l.qp_defaultLangLabel,
  language: l.qp_language,
  languageSubtitle: l.qp_languageSubtitle,
  translate: l.qp_translate,
  translateSubtitle: l.qp_translateSubtitle,
  theme: l.qp_theme,
  themeSubtitle: l.qp_themeSubtitle,
  darkMode: l.qp_darkMode,
  darkModeAuto: l.qp_darkModeAuto,
  darkModeLight: l.qp_darkModeLight,
  darkModeDark: l.qp_darkModeDark,
  amoled: l.qp_amoled,
  amoledSubtitle: l.qp_amoledSubtitle,
  highContrast: l.qp_highContrast,
  themePalette: l.qp_themePalette,
  schemeVariant: l.qp_schemeVariant,
  reminderTitle: l.qp_reminderTitle,
  reminderSubtitle: l.qp_reminderSubtitle,
  reminderEnabled: l.qp_reminderEnabled,
  reminderDays: l.qp_reminderDays,
  reminderTime: l.qp_reminderTime,
  firstDayOfWeek: l.qp_firstDayOfWeek,
  firstDayDefault: l.qp_firstDayDefault,
  dateFormat: l.qp_dateFormat,
  changelogTitle: l.qp_changelogTitle,
  settings: l.qp_settings,
  customization: l.qp_customization,
  notifications: l.qp_notifications,
);

/// Builds a [QPAboutStrings] instance from [AppLocalizations].
QPAboutStrings qpAboutStringsFromL10n(AppLocalizations l) => QPAboutStrings(
  version: l.version,
  changelog: l.changelog,
  sourceCode: l.sourcecode,
  licence: l.licence,
  tplTitle: l.tpl,
  tplAssetsGroup: l.assets,
  tplPackagesGroup: l.packages,
  loading: l.loading,
  undertpl:
      ({
        required String years,
        required String author,
        required String licence,
      }) => l.undertpl(years: years, author: author, licence: licence),
  about: l.about,
);
