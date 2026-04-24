import 'package:flutter/material.dart';
import 'package:quantumphysique/src/types/icons.dart';
import 'package:quantumphysique/src/types/string_extension.dart';
import 'package:quantumphysique/src/types/strings.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';
import 'package:quantumphysique/src/widgets/sliver_app_bar_snap.dart';
import 'package:quantumphysique/src/widgets/tile_group/tile_group.dart';

/// A single entry in a [QPSettingsGroup].
class QPSettingsTile {
  /// Creates a [QPSettingsTile].
  const QPSettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  /// Leading icon.
  final IconData icon;

  /// Tile title.
  final String title;

  /// Tile subtitle.
  final String subtitle;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;
}

/// A titled group of [QPSettingsTile]s displayed in the overview page.
class QPSettingsGroup {
  /// Creates a [QPSettingsGroup].
  const QPSettingsGroup({required this.title, required this.tiles});

  /// Section title.
  final String title;

  /// Tiles in this group.
  final List<QPSettingsTile> tiles;
}

/// Settings overview page composed of [QPSettingsGroup] sections.
///
/// Apps build the [groups] list, optionally prepend a [headerWidget]
/// (e.g. a donation banner), and optionally append a [footerWidget].
class QPSettingsOverviewPage extends StatelessWidget {
  /// Creates a [QPSettingsOverviewPage].
  const QPSettingsOverviewPage({
    required this.strings,
    required this.groups,
    this.headerWidget,
    this.footerWidget,
    super.key,
  });

  /// Localised strings.
  final QPStrings strings;

  /// Setting groups to display.
  final List<QPSettingsGroup> groups;

  /// Optional widget shown before the first group (e.g. [SettingsBanner]).
  final Widget? headerWidget;

  /// Optional widget shown after the last group (e.g. version text).
  final Widget? footerWidget;

  @override
  Widget build(BuildContext context) {
    final List<Widget> sliverList = <Widget>[
      if (headerWidget != null) headerWidget!,
      for (final QPSettingsGroup group in groups)
        QPWidgetGroup(
          title: group.title,
          children: group.tiles
              .map((QPSettingsTile tile) => _SettingsTile(tile: tile))
              .toList(),
        ),
      if (footerWidget != null) footerWidget!,
    ];

    return Scaffold(
      body: QPSliverAppBarSnap(title: strings.settings, sliverlist: sliverList),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.tile});

  final QPSettingsTile tile;

  @override
  Widget build(BuildContext context) {
    return QPGroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: QPLayout.padding),
      leading: PPIcon(tile.icon, context),
      title: Text(
        tile.title.inCaps,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      subtitle: Text(
        tile.subtitle.inCaps,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 1,
      ),
      onTap: tile.onTap,
    );
  }
}
