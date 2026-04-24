import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/src/notifier/qp_notifier.dart';
import 'package:quantumphysique/src/notifier/qp_theme_builder.dart';
import 'package:quantumphysique/src/preferences/qp_preferences.dart';
import 'package:quantumphysique/src/types/contrast.dart';
import 'package:quantumphysique/src/types/scheme_variant.dart';
import 'package:quantumphysique/src/types/strings.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';
import 'package:quantumphysique/src/widgets/selection_carousel.dart';
import 'package:quantumphysique/src/widgets/sliver_app_bar_snap.dart';
import 'package:quantumphysique/src/widgets/tile_group/tile_group.dart';

/// Named-record describing a single selectable palette entry.
typedef QPPalette = ({String name, Color seed});

/// Settings page for theme appearance.
///
/// Provides:
/// - Palette (colour) selection carousel parameterised by [palettes],
///   or a fully custom [paletteSection] widget when provided.
/// - Scheme-variant selection carousel, or a custom [schemeVariantSection].
/// - Dark mode selector (light / system / dark).
/// - AMOLED pure-black toggle.
/// - Contrast slider.
class QPThemeSettingsPage extends StatelessWidget {
  /// Creates a [QPThemeSettingsPage].
  const QPThemeSettingsPage({
    required this.strings,
    required this.palettes,
    this.paletteSection,
    this.schemeVariantSection,
    super.key,
  });

  /// Localised strings.
  final QPStrings strings;

  /// App-supplied palette list. Each entry carries a display [name] and a
  /// seed [Color] used for previewing and storing the selection.
  ///
  /// Ignored when [paletteSection] is provided.
  final List<QPPalette> palettes;

  /// Optional widget that completely replaces the default palette-carousel
  /// section (the [QPWidgetGroup] titled [QPStrings.themePalette]).
  ///
  /// Use this when the app has a richer palette preview (e.g. a custom
  /// colour-swatch carousel) that cannot be expressed as [QPPalette] entries.
  final Widget? paletteSection;

  /// Optional widget that completely replaces the default scheme-variant
  /// carousel section.
  final Widget? schemeVariantSection;

  @override
  Widget build(BuildContext context) {
    final QPNotifier notifier = Provider.of<QPNotifier>(context);
    final bool isDark =
        notifier.themeMode == ThemeMode.dark ||
        (notifier.themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final List<Widget> sliverList = <Widget>[
      paletteSection ??
          QPWidgetGroup(
            title: strings.themePalette,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: _PaletteCarousel(
                  palettes: palettes,
                  notifier: notifier,
                  isDark: isDark,
                ),
              ),
            ],
          ),
      schemeVariantSection ??
          QPWidgetGroup(
            title: strings.schemeVariant,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: _SchemeVariantCarousel(
                  notifier: notifier,
                  isDark: isDark,
                ),
              ),
            ],
          ),
      QPWidgetGroup(
        title: strings.theme,
        children: <Widget>[
          _DarkModeListTile(strings: strings),
          _AmoledListTile(strings: strings),
          _ContrastLevelSetting(strings: strings),
        ],
      ),
    ];

    return Scaffold(
      body: QPSliverAppBarSnap(title: strings.theme, sliverlist: sliverList),
    );
  }
}

// ---------------------------------------------------------------------------
// Ordered theme modes
// ---------------------------------------------------------------------------

const List<ThemeMode> _orderedThemeModes = <ThemeMode>[
  ThemeMode.light,
  ThemeMode.system,
  ThemeMode.dark,
];

IconData _themeModeIcon(ThemeMode mode, {bool active = false}) {
  return switch (mode) {
    ThemeMode.light => active ? Icons.wb_sunny : Icons.wb_sunny_outlined,
    ThemeMode.dark => active ? Icons.dark_mode : Icons.dark_mode_outlined,
    ThemeMode.system =>
      active ? Icons.brightness_auto : Icons.brightness_auto_outlined,
  };
}

// ---------------------------------------------------------------------------
// Dark mode tile
// ---------------------------------------------------------------------------

class _DarkModeListTile extends StatelessWidget {
  const _DarkModeListTile({required this.strings});

  final QPStrings strings;

  String _modeName(ThemeMode mode) => switch (mode) {
    ThemeMode.light => strings.darkModeLight,
    ThemeMode.dark => strings.darkModeDark,
    ThemeMode.system => strings.darkModeAuto,
  };

