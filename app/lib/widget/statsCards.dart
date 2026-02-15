import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:trale/core/font.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/animate_in_effect.dart';

class StatCard extends StatefulWidget {
  const StatCard({
    required this.childWidget,
    this.backgroundColor,
    this.delayInMilliseconds = 0,
    this.nx = 1,
    this.ny = 1,
    this.pillShape = false,
    super.key,
  });

  final Widget childWidget;
  final int nx;
  final int ny;
  final Color? backgroundColor;
  final int? delayInMilliseconds;
  final bool pillShape;

  @override
  _StatCardState createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  @override
  Widget build(BuildContext context) {
    final int animationDurationInMilliseconds = TraleTheme.of(
      context,
    )!.transitionDuration.slow.inMilliseconds;

    final Color backgroundcolor =
        widget.backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainer;
    final double xWidth =
        (MediaQuery.sizeOf(context).width -
            3 * TraleTheme.of(context)!.padding) /
        2;
    final double yWidth = (xWidth - TraleTheme.of(context)!.padding) / 2;

    final double height = widget.ny == 1
        ? yWidth * widget.ny
        : yWidth * widget.ny +
              (widget.ny - 1) * TraleTheme.of(context)!.padding;
    final double width = widget.nx == 1
        ? xWidth * widget.nx
        : xWidth * widget.nx +
              (widget.nx - 1) * TraleTheme.of(context)!.padding;

    final ShapeBorder shape = widget.pillShape
        ? const StadiumBorder()
        : TraleTheme.of(context)!.borderShape;

    final Card card = Card(
      shape: shape,
      color: backgroundcolor,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(height: height, width: width, child: widget.childWidget),
    );

    return AnimateInEffect(
      delayInMilliseconds: widget.delayInMilliseconds ?? 0,
      durationInMilliseconds: animationDurationInMilliseconds,
      child: card,
    );
  }
}

class OneThirdStatCard extends StatefulWidget {
  const OneThirdStatCard({
    required this.childWidget,
    this.delayInMilliseconds = 0,
    this.pillShape = false,
    super.key,
  });

  final Widget childWidget;
  final int? delayInMilliseconds;
  final bool pillShape;

  @override
  _OneThirdStatCardState createState() => _OneThirdStatCardState();
}

class _OneThirdStatCardState extends State<OneThirdStatCard> {
  @override
  Widget build(BuildContext context) {
    final int animationDurationInMilliseconds = TraleTheme.of(
      context,
    )!.transitionDuration.slow.inMilliseconds;

    final double xWidth =
        (MediaQuery.sizeOf(context).width -
            3 * TraleTheme.of(context)!.padding) /
        2;
    final double height = (xWidth - TraleTheme.of(context)!.padding) / 2;
    final double width =
        (MediaQuery.sizeOf(context).width -
            4 * TraleTheme.of(context)!.padding -
            height) /
        2;

    final ShapeBorder shape = widget.pillShape
        ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))
        : TraleTheme.of(context)!.borderShape;

    final Card card = Card(
      shape: shape,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SizedBox(height: height, width: width, child: widget.childWidget),
    );

    return AnimateInEffect(
      delayInMilliseconds: widget.delayInMilliseconds ?? 0,
      durationInMilliseconds: animationDurationInMilliseconds,
      child: card,
    );
  }
}

class DefaultStatCard extends StatefulWidget {
  const DefaultStatCard({
    required this.firstRow,
    required this.secondRow,
    this.delayInMilliseconds = 0,
    this.pillShape = false,
    super.key,
  });

  final String firstRow;
  final String secondRow;
  final int? delayInMilliseconds;
  final bool pillShape;

  @override
  _DefaultStatCardState createState() => _DefaultStatCardState();
}

class _DefaultStatCardState extends State<DefaultStatCard> {
  @override
  Widget build(BuildContext context) {
    final int animationDurationInMilliseconds = TraleTheme.of(
      context,
    )!.transitionDuration.slow.inMilliseconds;

    final StatCard card = StatCard(
      pillShape: widget.pillShape,
      childWidget: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: TraleTheme.of(context)!.padding / 2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AutoSizeText(
              widget.firstRow,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
            AutoSizeText(
              widget.secondRow,
              style: Theme.of(context).textTheme.emphasized.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );

    return AnimateInEffect(
      delayInMilliseconds: widget.delayInMilliseconds ?? 0,
      durationInMilliseconds: animationDurationInMilliseconds,
      child: card,
    );
  }
}
