import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/interpolationPreview.dart';
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

List<Measurement> parseMeasurementsTxt(List<String?> lines) {
  final List<Measurement> newMeasurements = <Measurement>[];
  for (final String? line in lines) {
    // parse comments
    if ((line != null) && !line.startsWith('#')) {
      newMeasurements.add(
        Measurement.fromString(exportString: line)
      );
    }
  }
  return newMeasurements;
}


/// Import backup
Future<bool> importBackup(BuildContext context) async {
  final FilePickerResult? pickerResult =
  await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: <String>['txt'],
  );
  final ScaffoldMessengerState sm = ScaffoldMessenger.of(context);
  final MeasurementDatabase db = MeasurementDatabase();

  final pickedSuccess =
    pickerResult != null && pickerResult.files.single.path != null;
  bool accepted = false;

  if (pickedSuccess) {
    // get file extension of the file
    final String ext = pickerResult.names.single!.split('.').last;
    final File file = File(pickerResult.files.single.path!);
    final List<String> lines = file.readAsLinesSync();

    final List<Measurement> newMeasurements = <Measurement>[];
    if (ext == 'txt') {
      newMeasurements.addAll(
        parseMeasurementsTxt(lines)
      );
    }

    // show loaded measurments
    accepted = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.import,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget> [
            Container(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height / 4,
              child: Scrollbar(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: newMeasurements.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: TraleTheme.of(context)!.padding,
                      ),
                      child: Text(
                        newMeasurements[index].measureToString(context, ws: 2),
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontFamily: 'CourierPrime',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Divider(
              height: 2 * TraleTheme.of(context)!.padding,
            ),
            Text(
              AppLocalizations.of(context)!.importDialog,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
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
              child: Text(AppLocalizations.of(context)!.abort),
            ),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            label: Text(AppLocalizations.of(context)!.yes),
            icon: PPIcon(PhosphorIconsRegular.download, context),
          ),
        ],
      ),
    ) ?? false;

    if (!accepted) {
      final int measurementCounts = db.insertMeasurementList(newMeasurements);
      sm.showSnackBar(
        SnackBar(
          content: Text('$measurementCounts measurements added'),
          behavior: SnackBarBehavior.floating,
          duration: TraleTheme.of(context)!.snackbarDuration,
        ),
      );
    }
  }

  if (!pickedSuccess || !accepted) {
    sm.showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.importingAbort,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  return true;
}