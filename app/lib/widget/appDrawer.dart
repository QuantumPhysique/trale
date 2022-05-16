import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/pages/about.dart';
import 'package:trale/pages/faq.dart';
import 'package:trale/pages/settings.dart';
import 'package:trale/widget/addWeightDialog.dart';
import 'package:trale/widget/routeTransition.dart';

/// Drawer for home screen
Drawer appDrawer (BuildContext context) {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(context);
  return Drawer(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(TraleTheme.of(context)!.borderRadius),
          bottomRight: Radius.circular(TraleTheme.of(context)!.borderRadius)
      ),
    ),
    backgroundColor: ElevationOverlay.colorWithOverlay(
      Theme.of(context).colorScheme.surface,
      Theme.of(context).colorScheme.primary,
      1.0,
    ),
    child: Column(
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(TraleTheme.of(context)!.borderRadius),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/launcher/icon_large.png',
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.width * 0.2,
              ),
              SizedBox(width: TraleTheme.of(context)!.padding),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AutoSizeText(
                    AppLocalizations.of(context)!.trale.toLowerCase(),
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                  ),
                  AutoSizeText(
                    AppLocalizations.of(context)!.tralesub,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
        ),
        ListTile(
          dense: true,
          leading: Icon(
            CustomIcons.account,
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
            CustomIcons.goal,
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
        const Spacer(),
        const Divider(),
        ListTile(
          dense: true,
          leading: Icon(
            CustomIcons.settings,
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
                  page: Settings(),
                  direction: TransitionDirection.left,
                )
            );
          },
        ),
        ListTile(
          dense: true,
          leading: Icon(
            CustomIcons.faq,
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
                  page: FAQ(),
                  direction: TransitionDirection.left,
                )
            );
          },
        ),
        ListTile(
          dense: true,
          leading: Icon(
            CustomIcons.info,
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
                  page: About(),
                  direction: TransitionDirection.left,
                )
            );
          },
        ),
      ],
    ),
  );
}

