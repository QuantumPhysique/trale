import 'package:flutter/material.dart';


/// Add monospace text styles to TextThemes default
///
/// Usage:
///    thof.textTheme.monospace.bodyMedium
extension MonospaceExtension on TextTheme {
  TextTheme get monospace => apply(
    fontFamily: 'RobotoMono',
  );
}
