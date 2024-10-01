import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/pages/about.dart';
import 'package:trale/pages/faq.dart';
import 'package:trale/pages/settings.dart';
import 'package:trale/widget/addWeightDialog.dart';
import 'package:trale/widget/iconHero.dart';
import 'package:trale/widget/routeTransition.dart';

// class SidebarDestination extends NavigationDrawerDestination {
//   const SidebarDestination({
//     super.key,
//     required super.icon,
//     required super.label,
//     super.selectedIcon,
//     required this.onTap,
//   });
//
//   final void Function() onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onPanDown: (_) => onTap(),
//       child: super.build(context),
//     );
//   }
// }

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
        leading: Icon(
          Icons.person_outline_rounded,
          color: Theme.of(context).iconTheme.color,
        ),
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
        leading: Icon(
          Icons.flag_outlined,
          color: Theme.of(context).iconTheme.color,
        ),
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
      // SizedBox(height: TraleTheme.of(context)!.padding),
      // NavigationDrawerDestination(
      //   icon: const Icon(CustomIcons.home),
      //   label: Text(AppLocalizations.of(context)!.home),
      // ),
      // SidebarDestination(
      //   onTap: () {
      //     Navigator.of(context).pop();
      //     Navigator.of(context).push<dynamic>(
      //         SlideRoute(
      //           page: Settings(),
      //           direction: TransitionDirection.left,
      //         )
      //     );
      //   },
      //   icon: const Icon(CustomIcons.settings),
      //   label: Text(AppLocalizations.of(context)!.settings),
      // ),
      ListTile(
        dense: true,
        leading: Icon(
          Icons.settings_outlined,
          color: Theme.of(context).iconTheme.color,
        ),
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
              SlideRoute(
                page: const Settings(),
                direction: TransitionDirection.left,
              )
          );
        },
      ),
      ListTile(
        dense: true,
        leading: Icon(
          Icons.question_answer_outlined,
          color: Theme.of(context).iconTheme.color,
        ),
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
              SlideRoute(
                page: const FAQ(),
                direction: TransitionDirection.left,
              )
          );
        },
      ),
      ListTile(
        dense: true,
        leading: Icon(
          Icons.info_outline_rounded,
          color: Theme.of(context).iconTheme.color,
        ),
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
              SlideRoute(
                page: const About(),
                direction: TransitionDirection.left,
              )
          );
        },
      ),
    ],
  );
}

