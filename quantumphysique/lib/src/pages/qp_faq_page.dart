/// FAQ page for QP-based apps.
library;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:quantumphysique/src/types/font.dart';
import 'package:quantumphysique/src/types/icons.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';
import 'package:quantumphysique/src/widgets/sliver_app_bar_snap.dart';
import 'package:quantumphysique/src/widgets/tile_group/tile_group.dart';

/// A single question/answer entry for [QPFAQPage].
class QPFAQEntry {
  /// Creates a [QPFAQEntry].
  const QPFAQEntry({
    required this.question,
    required this.answer,
    this.answerWidget,
  });

  /// The question text.
  final String question;

  /// The answer text.
  final String answer;

  /// Optional widget rendered below the answer tile (e.g. a call-to-action).
  final Widget? answerWidget;
}

/// Generic FAQ page for QP-based apps.
///
/// Renders [entries] as grouped question/answer tiles inside a
/// [QPSliverAppBarSnap] scaffold. An optional [headerWidget] is shown at the
/// top (e.g. a [QPSettingsBanner] linking to an issue tracker).
class QPFAQPage extends StatelessWidget {
  /// Creates a [QPFAQPage].
  const QPFAQPage({
    required this.title,
    required this.entries,
    this.headerWidget,
    super.key,
  });

  /// Page title shown in the collapsing app bar.
  final String title;

  /// FAQ entries to display.
  final List<QPFAQEntry> entries;

  /// Optional widget shown before the first entry (e.g. a link banner).
  final Widget? headerWidget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QPSliverAppBarSnap(
        title: title,
        sliverlist: <Widget>[
          if (headerWidget != null) ...<Widget>[
            headerWidget!,
            const SizedBox(height: 2 * QPLayout.padding),
          ],
          for (final QPFAQEntry entry in entries)
            _QPFAQEntryWidget(entry: entry),
        ],
      ),
    );
  }
}

class _QPFAQEntryWidget extends StatelessWidget {
  const _QPFAQEntryWidget({required this.entry});

  final QPFAQEntry entry;

  @override
  Widget build(BuildContext context) {
    return QPWidgetGroup(
      children: <Widget>[
        QPGroupedListTile(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          leading: PPIcon(PhosphorIconsDuotone.question, context),
          title: Text(
            entry.question,
            style: Theme.of(context).textTheme.emphasized.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        QPGroupedListTile(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          leading: PPIcon(PhosphorIconsDuotone.chatCircleDots, context),
          title: Text(
            entry.answer,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        ?entry.answerWidget,
      ],
    );
  }
}
