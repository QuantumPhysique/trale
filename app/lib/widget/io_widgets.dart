import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/measurement_formatter.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/trale_notifier.dart';

/// Export backup
Future<bool> exportBackup(BuildContext context, {bool share = false}) async {
  final ScaffoldMessengerState sm = ScaffoldMessenger.of(context);
  final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String filename = 'trale_${formatter.format(DateTime.now())}';
  const String fileext = 'txt';
  final Directory localPath = await getTemporaryDirectory();
  final String path = '${localPath.path}/$filename.$fileext';
  final File file = File(path);
  final MeasurementDatabase db = MeasurementDatabase();
  await file.writeAsString(db.exportString, mode: FileMode.write);

  bool success = false;
  if (share) {
    final ShareResult sharingResult = await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(path)],
        text: 'trale backup',
        title: 'trale backup',
      ),
    );
    success = sharingResult.status == ShareResultStatus.success;
  } else {
    final String? path = await FileSaver.instance.saveAs(
      name: filename,
      file: file,
      fileExtension: fileext,
      mimeType: MimeType.text,
    );
    success = path != null;
  }
  await file.delete();

  if (!context.mounted) {
    return success;
  }
  if (success) {
    sm.showSnackBar(
      SnackBar(
        content: Text(context.l10n.backupSuccess),
        behavior: SnackBarBehavior.floating,
        duration: TraleTheme.of(context)!.snackbarDuration,
      ),
    );
    // set latest backup date
    traleNotifier.latestBackupDate = DateTime.now();
  }
  return success;
}

/// Parses measurements from text format lines.
List<Measurement> parseMeasurementsTxt(List<String?> lines) {
  final List<Measurement> newMeasurements = <Measurement>[];
  for (final String? line in lines) {
    // parse comments
    if ((line != null) && !line.startsWith('#')) {
      try {
        newMeasurements.add(Measurement.fromString(exportString: line));
      } on FormatException catch (e) {
        QPAppLogger.warning(
          'Skipping invalid measurement line',
          tag: 'Parser',
          error: e,
        );
      }
    }
  }
  return newMeasurements;
}

/// parse csv format
List<Measurement> parseMeasurementsCSV(
  List<String?> lines,
  int dateIdx,
  int weightIdx, {
  String separator = ',',
  bool hasHeader = true,
  String dateFormat = 'yyyy-MM-dd HH:mm',
}) {
  final List<Measurement> newMeasurements = <Measurement>[];
  if (hasHeader) {
    lines.removeAt(0);
  }
  final DateFormat format = DateFormat(dateFormat);
  for (final String? line in lines) {
    if (line == null) {
      continue;
    }
    final List<String> strings = line.split(separator);
    if (strings.length <= dateIdx || strings.length <= weightIdx) {
      QPAppLogger.warning(
        'Invalid column count in CSV line',
        tag: 'Parser',
        error: line,
      );
      continue;
    }
    // catch date and weight parsing errors, including out-of-bounds access
    try {
      // remove all quotes from date String
      final String dateString = strings[dateIdx].replaceAll('"', '');
      final DateTime date = format.parse(dateString);
      final double weight = double.parse(strings[weightIdx]);
      newMeasurements.add(
        Measurement(weight: weight, date: date, isMeasured: true),
      );
    } catch (e) {
      QPAppLogger.warning(
        'Failed to parse CSV date/weight',
        tag: 'Parser',
        error: line,
      );
      continue;
    }
  }

  return newMeasurements;
}

/// get indices of date and weight column
List<int>? openScaleIndices(List<String?> lines, {String separator = ','}) {
  if (lines.isEmpty || lines[0] == null) {
    return null;
  }
  final List<String> names = lines[0]!.split(separator);
  // return idx of value "weight" in names (case-insensitive, trim whitespace)
  final int weightIdx = names.indexWhere(
    (String name) => name.trim().toLowerCase().contains('weight'),
  );
  final int dateIdx = names.indexWhere(
    (String name) => name.trim().toLowerCase().contains('datetime'),
  );
  if (weightIdx == -1 || dateIdx == -1) {
    return null;
  }
  return <int>[dateIdx, weightIdx];
}

/// Import backup
Future<bool> importBackup(BuildContext context) async {
  final FilePickerResult? pickerResult = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: <String>['txt', 'csv'],
  );
  if (!context.mounted) {
    return false;
  }
  final ScaffoldMessengerState sm = ScaffoldMessenger.of(context);
  final MeasurementDatabase db = MeasurementDatabase();

  final bool pickedSuccess =
      pickerResult != null && pickerResult.files.single.path != null;
  bool accepted = false;

  if (pickedSuccess) {
    // get file extension of the file
    final String ext = pickerResult.names.single!.split('.').last;
    final File file = File(pickerResult.files.single.path!);
    final List<String> lines;
    try {
      lines = file.readAsLinesSync();
    } on Exception catch (e) {
      QPAppLogger.warning(
        'Failed to read import file',
        tag: 'Import',
        error: e,
      );
      sm.showSnackBar(
        SnackBar(
          content: Text(context.l10n.importFileError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    final List<Measurement> newMeasurements = <Measurement>[];
    if (ext == 'txt') {
      newMeasurements.addAll(parseMeasurementsTxt(lines));
    } else if (ext == 'csv') {
      // check if openScale format
      final List<int>? indices = openScaleIndices(lines);
      if (indices != null) {
        newMeasurements.addAll(
          parseMeasurementsCSV(lines, indices[0], indices[1]),
        );
      } else {
        // try Withings format
        newMeasurements.addAll(parseMeasurementsCSV(lines, 0, 1));
      }
    }

    // guard: nothing was parsed — show descriptive error and bail out
    if (newMeasurements.isEmpty) {
      sm.showSnackBar(
        SnackBar(
          content: Text(context.l10n.importNoMeasurements),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    // show loaded measurements
    accepted =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(
              context.l10n.import,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: double.maxFinite,
                  height: MediaQuery.of(context).size.height / 4,
                  child: Scrollbar(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: newMeasurements.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: TraleTheme.of(context)!.padding,
                            ),
                            child: AutoSizeText(
                              MeasurementFormatter.fromContext(
                                context,
                              ).measureToString(newMeasurements[index], ws: 8),
                              style: Theme.of(
                                context,
                              ).textTheme.monospace.bodyLarge,
                              maxLines: 1,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Divider(height: 2 * TraleTheme.of(context)!.padding),
                Text(
                  context.l10n.importDialog,
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
                  child: Text(context.l10n.abort),
                ),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                label: Text(context.l10n.yes),
                icon: PPIcon(PhosphorIconsRegular.download, context),
              ),
            ],
          ),
        ) ??
        false;

    if (!context.mounted) {
      return true;
    }
    if (accepted) {
      final int measurementCounts = await db.insertMeasurementList(
        newMeasurements,
      );
      if (!context.mounted) {
        return true;
      }
      sm.showSnackBar(
        SnackBar(
          content: Text(context.l10n.importSuccess(count: measurementCounts)),
          behavior: SnackBarBehavior.floating,
          duration: TraleTheme.of(context)!.snackbarDuration,
        ),
      );
    }
  }

  if (!context.mounted) {
    return true;
  }
  if (!pickedSuccess || !accepted) {
    sm.showSnackBar(
      SnackBar(
        content: Text(context.l10n.importingAbort),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  return true;
}
