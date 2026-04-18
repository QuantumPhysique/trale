part of 'tile_group.dart';

/// A titled group of [GroupedWidget] tiles separated by thin gaps.
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

  /// List of children to display in the group.
  final List<Widget> children;

  /// Optional title shown above the group.
  final String? title;

  /// TextStyle for the title.
  final TextStyle? titleStyle;

  /// Number of items for the builder variant.
  final int? itemCount;

  /// Builder for the builder variant.
  final IndexedWidgetBuilder? itemBuilder;

  /// Axis along which items are laid out.
  final Axis direction;

  /// Whether the content should be scrollable along [direction].
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    const double padding = QPLayout.padding;
    const double gap = QPLayout.space;

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
                _inCaps(title!),
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
            shape: QPLayout.borderShape,
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

String _inCaps(String s) =>
    s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;
