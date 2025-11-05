import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/backupInterval.dart';
import 'package:trale/core/firstDay.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/interpolationPreview.dart';
import 'package:trale/core/printFormat.dart';

import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
import 'package:trale/widget/ioWidgets.dart';
import 'package:trale/widget/linechart.dart';
import 'package:trale/widget/tile_group.dart';
import 'package:trale/widget/userDialog.dart';

class ExportSettingsPage extends StatefulWidget {
  const ExportSettingsPage({super.key});

  @override
  State<ExportSettingsPage> createState() => _ExportSettingsPageState();
}

class _ExportSettingsPageState extends State<ExportSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final TraleNotifier notifier =
      Provider.of<TraleNotifier>(context, listen: false);

      final List<Widget> sliverlist = <Widget>[
        WidgetGroup(
          children:  <Widget>[
              const ExportListTile(),
              const ImportListTile(),
              const BackupIntervalListTile(),
              const LastBackupListTile(),
            ],
        ),
      ];

      return Scaffold(
        body: SliverAppBarSnap(
          title: AppLocalizations.of(context)!.backup,
          sliverlist: sliverlist,
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


/// ListTile for changing Amoled settings
class ExportListTile extends StatelessWidget {
  /// constructor
  const ExportListTile({super.key});

  @override
  Widget build(BuildContext context) {
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
        onPressed: () => importBackup(context),
      ),
    );
  }
}