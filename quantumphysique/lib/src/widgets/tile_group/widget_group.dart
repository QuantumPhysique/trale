part of 'tile_group.dart';

/// A titled group of [QPGroupedWidget] tiles separated by thin gaps.
class QPWidgetGroup extends StatelessWidget {
  const QPWidgetGroup({
    super.key,
    required this.children,
    this.title,
    this.titleStyle,
    this.titleTrailing,
    this.direction = Axis.vertical,
    this.scrollable = false,
    this.padding,
  }) : itemBuilder = null,
       itemCount = null;

  const QPWidgetGroup.builder({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.title,
    this.titleStyle,
    this.titleTrailing,
    this.direction = Axis.vertical,
    this.scrollable = false,
    this.padding,
  }) : children = const <Widget>[];

  /// List of children to display in the group.
  final List<Widget> children;

  /// Optional title shown above the group.
  final String? title;

  /// TextStyle for the title.
  final TextStyle? titleStyle;

  /// Optional widget rendered at the top-right of the title row, e.g. a compact
  /// "+" add button. When set, the title row is shown even if [title] is null.
  final Widget? titleTrailing;

  /// Number of items for the builder variant.
  final int? itemCount;

  /// Builder for the builder variant.
  final IndexedWidgetBuilder? itemBuilder;

  /// Axis along which items are laid out.
  final Axis direction;

  /// Whether the content should be scrollable along [direction].
  final bool scrollable;

  /// Overrides the default vertical margin around the group.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    const double unitPadding = QPLayout.padding;
    const double gap = QPLayout.space;

    final List<Widget> effectiveChildren = children.isNotEmpty
        ? children
        : List<Widget>.generate(
            itemCount ?? 0,
            (int i) => itemBuilder!(context, i),
          );

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: 0.5 * unitPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null || titleTrailing != null)
            Padding(
              padding: EdgeInsets.only(
                top: 0.5 * unitPadding,
                bottom: 0.5 * unitPadding,
                left: 0.5 * unitPadding,
              ),
              child: Row(
                children: <Widget>[
                  if (title != null)
                    Text(
                      _inCaps(title!),
                      style:
                          titleStyle ??
                          Theme.of(
                            context,
                          ).textTheme.emphasized.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  if (titleTrailing != null) ...<Widget>[
                    const Spacer(),
                    titleTrailing!,
                  ],
                ],
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

/// Lazy sliver equivalent of [QPWidgetGroup].
///
/// [QPWidgetGroup] materialises every child up front, which is wasteful for
/// long groups inside a [CustomScrollView]. This builds its tiles on demand
/// through [itemBuilder], so only the tiles the viewport (and cache extent)
/// actually needs are built.
///
/// The result is visually identical: the outer corners of the first and last
/// tile are rounded to [QPLayout.borderRadius] — matching the clip
/// [QPWidgetGroup] gets from its enclosing [Card] — while inner corners stay
/// at [QPLayout.innerBorderRadius] and tiles are separated by [QPLayout.space].
class QPSliverWidgetGroup extends StatelessWidget {
  /// Creates a [QPSliverWidgetGroup].
  const QPSliverWidgetGroup({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.title,
    this.titleStyle,
    this.titleTrailing,
  });

  /// Builds the tile at a given index.
  final IndexedWidgetBuilder itemBuilder;

  /// Number of tiles in the group.
  final int itemCount;

  /// Optional title shown above the group.
  final String? title;

  /// TextStyle for the title.
  final TextStyle? titleStyle;

  /// Optional widget rendered at the top-right of the title row. When set,
  /// the title row is shown even if [title] is null.
  final Widget? titleTrailing;

  @override
  Widget build(BuildContext context) {
    const double padding = QPLayout.padding;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 0.5 * padding),
      sliver: SliverMainAxisGroup(
        slivers: <Widget>[
          if (title != null || titleTrailing != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 0.5 * padding,
                  bottom: 0.5 * padding,
                  left: 0.5 * padding,
                ),
                child: Row(
                  children: <Widget>[
                    if (title != null)
                      Text(
                        _inCaps(title!),
                        style:
                            titleStyle ??
                            Theme.of(
                              context,
                            ).textTheme.emphasized.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    if (titleTrailing != null) ...<Widget>[
                      const Spacer(),
                      titleTrailing!,
                    ],
                  ],
                ),
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              final bool isFirst = index == 0;
              final bool isLast = index == itemCount - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : QPLayout.space),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      isFirst
                          ? QPLayout.borderRadius
                          : QPLayout.innerBorderRadius,
                    ),
                    bottom: Radius.circular(
                      isLast
                          ? QPLayout.borderRadius
                          : QPLayout.innerBorderRadius,
                    ),
                  ),
                  child: itemBuilder(context, index),
                ),
              );
            }, childCount: itemCount),
          ),
        ],
      ),
    );
  }
}

String _inCaps(String s) =>
    s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;
