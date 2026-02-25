import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/widget/bulletList.dart';
import 'package:trale/widget/tile_group.dart';
import 'package:trale/core/changelog.dart';

class ChangelogContent extends StatefulWidget {
  const ChangelogContent({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  State<ChangelogContent> createState() => _ChangelogContentState();
}

class _ChangelogContentState extends State<ChangelogContent>
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
      final String dateString = Provider.of<TraleNotifier>(
        context,
        listen: false,
      ).dateFormat(context).format(entry.date!);
      return '$version – $dateString';
    }

    TraleTheme theme = TraleTheme.of(context)!;

    final BottomSheetThemeData sheetTheme = Theme.of(context).bottomSheetTheme;
    final Size handleSize = sheetTheme.dragHandleSize ?? const Size(32, 4);
    final Color handleColor =
        sheetTheme.dragHandleColor ??
        Theme.of(context).colorScheme.onSurfaceVariant;

    final List<ChangelogEntry> entries = changelog.getReleasedEntries();
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
                height: kMinInteractiveDimension * t + (1 - t) * theme.padding,
                width: kMinInteractiveDimension,
                padding: EdgeInsets.only(top: (1 - t) * theme.padding),
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
            padding: EdgeInsets.symmetric(horizontal: theme.padding),
            child: WidgetGroup(
              title: getTitle(entries[i]),
              children: entries[i].sections.entries.map((
                MapEntry<ChangelogSection, List<String>> section,
              ) {
                return GroupedText(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  text: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.key.label,
                        style: Theme.of(context).textTheme.titleMedium!,
                      ),
                      BulletList(section.value),
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

/// open changelog in modal BottomSheet
void showChangelog(BuildContext context) {
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
          return ChangelogContent(scrollController: scrollController);
        },
      );
    },
  );
}
