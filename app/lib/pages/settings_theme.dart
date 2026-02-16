import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/contrast.dart';
import 'package:trale/core/font.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
import 'package:trale/widget/tile_group.dart';

/// ListTile for changing interpolation settings
class ContrastLevelSetting extends StatelessWidget {
  /// constructor
  const ContrastLevelSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupedWidget(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          TraleTheme.of(context)!.padding,
          0.5 * TraleTheme.of(context)!.padding,
          TraleTheme.of(context)!.padding,
          0.5 * TraleTheme.of(context)!.padding,
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            AutoSizeText(
              AppLocalizations.of(context)!.highContrast.inCaps,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
            ),
            Slider(
              value: Provider.of<TraleNotifier>(
                context,
              ).contrastLevel.idx.toDouble(),
              divisions: ContrastLevel.values.length - 1,
              min: 0.0,
              max: ContrastLevel.values.length.toDouble() - 1,
              label: Provider.of<TraleNotifier>(context).contrastLevel.nameLong,
              onChanged: (double newContrastLevel) async {
                Provider.of<TraleNotifier>(
                      context,
                      listen: false,
                    ).contrastLevel =
                    ContrastLevel.values[newContrastLevel.toInt()];
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ListTile for changing Amoled settings
class AmoledListTile extends StatelessWidget {
  /// constructor
  const AmoledListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupedWidget(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: SwitchListTile(
        dense: true,
        title: AutoSizeText(
          AppLocalizations.of(context)!.amoled,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: TraleTheme.of(context)!.padding,
        ),
        subtitle: AutoSizeText(
          AppLocalizations.of(context)!.amoledSubtitle,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        value: Provider.of<TraleNotifier>(context).isAmoled,
        onChanged: (bool isAmoled) async {
          Provider.of<TraleNotifier>(context, listen: false).isAmoled =
              isAmoled;
        },
      ),
    );
  }
}

/// ListTile for changing dark mode settings
class DarkModeListTile extends StatelessWidget {
  /// constructor
  const DarkModeListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: EdgeInsets.fromLTRB(
        TraleTheme.of(context)!.padding,
        0.5 * TraleTheme.of(context)!.padding,
        TraleTheme.of(context)!.padding,
        0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.darkmode,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: SegmentedButton<ThemeMode>(
        selected: <ThemeMode>{Provider.of<TraleNotifier>(context).themeMode},
        showSelectedIcon: false,
        segments: <ButtonSegment<ThemeMode>>[
          for (final ThemeMode mode in orderedThemeModes)
            ButtonSegment<ThemeMode>(
              value: mode,
              tooltip: mode.nameLong(context),
              icon: PPIcon(
                Provider.of<TraleNotifier>(context).themeMode == mode
                    ? mode.activeIcon
                    : mode.icon,
                context,
              ),
            ),
        ],
        onSelectionChanged: (Set<ThemeMode> newMode) async {
          Provider.of<TraleNotifier>(context, listen: false).themeMode =
              newMode.first;
        },
      ),
    );
  }
}

/// Carousel picker for selecting a `TraleSchemeVariant` using the generic
/// `SelectionCarousel` infrastructure.
class SchemeVariantSelection extends StatelessWidget {
  /// Constructor.
  const SchemeVariantSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);
    final bool isDark =
        notifier.themeMode == ThemeMode.dark ||
        (notifier.themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);
    final double padding = TraleTheme.of(context)!.padding;
    const List<TraleSchemeVariant> variants = TraleSchemeVariant.values;

    Widget previewBuilder(BuildContext ctx, TraleSchemeVariant variant) {
      // Create a temporary theme with this scheme
      // variant applied to derive colors.
      final TraleTheme baseTheme = isDark
          ? notifier.theme.dark(ctx)
          : notifier.theme.light(ctx);
      final DynamicSchemeVariant dynVariant = variant.schemeVariant;
      final TraleTheme themed = baseTheme.copyWith(schemeVariant: dynVariant);
      final bool isSelected = variant == notifier.schemeVariant;

      return Padding(
        padding: EdgeInsets.all(0.5 * padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AutoSizeText(
              variant.name,
              style: baseTheme.themeData.textTheme.emphasized.labelMedium
                  ?.apply(
                    color: isSelected
                        ? themed.themeData.colorScheme.onPrimaryContainer
                        : themed.themeData.colorScheme.onSurface,
                  ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.5 * padding),
            BurgerTheme(theme: themed, isSelected: isSelected),
          ],
        ),
      );
    }

    return SelectionCarousel<TraleSchemeVariant>(
      items: variants,
      isSelected: (TraleSchemeVariant v) => v == notifier.schemeVariant,
      onSelected: (TraleSchemeVariant v) => notifier.schemeVariant = v,
      previewBuilder: previewBuilder,
      shapeBuilder: themeItemShapeDefault,
    );
  }
}

/// ListTile for changing interpolation settings
class ThemeSelection extends StatelessWidget {
  /// Constructor.
  const ThemeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(context);
    final bool isDark =
        traleNotifier.themeMode == ThemeMode.dark ||
        (traleNotifier.themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);
    final double padding = TraleTheme.of(context)!.padding;

