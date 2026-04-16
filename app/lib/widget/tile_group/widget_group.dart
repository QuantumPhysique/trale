part of '../tile_group.dart';

class WidgetGroup extends StatelessWidget {
  const WidgetGroup({
    super.key,
    required this.children,
    this.title,
    this.titleStyle,
    this.direction = Axis.vertical,
    this.scrollable = false,
  }) : itemBuilder = null,
       itemCount = null;

  const WidgetGroup.builder({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.title,
    this.titleStyle,
    this.direction = Axis.vertical,
    this.scrollable = false,
  }) : children = const <Widget>[];

  /// List of GroupedWidgets to display in the group
  final List<Widget> children;

  /// Add a title above the grouped widgets
  final String? title;

  /// TextStyle for the title
  final TextStyle? titleStyle;

  /// Number of tiems for the builder
  final int? itemCount;

  /// Builder for GroupedWidgets
  final IndexedWidgetBuilder? itemBuilder;

  /// Vertical or horizontal layout
  final Axis direction;

  /// Whether the content should be scrollable along [direction].
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final double padding = TraleTheme.of(context)!.padding;
    final double gap = TraleTheme.of(context)!.space;

    final List<Widget> effectiveChildren = children.isNotEmpty
        ? children
        : List<Widget>.generate(
            itemCount ?? 0,
            (int i) => itemBuilder!(context, i),
          );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5 * padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null)
            Padding(
              padding: EdgeInsets.only(
                top: 0.5 * padding,
                bottom: 0.5 * padding,
                left: 0.5 * padding,
              ),
              child: Text(
                title!.inCaps,
                style:
                    titleStyle ??
                    Theme.of(
                      context,
                    ).textTheme.emphasized.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          Card(
            margin: EdgeInsets.zero,
            color: Colors.transparent,
            shape: TraleTheme.of(context)!.borderShape,
            clipBehavior: Clip.antiAlias,
            child: scrollable
                ? SingleChildScrollView(
                    scrollDirection: direction,
                    child: Flex(
                      spacing: gap,
                      direction: direction,
                      mainAxisSize: MainAxisSize.min,
                      children: effectiveChildren,
                    ),
                  )
                : Flex(
                    spacing: gap,
                    direction: direction,
                    mainAxisSize: MainAxisSize.min,
                    children: effectiveChildren,
                  ),
          ),
        ],
      ),
    );
  }
}

