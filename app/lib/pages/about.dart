import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/customSliverAppBar.dart';
import 'package:trale/widget/iconHero.dart';
import 'package:trale/widget/tile_group.dart';
import 'package:trale/widget/sinewave.dart';


/// get version number
Future<String> _getVersionNumber() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

/// launch url
Future<void> _launchURL(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    throw 'Could not launch $url';
  }
}

/// class for listing 3rd party licences
class ThirdPartyLicence {
  /// constructor
  ThirdPartyLicence({
    required this.name,
    required this.url,
    required this.licence,
    required this.author,
    required this.years,
  });

  /// get list representation of tpl
  ListTile toListTile(BuildContext context) => GroupedListTile(
    dense: true,
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    title: AutoSizeText(
      name.inCaps,
      style: Theme.of(context).textTheme.bodyLarge
    ),
    subtitle: AutoSizeText(
      AppLocalizations.of(context)!.undertpl(years, author, licence),
      style: Theme.of(context).textTheme.bodySmall,
      maxLines: 2,
    ),
    isThreeLine: false,
    onTap: () => _launchURL(url),
  );

  /// name of package
  final String name;
  /// name of url
  final String url;
  /// license
  final String licence;
  /// name of author
  final String author;
  /// year
  final String years;
}
/// list of third party licences
final List<ThirdPartyLicence> tplsAssets = <ThirdPartyLicence>[
  // ThirdPartyLicence(
  //     name: 'unDraw',
  //     url: 'https://undraw.co/',
  //     licence: 'unDraw',
  //     author: 'Katerina Limpitsouni',
  //     years: '2021',
  // ),
  ThirdPartyLicence(
      name: 'Roboto Flex',
      url: 'https://github.com/TypeNetwork/Roboto-Flex',
      licence: 'SIL Open Font',
      author: 'Roboto Flex Project Authors',
      years: '2017',
  ),
  ThirdPartyLicence(
    name: 'Roboto Mono',
    url: 'https://github.com/googlefonts/RobotoMono',
    licence: 'SIL Open Font',
    author: 'Roboto Mono Project Authors',
    years: '2007',
  ),
  ThirdPartyLicence(
    name: 'Phosphor Icons',
    url: 'https://phosphoricons.com/',
    licence: 'MIT',
    author: 'Phosphor Icons',
    years: '2020',
  ),
]..sort(
  (ThirdPartyLicence tpl1, ThirdPartyLicence tpl2)
    => tpl1.name.toLowerCase().compareTo(tpl2.name.toLowerCase())
);
/// list of third party licences
final List<ThirdPartyLicence> tpls = <ThirdPartyLicence>[
  // ThirdPartyLicence(
  //     name: 'animations',
  //     url: 'https://github.com/flutter/packages/tree/master/packages/animations',
  //     licence: 'BSD',
  //     author: 'Flutter authors',
  //     years: '2019',
  // ),
  ThirdPartyLicence(
      name: 'auto size text',
      url: 'https://github.com/leisim/auto_size_text',
      licence: 'MIT',
      author: 'Simon Leier',
      years: '2018',
  ),
  ThirdPartyLicence(
    name: 'dynamic color',
    url: 'https://github.com/material-foundation/flutter-packages/tree/main/packages/dynamic_color',
    licence: 'Apache',
    author: 'Material Foundation',
    years: '2023',
  ),
  ThirdPartyLicence(
    name: 'file picker',
    url: 'https://github.com/miguelpruivo/flutter_file_picker',
    licence: 'MIT',
    author: 'Miguel Ruivo',
    years: '2018',
  ),
  ThirdPartyLicence(
    name: 'fl chart',
    url: 'https://github.com/imaNNeoFighT/fl_chart',
    licence: 'BSD 3',
    author: 'Iman Khoshabi',
    years: '2019',
  ),
  ThirdPartyLicence(
    name: 'flutter svg',
    url: 'https://github.com/dnfield/flutter_svg/tree/master/packages/flutter_svg',
    licence: 'MIT',
    author: 'Dan Field',
    years: '2018',
  ),
  ThirdPartyLicence(
    name: 'font awesome flutter',
    url: 'https://github.com/fluttercommunity/font_awesome_flutter',
    licence: 'MIT',
    author: 'Brian Egan',
    years: '2017',
  ),
  ThirdPartyLicence(
    name: 'hive',
    url: 'https://github.com/hivedb/hive/',
    licence: 'Apache',
    author: 'Simon Leier',
    years: '2019',
  ),
  ThirdPartyLicence(
    name: 'hive flutter',
    url: 'https://github.com/hivedb/hive_flutter/',
    licence: 'Apache',
    author: 'Simon Leier',
    years: '2019',
  ),
  ThirdPartyLicence(
    name: 'intl',
    url: 'https://github.com/dart-lang/intl',
    licence: 'BSD',
    author: 'Dart project authors',
    years: '2013',
  ),
  ThirdPartyLicence(
    name: 'introduction screen',
    url: 'https://github.com/pyozer/introduction_screen',
    licence: 'MIT',
    author: 'Jean-Charles Moussé',
    years: '2019',
  ),
  ThirdPartyLicence(
    name: 'package info plus',
    url: 'https://github.com/fluttercommunity/plus_plugins/tree/main/packages/package_info_plus/package_info_plus',
    licence: 'BSD',
    author: 'Chromium authors',
    years: '2017',
  ),
  ThirdPartyLicence(
    name: 'path provider',
    url: 'https://github.com/flutter/packages/tree/main/packages/path_provider/path_provider',
    licence: 'BSD',
    author: 'Flutter authors',
    years: '2013',
  ),
  ThirdPartyLicence(
    name: 'provider',
    url: 'https://github.com/rrousselGit/provider',
    licence: 'MIT',
    author: 'Remi Rousselet',
    years: '2019',
  ),
  ThirdPartyLicence(
    name: 'shared preferences',
    url: 'https://github.com/flutter/plugins/tree/master/packages/shared_preferences/shared_preferences',
    licence: 'BSD',
    author: 'Flutter authors',
    years: '2013',
  ),
  ThirdPartyLicence(
    name: 'share plus',
    url: 'https://github.com/fluttercommunity/plus_plugins/tree/main/packages/share_plus/share_plus',
    licence: 'BSD',
    author: 'Flutter authors',
    years: '2017',
  ),
  ThirdPartyLicence(
    name: 'url launcher',
    url: 'https://github.com/flutter/plugins/tree/master/packages/url_launcher/url_launcher',
    licence: 'BSD',
    author: 'Flutter authors',
    years: '2013',
  ),
  ThirdPartyLicence(
    name: 'Flutter Launcher Icon',
    url: 'https://github.com/fluttercommunity/flutter_launcher_icons',
    licence: 'MIT',
    author: 'Mark O\'Sullivan',
    years: '2019',
  ),
]..sort(
  (ThirdPartyLicence tpl1, ThirdPartyLicence tpl2)
    => tpl1.name.toLowerCase().compareTo(tpl2.name.toLowerCase())
);

