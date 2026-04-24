/// Changelog data model for QP apps.
///
/// The changelog entries are auto-generated from CHANGELOG.md by running:
///   dart run tool/generate_changelog.dart
library;

/// The four changelog subsection types.
enum ChangelogSection {
  /// API changes warning ⚠️
  apiChanges('API changes warning ⚠️'),

  /// Added Features and Improvements 🙌
  addedFeatures('Added Features and Improvements 🙌'),

  /// Bugfix 🐛
  bugfix('Bugfix 🐛'),

  /// Other changes
  otherChanges('Other changes');

  const ChangelogSection(this.label);

  /// Human-readable label (matching the CHANGELOG.md header).
  final String label;
}

/// A single version entry in the changelog.
class ChangelogEntry {
  /// Creates a changelog entry.
  const ChangelogEntry({
    required this.version,
    this.dateString,
    this.sections = const <ChangelogSection, List<String>>{},
  });

  /// Semantic version string, e.g. `'0.15.1'` or `'Unreleased'`.
  final String version;

  /// Release date as ISO-8601 string (null for unreleased).
  final String? dateString;

  /// Parsed release date.
  DateTime? get date {
    final String? value = dateString;
    if (value == null) {
      return null;
    }
    try {
      return DateTime.parse(value);
    } on FormatException {
      return null;
    }
  }

  /// Mapping of section type to its list of bullet items.
  final Map<ChangelogSection, List<String>> sections;
}

/// The full parsed changelog.
class Changelog {
  /// Creates a changelog.
  const Changelog(this.entries);

  /// All changelog entries, newest first.
  final List<ChangelogEntry> entries;

  /// All changelog entries except the Unreleased one.
  List<ChangelogEntry> getReleasedEntries() =>
      entries.where((ChangelogEntry e) => e.version != 'Unreleased').toList();

  /// The latest released entry (skips "Unreleased").
  ChangelogEntry? get latestRelease {
    for (final ChangelogEntry entry in entries) {
      if (entry.version != 'Unreleased') {
        return entry;
      }
    }
    return null;
  }
}
