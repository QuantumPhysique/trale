import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/pages/about.dart';
import 'package:trale/pages/faq.dart';
import 'package:trale/pages/settings_export.dart';
import 'package:trale/pages/settings_language.dart';
import 'package:trale/pages/settings_personalization.dart';
import 'package:trale/pages/settings_reminder.dart';
import 'package:trale/pages/settings_theme.dart';
import 'package:trale/widget/sinewave.dart';

/// Settings overview page.
class SettingsOverviewPage extends StatelessWidget {
  /// Constructor.
  const SettingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    void push(Widget page) => Navigator.of(
      context,
    ).push<dynamic>(MaterialPageRoute<Widget>(builder: (_) => page));

    return QPSettingsOverviewPage(
      strings: qpStringsFromL10n(l10n),
      headerWidget: Column(
        children: <Widget>[
          QPSettingsBanner(
            leadingIcon: PhosphorIconsBold.handHeart,
            title: l10n.donation,
            subtitle: l10n.donationSubtitle,
            url: 'https://ko-fi.com/quantumphysique',
          ),
          const SineWave(),
        ],
      ),
      groups: <QPSettingsGroup>[
        QPSettingsGroup(
          title: l10n.customization,
          tiles: <QPSettingsTile>[
            QPSettingsTile(
              icon: PhosphorIconsDuotone.faders,
              title: l10n.personalizationTitle,
              subtitle: l10n.personalizationSubtitle,
              onTap: () => push(const PersonalizationSettingsPage()),
            ),
            QPSettingsTile(
              icon: PhosphorIconsDuotone.palette,
              title: l10n.theme,
              subtitle: l10n.themeSubtitle,
              onTap: () => push(const ThemeSettingsPage()),
            ),
            QPSettingsTile(
              icon: PhosphorIconsDuotone.globe,
              title: l10n.language,
              subtitle: l10n.languageSubtitle,
              onTap: () => push(const LanguageSettingsPage()),
            ),
          ],
        ),
        QPSettingsGroup(
          title: l10n.notifications,
          tiles: <QPSettingsTile>[
            QPSettingsTile(
              icon: PhosphorIconsDuotone.bellRinging,
              title: l10n.reminderTitle,
              subtitle: l10n.reminderSubtitle,
              onTap: () => push(const ReminderSettingsPage()),
            ),
          ],
        ),
        QPSettingsGroup(
          title: l10n.dataSettings,
          tiles: <QPSettingsTile>[
            QPSettingsTile(
              icon: PhosphorIconsDuotone.database,
              title: l10n.importAndExport,
              subtitle: l10n.importAndExportSubtitle,
              onTap: () => push(const ExportSettingsPage()),
            ),
          ],
        ),
        QPSettingsGroup(
          title: l10n.aboutTheApp,
          tiles: <QPSettingsTile>[
            QPSettingsTile(
              icon: PhosphorIconsDuotone.question,
              title: l10n.faq,
              subtitle: l10n.faqSubtitle,
              onTap: () => push(const FAQ()),
            ),
            QPSettingsTile(
              icon: PhosphorIconsDuotone.info,
              title: l10n.about,
              subtitle: l10n.aboutSubtitle,
              onTap: () => push(const About()),
            ),
          ],
        ),
      ],
    );
  }
}