  @override
  Widget build(BuildContext context) {
    const double halfPad = QPLayout.padding / 2;
    return QPGroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.fromLTRB(
        QPLayout.padding,
        halfPad,
        QPLayout.padding,
        halfPad,
      ),
      title: AutoSizeText(
        strings.darkMode,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: SegmentedButton<ThemeMode>(
        selected: <ThemeMode>{Provider.of<QPNotifier>(context).themeMode},
        showSelectedIcon: false,
        segments: <ButtonSegment<ThemeMode>>[
          for (final ThemeMode mode in _orderedThemeModes)
            ButtonSegment<ThemeMode>(
              value: mode,
              tooltip: _modeName(mode),
              icon: Icon(
                _themeModeIcon(
                  mode,
                  active: Provider.of<QPNotifier>(context).themeMode == mode,
                ),
              ),
            ),
        ],
        onSelectionChanged: (Set<ThemeMode> selected) {
          if (selected.isNotEmpty) {
            Provider.of<QPNotifier>(context, listen: false).themeMode =
                selected.first;
          }
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AMOLED tile
// ---------------------------------------------------------------------------

class _AmoledListTile extends StatelessWidget {
  const _AmoledListTile({required this.strings});

  final QPStrings strings;

  @override
  Widget build(BuildContext context) {
    return QPGroupedWidget(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: SwitchListTile(
        dense: true,
        title: AutoSizeText(
          strings.amoled,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: QPLayout.padding,
        ),
        subtitle: AutoSizeText(
          strings.amoledSubtitle,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        value: Provider.of<QPNotifier>(context).isAmoled,
        onChanged: (bool value) {
          Provider.of<QPNotifier>(context, listen: false).isAmoled = value;
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Contrast slider
// ---------------------------------------------------------------------------

class _ContrastLevelSetting extends StatelessWidget {
  const _ContrastLevelSetting({required this.strings});

  final QPStrings strings;

  @override
  Widget build(BuildContext context) {
    const double halfPad = QPLayout.padding / 2;
    final QPNotifier notifier = Provider.of<QPNotifier>(context);
    return QPGroupedWidget(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          QPLayout.padding,
          halfPad,
          QPLayout.padding,
          halfPad,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            AutoSizeText(
              strings.highContrast,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
            ),
            Slider(
              value: notifier.contrastLevel.idx.toDouble(),
              divisions: QPContrast.values.length - 1,
              min: 0.0,
              max: (QPContrast.values.length - 1).toDouble(),
              label: notifier.contrastLevel.nameLong,
              onChanged: (double value) {
                Provider.of<QPNotifier>(context, listen: false).contrastLevel =
                    QPContrast.values[value.toInt()];
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Palette carousel
// ---------------------------------------------------------------------------

class _PaletteCarousel extends StatelessWidget {
  const _PaletteCarousel({
    required this.palettes,
    required this.notifier,
    required this.isDark,
  });

  final List<QPPalette> palettes;
  final QPNotifier notifier;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return QPSelectionCarousel<QPPalette>(
      items: palettes,
      isSelected: (QPPalette p) => p.name == notifier.prefs.themeName,
      onSelected: (QPPalette p) => notifier.prefs.themeName = p.name,
      previewBuilder: (BuildContext ctx, QPPalette palette) {
        final bool isSelected = palette.name == notifier.prefs.themeName;
        final ColorScheme cs = ColorScheme.fromSeed(
          seedColor: palette.seed,
          brightness: isDark ? Brightness.dark : Brightness.light,
        );
        return Padding(
          padding: const EdgeInsets.all(0.5 * QPLayout.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AutoSizeText(
                palette.name,
                style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                  color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 0.5 * QPLayout.padding),
              Expanded(child: _ColorSwatchPreview(colorScheme: cs)),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Scheme variant carousel
// ---------------------------------------------------------------------------

class _SchemeVariantCarousel extends StatelessWidget {
  const _SchemeVariantCarousel({required this.notifier, required this.isDark});

  final QPNotifier notifier;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return QPSelectionCarousel<QPSchemeVariant>(
      items: QPSchemeVariant.values,
      isSelected: (QPSchemeVariant v) => v == notifier.schemeVariant,
      onSelected: (QPSchemeVariant v) => notifier.schemeVariant = v,
      previewBuilder: (BuildContext ctx, QPSchemeVariant variant) {
        final bool isSelected = variant == notifier.schemeVariant;
        final ThemeData td = buildQPThemeData(
          seedColor: notifier.seedColor,
          brightness: isDark ? Brightness.dark : Brightness.light,
          schemeVariant: variant,
          contrast: notifier.contrastLevel,
        );
        return Padding(
          padding: const EdgeInsets.all(0.5 * QPLayout.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AutoSizeText(
                variant.name,
                style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? td.colorScheme.onPrimaryContainer
                      : td.colorScheme.onSurface,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 0.5 * QPLayout.padding),
              Expanded(child: _ColorSwatchPreview(colorScheme: td.colorScheme)),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Simple 4-color swatch used in both carousels
// ---------------------------------------------------------------------------

class _ColorSwatchPreview extends StatelessWidget {
  const _ColorSwatchPreview({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = <Color>[
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
      colorScheme.surface,
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(QPLayout.innerBorderRadius),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(child: ColoredBox(color: colors[0])),
                Expanded(child: ColoredBox(color: colors[1])),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(child: ColoredBox(color: colors[2])),
                Expanded(child: ColoredBox(color: colors[3])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
