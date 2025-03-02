import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/backupInterval.dart';
import 'package:trale/core/firstDay.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/interpolationPreview.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/printFormat.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/backupDialog.dart';
import 'package:trale/widget/coloredContainer.dart';
import 'package:trale/widget/customSliverAppBar.dart';
import 'package:trale/widget/linechart.dart';

/// ListTile for changing Amoled settings
class ExportListTile extends StatelessWidget {
  /// constructor
  const ExportListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final ScaffoldMessengerState sm = ScaffoldMessenger.of(context);
    return ListTile(
      dense: true,
      title: AutoSizeText(
        AppLocalizations.of(context)!.export,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
      ),
      subtitle: AutoSizeText(
        AppLocalizations.of(context)!.exportSubtitle,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: PPIcon(PhosphorIconsDuotone.shareNetwork, context),
            onPressed: () => exportBackup(context, share: true),
          ),
          IconButton(
            icon: PPIcon(PhosphorIconsDuotone.upload, context),
            onPressed: () => exportBackup(context),
          ),
        ],
      ),
    );
  }
}

/// ListTile for importing
class ImportListTile extends StatelessWidget {
  /// constructor
  const ImportListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final ScaffoldMessengerState sm = ScaffoldMessenger.of(context);
    final MeasurementDatabase db = MeasurementDatabase();
    return ListTile(
      dense: true,
      title: AutoSizeText(
        AppLocalizations.of(context)!.import,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
      ),
      subtitle: AutoSizeText(
        AppLocalizations.of(context)!.importSubtitle,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: IconButton(
        icon: PPIcon(PhosphorIconsDuotone.download, context),
        onPressed: () async {
          final bool accepted = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(
                    AppLocalizations.of(context)!.import,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.importDialog,
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
                          child: Text(AppLocalizations.of(context)!.abort)),
                    ),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      label: Text(AppLocalizations.of(context)!.yes),
                      icon: PPIcon(PhosphorIconsRegular.download, context),
                    ),
                  ],
                ),
              ) ??
              false;
          if (accepted) {
            final FilePickerResult? pickerResult =
                await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: <String>['txt'],
            );
            if (pickerResult != null &&
                pickerResult.files.single.path != null) {
              final File file = File(pickerResult.files.single.path!);
              final List<Measurement> newMeasurements = <Measurement>[];
              for (final String line in file.readAsLinesSync()) {
                // parse comments
                if (!line.startsWith('#')) {
                  newMeasurements
                      .add(Measurement.fromString(exportString: line));
                }
              }

              final int measurementCounts =
                  db.insertMeasurementList(newMeasurements);
              sm.showSnackBar(
                SnackBar(
                  content: Text('$measurementCounts measurements added'),
                  behavior: SnackBarBehavior.floating,
                  duration: TraleTheme.of(context)!.snackbarDuration,
                ),
              );
            } else {
              sm.showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.importingAbort,
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

/// ListTile for changing Amoled settings
class ResetListTile extends StatelessWidget {
  /// constructor
  const ResetListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: AutoSizeText(
        AppLocalizations.of(context)!.factoryReset,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
      ),
      subtitle: AutoSizeText(
        AppLocalizations.of(context)!.factoryResetSubtitle,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: IconButton(
        icon: PPIcon(PhosphorIconsDuotone.trash, context),
        onPressed: () async {
          final bool accepted = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(
                    AppLocalizations.of(context)!.factoryReset,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.factoryResetDialog,
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
                          child: Text(AppLocalizations.of(context)!.abort)),
                    ),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      label: Text(AppLocalizations.of(context)!.yes),
                      icon: PPIcon(PhosphorIconsRegular.trash, context),
                    ),
                  ],
                ),
              ) ??
              false;
          if (accepted) {
            Provider.of<TraleNotifier>(context, listen: false).factoryReset();
            // leave settings
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}

/// ListTile for changing Amoled settings
class AmoledListTile extends StatelessWidget {
  /// constructor
  const AmoledListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      dense: true,
      title: AutoSizeText(
        AppLocalizations.of(context)!.amoled,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
      ),
      subtitle: AutoSizeText(
        AppLocalizations.of(context)!.amoledSubtitle,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      value: Provider.of<TraleNotifier>(context).isAmoled,
      onChanged: (bool isAmoled) async {
        Provider.of<TraleNotifier>(context, listen: false).isAmoled = isAmoled;
      },
    );
  }
}

