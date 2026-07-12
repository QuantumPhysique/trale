/// Themed icon wrapper for QP apps.
library;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// A themed [PhosphorIcon] wrapper with a duotone secondary color derived from
/// the current [Theme].
///
/// Besides the built-in Phosphor duotone font, custom duotone icon fonts can
/// be registered once (e.g. in `main()`) via [registerDuotoneFont]; their
/// icons then render with the themed background layer through any [PPIcon].
class PPIcon extends PhosphorIcon {
  /// Creates a [PPIcon] with a themed duotone secondary color.
  PPIcon(
    super.icon,
    BuildContext context, {
    super.key,
    super.size,
    super.fill,
    super.weight,
    super.grade,
    super.opticalSize,
    super.color,
    super.shadows,
    super.semanticLabel,
    super.textDirection,
    Color? duotoneSecondaryColor,
  }) : super(
         duotoneSecondaryOpacity: 1.0,
         duotoneSecondaryColor:
             duotoneSecondaryColor ??
             Theme.of(context).colorScheme.secondaryContainer,
       );

  /// Secondary (background) glyph lookup per registered custom font family.
  static final Map<String, Map<int, IconData>> _duotoneFonts =
      <String, Map<int, IconData>>{};

  /// Registers a custom duotone icon font.
  ///
  /// [secondaryFor] maps the code point of a primary (foreground) glyph in
  /// [fontFamily] to the [IconData] of its secondary (background) glyph,
  /// which is rendered behind the foreground glyph and tinted with the
  /// duotone secondary color.
  static void registerDuotoneFont(
    String fontFamily,
    Map<int, IconData> secondaryFor,
  ) {
    _duotoneFonts[fontFamily] = secondaryFor;
  }

  @override
  Widget build(BuildContext context) {
    final IconData? secondary =
        _duotoneFonts[icon?.fontFamily]?[icon?.codePoint];
    if (secondary == null) {
      return super.build(context);
    }
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Opacity(
          opacity: duotoneSecondaryOpacity,
          child: Icon(
            secondary,
            size: size,
            fill: fill,
            weight: weight,
            grade: grade,
            opticalSize: opticalSize,
            color: duotoneSecondaryColor ?? color,
            shadows: shadows,
            semanticLabel: semanticLabel,
            textDirection: textDirection,
          ),
        ),
        super.build(context),
      ],
    );
  }
}
