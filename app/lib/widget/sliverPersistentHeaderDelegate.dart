// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/text_size_in_effect.dart';

/// Custom sliver persistent header delegate.
class HeaderDelegate extends SliverPersistentHeaderDelegate {
  /// Constructor.
  const HeaderDelegate(
    this.title,
    this.animationDurationInMilliseconds,
    this.firstDelayInMilliseconds,
  );

  /// Header title text.
  final String title;

  /// Animation duration in milliseconds.
  final int animationDurationInMilliseconds;

  /// Delay before first animation.
  final int firstDelayInMilliseconds;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: TraleTheme.of(context)!.padding,
    );
    return Align(
      child: Container(
        padding: padding,
        color: Theme.of(context).colorScheme.surface,
        width: MediaQuery.of(context).size.width,
        child: TextSizeInEffect(
          text: title,
          textStyle: Theme.of(context).textTheme.headlineMedium!,
          durationInMilliseconds: animationDurationInMilliseconds,
          delayInMilliseconds: firstDelayInMilliseconds,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 36;

  @override
  double get minExtent => 36;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
