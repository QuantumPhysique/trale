import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';


/// Backup dialog
Future<void> backupDialog(BuildContext context) async {
  final ScaffoldMessengerState sm = ScaffoldMessenger.of(context);
  final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(
    context, listen: false,
  );

  final bool accepted = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.export,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Text(
        AppLocalizations.of(context)!.exportDialog,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: <Widget>[
        TextButton(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all<Color>(
              Theme.of(context).colorScheme.onSurface,
            ),
          ),
          onPressed: () => Navigator.pop(context, false),
          child: Container(
              padding: EdgeInsets.symmetric(
                vertical: TraleTheme.of(context)!.padding / 2,
                horizontal: TraleTheme.of(context)!.padding,
              ),
              child: Text(AppLocalizations.of(context)!.abort)
          ),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          label: Text(AppLocalizations.of(context)!.yes),
          icon: PPIcon(PhosphorIconsRegular.upload, context),
        ),
      ],
    ),
  ) ?? false;
  if (accepted) {
    final Directory localPath = await getTemporaryDirectory();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String filename =
        'trale_${formatter.format(DateTime.now())}.txt';
    final String path = '${localPath.path}/$filename';
    final File file = File(path);
    final MeasurementDatabase db = MeasurementDatabase();
    file.writeAsString(db.exportString, mode: FileMode.write);
    final ShareResult sharingResult = await Share.shareXFiles(
      <XFile>[XFile(path)],
      text: 'trale backup',
      subject: 'trale backup',
    );
    if (sharingResult.status == ShareResultStatus.success) {
      sm.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.backupSuccess),
          behavior: SnackBarBehavior.floating,
          duration: TraleTheme.of(context)!.snackbarDuration,
        ),
      );
// set latest backup date
      traleNotifier.latestBackupDate = DateTime.now();
    }
    await file.delete();
  }
}