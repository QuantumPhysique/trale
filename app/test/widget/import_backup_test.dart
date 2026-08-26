import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/widget/io_widgets.dart';

import '../helpers/widget_test_helper.dart';

// Covers the file picker side of importBackup, which is the part the
// file_picker 12 upgrade touched: which file is handed to the parser, how its
// extension decides between the txt and csv branches, and what happens when
// the user backs out.  The parsers themselves are covered by
// import_parser_test.dart, and the insert path is untouched by the upgrade —
// every test here stops at the confirmation dialog, which lists exactly what
// was parsed.

/// Stands in for the picked file without going near the platform channel.
///
/// Only [name] and [uri] are real: `path` and `extension` are what
/// importBackup reads, and both are computed by [PlatformFile] itself from
/// those two — so this exercises the same getters the app relies on.
final class _FakePickedFile extends PlatformFile {
  _FakePickedFile({required this.name, required this.uri});

  @override
  final String name;

  @override
  final Uri uri;

  // Forwards the members importBackup never touches (xFile, length,
  // readAsBytes, readAsByteStream) so they need not be implemented.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Returns a canned result and records how it was asked for.
final class _FakePicker extends FilePickerPlatform {
  _FakePicker(this.result);

  final PlatformFile? result;

  int calls = 0;
  FileType? requestedType;
  List<String>? requestedExtensions;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    calls++;
    requestedType = type;
    requestedExtensions = allowedExtensions;
    return result;
  }
}

void main() {
  late TraleNotifier notifier;
  late Directory tempDir;

  setUp(() async {
    notifier = await setUpWidgetTestDependencies();
    tempDir = Directory.systemTemp.createTempSync('trale_import_test');
  });

  tearDown(() {
    resetWidgetTestDependencies();
    FilePickerPlatform.instance = MethodChannelFilePicker();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  const String traleBackup =
      '# This file was created with trale.\n'
      '#Date weight[kg]\n'
      '2024-03-01T08:00:00.000 75.5000000000\n'
      '2024-03-02T08:00:00.000 76.0000000000\n'
      '2024-03-03T08:00:00.000 74.2000000000';

  const String openScaleCsv =
      'dateTime,weight\n'
      '2024-03-01 08:00,80.1\n'
      '2024-03-02 08:00,80.4';

  /// Writes [content] to [filename] and points a fake picker at it.
  _FakePicker installPicker(String filename, {String? content}) {
    PlatformFile? picked;
    if (content != null) {
      final File file = File('${tempDir.path}/$filename')
        ..writeAsStringSync(content);
      picked = _FakePickedFile(name: filename, uri: Uri.file(file.path));
    }
    final _FakePicker picker = _FakePicker(picked);
    FilePickerPlatform.instance = picker;
    return picker;
  }

  /// Renders a button that runs importBackup and taps it.
  Future<void> runImport(WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(
        notifier: notifier,
        child: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => importBackup(context),
            child: const Text('import'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('import'));
    await tester.pumpAndSettle();
  }

  /// Number of measurement rows listed in the confirmation dialog.
  int listedMeasurements() => find.byType(AutoSizeText).evaluate().length;

  testWidgets('a picked .txt backup reaches the parser intact', (
    WidgetTester tester,
  ) async {
    installPicker('trale_2024-03-04.txt', content: traleBackup);

    await runImport(tester);

    expect(find.byType(Dialog), findsOneWidget);
    expect(listedMeasurements(), 3);
  });

  testWidgets('a picked .csv backup is routed to the csv parser', (
    WidgetTester tester,
  ) async {
    installPicker('openscale.csv', content: openScaleCsv);

    await runImport(tester);

    expect(find.byType(Dialog), findsOneWidget);
    expect(listedMeasurements(), 2);
  });

  testWidgets('the picker is asked for txt and csv only', (
    WidgetTester tester,
  ) async {
    final _FakePicker picker = installPicker('trale.txt', content: traleBackup);

    await runImport(tester);

    expect(picker.calls, 1);
    expect(picker.requestedType, FileType.custom);
    expect(picker.requestedExtensions, <String>['txt', 'csv']);
  });

  testWidgets('cancelling the picker opens no dialog', (
    WidgetTester tester,
  ) async {
    installPicker('unused.txt');

    await runImport(tester);

    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('the last dot decides the extension', (
    WidgetTester tester,
  ) async {
    installPicker('trale.backup.2024.csv', content: openScaleCsv);

    await runImport(tester);

    expect(find.byType(Dialog), findsOneWidget);
    expect(listedMeasurements(), 2);
  });

  testWidgets('a file without an extension is refused, not guessed', (
    WidgetTester tester,
  ) async {
    installPicker('backup', content: traleBackup);

    await runImport(tester);

    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('declining the dialog inserts nothing', (
    WidgetTester tester,
  ) async {
    installPicker('trale.txt', content: traleBackup);

    await runImport(tester);
    await tester.tap(
      find.widgetWithIcon(QPDialogAction, PhosphorIconsRegular.x),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(MeasurementDatabase().measurements, isEmpty);
  });

  // The point of the whole feature: what the app writes out has to come back
  // in unchanged.  Runs the real export string through the real parser.
  testWidgets('an exported backup parses back to the same measurements', (
    WidgetTester tester,
  ) async {
    final List<Measurement> original = <Measurement>[
      Measurement(weight: 75.5, date: DateTime(2024, 3, 1, 8)),
      Measurement(weight: 76.0, date: DateTime(2024, 3, 2, 8)),
      Measurement(weight: 74.2, date: DateTime(2024, 3, 3, 8)),
    ];
    MeasurementDatabase.testInstance = MeasurementDatabase.forTestingWithData(
      original,
    );

    installPicker(
      'trale_roundtrip.txt',
      content: MeasurementDatabase().exportString,
    );

    await runImport(tester);

    expect(find.byType(Dialog), findsOneWidget);
    expect(listedMeasurements(), original.length);
  });
}
