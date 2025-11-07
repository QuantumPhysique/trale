import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/contrast.dart';
import 'package:trale/core/font.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/icons.dart';
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

class SchemeVariantListTile extends StatelessWidget {
  /// constructor
  const SchemeVariantListTile({super.key});

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
        AppLocalizations.of(context)!.schemeVariant,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<TraleSchemeVariant>(
        initialSelection: Provider.of<TraleNotifier>(context).schemeVariant,
        label: AutoSizeText(
          AppLocalizations.of(context)!.schemeVariant,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        dropdownMenuEntries: <DropdownMenuEntry<TraleSchemeVariant>>[
          for (final TraleSchemeVariant variant in TraleSchemeVariant.values)
            DropdownMenuEntry<TraleSchemeVariant>(
              value: variant,
              label: variant.name,
            ),
        ],
        onSelected: (TraleSchemeVariant? newVariant) async {
          if (newVariant != null) {
            Provider.of<TraleNotifier>(context, listen: false).schemeVariant =
                newVariant;
          }
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

/// ListTile for changing interpolation settings
class ThemeSelection extends StatefulWidget {
  /// constructor
  const ThemeSelection({super.key});

  @override
  State<ThemeSelection> createState() => _ThemeSelectionState();
}

class _ThemeSelectionState extends State<ThemeSelection> {
  late final CarouselController _carouselController;
  bool loadedFirst = true;

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loadedFirst) {
      loadedFirst = false;
      final List<TraleCustomTheme> cthemes = TraleCustomTheme.values.toList();
      if (!Provider.of<TraleNotifier>(context).systemColorsAvailable) {
        cthemes.remove(TraleCustomTheme.system);
      }
      final int idx = cthemes.indexWhere(
        (TraleCustomTheme theme) =>
            theme == Provider.of<TraleNotifier>(context).theme,
      );

      // last two cannot be selected, so cap idx
      _carouselController = CarouselController(
        initialItem: idx < cthemes.length - 3 ? idx : cthemes.length - 3,
      );
    }

    /// Used to adjust themeMode to dark or light
    final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(context);
    final bool isDark =
        traleNotifier.themeMode == ThemeMode.dark ||
        (traleNotifier.themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);
    final double padding = TraleTheme.of(context)!.padding;

    Widget themePreview(BuildContext context, TraleCustomTheme ctheme) {
      final TraleTheme theme = isDark
          ? ctheme.dark(context)
          : ctheme.light(context);
      return Padding(
        padding: EdgeInsets.all(0.5 * padding),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Use a Column where the colored block area expands to fill remaining space.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AutoSizeText(
                  ctheme.name,
                  style: theme.themeData.textTheme.emphasized.labelMedium,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 0.5 * padding),
                // Expanded area for colored preview blocks
                BurgerTheme(theme: theme, ctheme: ctheme),
              ],
            );
          },
        ),
      );
    }

    final List<TraleCustomTheme> cthemes = TraleCustomTheme.values.toList();
    if (!traleNotifier.systemColorsAvailable) {
      cthemes.remove(TraleCustomTheme.system);
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Build the carousel widget once so we can wrap it conditionally.
        final Widget carousel = CarouselView.weighted(
          controller: _carouselController,
          scrollDirection: Axis.horizontal,
          flexWeights: const <int>[1, 3, 3, 3, 1],
          padding: EdgeInsets.symmetric(
            horizontal: TraleTheme.of(context)!.space,
          ),
          itemSnapping: true,
          backgroundColor: Colors.transparent,
          onTap: (int index) {
            final TraleCustomTheme ctheme = cthemes[index];
            traleNotifier.theme = ctheme;
          },
          shape: TraleTheme.of(context)?.innerBorderShape,
          children: List<Widget>.generate(cthemes.length, (int index) {
            final TraleCustomTheme ctheme = cthemes[index];
            final bool isSelected = cthemes[index] == traleNotifier.theme;
            final ShapeBorder itemShape = _themeItemShape(
              context,
              index,
              cthemes.length,
              isSelected,
            );
            return GroupedWidget(
              shape: itemShape,
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerLowest,
              child: LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints itemConstraints) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.5 * padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // Preview takes all remaining vertical space
                            Expanded(child: themePreview(context, ctheme)),
                            // Radio with controlled compact height
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
                                      child: Radio<TraleCustomTheme>(
                                        value: cthemes[index],
                                        groupValue: traleNotifier.theme,
                                        onChanged: (TraleCustomTheme? theme) {},
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
                      );
                    },
              ),
            );
          }),
        );

        // If the parent already provides a finite height, just use it.
        final bool hasBoundedHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
        if (hasBoundedHeight) return carousel;

        // Otherwise, pick a sensible height derived from width so callers
        // don't need to bind height explicitly.
        final double width =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final double estimatedHeight = _estimateCarouselHeight(context, width);
        return SizedBox(height: estimatedHeight, child: carousel);
      },
    );
  }
}

class BurgerTheme extends StatelessWidget {
  const BurgerTheme({super.key, required this.theme, required this.ctheme});

  final TraleCustomTheme ctheme;
  final TraleTheme theme;

  @override
  Widget build(BuildContext context) {
    final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(context);
    final bool isSelected = ctheme == traleNotifier.theme;
    final ColorScheme colorScheme = theme.themeData.colorScheme;
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.transparent,
        shape: TraleTheme.of(context)!.borderShape,
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // When the carousel scales items down (edge slots), available width is small.
            // In that case, reduce the middle row from 4 to 2 color blocks to keep clarity.
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

extension on _ThemeSelectionState {
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

    // Desired preview (color area) height target from width (aspect ratio heuristic).
    final double targetAspectHeight = width * 0.25; // empirical sweet spot

    // Compute minimum height needed by fixed pieces and a conservative color area.
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

  /// Returns the shape for a carousel theme item.
  /// StadiumBorder when selected, otherwise asymmetric corner radii:
  /// Outer edges (first left side, last right side) get 16, inner edges get 4.
  ShapeBorder _themeItemShape(
    BuildContext context,
    index,
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
}

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> sliverlist = <Widget>[
      WidgetGroup(
        title: AppLocalizations.of(context)!.theme,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const ThemeSelection(),
          ),
        ],
      ),
      const WidgetGroup(
        children: <Widget>[
          DarkModeListTile(),
          SchemeVariantListTile(),
          AmoledListTile(),
          ContrastLevelSetting(),
        ],
      ),
    ];

    return Scaffold(
      body: SliverAppBarSnap(
        title: AppLocalizations.of(context)!.theme,
        sliverlist: sliverlist,
      ),
    );
  }
}
