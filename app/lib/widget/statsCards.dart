import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:trale/core/theme.dart';
import 'package:trale/widget/animate_in_effect.dart';


class StatCard extends StatefulWidget {
  const StatCard({
    required this.childWidget,
    this.backgroundColor,
    this.delayInMilliseconds = 0,
    this.nx = 1,
    this.ny = 1,
    super.key});

  final Widget childWidget;
  final int nx;
  final int ny;
  final Color? backgroundColor;
  final int? delayInMilliseconds;

  @override
  _StatCardState createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  @override
  Widget build(BuildContext context) {

    final int animationDurationInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.slow.inMilliseconds;

    final Color backgroundcolor = widget.backgroundColor
        ?? Theme.of(context).colorScheme.secondaryContainer;
    final double xWidth = (MediaQuery.sizeOf(context).width
        - 3 * TraleTheme.of(context)!.padding) / 2;
    final double yWidth = (xWidth - TraleTheme.of(context)!.padding) / 2;

    final double height = widget.ny == 1
        ? yWidth * widget.ny
        : yWidth * widget.ny
          + (widget.ny - 1) * TraleTheme.of(context)!.padding;
    final double width = widget.nx == 1
        ? xWidth * widget.nx
        : xWidth * widget.nx
          + (widget.nx - 1) * TraleTheme.of(context)!.padding;

    final Card card = Card(
      shape: TraleTheme.of(context)!.borderShape,
      color: backgroundcolor,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        height: height,
        width: width,
        child: widget.childWidget,
      ),
    );

    return AnimateInEffect(
      delayInMilliseconds: widget.delayInMilliseconds ?? 0,
      durationInMilliseconds: animationDurationInMilliseconds,
      child: card);
  }
}


class OneThirdStatCard extends StatefulWidget {
  const OneThirdStatCard({
    required this.childWidget,
    this.delayInMilliseconds = 0,
    super.key});

  final Widget childWidget;
  final int? delayInMilliseconds;

  @override
  _OneThirdStatCardState createState() => _OneThirdStatCardState();
}

class _OneThirdStatCardState extends State<OneThirdStatCard> {
  @override
  Widget build(BuildContext context) {

    final int animationDurationInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.slow.inMilliseconds;

    final double xWidth = (MediaQuery.sizeOf(context).width
        - 3 * TraleTheme.of(context)!.padding) / 2;
    final double height = (xWidth - TraleTheme.of(context)!.padding) / 2;
    final double width = (MediaQuery.sizeOf(context).width
        - 4 * TraleTheme.of(context)!.padding - height) / 2;

    final Card card = Card(
      shape: TraleTheme.of(context)!.borderShape,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: SizedBox(
        height: height,
        width: width,
        child: widget.childWidget,
      ),
    );

    return AnimateInEffect(
        delayInMilliseconds: widget.delayInMilliseconds ?? 0,
        durationInMilliseconds: animationDurationInMilliseconds,
        child: card);
  }
}


class DefaultStatCard extends StatefulWidget {
  const DefaultStatCard({
    required this.firstRow,
    required this.secondRow,
    this.delayInMilliseconds = 0,
    super.key});

  final String firstRow;
  final String secondRow;
  final int? delayInMilliseconds;

  @override
  _DefaultStatCardState createState() => _DefaultStatCardState();
}

class _DefaultStatCardState extends State<DefaultStatCard> {
  @override
  Widget build(BuildContext context) {

    final int animationDurationInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.slow.inMilliseconds;

    final StatCard card = StatCard(childWidget:
    Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AutoSizeText(
            widget.firstRow,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            maxLines: 1,
          ),
          AutoSizeText(
            widget.secondRow,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w700
            ),
            maxLines: 1,
          ),
        ])
    );

    return AnimateInEffect(
        delayInMilliseconds: widget.delayInMilliseconds ?? 0,
        durationInMilliseconds: animationDurationInMilliseconds,
        child: card);
  }
}