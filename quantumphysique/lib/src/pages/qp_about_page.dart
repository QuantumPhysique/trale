/// About page for QP-based apps.
library;

import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quantumphysique/src/types/about_strings.dart';
import 'package:quantumphysique/src/changelog/changelog.dart';
import 'package:quantumphysique/src/types/string_extension.dart';
import 'package:quantumphysique/src/widgets/changelog_widget.dart';
import 'package:quantumphysique/src/widgets/sliver_app_bar_snap.dart';
import 'package:quantumphysique/src/widgets/third_party_licence.dart';
import 'package:quantumphysique/src/widgets/tile_group/tile_group.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Retrieves the app version string from [PackageInfo].
Future<String> _getVersionNumber() async {
  final PackageInfo info = await PackageInfo.fromPlatform();
  return info.version;
}

/// Generic about page for QP-based apps.
///
/// Shows:
/// - An optional [heroWidget] at the top.
/// - A [descriptionWidget] with app description text.
/// - A row of info tiles: version, changelog, optional source-code link, and
///   optional licence link.
/// - An optional [decorationWidget] (e.g. a decorative wave).
/// - TPL sections for [tplAssets] and [tpls].
class QPAboutPage extends StatelessWidget {
  /// Creates a [QPAboutPage].
  const QPAboutPage({
    required this.aboutStrings,
    required this.descriptionWidget,
    required this.tpls,
    required this.tplAssets,
    this.heroWidget,
    this.changelog,
    this.decorationWidget,
    this.sourceCodeUrl,
    this.licenceName,
    this.licenceUrl,
    super.key,
  });

  /// Localised strings for the about page.
  final QPAboutStrings aboutStrings;

  /// Widget shown as the app description (body text).
  final Widget descriptionWidget;

  /// Third-party licence entries for code packages.
  final List<QPThirdPartyLicence> tpls;

  /// Third-party licence entries for assets (fonts, icons, etc.).
  final List<QPThirdPartyLicence> tplAssets;

  /// Optional logo / hero widget shown above the description.
  final Widget? heroWidget;

  /// Optional changelog to display in a bottom sheet.
  ///
  /// When provided, a changelog tile is shown in the info group.
  final Changelog? changelog;

  /// Optional decoration widget shown between the info group and the TPL
  /// section (e.g. a decorative wave illustration).
  final Widget? decorationWidget;

  /// Optional URL to the app's source-code repository.
  ///
  /// When provided, a source-code tile is shown.
  final String? sourceCodeUrl;

  /// Optional short licence name (e.g. `'GNU AGPLv3+'`).
  ///
  /// Shown as the trailing label of a licence tile when [licenceUrl] is set.
  final String? licenceName;

  /// Optional URL to the full licence text.
  ///
  /// When provided (and [licenceName] is non-null), a licence tile is shown.
  final String? licenceUrl;

  @override
  Widget build(BuildContext context) {
    final List<Widget> content = <Widget>[
      if (heroWidget != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(
            QPLayout.padding,
            0,
            QPLayout.padding,
            2 * QPLayout.padding,
          ),
          child: heroWidget,
        ),
      QPWidgetGroup(children: <Widget>[descriptionWidget]),
      const SizedBox(height: QPLayout.padding),
      QPWidgetGroup(
        children: <Widget>[
          QPGroupedListTile(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            dense: true,
            title: AutoSizeText(
              aboutStrings.version.allInCaps,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
            ),
            trailing: FutureBuilder<String>(
              future: _getVersionNumber(),
              builder: (BuildContext ctx, AsyncSnapshot<String> snap) => Text(
                snap.hasData ? snap.data! : '${aboutStrings.loading} ...',
                style: Theme.of(ctx).textTheme.bodyLarge,
              ),
            ),
          ),
          if (changelog != null)
            QPGroupedListTile(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              dense: true,
              title: AutoSizeText(
                aboutStrings.changelog.allInCaps,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
              ),
              trailing: const Icon(Icons.article_outlined),
              onTap: () => showQPChangelog(context, changelog!),
            ),
          if (sourceCodeUrl != null)
            QPGroupedListTile(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              dense: true,
              title: AutoSizeText(
                aboutStrings.sourceCode.allInCaps,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
              ),
              trailing: const Icon(Icons.code),
              onTap: () async {
                if (await canLaunchUrlString(sourceCodeUrl!)) {
                  await launchUrlString(sourceCodeUrl!);
                }
              },
            ),
          if (licenceName != null && licenceUrl != null)
            QPGroupedListTile(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              dense: true,
              title: AutoSizeText(
                aboutStrings.licence.allInCaps,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
              ),
              trailing: AutoSizeText(
                licenceName!,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
              ),
              onTap: () async {
                if (await canLaunchUrlString(licenceUrl!)) {
                  await launchUrlString(licenceUrl!);
                }
              },
            ),
        ],
      ),
      if (decorationWidget != null) decorationWidget!,
      Text(
        aboutStrings.tplTitle.allInCaps,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      if (tplAssets.isNotEmpty)
        QPWidgetGroup(
          title: aboutStrings.tplAssetsGroup.allInCaps,
          children: <Widget>[
            for (final QPThirdPartyLicence tpl in tplAssets)
              tpl.toListTile(context, aboutStrings),
          ],
        ),
      if (tpls.isNotEmpty)
        QPWidgetGroup(
          title: aboutStrings.tplPackagesGroup.allInCaps,
          children: <Widget>[
            for (final QPThirdPartyLicence tpl in tpls)
              tpl.toListTile(context, aboutStrings),
          ],
        ),
    ];

    return Scaffold(
      body: QPSliverAppBarSnap(title: aboutStrings.about, sliverlist: content),
    );
  }
}
