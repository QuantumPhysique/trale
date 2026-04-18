/// Themed icon wrapper for QP apps.
library;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// A themed [PhosphorIcon] wrapper with a duotone secondary color derived from
/// the current [Theme].
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
}
