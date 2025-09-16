import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/addWeightDialog.dart';


///
Future<bool> showUserDialog({
  required BuildContext context,
}) async {
  final TraleNotifier notifier =
      Provider.of<TraleNotifier>(context, listen: false);
  final double width = MediaQuery.of(context).size.width - 80;

  final Widget content = StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Container(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              dense: false,
              leading: _buildLeading(
                context,
                PhosphorIconsDuotone.user,
                'name',
              ),
              title: TextFormField(
              keyboardType: TextInputType.name,
              decoration: InputDecoration.collapsed(
                hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                hintText: AppLocalizations.of(context)!.addUserName,
                hintMaxLines: 2,
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
              dense: false,
              leading: _buildLeading(
                context,
                PhosphorIconsDuotone.target,
                AppLocalizations.of(context)!.target,
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
                // Navigator.of(context).pop();
                await showTargetWeightDialog(
                  context: context,
                  weight: notifier.userTargetWeight
                    ?? Preferences().defaultUserWeight,
                );
                notifier.notify;
                setState(() {});
              },
            ),
            ListTile(
              dense: false,
              leading: _buildLeading(
                context,
                PhosphorIconsDuotone.arrowsVertical,
                AppLocalizations.of(context)!.height,
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
                  hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                  ),
                  hintText: AppLocalizations.of(context)!.addHeight,
                  suffixText: 'cm',
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
        ),
      );
    },
  );

  final bool accepted = await showDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: TraleTheme.of(context)!.borderShape,
              backgroundColor: ElevationOverlay.colorWithOverlay(
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.primary,
                3.0,
              ),
              elevation: 0,
              contentPadding: EdgeInsets.only(
                top: TraleTheme.of(context)!.padding,
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
              content: content,
              actions: actions(context, () {
                Navigator.pop(context, true);
              }),
            );
          }) ??
      false;
  return accepted;
}

///
List<Widget> actions(BuildContext context, Function onPress,
    {bool enabled = true}) {
  return <Widget>[
    FilledButton.icon(
      onPressed: enabled ? () => onPress() : null,
      icon: PPIcon(PhosphorIconsRegular.arrowLeft, context),
      label: Text(AppLocalizations.of(context)!.back,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              )),
    ),
  ];
}


Widget _buildLeading(BuildContext context, IconData icon, String text) {
  final double width = MediaQuery.of(context).size.width - 80;
  return SizedBox(
    width: width * 0.33,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        AutoSizeText(
          text,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 2,
        ),
        SizedBox(width: TraleTheme.of(context)!.padding),
        PPIcon(icon, context),
      ],
    ),
  );
}