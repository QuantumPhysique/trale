import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/pages/about.dart';
import 'package:trale/pages/faq.dart';
import 'package:trale/pages/settings_export.dart';
import 'package:trale/pages/settings_language.dart';
import 'package:trale/pages/settings_personalization.dart';
import 'package:trale/pages/settings_reminder.dart';
import 'package:trale/pages/settings_theme.dart';
import 'package:trale/widget/custom_scroll_view_snapping.dart';
import 'package:trale/widget/sinewave.dart';

/// Settings overview page.
class SettingsOverviewPage extends StatelessWidget {
  /// Constructor.
  const SettingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> sliverlist = <Widget>[
      QPSettingsBanner(
        leadingIcon: PhosphorIconsBold.handHeart,
        title: context.l10n.donation,
        subtitle: context.l10n.donationSubtitle,
        url: 'https://ko-fi.com/quantumphysique',
        // TODO(gwosd): Update URL to donation page
      ),
      const SineWave(),
      QPWidgetGroup(
        title: context.l10n.customization,
        children: <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.faders,
            title: context.l10n.personalizationTitle,
            subtitle: context.l10n.personalizationSubtitle,
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) =>
                    const PersonalizationSettingsPage(),
              ),
            ),
          ),
          _SettingsTile(
            icon: PhosphorIconsDuotone.palette,
            title: context.l10n.theme,
            subtitle: context.l10n.themeSubtitle,
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const ThemeSettingsPage(),
              ),
            ),
          ),
          _SettingsTile(
            icon: PhosphorIconsDuotone.globe,
            title: context.l10n.language,
            subtitle: context.l10n.languageSubtitle,
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const LanguageSettingsPage(),
              ),
            ),
          ),
        ],
      ),
      QPWidgetGroup(
        title: context.l10n.notifications,
        children: <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.bellRinging,
            title: context.l10n.reminderTitle,
            subtitle: context.l10n.reminderSubtitle,
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const ReminderSettingsPage(),
              ),
            ),
          ),
        ],
      ),
      QPWidgetGroup(
        title: context.l10n.dataSettings,
        children: <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.database,
            title: context.l10n.importAndExport,
            subtitle: context.l10n.importAndExportSubtitle,
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const ExportSettingsPage(),
              ),
            ),
          ),
        ],
      ),
      QPWidgetGroup(
        title: context.l10n.aboutTheApp,
        children: <Widget>[
          _SettingsTile(
            icon: PhosphorIconsDuotone.question,
            title: context.l10n.faq,
            subtitle: context.l10n.faqSubtitle,
            onTap: () => Navigator.of(context).push<dynamic>(
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => const FAQ(),
              ),
            ),
          ),
          _SettingsTile(
            icon: PhosphorIconsDuotone.info,
            title: context.l10n.about,
            subtitle: context.l10n.aboutSubtitle,
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
        title: context.l10n.settings,
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
    return QPGroupedListTile(
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
