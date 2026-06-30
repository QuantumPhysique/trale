import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/health_connect_service.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/trale_notifier.dart';

/// Settings page for configuring Health Connect integration.
class HealthConnectSettingsPage extends StatefulWidget {
  /// Constructor.
  const HealthConnectSettingsPage({super.key});

  @override
  State<HealthConnectSettingsPage> createState() =>
      _HealthConnectSettingsPageState();
}

class _HealthConnectSettingsPageState extends State<HealthConnectSettingsPage> {
  bool _isAvailable = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final bool available = await HealthConnectService().isAvailable();
    if (mounted) {
      setState(() {
        _isAvailable = available;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);
    final QPTheme? qpTheme = QPTheme.of(context);
    final double pad = qpTheme!.padding;
    final double bpad = qpTheme.bentoPadding;
    final ShapeBorder shape = qpTheme.borderShape;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.healthConnect)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                  padding: EdgeInsets.all(pad),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(<Widget>[
                      if (!_isAvailable)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: pad),
                          child: Text(
                            context.l10n.healthConnectNotAvailable,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else ...<Widget>[
                        // Privacy warning card
                        Card(
                          margin: EdgeInsets.only(bottom: pad),
                          color: Theme.of(context).colorScheme.errorContainer,
                          shape: shape,
                          elevation: 0,
                          child: Padding(
                            padding: EdgeInsets.all(pad),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      PhosphorIconsBold.warning,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                    ),
                                    SizedBox(width: bpad),
                                    Text(
                                      context.l10n.healthConnectWarningTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onErrorContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: bpad),
                                Text(
                                  context.l10n.healthConnectWarningText,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Master enable/disable group
                        QPWidgetGroup(
                          title: context.l10n.healthConnect,
                          children: <Widget>[
                            QPGroupedSwitchListTile(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLowest,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: pad,
                              ),
                              title: Text(context.l10n.healthConnectEnable),
                              value: notifier.healthConnectEnabled,
                              onChanged: (bool? value) async {
                                final bool val = value ?? false;
                                if (val) {
                                  final bool granted =
                                      await HealthConnectService()
                                          .requestPermissions(
                                            read: true,
                                            write: true,
                                          );
                                  if (granted) {
                                    notifier.healthConnectEnabled = true;
                                  } else {
                                    if (context.mounted) {
                                      final String msg = context
                                          .l10n
                                          .healthConnectPermissionsRequired;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(msg)),
                                      );
                                    }
                                  }
                                } else {
                                  notifier.healthConnectEnabled = false;
                                  notifier.healthConnectImportEnabled = false;
                                  notifier.healthConnectExportEnabled = false;
                                  unawaited(
                                    HealthConnectService().revokePermissions(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: pad),

                        // Sub-settings group (disabled if master switch is off)
                        QPWidgetGroup(
                          title: context.l10n.dataSettings,
                          children: <Widget>[
                            QPGroupedSwitchListTile(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLowest,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: pad,
                              ),
                              title: Text(context.l10n.healthConnectImport),
                              subtitle: Text(
                                context.l10n.healthConnectImportDesc,
                              ),
                              value: notifier.healthConnectImportEnabled,
                              onChanged: notifier.healthConnectEnabled
                                  ? (bool? value) async {
                                      final bool val = value ?? false;
                                      if (val) {
                                        final bool hasRead =
                                            await HealthConnectService()
                                                .hasPermissions(
                                                  read: true,
                                                  write: false,
                                                );
                                        if (!hasRead) {
                                          final bool granted =
                                              await HealthConnectService()
                                                  .requestPermissions(
                                                    read: true,
                                                    write: false,
                                                  );
                                          if (!granted) {
                                            return;
                                          }
                                        }
                                      }
                                      notifier.healthConnectImportEnabled = val;
                                    }
                                  : null,
                            ),
                            QPGroupedSwitchListTile(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLowest,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: pad,
                              ),
                              title: Text(context.l10n.healthConnectExport),
                              subtitle: Text(
                                context.l10n.healthConnectExportDesc,
                              ),
                              value: notifier.healthConnectExportEnabled,
                              onChanged: notifier.healthConnectEnabled
                                  ? (bool? value) async {
                                      final bool val = value ?? false;
                                      if (val) {
                                        final bool hasWrite =
                                            await HealthConnectService()
                                                .hasPermissions(
                                                  read: false,
                                                  write: true,
                                                );
                                        if (!hasWrite) {
                                          final bool granted =
                                              await HealthConnectService()
                                                  .requestPermissions(
                                                    read: false,
                                                    write: true,
                                                  );
                                          if (!granted) {
                                            return;
                                          }
                                        }
                                      }
                                      notifier.healthConnectExportEnabled = val;
                                    }
                                  : null,
                            ),
                          ],
                        ),

                        SizedBox(height: pad),

                        // Action sync buttons
                        QPWidgetGroup(
                          children: <Widget>[
                            QPGroupedListTile(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLowest,
                              title: Text(context.l10n.healthConnectSyncNow),
                              enabled:
                                  notifier.healthConnectEnabled &&
                                  (notifier.healthConnectImportEnabled ||
                                      notifier.healthConnectExportEnabled),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: pad,
                              ),
                              trailing: IconButton(
                                icon: PPIcon(
                                  PhosphorIconsDuotone.arrowsClockwise,
                                  context,
                                ),
                                onPressed:
                                    (notifier.healthConnectEnabled &&
                                        (notifier.healthConnectImportEnabled ||
                                            notifier
                                                .healthConnectExportEnabled))
                                    ? () async {
                                        showDialog<void>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (_) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                        final Map<String, int> result =
                                            await HealthConnectService().sync();
                                        final int imported =
                                            result['imported'] ?? 0;
                                        final int exported =
                                            result['exported'] ?? 0;
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                          final String msg = context.l10n
                                              .healthConnectSyncSuccess(
                                                importCount: imported,
                                                exportCount: exported,
                                              );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(content: Text(msg)),
                                          );
                                        }
                                      }
                                    : null,
                              ),
                            ),
                            QPGroupedListTile(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLowest,
                              title: Text(
                                context.l10n.healthConnectImportHistory,
                              ),
                              enabled:
                                  notifier.healthConnectEnabled &&
                                  notifier.healthConnectImportEnabled,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: pad,
                              ),
                              trailing: IconButton(
                                icon: PPIcon(
                                  PhosphorIconsDuotone.downloadSimple,
                                  context,
                                ),
                                onPressed:
                                    (notifier.healthConnectEnabled &&
                                        notifier.healthConnectImportEnabled)
                                    ? () async {
                                        showDialog<void>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (_) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                        final int imported =
                                            await HealthConnectService()
                                                .importMeasurements(
                                                  ignoreOwnOrigin: true,
                                                );
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                          final String msg = context.l10n
                                              .healthConnectImportSuccess(
                                                count: imported,
                                              );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(content: Text(msg)),
                                          );
                                        }
                                      }
                                    : null,
                              ),
                            ),
                            QPGroupedListTile(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLowest,
                              title: Text(
                                context.l10n.healthConnectExportHistory,
                              ),
                              enabled:
                                  notifier.healthConnectEnabled &&
                                  notifier.healthConnectExportEnabled,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: pad,
                              ),
                              trailing: IconButton(
                                icon: PPIcon(
                                  PhosphorIconsDuotone.export,
                                  context,
                                ),
                                onPressed:
                                    (notifier.healthConnectEnabled &&
                                        notifier.healthConnectExportEnabled)
                                    ? () async {
                                        showDialog<void>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (_) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                        final int exported =
                                            await HealthConnectService()
                                                .exportAllMeasurements();
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                          final String msg = context.l10n
                                              .healthConnectExportSuccess(
                                                count: exported,
                                              );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(content: Text(msg)),
                                          );
                                        }
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}
