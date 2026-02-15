import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/backupInterval.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
import 'package:trale/widget/ioWidgets.dart';
import 'package:trale/widget/tile_group.dart';

class ExportSettingsPage extends StatefulWidget {
  const ExportSettingsPage({super.key});

  @override
  State<ExportSettingsPage> createState() => _ExportSettingsPageState();
}

class _ExportSettingsPageState extends State<ExportSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final DateTime? nextBackupDate = Provider.of<TraleNotifier>(
      context,
    ).nextBackupDate;
    final DateTime? latestBackupDate = Provider.of<TraleNotifier>(
      context,
    ).latestBackupDate;

    String date2string(DateTime? date) => date == null
        ? AppLocalizations.of(context)!.never
        : Provider.of<TraleNotifier>(
            context,
            listen: false,
          ).dateFormat(context).format(date);

    final List<Widget> sliverList = <Widget>[
      WidgetGroup(
        title: AppLocalizations.of(context)!.export,
        children: <Widget>[
          const ExportListTile(),
          const BackupIntervalListTile(),
          GroupedListTile(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                AutoSizeText(
                  AppLocalizations.of(context)!.lastBackup.inCaps,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 1,
                ),
                Text(
                  date2string(latestBackupDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          GroupedListTile(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                AutoSizeText(
                  AppLocalizations.of(context)!.nextBackup.inCaps,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 1,
                ),
                Text(
                  date2string(nextBackupDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
      WidgetGroup(
        title: AppLocalizations.of(context)!.import,
        children: const <Widget>[ImportListTile()],
      ),
      GroupedText(
        text: Text(
          AppLocalizations.of(context)!.importLongDescription,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.justify,
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: TraleTheme.of(context)!.padding,
        ),
        child: WidgetGroup(
          children: <GroupedText>[
            for (final String fmt in <String>[
              '2025-12-24T16:00 67.9',
              '2025-12-24 67.9',
            ])
              GroupedText(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                text: Text(
                  fmt,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.justify,
                ),
              ),
          ],
        ),
      ),
      WidgetGroup(
        title: AppLocalizations.of(context)!.dangerzone,
        children: const <Widget>[ResetListTile()],
      ),
    ];

    return Scaffold(
      body: SliverAppBarSnap(
        title: AppLocalizations.of(context)!.importAndExport,
        sliverlist: sliverList,
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
    return GroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding,
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
            ),
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

/// ListTile for changing Amoled settings
class ExportListTile extends StatelessWidget {
  /// constructor
  const ExportListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      title: AutoSizeText(
        AppLocalizations.of(context)!.export,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
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
    return GroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      title: AutoSizeText(
        AppLocalizations.of(context)!.import,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
      ),
      subtitle: AutoSizeText(
        AppLocalizations.of(context)!.importSubtitle,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: IconButton(
        icon: PPIcon(PhosphorIconsDuotone.download, context),
        onPressed: () async {
          await importBackup(context);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
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
    return GroupedListTile(
      color: Theme.of(context).colorScheme.errorContainer,
      title: AutoSizeText(
        AppLocalizations.of(context)!.factoryReset,
        style: Theme.of(context).textTheme.bodyLarge!.apply(
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
        maxLines: 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
      ),
      subtitle: AutoSizeText(
        AppLocalizations.of(context)!.factoryResetSubtitle,
        style: Theme.of(context).textTheme.labelSmall!.apply(
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      trailing: IconButton(
        icon: PPIcon(
          PhosphorIconsDuotone.trash,
          context,
          duotoneSecondaryColor: Theme.of(context).colorScheme.onError,
        ),
        onPressed: () async {
          final bool accepted =
              await showDialog<bool>(
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
                        child: Text(AppLocalizations.of(context)!.abort),
                      ),
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
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