/// about screen widget class
class About extends StatefulWidget {
  const About({super.key});

  @override
  _About createState() => _About();
}

class _About extends State<About> {
  @override
  Widget build(BuildContext context) {
    List<Widget> aboutList() {
      return <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(
            TraleTheme.of(context)!.padding,
            0,
            TraleTheme.of(context)!.padding,
            2 * TraleTheme.of(context)!.padding,
          ),
          child: const IconHero()
        ),
        const WidgetGroup(
          children: <Widget>[
            GroupedText(
              text: Text(
                'A simple weight log with short-term extrapolation.\n\n'
                'Your privacy is respected. '
                'No revenue sources in the app, nor error logs sent. '
                'Please open an issue if you have problems.\n\n'
                'Made by two devs with little spare time.\n'
                'Consider contributing or donating.',
              ),
            ),
          ],
        ),
        SizedBox(height: TraleTheme.of(context)!.padding),
        WidgetGroup(
          children: <Widget>[
            GroupedListTile(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              dense: true,
              title: AutoSizeText(
                AppLocalizations.of(context)!.version.allInCaps,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
              ),
              trailing: FutureBuilder<String>(
                future: _getVersionNumber(),
                builder: (
                  BuildContext context, AsyncSnapshot<String> snapshot
                  ) => Text(
                    snapshot.hasData
                      ? snapshot.data!
                      : '${AppLocalizations.of(context)!.loading} ...',
                    style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            GroupedListTile(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              dense: true,
              title: AutoSizeText(
                AppLocalizations.of(context)!.sourcecode.allInCaps,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
              ),
              trailing: PPIcon( PhosphorIconsDuotone.githubLogo, context),
              onTap: () => _launchURL(
                  'https://github.com/quantumphysique/trale'
              ),
            ),
            GroupedListTile(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              dense: true,
              title: AutoSizeText(
                AppLocalizations.of(context)!.licence.allInCaps,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
              ),
              trailing: AutoSizeText(
                'GNU AGPLv3+',
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
              ),
              onTap: () => _launchURL(
                'https://github.com/QuantumPhysique/trale/blob/main/LICENSE',
              ),
            ),
          ],
        ),
        const SineWave(),
        Text(
          AppLocalizations.of(context)!.tpl.allInCaps,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        WidgetGroup(
          title: AppLocalizations.of(context)!.assets.allInCaps,
          children: <Widget>[
            for (final ThirdPartyLicence tpl in tplsAssets)
              tpl.toListTile(context),
          ]
        ),
        WidgetGroup(
          title: AppLocalizations.of(context)!.packages.allInCaps,
          children: <Widget>[
            for (final ThirdPartyLicence tpl in tpls)
              tpl.toListTile(context),
          ]
        ),
      ];
    }

    return Scaffold(
      body: SliverAppBarSnap(
        title: AppLocalizations.of(context)!.about.allInCaps,
        sliverlist: aboutList(),
      ),
    );
  }
}
