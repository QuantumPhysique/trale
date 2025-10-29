import 'package:flutter/material.dart';

/// extend widget list
extension GapListExtension on List<Widget> {
  /// Add padding between each widget
  List<Widget> addGap({
    required double padding,
    required Axis direction,
    /// Number of gaps to skip from start and end,
    /// offset of 1 means no gap at start and end
    int offset = 0,
  }) {
    final List<Widget> list = <Widget>[...this];
    final Widget gap = SizedBox(
      height: direction == Axis.vertical ? padding : 0,
      width: direction == Axis.horizontal ? padding : 0,
    );
    for (int i=length - offset; i >= offset; i--) {
      list.insert(i, gap);
    }
    return list;
  }
}


/// extend widget list
extension DividerListExtension on List<Widget> {
  /// Add padding between each widget
  List<Widget> addDivider({
    required double padding,
  }) {
    final Widget gap = Divider(
      height: padding,
    );
    for (int i=length - 1; i >= 1; i--) {
      insert(i, gap);
    }
    return this;
  }
}
