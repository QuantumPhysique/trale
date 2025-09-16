import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/language.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);

    // Build list of sliver children: translate pill + radio list + bottom spacer
    final List<Widget> sliverlist = <Widget>[
      Container(
        padding: EdgeInsets.symmetric(
          vertical: TraleTheme.of(context)!.padding,
          horizontal: 2 * TraleTheme.of(context)!.padding,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .secondaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              PhosphorIconsDuotone.translate,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              size: 28,
            ),
            SizedBox(width: TraleTheme.of(context)!.padding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.language,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Help translate the app',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
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
        child: Column(
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

    return RadioListTile<String>(
      // groupValue omitted (deprecated) — RadioGroup ancestor supplies selection
      value: language.language,
      // onChanged omitted; RadioGroup handles it
      title: Text(
        language.languageLong(context),
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding * 0.25,
      ),
      visualDensity: VisualDensity.compact,
      dense: true,
    );
  }
}