/// ListTile for changing Language settings
class LanguageListTile extends StatelessWidget {
  /// constructor
  const LanguageListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: 0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.language,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<String>(
        label: AutoSizeText(
          AppLocalizations.of(context)!.language,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        initialSelection: Provider.of<TraleNotifier>(context).language.language,
        dropdownMenuEntries: <DropdownMenuEntry<String>>[
          for (final Language lang in Language.supportedLanguages)
            DropdownMenuEntry<String>(
              value: lang.language,
              label: lang.languageLong(context),
            )
        ],
        onSelected: (String? lang) async {
          Provider.of<TraleNotifier>(context, listen: false).language =
              lang!.toLanguage();
        },
      ),
    );
  }
}

/// ListTile for changing units settings
class UnitsListTile extends StatelessWidget {
  /// constructor
  const UnitsListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: 0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.unit,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<TraleUnit>(
        initialSelection: Provider.of<TraleNotifier>(context).unit,
        label: AutoSizeText(
          AppLocalizations.of(context)!.unit,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        dropdownMenuEntries: <DropdownMenuEntry<TraleUnit>>[
          for (final TraleUnit unit in TraleUnit.values)
            DropdownMenuEntry<TraleUnit>(
              value: unit,
              label: unit.name,
            )
        ],
        onSelected: (TraleUnit? newUnit) async {
          if (newUnit != null) {
            Provider.of<TraleNotifier>(context, listen: false).unit = newUnit;
          }
        },
      ),
    );
  }
}

/// ListTile for changing units settings
class BackupIntervalListTile extends StatelessWidget {
  /// constructor
  const BackupIntervalListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: 0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.backupInterval,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<BackupInterval>(
        initialSelection: Provider.of<TraleNotifier>(context).backupInterval,
        label: AutoSizeText(
          AppLocalizations.of(context)!.backupInterval,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        dropdownMenuEntries: <DropdownMenuEntry<BackupInterval>>[
          for (final BackupInterval interval in BackupInterval.values)
            DropdownMenuEntry<BackupInterval>(
              value: interval,
              label: interval.name,
            )
        ],
        onSelected: (BackupInterval? newInterval) async {
          if (newInterval != null) {
            Provider.of<TraleNotifier>(context, listen: false).backupInterval =
                newInterval;
          }
        },
      ),
    );
  }
}

/// ListTile for changing units settings
class LastBackupListTile extends StatelessWidget {
  /// constructor
  const LastBackupListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime? nextBackupDate =
        Provider.of<TraleNotifier>(context).nextBackupDate;
    final DateTime? latestBackupDate =
        Provider.of<TraleNotifier>(context).latestBackupDate;

    String date2string(DateTime? date) => date == null
        ? AppLocalizations.of(context)!.never
        : Provider.of<TraleNotifier>(context, listen: false)
            .dateFormat(context)
            .format(date);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding,
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              AutoSizeText(
                AppLocalizations.of(context)!.lastBackup,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
              ),
              Text(
                date2string(latestBackupDate),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          SizedBox(height: TraleTheme.of(context)!.padding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              AutoSizeText(
                AppLocalizations.of(context)!.nextBackup,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
              ),
              Text(
                date2string(nextBackupDate),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ListTile for changing dark mode settings
class DarkModeListTile extends StatelessWidget {
  /// constructor
  const DarkModeListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: 0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.darkmode,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: SegmentedButton<ThemeMode>(
        selected: <ThemeMode>{Provider.of<TraleNotifier>(context).themeMode},
        showSelectedIcon: false,
        segments: <ButtonSegment<ThemeMode>>[
          for (final ThemeMode mode in orderedThemeModes)
            ButtonSegment<ThemeMode>(
              value: mode,
              tooltip: mode.nameLong(context),
              icon: PPIcon(
                Provider.of<TraleNotifier>(context).themeMode == mode
                    ? mode.activeIcon
                    : mode.icon,
                context,
              ),
            )
        ],
        onSelectionChanged: (Set<ThemeMode> newMode) async {
          Provider.of<TraleNotifier>(context, listen: false).themeMode =
              newMode.first;
        },
      ),
    );
  }
}

/// ListTile for changing interpolation settings
class InterpolationSetting extends StatelessWidget {
  /// constructor
  const InterpolationSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final Widget sliderTile = Container(
      padding: EdgeInsets.fromLTRB(
        2 * TraleTheme.of(context)!.padding,
        0.5 * TraleTheme.of(context)!.padding,
        TraleTheme.of(context)!.padding,
        0.5 * TraleTheme.of(context)!.padding,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          AutoSizeText(
            AppLocalizations.of(context)!.strength.inCaps,
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 1,
          ),
          Slider(
            value: Provider.of<TraleNotifier>(context)
                .interpolStrength.idx.toDouble(),
            divisions: InterpolStrength.values.length - 1,
            min: 0.0,
            max: InterpolStrength.values.length.toDouble() - 1,
            label: Provider.of<TraleNotifier>(context).interpolStrength.name,
            onChanged: (double newStrength) async {
              Provider.of<TraleNotifier>(
                  context, listen: false
              ).interpolStrength = InterpolStrength.values[newStrength.toInt()];
            },
          ),
        ],
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: TraleTheme.of(context)!.padding,
            vertical: 0.5 * TraleTheme.of(context)!.padding,
          ),
          height: 0.5 * MediaQuery.of(context).size.width,
          child: Card(
            shape: TraleTheme.of(context)!.borderShape,
            margin: EdgeInsets.symmetric(
              horizontal: TraleTheme.of(context)!.padding,
            ),
            child: CustomLineChart(
              loadedFirst: false,
              ip: PreviewInterpolation(),
              isPreview: true,
            ),
          ),
        ),
        sliderTile,
      ],
    );
  }
}

