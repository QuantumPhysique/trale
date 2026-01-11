import 'package:flutter/material.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/text_size_in_effect.dart';

class HeaderDelegate extends SliverPersistentHeaderDelegate {
  const HeaderDelegate(
    this.title,
    this.animationDurationInMilliseconds,
    this.firstDelayInMilliseconds,
  );
  final String title;
  final int animationDurationInMilliseconds;
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
