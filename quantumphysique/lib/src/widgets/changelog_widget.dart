import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/src/changelog/changelog.dart';
import 'package:quantumphysique/src/notifier/qp_notifier.dart';
import 'package:quantumphysique/src/widgets/bullet_list.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';
import 'package:quantumphysique/src/widgets/tile_group/tile_group.dart';

/// Stateful widget that renders a scrollable changelog sheet.
class QPChangelogContent extends StatefulWidget {
  /// Constructor.
  const QPChangelogContent({
    super.key,
    required this.scrollController,
    required this.changelog,
    required this.dateFormatter,
    this.sectionLabels,
  });

  /// Scroll controller provided by [DraggableScrollableSheet].
  final ScrollController scrollController;

  /// Changelog data to display.
  final Changelog changelog;

  /// Converts a release date to a display string.
  final String Function(DateTime) dateFormatter;

  /// Optional overrides for [ChangelogSection] labels.
  final Map<ChangelogSection, String>? sectionLabels;

  @override
  State<QPChangelogContent> createState() => _QPChangelogContentState();
}

class _QPChangelogContentState extends State<QPChangelogContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _handleController;

  @override
  void initState() {
    super.initState();
    _handleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.scrollController.offset > 0) {
      _handleController.reverse();
    } else {
      _handleController.forward();
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _handleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String getTitle(ChangelogEntry entry) {
      final String version = entry.version;
      if (version == 'Unreleased' || entry.date == null) {
        return version;
      }
      final String dateString = widget.dateFormatter(entry.date!);
      return '$version \u2013 $dateString';
    }

    const double padding = QPLayout.padding;

    final BottomSheetThemeData sheetTheme = Theme.of(context).bottomSheetTheme;
    final Size handleSize = sheetTheme.dragHandleSize ?? const Size(32, 4);
    final Color handleColor =
        sheetTheme.dragHandleColor ??
        Theme.of(context).colorScheme.onSurfaceVariant;

    final List<ChangelogEntry> entries = widget.changelog.getReleasedEntries();

    return CustomScrollView(
      controller: widget.scrollController,
      slivers: <Widget>[
        // Drag handle matching Flutter's internal _DragHandle
        SliverToBoxAdapter(
          child: AnimatedBuilder(
            animation: _handleController,
            builder: (BuildContext context, Widget? child) {
              final double t = _handleController.value;
              return Container(
                alignment: Alignment.center,
                height: kMinInteractiveDimension * t + (1 - t) * padding,
                width: kMinInteractiveDimension,
                padding: EdgeInsets.only(top: (1 - t) * padding),
                child: Container(
                  width: handleSize.width,
                  height: handleSize.height * t,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(handleSize.height / 2),
                    color: handleColor,
                  ),
                ),
              );
            },
          ),
        ),
        SliverList.builder(
          itemCount: entries.length,
          itemBuilder: (_, int i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: padding),
            child: QPWidgetGroup(
              title: getTitle(entries[i]),
              children: entries[i].sections.entries.map((
                MapEntry<ChangelogSection, List<String>> section,
              ) {
                final String label =
                    widget.sectionLabels?[section.key] ?? section.key.label;
                return QPGroupedText(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  text: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      QPBulletList(section.value),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Opens the changelog in a modal bottom sheet.
///
/// Uses [QPNotifier.dateFormat] from the widget tree to format release dates.
void showQPChangelog(BuildContext context, Changelog changelog) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    clipBehavior: Clip.antiAlias,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        snapSizes: const <double>[0.5, 1.0],
        snap: true,
        expand: false,
        shouldCloseOnMinExtent: true,
        builder: (BuildContext context, ScrollController scrollController) {
          return QPChangelogContent(
            scrollController: scrollController,
            changelog: changelog,
            dateFormatter: (DateTime d) => Provider.of<QPNotifier>(
              context,
              listen: false,
            ).dateFormat(context).format(d),
          );
        },
      );
    },
  );
}
