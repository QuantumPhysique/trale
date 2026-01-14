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
          leading: PPIcon(PhosphorIconsDuotone.arrowsVertical, context),
          title: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^[1-9][0-9]*')),
            ],
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              hintText: AppLocalizations.of(context)!.addHeight,
              suffixText: 'cm',
              labelText: AppLocalizations.of(context)!.height.inCaps,
            ),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
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
  }
}
