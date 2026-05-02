import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';
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

/// Carousel picker for selecting a [QPSchemeVariant] (= [QPSchemeVariant]).
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

    Widget previewBuilder(BuildContext ctx, QPSchemeVariant variant) {
      final QPTheme baseTheme = isDark
          ? notifier.theme.dark(ctx)
          : notifier.theme.light(ctx);
      final DynamicSchemeVariant dynVariant = variant.toDynamicSchemeVariant;
      final QPTheme themed = baseTheme.copyWith(schemeVariant: dynVariant);
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
            QPBurgerTheme(
              colorScheme: themed.themeData.colorScheme,
              isSelected: isSelected,
            ),
          ],
        ),
      );
    }

    return QPSelectionCarousel<QPSchemeVariant>(
      items: QPSchemeVariant.values,
      isSelected: (QPSchemeVariant v) => v == notifier.schemeVariant,
      onSelected: (QPSchemeVariant v) => notifier.schemeVariant = v,
      previewBuilder: previewBuilder,
      shapeBuilder: themeItemShapeDefault,
    );
  }
}

/// Carousel picker for selecting a [QPCustomTheme].
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

    final List<QPCustomTheme> cthemes = QPCustomTheme.values.toList();
    if (!notifier.systemColorsAvailable) {
      cthemes.remove(QPCustomTheme.system);
    }

    Widget previewBuilder(BuildContext ctx, QPCustomTheme ctheme) {
      final QPTheme theme = isDark ? ctheme.dark(ctx) : ctheme.light(ctx);
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
            QPBurgerTheme(
              colorScheme: theme.themeData.colorScheme,
              isSelected: isSelected,
            ),
          ],
        ),
      );
    }

    return QPSelectionCarousel<QPCustomTheme>(
      items: cthemes,
      isSelected: (QPCustomTheme t) => t == notifier.theme,
      onSelected: (QPCustomTheme t) => notifier.theme = t,
      previewBuilder: previewBuilder,
      shapeBuilder: themeItemShapeDefault,
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
