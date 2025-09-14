import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/pages/home.dart';
import 'package:trale/pages/settingsLanguage.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
class SettingsOverviewPage extends StatelessWidget {
  const SettingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {

    List<Widget> sliverlist = <Widget>[
      _SettingsSection(
        children: const <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.faders,
            title: 'Personalization',
            subtitle: 'Customize your experience',
          ),
          _SettingsTile(
            icon: PhosphorIconsDuotone.palette,
            title: 'Theme',
            subtitle: 'Set the color scheme',
          ),
          _SettingsTile(
            icon: PhosphorIconsDuotone.lineSegments,
            title: 'Interpolation',
            subtitle: 'Choose a interpolation strength',
          ),
        ],
      ),
      SizedBox(height: TraleTheme.of(context)!.padding),
      _SettingsSection(
        children: <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.globe,
            title: 'Language',
            subtitle: 'English (United States)',
            pageRoute: MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => const LanguageSettingsPage(),
            ),
          ),
          const _SettingsTile(
            icon: PhosphorIconsDuotone.ruler,
            title: 'Units',
            subtitle: 'weight in kg and height in cm',
          ),
        ],
      ),
      SizedBox(height: TraleTheme.of(context)!.padding),
      _SettingsSection(
        children: const <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.database,
            title: 'Import and export',
            subtitle: 'Save and load your data',
          ),
        ],
      ),
      SizedBox(height: TraleTheme.of(context)!.padding),
      _SettingsSection(
        children: <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.question,
            title: AppLocalizations.of(context)!.faq,
            subtitle: 'Learn more about the app',
          ),
          _SettingsTile(
            icon: PhosphorIconsDuotone.info,
            title: AppLocalizations.of(context)!.about,
            subtitle: 'Learn more about the app',
          ),
        ],
      ),
      SizedBox(height: TraleTheme.of(context)!.padding),
      _SettingsSection(
        children: <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.warning,
            title: AppLocalizations.of(context)!.dangerzone,
            subtitle: 'Delete all data and reset the app',
            trailing: _ExperimentalBadge(),
          ),
        ],
      ),
    ];

    return Scaffold(
      body: SliverAppBarSnap(
        title: AppLocalizations.of(context)!.settings,
        sliverlist: sliverlist,
        returnPage: const Home(),
      ),
    );
  }
}

/// A rounded section that groups a list of tiles and draws dividers between theme.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: TraleTheme.of(context)!.borderShape,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: _withDividers(context, children),
      ),
    );
  }

  List<Widget> _withDividers(BuildContext context, List<Widget> items) {
    final List<Widget> result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i != items.length - 1) {
        result.add(
          Container(
            height: TraleTheme.of(context)!.space,
            color: Theme.of(context).colorScheme.surface,
          ),
        );
      }
    }
    return result;
  }
}

/// Rounded tile with icon, title, subtitle and optional trailing widget.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.pageRoute,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final PageRoute<dynamic>? pageRoute;

  @override
  Widget build(BuildContext context) {
    final Widget content = ListTile(
      // Remove inner padding so content spans full width
      contentPadding: EdgeInsets.zero,
      leading: PPIcon(icon, context),
      title: AutoSizeText(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      subtitle: AutoSizeText(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 1,
      ),
      trailing: trailing,
      onTap: () {
        if (pageRoute != null) {
          Navigator.of(context).push<dynamic>(pageRoute!);
        }
      },
    );

    return Card(
      // Remove default Card margin so tile fills parent width/height
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: TraleTheme.of(context)!.borderShape.copyWith(
        borderRadius: BorderRadius.circular(
          TraleTheme.of(context)!.padding / 4,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: TraleTheme.of(context)!.padding
        ),
        child: content,
      ),
    );
  }
}


class _ExperimentalBadge extends StatelessWidget {
  const _ExperimentalBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: EdgeInsets.all(
        TraleTheme.of(context)!.padding,
      ),
      child: Text(
        'Experimental',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}