/// ListTile for changing interpolation settings
class ThemeSelection extends StatelessWidget {
  /// constructor
  const ThemeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    /// Used to adjust themeMode to dark or light
    final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(context);
    final bool isDark = traleNotifier.themeMode == ThemeMode.dark ||
        (traleNotifier.themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    return ListView.builder(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: TraleCustomTheme.values.length,
        itemBuilder: (BuildContext context, int index) {
          final TraleCustomTheme ctheme = TraleCustomTheme.values[index];
          if (!traleNotifier.systemColorsAvailable &&
              ctheme == TraleCustomTheme.system) {
            return const SizedBox.shrink();
          }
          return GestureDetector(
            onTap: () {
              traleNotifier.theme = TraleCustomTheme.values[index];
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          TraleTheme.of(context)!.borderShape.borderRadius,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      color: (isDark
                              ? traleNotifier.isAmoled
                                  ? ctheme.dark(context).amoled
                                  : ctheme.dark(context)
                              : ctheme.light(context))
                          .themeData
                          .colorScheme
                          .surface,
                    ),
                    width: 0.2 * MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(TraleTheme.of(context)!.padding),
                    child: Container(
                      margin: EdgeInsets.all(
                          0.04 * MediaQuery.of(context).size.width),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          AutoSizeText(
                            ctheme.name,
                            style: isDark
                                ? ctheme
                                    .dark(context)
                                    .themeData
                                    .textTheme
                                    .labelSmall
                                : ctheme
                                    .light(context)
                                    .themeData
                                    .textTheme
                                    .labelSmall,
                            maxLines: 1,
                          ),
                          Divider(
                            height: 5,
                            color: (isDark
                                    ? ctheme.dark(context)
                                    : ctheme.light(context))
                                .themeData
                                .colorScheme
                                .onSurface,
                          ),
                          AutoSizeText(
                            'wwwwwwwwww',
                            style: isDark
                                ? ctheme
                                    .dark(context)
                                    .themeData
                                    .textTheme
                                    .labelSmall
                                : ctheme
                                    .light(context)
                                    .themeData
                                    .textTheme
                                    .labelSmall,
                            maxLines: 2,
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: TraleTheme.of(context)!
                                  .borderShape
                                  .borderRadius,
                              color: (isDark
                                      ? ctheme.dark(context)
                                      : ctheme.light(context))
                                  .themeData
                                  .colorScheme
                                  .primary,
                            ),
                            height: 0.05 * MediaQuery.of(context).size.width,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Radio<TraleCustomTheme>(
                  value: TraleCustomTheme.values[index],
                  groupValue: traleNotifier.theme,
                  onChanged: (TraleCustomTheme? theme) {
                    if (theme != null) {
                      traleNotifier.theme = theme;
                    }
                  },
                ),
              ],
            ),
          );
        });
  }
}

class FirstDayListTile extends StatelessWidget {
  /// constructor
  const FirstDayListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(context);
    return FutureBuilder<void>(
      future: TraleFirstDayExtension.loadLocalizedNames(locale),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 2 * TraleTheme.of(context)!.padding,
            vertical: 0.5 * TraleTheme.of(context)!.padding,
          ),
          title: AutoSizeText(
            AppLocalizations.of(context)!.firstDay,
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 1,
          ),
          trailing: DropdownMenu<TraleFirstDay>(
            initialSelection: traleNotifier.firstDay,
            label: AutoSizeText(
              AppLocalizations.of(context)!.firstDay,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
            ),
            dropdownMenuEntries: <DropdownMenuEntry<TraleFirstDay>>[
              for (final TraleFirstDay firstDay in TraleFirstDay.values)
                DropdownMenuEntry<TraleFirstDay>(
                  value: firstDay,
                  label:
                      TraleFirstDayExtension.getLocalizedName(firstDay, locale),
                )
            ],
            onSelected: (TraleFirstDay? newFirstDay) async {
              if (newFirstDay != null) {
                traleNotifier.firstDay = newFirstDay;
              }
            },
          ),
        );
      },
    );
  }
}

