import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/src/notifier/qp_notifier.dart';
import 'package:quantumphysique/src/types/language.dart';
import 'package:quantumphysique/src/types/string_extension.dart';
import 'package:quantumphysique/src/types/strings.dart';
import 'package:quantumphysique/src/widgets/settings_banner.dart';
import 'package:quantumphysique/src/widgets/sliver_app_bar_snap.dart';
import 'package:quantumphysique/src/widgets/tile_group/tile_group.dart';

/// Settings page for selecting the display language.
///
/// Reads [QPLanguage.supportedLanguages] (which the app populates at startup)
/// to build the radio list.
///
/// When [translationUrl] is provided a [QPSettingsBanner] is shown at the
/// top inviting users to contribute translations.  [appName] is appended to
/// the banner title (e.g. "translate trale").
class QPLanguageSettingsPage extends StatelessWidget {
  /// Creates a [QPLanguageSettingsPage].
  const QPLanguageSettingsPage({
    required this.strings,
    this.translationUrl,
    this.appName,
    super.key,
  });

  /// Localised strings.
  final QPStrings strings;

  /// URL to the translation platform (e.g. Weblate).  When `null` no banner
  /// is shown.
  final String? translationUrl;

  /// App name appended to the banner translate title.
  final String? appName;

  @override
  Widget build(BuildContext context) {
    final QPNotifier notifier = Provider.of<QPNotifier>(context);
    final String bannerTitle = appName != null
        ? '${strings.translate} $appName'.inCaps
        : strings.translate.inCaps;

    final List<Widget> sliverList = <Widget>[
      if (translationUrl != null)
        QPSettingsBanner(
          leadingIcon: PhosphorIconsBold.translate,
          title: bannerTitle,
          subtitle: strings.translateSubtitle.inCaps,
          url: translationUrl!,
        ),
      if (translationUrl != null) const SizedBox(height: 2 * 16),
      RadioGroup<String>(
        groupValue: notifier.language.language,
        onChanged: (String? newLang) {
          if (newLang != null && notifier.language.language != newLang) {
            notifier.language = newLang.toQPLanguage();
          }
        },
        child: QPWidgetGroup(
          children: QPLanguage.supportedLanguages
              .map(
                (QPLanguage lang) => _QPLanguageRadioTile(
                  language: lang,
                  defaultLabel: strings.defaultLangLabel,
                ),
              )
              .toList(),
        ),
      ),
    ];

    return Scaffold(
      body: QPSliverAppBarSnap(title: strings.language, sliverlist: sliverList),
    );
  }
}

class _QPLanguageRadioTile extends StatelessWidget {
  const _QPLanguageRadioTile({
    required this.language,
    required this.defaultLabel,
  });

  final QPLanguage language;
  final String defaultLabel;

  @override
  Widget build(BuildContext context) {
    final String selectedLanguage = context.select<QPNotifier, String>(
      (QPNotifier n) => n.language.language,
    );
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isSelected = selectedLanguage == language.language;
    return QPGroupedRadioListTile<String>(
      color: isSelected
          ? colorScheme.secondaryContainer
          : colorScheme.surfaceContainerLowest,
      shape: isSelected ? const StadiumBorder() : null,
      value: language.language,
      title: Text(
        language.languageLong(defaultLabel),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.apply(color: colorScheme.onSurface),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
