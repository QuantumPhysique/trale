/// Parses a CHANGELOG.md and generates a Dart part file with changelog data.
///
/// Usage (from the app package root):
///   dart run quantumphysique:generate_changelog [options]
///
/// Options:
///   --changelog <path>   Path to CHANGELOG.md (default: ../CHANGELOG.md)
///   --output <path>      Output .dart file path (default: lib/core/changelog.g.dart)
///   --part-of <name>     Library name for the `part of` directive
///                        (default: changelog.dart)
// ignore_for_file: avoid_print
library;

import 'dart:io';

/// Section header patterns mapped to [ChangelogSection] enum accessors.
const Map<String, String> _sectionMap = <String, String>{
  'API changes warning': 'ChangelogSection.apiChanges',
  'Added Features and Improvements': 'ChangelogSection.addedFeatures',
  'Bugfix': 'ChangelogSection.bugfix',
  'Other changes': 'ChangelogSection.otherChanges',
};

/// Try to match a `### ...` header to one of the known sections.
String? _matchSection(String line) {
  final String trimmed = line.trim();
  if (!trimmed.startsWith('### ')) {
    return null;
  }
  final String header = trimmed.substring(4).replaceAll(RegExp(r':$'), '');
  for (final MapEntry<String, String> entry in _sectionMap.entries) {
    if (header.toLowerCase().contains(entry.key.toLowerCase())) {
      return entry.value;
    }
  }
  return null;
}

/// Parse a version header line like `## [0.15.1] - 2026-02-03` or
/// `## [Unreleased]`.
({String version, String? date})? _parseVersionHeader(String line) {
  final RegExp re = RegExp(
    r'^##\s+\[([^\]]+)\](?:\s*-\s*(\d{4}-\d{2}-\d{2}))?',
  );
  final RegExpMatch? m = re.firstMatch(line.trim());
  if (m == null) {
    return null;
  }
  return (version: m.group(1)!, date: m.group(2));
}

/// Escape single quotes and backslashes for Dart string literals.
String _escape(String s) => s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

/// Parse a simple `--key value` or `--key=value` argument list.
Map<String, String> _parseArgs(List<String> args) {
  final Map<String, String> result = <String, String>{};
  for (int i = 0; i < args.length; i++) {
    final String arg = args[i];
    if (arg.startsWith('--')) {
      final int eq = arg.indexOf('=');
      if (eq != -1) {
        result[arg.substring(2, eq)] = arg.substring(eq + 1);
      } else if (i + 1 < args.length && !args[i + 1].startsWith('--')) {
        result[arg.substring(2)] = args[++i];
      }
    }
  }
  return result;
}

