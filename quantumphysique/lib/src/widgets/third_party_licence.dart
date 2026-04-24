/// Data class for a third-party licence entry used by [QPAboutPage].
library;

import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:quantumphysique/src/types/about_strings.dart';
import 'package:quantumphysique/src/types/string_extension.dart';
import 'package:quantumphysique/src/widgets/tile_group/tile_group.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Data class describing a third-party dependency and its licence.
///
/// Pass lists of [QPThirdPartyLicence] to [QPAboutPage.tpls] (packages) and
/// [QPAboutPage.tplAssets] (assets / fonts / icons).
class QPThirdPartyLicence {
  /// Creates a [QPThirdPartyLicence].
  const QPThirdPartyLicence({
    required this.name,
    required this.url,
    required this.licence,
    required this.author,
    required this.years,
  });

  /// Display name of the dependency.
  final String name;

  /// URL to the dependency's repository or homepage.
  final String url;

  /// Short licence identifier (e.g. `'MIT'`, `'BSD'`, `'Apache'`).
  final String licence;

  /// Author or copyright holder name.
  final String author;

  /// Copyright years string (e.g. `'2019'` or `'2019–2023'`).
  final String years;

  /// Builds a [ListTile] representation suitable for use inside a
  /// [QPWidgetGroup].
  ListTile toListTile(BuildContext context, QPAboutStrings strings) =>
      QPGroupedListTile(
        dense: true,
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        title: AutoSizeText(
          name.inCaps,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: AutoSizeText(
          strings.undertpl(years: years, author: author, licence: licence),
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 2,
        ),
        isThreeLine: false,
        onTap: () async {
          if (await canLaunchUrlString(url)) {
            await launchUrlString(url);
          }
        },
      );
}
