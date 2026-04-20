/// Localised strings used by [QPAboutPage] and [QPThirdPartyLicence].
library;

import 'package:flutter/foundation.dart';

/// Formatter for the "under" line of a third-party licence tile.
///
/// Example: `(years, author, licence) => "$years, $author — $licence"`
typedef QPUnderTplFormatter =
    String Function({
      required String years,
      required String author,
      required String licence,
    });

/// All user-visible strings needed by the QP about-page widgets.
@immutable
class QPAboutStrings {
  /// Creates a [QPAboutStrings] instance.
  const QPAboutStrings({
    required this.version,
    required this.changelog,
    required this.sourceCode,
    required this.licence,
    required this.tplTitle,
    required this.tplAssetsGroup,
    required this.tplPackagesGroup,
    required this.loading,
    required this.undertpl,
    required this.about,
  });

  /// Label for the version tile (e.g. "Version").
  final String version;

  /// Label for the changelog tile (e.g. "Changelog").
  final String changelog;

  /// Label for the source code tile (e.g. "Source code").
  final String sourceCode;

  /// Label for the licence tile (e.g. "License").
  final String licence;

  /// Section heading for third-party licences (e.g. "Third party licences").
  final String tplTitle;

  /// Group heading for asset licences (e.g. "Assets").
  final String tplAssetsGroup;

  /// Group heading for package licences (e.g. "Packages").
  final String tplPackagesGroup;

  /// Loading indicator label (e.g. "Loading").
  final String loading;

  /// Formats the subtitle line of a TPL tile.
  ///
  /// Receives [years], [author], and [licence] as named parameters.
  final QPUnderTplFormatter undertpl;

  /// Page title (e.g. "About").
  final String about;
}
