import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/pages/home.dart';
import 'package:trale/pages/settingsOverview.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
import 'package:trale/widget/customSliverAppBar.dart';


class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {

    List<Widget> sliverlist = <Widget>[
      ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: 0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.language,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<String>(
        label: AutoSizeText(
          AppLocalizations.of(context)!.language,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        initialSelection: Provider.of<TraleNotifier>(context).language.language,
        dropdownMenuEntries: <DropdownMenuEntry<String>>[
          for (final Language lang in Language.supportedLanguages)
            DropdownMenuEntry<String>(
              value: lang.language,
              label: lang.languageLong(context),
            )
        ],
        onSelected: (String? lang) async {
          Provider.of<TraleNotifier>(context, listen: false).language =
              lang!.toLanguage();
        },
      ))
    ];

    return Scaffold(
      body: SliverAppBarSnap(
        title: AppLocalizations.of(context)!.settings,
        sliverlist: sliverlist,
      ),
    );
  }
}
