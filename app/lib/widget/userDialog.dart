import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/addWeightDialog.dart';
import 'package:trale/widget/dialog.dart';
import 'package:trale/widget/tile_group.dart';

///
Future<bool> showUserDialog({required BuildContext context}) async {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );

  final Widget content = StatefulBuilder(
    builder: (BuildContext innerContext, StateSetter setState) {
      return UserDetailsGroup(
        notifier: notifier,
        onRefresh: () => setState(() {}),
      );
    },
  );

  final bool accepted =
      await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return DialogM3E(
            title: AppLocalizations.of(context)!.userDialogTitle,
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: content,
            ),
            actions: actions(context, () {
              Navigator.pop(context, true);
            }),
          );
        },
      ) ??
      false;
  return accepted;
}

///
List<Widget> actions(
  BuildContext context,
  Function onPress, {
  bool enabled = true,
}) {
  return <Widget>[
    FilledButton.icon(
      onPressed: enabled ? () => onPress() : null,
      icon: PPIcon(PhosphorIconsRegular.arrowLeft, context),
      label: Text(AppLocalizations.of(context)!.back),
    ),
  ];
}

class LooseWeightListTile extends StatelessWidget {
  /// constructor
  const LooseWeightListTile({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color tileColor =
        color ?? Theme.of(context).colorScheme.surfaceContainerLow;
    return GroupedSwitchListTile(
      color: tileColor,
      dense: true,
      leading: PPIcon(
        Provider.of<TraleNotifier>(context).looseWeight
            ? PhosphorIconsDuotone.trendDown
            : PhosphorIconsDuotone.trendUp,
        context,
      ),
      title: Text(
        Provider.of<TraleNotifier>(context).looseWeight
            ? AppLocalizations.of(context)!.looseWeight
            : AppLocalizations.of(context)!.gainWeight,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      subtitle: Text(
        AppLocalizations.of(context)!.looseWeightSubtitle,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      value: !Provider.of<TraleNotifier>(context).looseWeight,
      onChanged: (bool? loose) {
        if (loose == null) {
          return;
        }
        Provider.of<TraleNotifier>(context, listen: false).looseWeight = !loose;
      },
    );
  }
}

class UserDetailsGroup extends StatelessWidget {
  const UserDetailsGroup({
    super.key,
    required this.notifier,
    required this.onRefresh,
    this.title,
    this.backgroundColor,
  });

  final TraleNotifier notifier;
  final VoidCallback onRefresh;
  final String? title;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Color tileColor =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow;
    return WidgetGroup(
      title: title,
      children: <Widget>[
        GroupedListTile(
          color: tileColor,
          dense: false,
          leading: PPIcon(PhosphorIconsDuotone.user, context),
          title: TextFormField(
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              hintText: AppLocalizations.of(context)!.addUserName,
              hintMaxLines: 2,
              labelText: AppLocalizations.of(context)!.name.inCaps,
            ),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            initialValue: notifier.userName,
            onChanged: (String value) {
              notifier.userName = value;
            },
          ),
          onTap: () {},
        ),
        GroupedListTile(
          color: tileColor,
          dense: false,
          leading: PPIcon(PhosphorIconsDuotone.target, context),
          title: TextFormField(
            readOnly: true,
            initialValue: notifier.userTargetWeight != null
                ? notifier.unit.weightToString(
                    notifier.userTargetWeight!,
                    notifier.unitPrecision,
                  )
                : AppLocalizations.of(context)!.addTargetWeight,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              labelText: AppLocalizations.of(context)!.targetWeight,
            ),
            onTap: () async {
              await showTargetWeightDialog(
                context: context,
                weight:
                    notifier.userTargetWeight ??
                    Preferences().defaultUserWeight,
              );
              notifier.notify;
              onRefresh();
            },
          ),
        ),
        LooseWeightListTile(color: tileColor),
        GroupedListTile(
          color: tileColor,
          dense: false,
          leading: PPIcon(PhosphorIconsDuotone.arrowsVertical, context),
          title: TextFormField(
            key: ValueKey<Object>((notifier.heightUnit, notifier.userHeight)),
            keyboardType: notifier.heightUnit == TraleUnitHeight.metric
                ? TextInputType.number
                : TextInputType.text,
            inputFormatters: notifier.heightUnit == TraleUnitHeight.metric
                ? <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'^[1-9][0-9]*')),
                  ]
                : <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'''[0-9'″" ]''')),
                  ],
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              hintText: notifier.heightUnit == TraleUnitHeight.imperial
                  ? '5\'11"'
                  : AppLocalizations.of(context)!.addHeight,
              suffixText: notifier.heightUnit.suffixText,
              labelText: AppLocalizations.of(context)!.height.inCaps,
            ),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            initialValue: notifier.userHeight != null
                ? notifier.heightUnit.heightToString(notifier.userHeight!)
                : null,
            onChanged: (String value) {
              final double? newHeight = notifier.heightUnit.parseHeight(value);
              if (newHeight != null) {
                notifier.userHeight = newHeight;
              }
            },
            onEditingComplete: () {
              onRefresh();
            },
          ),
          onTap: () {},
        ),
      ],
    );
  }
}
