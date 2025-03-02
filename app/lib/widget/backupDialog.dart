import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

/// Export backup
Future<bool> exportBackup(BuildContext context, {bool share=false}) async {
  final ScaffoldMessengerState sm = ScaffoldMessenger.of(context);
  final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(
    context, listen: false,
  );
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String filename =
      'trale_${formatter.format(DateTime.now())}';
  const String fileext = 'txt';
  final Directory localPath = await getTemporaryDirectory();
  final String path = '${localPath.path}/$filename.$fileext';
  final File file = File(path);
  final MeasurementDatabase db = MeasurementDatabase();
  await file.writeAsString(db.exportString, mode: FileMode.write);

  bool success = false;
  if (share) {
    final ShareResult sharingResult = await Share.shareXFiles(
      <XFile>[XFile(path)],
      text: 'trale backup',
      subject: 'trale backup',
    );
    success = sharingResult.status == ShareResultStatus.success;
  } else {
    final String? path = await FileSaver.instance.saveAs(
        name: filename,
        file: file,
        ext: fileext,
        mimeType: MimeType.text,
    );
    success = path != null;
  }
  await file.delete();

  if (success) {
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
  return success;
}