class DatePrintListTile extends StatelessWidget {
  /// constructor
  const DatePrintListTile({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch the current date print format from the provider
    final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(context);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: 0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        'Format',
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<TraleDatePrintFormat>(
        initialSelection: Provider.of<TraleNotifier>(context).datePrintFormat,
        label: AutoSizeText(
          'Format',
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        dropdownMenuEntries: <DropdownMenuEntry<TraleDatePrintFormat>>[
          for (final TraleDatePrintFormat datePrintFormat
              in TraleDatePrintFormat.values)
            DropdownMenuEntry<TraleDatePrintFormat>(
              value: datePrintFormat,
              label: datePrintFormat.pattern ?? 'Default',
            )
        ],
        onSelected: (TraleDatePrintFormat? newDatePrintFormat) async {
          if (newDatePrintFormat != null) {
            traleNotifier.datePrintFormat = newDatePrintFormat;
          }
        },
      ),
    );
  }
}

/// ListTile for changing LooseWeight mode
class LooseWeightListTile extends StatelessWidget {
  /// constructor
  const LooseWeightListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      dense: true,
      title: AutoSizeText(
        AppLocalizations.of(context)!.looseWeight,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
      ),
      subtitle: AutoSizeText(
        AppLocalizations.of(context)!.looseWeightSubtitle,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      value: Provider.of<TraleNotifier>(context).looseWeight,
      onChanged: (bool loose) async {
        Provider.of<TraleNotifier>(context, listen: false).looseWeight = loose;
      },
    );
  }
}

/// about screen widget class
class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _Settings createState() => _Settings();
}

class _Settings extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: TraleTheme.of(context)!.padding,
    );
    Widget settingsList() {
      return ListView(
        children: <Widget>[
          Padding(
            padding: padding,
            child: AutoSizeText(
              AppLocalizations.of(context)!.theme.inCaps,
              style: Theme.of(context).textTheme.headlineMedium,
              maxLines: 1,
            ),
          ),
          ColoredContainer(
            height: 0.7 * MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            child: const ThemeSelection(),
          ),
          const DarkModeListTile(),
          const AmoledListTile(),
          Divider(
            height: 2 * TraleTheme.of(context)!.padding,
          ),
          Padding(
            padding: padding,
            child: AutoSizeText(
              AppLocalizations.of(context)!.interpolation.inCaps,
              style: Theme.of(context).textTheme.headlineMedium,
              maxLines: 1,
            ),
          ),
          const InterpolationSetting(),
          Divider(
            height: 2 * TraleTheme.of(context)!.padding,
          ),
          Padding(
            padding: padding,
            child: AutoSizeText(
              AppLocalizations.of(context)!.userSettings.inCaps,
              style: Theme.of(context).textTheme.headlineMedium,
              maxLines: 1,
            ),
          ),
          const LanguageListTile(),
          const UnitsListTile(),
          const FirstDayListTile(),
          const DatePrintListTile(),
          Divider(
            height: 2 * TraleTheme.of(context)!.padding,
          ),
          Padding(
            padding: padding,
            child: AutoSizeText(
              AppLocalizations.of(context)!.backup.inCaps,
              style: Theme.of(context).textTheme.headlineMedium,
              maxLines: 1,
            ),
          ),
          const ExportListTile(),
          const ImportListTile(),
          const BackupIntervalListTile(),
          const LastBackupListTile(),
          Divider(
            height: 2 * TraleTheme.of(context)!.padding,
          ),
          Padding(
            padding: padding,
            child: AutoSizeText(
              AppLocalizations.of(context)!.experimentalFeatures.inCaps,
              style: Theme.of(context).textTheme.headlineMedium,
              maxLines: 1,
            ),
          ),
          const LooseWeightListTile(),
          SizedBox(height: TraleTheme.of(context)!.padding),
          Divider(
            height: 2 * TraleTheme.of(context)!.padding,
          ),
          Padding(
            padding: padding,
            child: AutoSizeText(
              AppLocalizations.of(context)!.dangerzone.inCaps,
              style: Theme.of(context).textTheme.headlineMedium,
              maxLines: 1,
            ),
          ),
          const ResetListTile(),
          SizedBox(height: TraleTheme.of(context)!.padding),
        ],
      );
    }

    Widget appBar() {
      return CustomSliverAppBar(
        title: AutoSizeText(
          AppLocalizations.of(context)!.settings.allInCaps,
          style: Theme.of(context).textTheme.headlineMedium,
          maxLines: 1,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(PhosphorIconsDuotone.arrowLeft),
        ),
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool _) {
              return <Widget>[appBar()];
            },
            body: settingsList(),
          ),
        ),
      ),
    );
  }
}
