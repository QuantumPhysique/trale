import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/widget/bulletList.dart';
import 'package:trale/widget/tile_group.dart';
import 'package:trale/core/changelog.dart';

class ChangelogContent extends StatelessWidget {
  const ChangelogContent({super.key, required this.scrollController});
  final ScrollController scrollController;

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

    return CustomScrollView(
      controller: scrollController,
      slivers: <Widget>[
        // Drag handle matching Flutter's internal _DragHandle
        SliverToBoxAdapter(
          child: Center(
            child: SizedBox(
              height: kMinInteractiveDimension,
              width: kMinInteractiveDimension,
              child: Center(
                child: Container(
                  width: handleSize.width,
                  height: handleSize.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(handleSize.height / 2),
                    color: handleColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverList.builder(
          itemCount: changelog.entries.length,
          itemBuilder: (_, int i) => Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.padding),
            child: WidgetGroup(
              title: getTitle(changelog.entries[i]),
              children: changelog.entries[i].sections.entries.map((
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
