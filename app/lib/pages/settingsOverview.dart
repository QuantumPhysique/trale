import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/pages/about.dart';
import 'package:trale/pages/faq.dart';
import 'package:trale/pages/settings_export.dart';
import 'package:trale/pages/settingsPersonalization.dart';
import 'package:trale/pages/settingsLanguage.dart';
import 'package:trale/pages/settingsTheme.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
import 'package:trale/widget/settingsBanner.dart';
import 'package:trale/widget/sinewave.dart';
import 'package:trale/widget/tile_group.dart';

class SettingsOverviewPage extends StatelessWidget {
  const SettingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Widget> sliverlist = <Widget>[
      SettingsBanner(
        leadingIcon: PhosphorIconsBold.handHeart,
        title: 'Donation',
        subtitle: 'Support the development of trale',
        url: 'https://ko-fi.com/quantumphysique',
        // TODO(gwosd): Update URL to donation page
      ),
      const SineWave(),
      WidgetGroup(
        title: 'Customization',
        children: <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.faders,
            title: 'Personalization',
            subtitle: 'Customize your experience',
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context)
                  => const PersonalizationSettingsPage(),
              ),
            ),
          ),
          _SettingsTile(
            icon: PhosphorIconsDuotone.palette,
            title: 'Theme',
            subtitle: 'Set the color scheme',
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context)
                => const ThemeSettingsPage(),
              ),
            ),
          ),
          _SettingsTile(
            icon: PhosphorIconsDuotone.globe,
            title: 'Language',
            subtitle: 'English (United States)',
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context)
                  => const LanguageSettingsPage(),
              ),
            ),
          ),
        ],
      ),
      WidgetGroup(
        title: 'Data settings',
        children: <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.database,
            title: 'Import and export',
            subtitle: 'Save and load your data',
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context)
                  => const ExportSettingsPage(),
              ),
            ),
          ),
        ],
      ),
      WidgetGroup(
        title: 'About the app',
        children: <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.question,
            title: AppLocalizations.of(context)!.faq,
            subtitle: 'Learn more about the app',
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const FAQ(),
              ),
            ),
          ),
          _SettingsTile(
            icon: PhosphorIconsDuotone.info,
            title: AppLocalizations.of(context)!.about,
            subtitle: 'Learn more about the app',
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const About(),
              ),
            ),
          ),
        ],
      ),
    ];

    return Scaffold(
      body: SliverAppBarSnap(
        title: AppLocalizations.of(context)!.settings,
        sliverlist: sliverlist,
      ),
    );
  }
}

/// A rounded section that groups a list of tiles and draws dividers between theme.
/// Rounded tile with icon, title, subtitle and optional trailing widget.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;



  @override
  Widget build(BuildContext context) {

    return GroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      // Remove inner padding so content spans full width
      contentPadding: EdgeInsets.symmetric(
          horizontal: TraleTheme.of(context)!.padding
      ),
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
        if (onTap != null) {
          onTap!();
        }
      },
    );
  }
}