    final List<TraleCustomTheme> cthemes = TraleCustomTheme.values.toList();
    if (!traleNotifier.systemColorsAvailable) {
      cthemes.remove(TraleCustomTheme.system);
    }

    Widget previewBuilder(BuildContext ctx, TraleCustomTheme ctheme) {
      final TraleTheme theme = isDark ? ctheme.dark(ctx) : ctheme.light(ctx);
      final bool isSelected = ctheme == traleNotifier.theme;
      return Padding(
        padding: EdgeInsets.all(0.5 * padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AutoSizeText(
              ctheme.name,
              style: theme.themeData.textTheme.emphasized.labelMedium?.apply(
                color: isSelected
                    ? theme.themeData.colorScheme.onPrimaryContainer
                    : theme.themeData.colorScheme.onSurface,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.5 * padding),
            BurgerTheme(theme: theme, isSelected: isSelected),
          ],
        ),
      );
    }

    return SelectionCarousel<TraleCustomTheme>(
      items: cthemes,
      isSelected: (TraleCustomTheme t) => t == traleNotifier.theme,
      onSelected: (TraleCustomTheme t) => traleNotifier.theme = t,
      previewBuilder: previewBuilder,
      shapeBuilder: themeItemShapeDefault,
    );
  }
}

/// A generic carousel widget for selecting from a list of items.
class SelectionCarousel<T> extends StatefulWidget {
  /// Constructor.
  const SelectionCarousel({
    super.key,
    required this.items,
    required this.isSelected,
    required this.onSelected,
    required this.previewBuilder,
    this.shapeBuilder,
  });

  /// Items to display in the carousel.
  final List<T> items;

  /// Callback to check if an item is selected.
  final bool Function(T item) isSelected;

  /// Callback when an item is selected.
  final void Function(T item) onSelected;

  /// Builder for item preview widgets.
  final Widget Function(BuildContext context, T item) previewBuilder;

  /// Optional custom shape builder.
  final ShapeBorder Function(
    BuildContext context,
    int index,
    int length,
    bool isSelected,
  )?
  shapeBuilder;

  @override
  State<SelectionCarousel<T>> createState() => _SelectionCarouselState<T>();
}

