import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/trale_notifier.dart';

/// Default carousel shape: Stadium on selected, asymmetric rounded rectangle
/// otherwise (outer edges 16 dp, inner edges 4 dp — same as QPLayout values).
ShapeBorder themeItemShapeDefault(
  BuildContext context,
  int index,
  int length,
  bool isSelected,
) {
  if (isSelected) {
    return const StadiumBorder();
  }
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(
      left: Radius.circular(
        index == 0 ? QPLayout.borderRadius : QPLayout.innerBorderRadius,
      ),
      right: Radius.circular(
        index == length - 1
            ? QPLayout.borderRadius
            : QPLayout.innerBorderRadius,
      ),
    ),
  );
}

/// Carousel picker for selecting a [TraleSchemeVariant] (= [QPSchemeVariant]).
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

    Widget previewBuilder(BuildContext ctx, TraleSchemeVariant variant) {
      final TraleTheme baseTheme = isDark
          ? notifier.theme.dark(ctx)
          : notifier.theme.light(ctx);
      final DynamicSchemeVariant dynVariant = variant.schemeVariant;
      final TraleTheme themed = baseTheme.copyWith(schemeVariant: dynVariant);
      final bool isSelected = variant == notifier.schemeVariant;

      return Padding(
        padding: const EdgeInsets.all(0.5 * QPLayout.padding),
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
            const SizedBox(height: 0.5 * QPLayout.padding),
            BurgerTheme(theme: themed, isSelected: isSelected),
          ],
        ),
      );
    }

    return QPSelectionCarousel<TraleSchemeVariant>(
      items: TraleSchemeVariant.values,
      isSelected: (TraleSchemeVariant v) => v == notifier.schemeVariant,
      onSelected: (TraleSchemeVariant v) => notifier.schemeVariant = v,
      previewBuilder: previewBuilder,
      shapeBuilder: themeItemShapeDefault,
    );
  }
}

/// Carousel picker for selecting a [TraleCustomTheme].
class ThemeSelection extends StatelessWidget {
  /// Constructor.
  const ThemeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);
    final bool isDark =
        notifier.themeMode == ThemeMode.dark ||
        (notifier.themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final List<TraleCustomTheme> cthemes = TraleCustomTheme.values.toList();
    if (!notifier.systemColorsAvailable) {
      cthemes.remove(TraleCustomTheme.system);
    }

    Widget previewBuilder(BuildContext ctx, TraleCustomTheme ctheme) {
      final TraleTheme theme = isDark ? ctheme.dark(ctx) : ctheme.light(ctx);
      final bool isSelected = ctheme == notifier.theme;
      return Padding(
        padding: const EdgeInsets.all(0.5 * QPLayout.padding),
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
            const SizedBox(height: 0.5 * QPLayout.padding),
            BurgerTheme(theme: theme, isSelected: isSelected),
          ],
        ),
      );
    }

    return QPSelectionCarousel<TraleCustomTheme>(
      items: cthemes,
      isSelected: (TraleCustomTheme t) => t == notifier.theme,
      onSelected: (TraleCustomTheme t) => notifier.theme = t,
      previewBuilder: previewBuilder,
      shapeBuilder: themeItemShapeDefault,
    );
  }
}

/// Burger-style colour-swatch preview used by [ThemeSelection] and
/// [SchemeVariantSelection].
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
        shape: QPLayout.borderShape,
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact =
                constraints.maxWidth < (3 + 4 * 2) * QPLayout.space;
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
              spacing: QPLayout.space,
              children: <Widget>[
                Expanded(
                  child: QPGroupedWidget(
                    color: colorScheme.primary,
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: middleRowColors
                        .map(
                          (Color color) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: QPLayout.space / 2,
                              ),
                              child: QPGroupedWidget(
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
                  child: QPGroupedWidget(
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

/// Trale theme settings page.
///
/// Delegates to [QPThemeSettingsPage] and injects trale-specific carousel
/// widgets for palette and scheme-variant selection.
class ThemeSettingsPage extends StatelessWidget {
  /// Constructor.
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QPThemeSettingsPage(
      strings: qpStringsFromL10n(context.l10n),
      palettes: const <QPPalette>[],
      paletteSection: QPWidgetGroup(
        title: context.l10n.theme,
        children: <Widget>[
          QPGroupedText(text: Text(context.l10n.themeDescription)),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const ThemeSelection(),
          ),
        ],
      ),
      schemeVariantSection: QPWidgetGroup(
        title: context.l10n.schemeVariant,
        children: <Widget>[
          QPGroupedText(text: Text(context.l10n.schemeVariantDescription)),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: const SchemeVariantSelection(),
          ),
        ],
      ),
    );
  }
}
