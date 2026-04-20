import 'package:flutter/material.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/changelog.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/widget/icon_hero.dart';
import 'package:trale/widget/sinewave.dart';

/// list of third party licences (assets: fonts, icons)
final List<QPThirdPartyLicence> tplsAssets =
    <QPThirdPartyLicence>[
      const QPThirdPartyLicence(
        name: 'Roboto Flex',
        url: 'https://github.com/TypeNetwork/Roboto-Flex',
        licence: 'SIL Open Font',
        author: 'Roboto Flex Project Authors',
        years: '2017',
      ),
      const QPThirdPartyLicence(
        name: 'Roboto Mono',
        url: 'https://github.com/googlefonts/RobotoMono',
        licence: 'SIL Open Font',
        author: 'Roboto Mono Project Authors',
        years: '2007',
      ),
      const QPThirdPartyLicence(
        name: 'Phosphor Icons',
        url: 'https://phosphoricons.com/',
        licence: 'MIT',
        author: 'Phosphor Icons',
        years: '2020',
      ),
    ]..sort(
      (QPThirdPartyLicence a, QPThirdPartyLicence b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

/// list of third party licences (packages)
final List<QPThirdPartyLicence> tpls =
    <QPThirdPartyLicence>[
      const QPThirdPartyLicence(
        name: 'dynamic color',
        url:
            'https://github.com/material-foundation/flutter-packages/tree/main/packages/dynamic_color',
        licence: 'Apache',
        author: 'Material Foundation',
        years: '2023',
      ),
      const QPThirdPartyLicence(
        name: 'file picker',
        url: 'https://github.com/miguelpruivo/flutter_file_picker',
        licence: 'MIT',
        author: 'Miguel Ruivo',
        years: '2018',
      ),
      const QPThirdPartyLicence(
        name: 'fl chart',
        url: 'https://github.com/imaNNeoFighT/fl_chart',
        licence: 'BSD 3',
        author: 'Iman Khoshabi',
        years: '2019',
      ),
      const QPThirdPartyLicence(
        name: 'flutter auto size text',
        url: 'https://github.com/FaFre/auto_size_text',
        licence: 'MIT',
        author: 'Simon Leier',
        years: '2018',
      ),
      const QPThirdPartyLicence(
        name: 'flutter svg',
        url:
            'https://github.com/dnfield/flutter_svg/tree/master/packages/flutter_svg',
        licence: 'MIT',
        author: 'Dan Field',
        years: '2018',
      ),
      const QPThirdPartyLicence(
        name: 'font awesome flutter',
        url: 'https://github.com/fluttercommunity/font_awesome_flutter',
        licence: 'MIT',
        author: 'Brian Egan',
        years: '2017',
      ),
      const QPThirdPartyLicence(
        name: 'hive',
        url: 'https://github.com/hivedb/hive/',
        licence: 'Apache',
        author: 'Simon Leier',
        years: '2019',
      ),
      const QPThirdPartyLicence(
        name: 'hive flutter',
        url: 'https://github.com/hivedb/hive_flutter/',
        licence: 'Apache',
        author: 'Simon Leier',
        years: '2019',
      ),
      const QPThirdPartyLicence(
        name: 'intl',
        url: 'https://github.com/dart-lang/intl',
        licence: 'BSD',
        author: 'Dart project authors',
        years: '2013',
      ),
      const QPThirdPartyLicence(
        name: 'introduction screen',
        url: 'https://github.com/pyozer/introduction_screen',
        licence: 'MIT',
        author: 'Jean-Charles Moussé',
        years: '2019',
      ),
      const QPThirdPartyLicence(
        name: 'package info plus',
        url:
            'https://github.com/fluttercommunity/plus_plugins/tree/main/packages/package_info_plus/package_info_plus',
        licence: 'BSD',
        author: 'Chromium authors',
        years: '2017',
      ),
      const QPThirdPartyLicence(
        name: 'path provider',
        url:
            'https://github.com/flutter/packages/tree/main/packages/path_provider/path_provider',
        licence: 'BSD',
        author: 'Flutter authors',
        years: '2013',
      ),
      const QPThirdPartyLicence(
        name: 'provider',
        url: 'https://github.com/rrousselGit/provider',
        licence: 'MIT',
        author: 'Remi Rousselet',
        years: '2019',
      ),
      const QPThirdPartyLicence(
        name: 'shared preferences',
        url:
            'https://github.com/flutter/plugins/tree/master/packages/shared_preferences/shared_preferences',
        licence: 'BSD',
        author: 'Flutter authors',
        years: '2013',
      ),
      const QPThirdPartyLicence(
        name: 'share plus',
        url:
            'https://github.com/fluttercommunity/plus_plugins/tree/main/packages/share_plus/share_plus',
        licence: 'BSD',
        author: 'Flutter authors',
        years: '2017',
      ),
      const QPThirdPartyLicence(
        name: 'url launcher',
        url:
            'https://github.com/flutter/plugins/tree/master/packages/url_launcher/url_launcher',
        licence: 'BSD',
        author: 'Flutter authors',
        years: '2013',
      ),
      const QPThirdPartyLicence(
        name: 'Flutter Launcher Icon',
        url: 'https://github.com/fluttercommunity/flutter_launcher_icons',
        licence: 'MIT',
        author: "Mark O'Sullivan",
        years: '2019',
      ),
    ]..sort(
      (QPThirdPartyLicence a, QPThirdPartyLicence b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

/// About page widget.
class About extends StatelessWidget {
  /// Constructor.
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return QPAboutPage(
      aboutStrings: qpAboutStringsFromL10n(context.l10n),
      descriptionWidget: QPGroupedText(
        text: Text(
          '${context.l10n.aboutDescription1}\n\n'
          '${context.l10n.aboutDescription2}\n\n'
          '${context.l10n.aboutDescription3}',
        ),
      ),
      heroWidget: const IconHero(),
      changelog: changelog,
      decorationWidget: const SineWave(),
      sourceCodeUrl: 'https://github.com/quantumphysique/trale',
      licenceName: 'GNU AGPLv3+',
      licenceUrl: 'https://github.com/QuantumPhysique/trale/blob/main/LICENSE',
      tpls: tpls,
      tplAssets: tplsAssets,
    );
  }
}