void main(List<String> args) {
  final Map<String, String> opts = _parseArgs(args);

  final String changelogPath = opts['changelog'] ?? '../CHANGELOG.md';
  final String outputPath = opts['output'] ?? 'lib/core/changelog.g.dart';
  final String partOf = opts['part-of'] ?? 'changelog.dart';

  final File changelogFile = File(changelogPath);
  final File outputFile = File(outputPath);

  if (!changelogFile.existsSync()) {
    stderr.writeln('ERROR: ${changelogFile.path} not found.');
    exit(1);
  }

  final List<String> lines = changelogFile.readAsLinesSync();

  // ── Parse ───────────────────────────────────────────────────────────────

  final List<
    ({
      String version,
      String? date,
      String? summary,
      Map<String, List<String>> sections,
    })
  >
  entries =
      <
        ({
          String version,
          String? date,
          String? summary,
          Map<String, List<String>> sections,
        })
      >[];

  String? currentSection;
  Map<String, List<String>>? currentSections;
  bool insideEntries = false;
  bool trailingLinks = false;
  final List<({int lineNumber, String text})> unparsedLines =
      <({int lineNumber, String text})>[];

  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i];

    // ── version header ──
    final ({String version, String? date})? versionMatch = _parseVersionHeader(
      line,
    );
    if (versionMatch != null) {
      insideEntries = true;
      trailingLinks = false;
      currentSections = <String, List<String>>{};
      currentSection = null;
      entries.add((
        version: versionMatch.version,
        date: versionMatch.date,
        summary: null,
        sections: currentSections,
      ));
      continue;
    }

    if (!insideEntries) {
      continue;
    }

    // ── trailing link references like [0.15.1]: https://... ──
    final String trimmed = line.trim();
    if (trimmed.startsWith('[') && trimmed.contains(']: ')) {
      trailingLinks = true;
      continue;
    }
    if (trailingLinks) {
      continue;
    }

    // ── section header ──
    final String? sec = _matchSection(line);
    if (sec != null) {
      currentSection = sec;
      currentSections?.putIfAbsent(sec, () => <String>[]);
      continue;
    }

    // ── bullet item ──
    if (trimmed.startsWith('- ') &&
        currentSection != null &&
        currentSections != null) {
      currentSections[currentSection]!.add(trimmed.substring(2));
      continue;
    }

    // ── continuation of a multi-line bullet ──
    if (trimmed.isNotEmpty &&
        !trimmed.startsWith('#') &&
        !trimmed.startsWith('[') &&
        currentSection != null &&
        currentSections != null &&
        currentSections[currentSection]!.isNotEmpty) {
      currentSections[currentSection]!.last += ' $trimmed';
      continue;
    }

    if (trimmed.isEmpty) {
      continue;
    }

    // ── summary text before any section ──
    if (trimmed.isNotEmpty &&
        !trimmed.startsWith('#') &&
        !trimmed.startsWith('[') &&
        currentSection == null) {
      final int lastIndex = entries.length - 1;
      final currentEntry = entries[lastIndex];
      final String newSummary = currentEntry.summary == null
          ? trimmed
          : '${currentEntry.summary}\n$trimmed';
      entries[lastIndex] = (
        version: currentEntry.version,
        date: currentEntry.date,
        summary: newSummary,
        sections: currentEntry.sections,
      );
      continue;
    }

    unparsedLines.add((lineNumber: i + 1, text: line));
  }

  // ── Generate Dart source ─────────────────────────────────────────────────

  final StringBuffer buf = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln('// Generated by: dart run quantumphysique:generate_changelog')
    ..writeln('// dart format off')
    ..writeln('// ignore_for_file: public_member_api_docs')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln()
    ..writeln("part of '$partOf';")
    ..writeln()
    ..writeln('/// The full parsed changelog from CHANGELOG.md.')
    ..writeln('const Changelog changelog = Changelog(<ChangelogEntry>[');

  for (final ({
        String version,
        String? date,
        String? summary,
        Map<String, List<String>> sections,
      })
      entry
      in entries) {
    buf.writeln('  ChangelogEntry(');
    buf.writeln("    version: '${_escape(entry.version)}',");
    if (entry.date != null) {
      buf.writeln("    dateString: '${entry.date}',");
    }
    if (entry.summary != null) {
      buf.writeln(
        "    summary: '${_escape(entry.summary!).replaceAll('\n', r'\n')}',",
      );
    }
    if (entry.sections.isNotEmpty) {
      buf.writeln('    sections: <ChangelogSection, List<String>>{');
      for (final MapEntry<String, List<String>> sec in entry.sections.entries) {
        buf.writeln('      ${sec.key}: <String>[');
        for (final String item in sec.value) {
          buf.writeln("        '${_escape(item)}',");
        }
        buf.writeln('      ],');
      }
      buf.writeln('    },');
    }
    buf.writeln('  ),');
  }

  buf.writeln(']);');

  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(buf.toString());
  print('Generated ${outputFile.path} with ${entries.length} entries.');

  if (unparsedLines.isNotEmpty) {
    print('');
    print('WARNING: ${unparsedLines.length} line(s) could not be parsed:');
    for (final ({int lineNumber, String text}) line in unparsedLines) {
      print('  L${line.lineNumber}: ${line.text}');
    }
  }
}
