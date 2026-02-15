// ignore_for_file: file_names
import 'package:flutter/material.dart';

/// function to measure size of text widget
Size sizeOfText({
  required String text,
  required BuildContext context,
  TextStyle? style,
}) {
  style = style ?? Theme.of(context).textTheme.bodyLarge;
  return (TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textScaler: MediaQuery.textScalerOf(context),
    textDirection: Directionality.of(context),
  )..layout()).size;
}
