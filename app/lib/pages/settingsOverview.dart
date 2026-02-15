// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/pages/about.dart';
import 'package:trale/pages/faq.dart';
import 'package:trale/pages/settingsPersonalization.dart';
import 'package:trale/pages/settings_export.dart';
import 'package:trale/pages/settings_language.dart';
import 'package:trale/pages/settings_reminder.dart';
import 'package:trale/pages/settings_theme.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
import 'package:trale/widget/settingsBanner.dart';
import 'package:trale/widget/sinewave.dart';
import 'package:trale/widget/tile_group.dart';

/// Settings overview page.
class SettingsOverviewPage extends StatelessWidget {
  /// Constructor.
  const SettingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> sliverlist = <Widget>[
      SettingsBanner(
        leadingIcon: PhosphorIconsBold.handHeart,
        title: AppLocalizations.of(context)!.donation,
        subtitle: AppLocalizations.of(context)!.donationSubtitle,
        url: 'https://ko-fi.com/quantumphysique',
        // TODO(gwosd): Update URL to donation page
      ),
      const SineWave(),
      WidgetGroup(
        title: AppLocalizations.of(context)!.customization,
        children: <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.faders,
            title: AppLocalizations.of(context)!.personalizationTitle,
            subtitle: AppLocalizations.of(context)!.personalizationSubtitle,
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) =>
                    const PersonalizationSettingsPage(),
              ),
            ),
          ),
          _SettingsTile(
            icon: PhosphorIconsDuotone.palette,
            title: AppLocalizations.of(context)!.theme,
            subtitle: AppLocalizations.of(context)!.themeSubtitle,
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const ThemeSettingsPage(),
              ),
            ),
          ),
          _SettingsTile(
            icon: PhosphorIconsDuotone.globe,
            title: AppLocalizations.of(context)!.language,
            subtitle: AppLocalizations.of(context)!.languageSubtitle,
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const LanguageSettingsPage(),
              ),
            ),
          ),
        ],
      ),
      WidgetGroup(
        title: AppLocalizations.of(context)!.notifications,
        children: <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.bellRinging,
            title: AppLocalizations.of(context)!.reminderTitle,
            subtitle: AppLocalizations.of(context)!.reminderSubtitle,
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const ReminderSettingsPage(),
              ),
            ),
          ),
        ],
      ),
      WidgetGroup(
        title: AppLocalizations.of(context)!.dataSettings,
        children: <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.database,
            title: AppLocalizations.of(context)!.importAndExport,
            subtitle: AppLocalizations.of(context)!.importAndExportSubtitle,
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const ExportSettingsPage(),
              ),
            ),
          ),
        ],
      ),
      WidgetGroup(
        title: AppLocalizations.of(context)!.aboutTheApp,
        children: <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.question,
            title: AppLocalizations.of(context)!.faq,
            subtitle: AppLocalizations.of(context)!.faqSubtitle,
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const FAQ(),
              ),
            ),
          ),
          _SettingsTile(
            icon: PhosphorIconsDuotone.info,
            title: AppLocalizations.of(context)!.about,
            subtitle: AppLocalizations.of(context)!.aboutSubtitle,
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

/// A rounded section that groups a list of tiles
/// and draws dividers between theme.
/// Rounded tile with icon, title, subtitle and optional trailing widget.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      // Remove inner padding so content spans full width
      contentPadding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
      ),
      leading: PPIcon(icon, context),
      title: Text(
        title.inCaps,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      subtitle: Text(
        subtitle.inCaps,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 1,
      ),
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
    );
  }
}
