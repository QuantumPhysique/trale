import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/language.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
import 'package:trale/widget/settingsBanner.dart';
import 'package:trale/widget/tile_group.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);

    // Build list of sliver children: translate pill + radio list + bottom spacer
    final List<Widget> sliverlist = <Widget>[
      SettingsBanner(
        leadingIcon: PhosphorIconsBold.translate,
        title: "${AppLocalizations.of(context)!.translate} trale".inCaps,
        subtitle: AppLocalizations.of(context)!.translateSubtitle.inCaps,
        url: 'https://hosted.weblate.org/engage/trale/',
      ),
      SizedBox(height: 2 * TraleTheme.of(context)!.padding),
      // RadioGroup wrapping the language tiles (replaces per-tile groupValue)
      RadioGroup<String>(
        groupValue: notifier.language.language,
        onChanged: (String? newLang) {
          if (newLang != null && notifier.language.language != newLang) {
            notifier.language = newLang.toLanguage();
          }
        },
        child: WidgetGroup(
          children: Language.supportedLanguages
            .map((Language lang) => _LanguageRadioTile(language: lang))
            .toList(),
        ),
      ),
    ];

    return Scaffold(
      body: SliverAppBarSnap(
        title: AppLocalizations.of(context)!.language,
        sliverlist: sliverlist,
      ),
    );
  }
}

class _LanguageRadioTile extends StatelessWidget {
  const _LanguageRadioTile({required this.language});

  final Language language;

  @override
  Widget build(BuildContext context) {
    final String selectedLanguage =
        context.select<TraleNotifier, String>((notifier) => notifier.language.language);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isSelected = selectedLanguage == language.language;
    return GroupedRadioListTile<String>(
      color: isSelected
          ? colorScheme.secondaryContainer
          : colorScheme.surfaceContainerLowest,
      shape: isSelected
        ? const StadiumBorder() : null,
      // groupValue omitted (deprecated) — RadioGroup ancestor supplies selection
      value: language.language,
      // onChanged omitted; RadioGroup handles it
      title: Text(
        language.languageLong(context),
        style: Theme.of(context).textTheme.titleMedium?.apply(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}