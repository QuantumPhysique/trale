import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/addWeightDialog.dart';
import 'package:trale/widget/tile_group.dart';


///
Future<bool> showUserDialog({
  required BuildContext context,
}) async {
  final TraleNotifier notifier =
      Provider.of<TraleNotifier>(context, listen: false);

  final Widget content = StatefulBuilder(
    builder: (BuildContext innerContext, StateSetter setState) {
      return WidgetGroup(
        children: <Widget>[
          GroupedListTile(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            dense: false,
            leading: PPIcon(
              PhosphorIconsDuotone.user,
              innerContext,
            ),
            title: TextFormField(
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: Theme.of(innerContext).textTheme.titleSmall!.copyWith(
                color: Theme.of(innerContext).colorScheme.onSurface,
              ),
              hintText: AppLocalizations.of(innerContext)!.addUserName,
              hintMaxLines: 2,
              labelText: AppLocalizations.of(innerContext)!.name,
            ),
            style: Theme.of(innerContext).textTheme.titleSmall!.copyWith(
              color: Theme.of(innerContext).colorScheme.onSurface,
            ),
            initialValue: notifier.userName,
            onChanged: (String value) {
              notifier.userName = value;
            }
            ),
            onTap: () {},
          ),
          GroupedListTile(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            dense: false,
            leading: PPIcon(
              PhosphorIconsDuotone.target,
              innerContext,
            ),
            title: TextFormField(
              readOnly: true,
              initialValue: notifier.userTargetWeight != null
                ? notifier.unit.weightToString(notifier.userTargetWeight!)
                : AppLocalizations.of(innerContext)!.addTargetWeight,
              style: Theme.of(innerContext).textTheme.titleSmall!.copyWith(
            color: Theme.of(innerContext).colorScheme.onSurface,
              ),
              maxLines: 1,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: Theme.of(innerContext).textTheme.titleSmall!.copyWith(
                  color: Theme.of(innerContext).colorScheme.onSurface,
                ),
                labelText: AppLocalizations.of(innerContext)!.targetWeight,
              ),
              onTap: () async {
                // Navigator.of(innerContext).pop();
                await showTargetWeightDialog(
                  context: innerContext,
                  weight: notifier.userTargetWeight
                      ?? Preferences().defaultUserWeight,
                );
                notifier.notify;
                setState(() {});
              },
            ),
          ),
          GroupedListTile(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            dense: false,
            leading: PPIcon(
              PhosphorIconsDuotone.arrowsVertical,
              innerContext,
            ),
            title: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(
                    RegExp(r'^[1-9][0-9]*'),
                )
              ],
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: Theme.of(innerContext).textTheme.titleSmall!.copyWith(
                    color: Theme.of(innerContext).colorScheme.onSurface,
                ),
                hintText: AppLocalizations.of(innerContext)!.addHeight,
                suffixText: 'cm',
                labelText: AppLocalizations.of(innerContext)!.height,
              ),
              style: Theme.of(innerContext).textTheme.titleSmall!.copyWith(
                color: Theme.of(innerContext).colorScheme.onSurface,
              ),
              initialValue: notifier.userHeight != null
                ? '${notifier.userHeight!.toInt()}'
                : null,
              onChanged: (String value) {
                final double? newHeight = double.tryParse(value);
                if (newHeight != null) {
                    notifier.userHeight = newHeight;
                }
              },
            ),
            onTap: () {},
          ),
        ],
      );
    },
  );

  final bool accepted = await showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        titlePadding: EdgeInsets.all(TraleTheme.of(context)!.padding),
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.symmetric(
          horizontal: TraleTheme.of(context)!.padding,
          /// todo: why -4? Find reason and fix properly
          vertical: TraleTheme.of(context)!.padding - 4,
        ),
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.userDialogTitle,
            style: Theme.of(context).textTheme.headlineSmall!.apply(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            maxLines: 1,
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: content,
        ),
        actions: actions(context, () {
          Navigator.pop(context, true);
        }),
      );
    }) ?? false;
  return accepted;
}

///
List<Widget> actions(BuildContext context, Function onPress,
    {bool enabled = true}) {
  return <Widget>[
    FilledButton.icon(
      onPressed: enabled ? () => onPress() : null,
      icon: PPIcon(PhosphorIconsRegular.arrowLeft, context),
      label: Text(AppLocalizations.of(context)!.back),
    ),
  ];
}