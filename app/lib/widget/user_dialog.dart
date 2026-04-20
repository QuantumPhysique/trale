import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/widget/add_weight_dialog.dart';

part 'user_dialog/form_field.dart';
part 'user_dialog/user_details.dart';
part 'user_dialog/target_weight.dart';

/// Shows the user dialog.
Future<bool> showUserDialog({required BuildContext context}) async {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );

  /// define actions with single button
  List<Widget> actions(
    BuildContext context,
    Function onPress, {
    bool enabled = true,
  }) {
    return <Widget>[
      FilledButton.icon(
        onPressed: enabled ? () => onPress() : null,
        icon: PPIcon(PhosphorIconsRegular.arrowLeft, context),
        label: Text(context.l10n.back),
      ),
    ];
  }

  final Widget content = StatefulBuilder(
    builder: (BuildContext innerContext, StateSetter setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          UserDetailsGroup(
            notifier: notifier,
            onRefresh: () => setState(() {}),
            title: AppLocalizations.of(innerContext)!.user,
          ),
          SizedBox(height: TraleTheme.of(innerContext)!.padding),
          TargetWeightGroup(
            notifier: notifier,
            onRefresh: () => setState(() {}),
            title: AppLocalizations.of(innerContext)!.targetWeight,
          ),
        ],
      );
    },
  );

  final bool accepted =
      await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return QPDialog(
            title: context.l10n.userDialogTitle,
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
