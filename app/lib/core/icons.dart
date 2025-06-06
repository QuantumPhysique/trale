/// Flutter icons CustomIcons
/// Copyright (C) 2020 by original authors @ fluttericon.com, fontello.com
/// This font was generated by FlutterIcon.com, which is derived from Fontello.
///
/// To use this font, place it in your fonts/ directory and include the
/// following in your pubspec.yaml
///
/// flutter:
///   fonts:
///    - family:  CustomIcons
///      fonts:
///       - asset: fonts/CustomIcons.ttf
///
///
///
library;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Class for custom icons
class CustomIcons {
  CustomIcons._();

  // font family name
  static const String _kFontFam = 'CustomIcons';

  static const IconData interpol_medium = IconData(0xe812, fontFamily: _kFontFam);
  static const IconData interpol_none = IconData(0xe813, fontFamily: _kFontFam);
  static const IconData interpol_strong = IconData(0xe814, fontFamily: _kFontFam);
  static const IconData interpol_weak = IconData(0xe815, fontFamily: _kFontFam);
}


class PPIcon extends PhosphorIcon {
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
  }) : super(
          duotoneSecondaryOpacity: 1.0,
          duotoneSecondaryColor: Theme.of(context).colorScheme.secondaryContainer,
        );
}