class _SelectionCarouselState<T> extends State<SelectionCarousel<T>> {
  late final CarouselController _carouselController;
  bool _initialized = false;

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _initialized = true;
      final int idx = widget.items.indexWhere(widget.isSelected);
      final int clamped = idx < 0
          ? 0
          : (idx < widget.items.length - 3 ? idx : widget.items.length - 3);
      _carouselController = CarouselController(initialItem: clamped);
    }

    final double padding = TraleTheme.of(context)!.padding;
    final List<T> items = widget.items;
    // Determine currently selected item for RadioGroup.
    final T selectedItem = items.firstWhere(
      widget.isSelected,
      orElse: () => items.first,
    );

    Widget buildCarousel() {
      return CarouselView.weighted(
        controller: _carouselController,
        scrollDirection: Axis.horizontal,
        flexWeights: const <int>[1, 3, 3, 3, 1],
        padding: EdgeInsets.symmetric(
          horizontal: TraleTheme.of(context)!.space,
        ),
        itemSnapping: true,
        backgroundColor: Colors.transparent,
        onTap: (int index) => widget.onSelected(items[index]),
        shape: TraleTheme.of(context)?.innerBorderShape,
        children: List<Widget>.generate(items.length, (int index) {
          final T item = items[index];
          final bool isSelected = widget.isSelected(item);
          final ShapeBorder? shape = widget.shapeBuilder?.call(
            context,
            index,
            items.length,
            isSelected,
          );
          return GroupedWidget(
            key: ValueKey<T>(item),
            shape: shape,
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 0.5 * padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: widget.previewBuilder(context, item)),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      0.5 * padding,
                      0,
                      0.5 * padding,
                      0.5 * padding,
                    ),
                    child: SizedBox(
                      height: 24,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          height: 24,
                          child: Center(
                            child: Radio<T>(
                              value: item,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                                vertical: -4,
                              ),
                              splashRadius: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    }

    return RadioGroup<T>(
      groupValue: selectedItem,
      onChanged: (T? value) {
        if (value != null && !widget.isSelected(value)) {
          widget.onSelected(value);
        }
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget carousel = buildCarousel();
          final bool hasBoundedHeight =
              constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
          if (hasBoundedHeight) {
            return carousel;
          }

          final double width =
              constraints.hasBoundedWidth && constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width;
          final double estimatedHeight = _estimateCarouselHeight(
            context,
            width,
          );
          return SizedBox(height: estimatedHeight, child: carousel);
        },
      ),
    );
  }
}

/// Burger-style theme preview widget.
class BurgerTheme extends StatelessWidget {
  /// Constructor.
  const BurgerTheme({super.key, required this.theme, required this.isSelected});

  /// Theme to preview.
  final TraleTheme theme;

  /// Whether this theme is currently selected.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = theme.themeData.colorScheme;
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.transparent,
        shape: TraleTheme.of(context)!.borderShape,
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // on scaling show only 2 middle colors
            final bool compact =
                constraints.maxWidth < (3 + 4 * 2) * theme.space;

            final List<Color> middleRowColors = compact
                ? <Color>[
                    colorScheme.secondaryContainer,
                    colorScheme.tertiaryContainer,
                  ]
                : <Color>[
                    colorScheme.secondary,
                    colorScheme.secondaryContainer,
                    colorScheme.tertiary,
                    colorScheme.tertiaryContainer,
                  ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: theme.space,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GroupedWidget(
                    color: colorScheme.primary,
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: middleRowColors
                        .map(
                          (Color color) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: theme.space / 2,
                              ),
                              child: GroupedWidget(
                                color: color,
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GroupedWidget(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.primaryContainer,
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Height estimation helpers for the selection carousel.
extension _CarouselHeightEstimate on _SelectionCarouselState<Object?> {
  /// This heuristic is (obviously) generated with copilot. Do not trust it!
  ///
  /// Heuristic height estimate for the carousel based on available width.
  /// This mirrors `themePreview` which uses widths for its bar heights.
  double _estimateCarouselHeight(BuildContext context, double width) {
    final double padding = TraleTheme.of(context)!.padding;
    final double space = TraleTheme.of(context)!.space;

    // Label height with a modest line-height multiplier.
    final double labelFontSize = Theme.of(
      context,
    ).textTheme.emphasized.labelMedium!.fontSize!;
    final double labelHeight = labelFontSize * 1.2;

    // Fixed radio footprint including its own bottom padding.
    const double rawRadioHeight = 24.0; // we clamp radio container to 24
    final double radioBlockHeight =
        rawRadioHeight + 0.5 * padding; // bottom padding inside item

    // Desired preview (color area) height target
    // from width (aspect ratio heuristic).
    final double targetAspectHeight = width * 0.25; // empirical sweet spot

    // Compute minimum height needed by fixed pieces
    // and a conservative color area.
    final double minColorArea =
        4 * labelFontSize; // fallback if width very small
    final double colorAreaHeight = targetAspectHeight.clamp(
      minColorArea,
      width * 0.65,
    );

    // Sum all vertical contributions.
    final double total =
        (0.5 * padding) + // top padding
        labelHeight +
        (0.5 * padding) + // spacing under label
        colorAreaHeight +
        (2 * space) + // gaps between the three bar groups
        radioBlockHeight;

    // Clamp to a reasonable minimum to avoid being too small on narrow screens.
    return total.clamp(140.0, double.infinity);
  }
}

/// Default shape for carousel items: Stadium on selected, asymmetric rounded
/// rectangle otherwise (outer edges 16, inner edges 4 based on theme).
ShapeBorder themeItemShapeDefault(
  BuildContext context,
  int index,
  int length,
  bool isSelected,
) {
  if (isSelected) {
    return const StadiumBorder();
  }
  final double outerRadius = TraleTheme.of(context)!.borderRadius;
  final double innerRadius = TraleTheme.of(context)!.innerBorderRadius;
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(
      left: Radius.circular(index == 0 ? outerRadius : innerRadius),
      right: Radius.circular(index == length - 1 ? outerRadius : innerRadius),
    ),
  );
}

/// Theme settings page.
class ThemeSettingsPage extends StatelessWidget {
  /// Constructor.
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> sliverList = <Widget>[
      WidgetGroup(
        title: AppLocalizations.of(context)!.theme,
        children: <Widget>[
          GroupedText(
            text: Text(AppLocalizations.of(context)!.themeDescription),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const ThemeSelection(),
          ),
        ],
      ),

      WidgetGroup(
        title: AppLocalizations.of(context)!.schemeVariant,
        children: <Widget>[
          GroupedText(
            text: Text(AppLocalizations.of(context)!.schemeVariantDescription),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const SchemeVariantSelection(),
          ),
        ],
      ),
      WidgetGroup(
        title: AppLocalizations.of(context)!.additionalSettings,
        children: const <Widget>[
          DarkModeListTile(),
          AmoledListTile(),
          ContrastLevelSetting(),
        ],
      ),
    ];

    return Scaffold(
      body: SliverAppBarSnap(
        title: AppLocalizations.of(context)!.theme,
        sliverlist: sliverList,
      ),
    );
  }
}
