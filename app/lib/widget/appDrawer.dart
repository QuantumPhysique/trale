import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/pages/about.dart';
import 'package:trale/pages/faq.dart';
import 'package:trale/pages/settings.dart';
import 'package:trale/widget/addWeightDialog.dart';
import 'package:trale/widget/iconHero.dart';


/// Drawer for home screen
NavigationDrawer appDrawer (
  BuildContext context,
  Function(int) handlePageChanged,
  int selectedIndex,
) {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(context);
  return NavigationDrawer(
    onDestinationSelected: handlePageChanged,
    selectedIndex: selectedIndex,
    children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(TraleTheme.of(context)!.borderRadius),
            ),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const IconHero(),
          ),
      ),
      ListTile(
        dense: true,
        leading: PPIcon( PhosphorIconsDuotone.user, context),
        title: TextFormField(
            keyboardType: TextInputType.name,
            decoration: InputDecoration.collapsed(
              hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              hintText: AppLocalizations.of(context)!.addUserName,
            ),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            initialValue: notifier.userName,
            onChanged: (String value) {
              notifier.userName = value;
            }
        ),
        onTap: () {},
      ),
      ListTile(
        dense: true,
        leading: PPIcon(PhosphorIconsDuotone.target, context),
        title: AutoSizeText(
          notifier.userTargetWeight != null
              ? notifier.unit.weightToString(notifier.userTargetWeight!)
              : AppLocalizations.of(context)!.addTargetWeight,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
        ),
        onTap: () async {
          Navigator.of(context).pop();
          await showTargetWeightDialog(
            context: context,
            weight: notifier.userTargetWeight
                ?? Preferences().defaultUserWeight,
          );
          notifier.notify;
        },
      ),
      const Divider(),
      ListTile(
        dense: true,
        leading: PPIcon(PhosphorIconsDuotone.sliders, context),
        title: AutoSizeText(
          AppLocalizations.of(context)!.settings,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
        ),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push<dynamic>(
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => const Settings(),
            )
          );
        },
      ),
      ListTile(
        dense: true,
        leading: PPIcon(PhosphorIconsDuotone.question, context),
        title: AutoSizeText(
          AppLocalizations.of(context)!.faq,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
        ),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push<dynamic>(
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => const FAQ(),
            ),
          );
        },
      ),
      ListTile(
        dense: true,
        leading: PPIcon(PhosphorIconsDuotone.info, context),
        title: AutoSizeText(
          AppLocalizations.of(context)!.about,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
        ),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push<dynamic>(
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => const About(),
            ),
          );
        },
      ),
    ],
  );
}

