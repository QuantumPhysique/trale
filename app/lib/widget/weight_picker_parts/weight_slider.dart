part of '../weight_picker.dart';

class _WeightSlider extends StatefulWidget {
  const _WeightSlider({
    required this.constraints,
    required this.scrollController,
    required this.ticksPerStep,
    required this.onValueChange,
    required this.tickWidth,
  });

  final double tickWidth;
  final BoxConstraints constraints;
  final ScrollController scrollController;
  final ValueChangedCallback onValueChange;
  final int ticksPerStep;
  @override
  State<_WeightSlider> createState() => _WeightSliderState();
}

class _WeightSliderState extends State<_WeightSlider> {
  int _lastReportedIndex = -1;

  final double barWidth = 4.0;
  final double widthLargeTick = 10.0;
  @override
  Widget build(BuildContext context) {
    final double padding = QPTheme.of(context)!.padding;
    final double width = widget.constraints.maxWidth;
    final double height = widget.constraints.maxHeight - 1.5 * padding;
    final ScrollController scrollController = widget.scrollController;
    final double heightLargeTick = height - 2 * padding;
    final double heightSmallTick = height - 3.5 * padding;
    final double tickWidth = widget.tickWidth;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double leadTrailPad = ((width - tickWidth) / 2.0).clamp(
      0.0,
      double.infinity,
    );

    final Widget marker = _SliderMarker(
      widthLargeTick: widthLargeTick,
      heightLargeTick: heightLargeTick,
      barWidth: barWidth,
      tickWidth: tickWidth,
    );

    return Container(
      width: width,
      height: height + 1.5 * padding,
      padding: EdgeInsets.only(bottom: 0.5 * padding, top: padding),
      child: Listener(
        onPointerDown: (_) => FocusScope.of(context).requestFocus(FocusNode()),
        child: AnimatedBuilder(
          animation: scrollController,
          builder: (BuildContext context, _) {
            final double offset = scrollController.hasClients
                ? scrollController.offset
                : 0.0;
            final double page = offset / tickWidth;

            // Visible items count in viewport (approx).
            final double pagesVisible = (width / tickWidth).clamp(
              1.0,
              double.infinity,
            );

            // Start fading at the third-last visible tick towards each edge
            final double edgeStart = (1.0 - 4.0 / pagesVisible).clamp(0.0, 1.0);

            // Inside build(), before scaleForIndex:
            final double zeroAtInsetPx =
                0.5 * tickWidth; // reach 0 scale this many px before the edge
            final double halfViewportPx = width / 2.0;
            final double zeroAtRel =
                ((halfViewportPx - zeroAtInsetPx) / halfViewportPx).clamp(
                  0.0,
                  1.0,
                );

            // Keep pagesVisible and edgeStart as you already compute them.
            // Then update scaleForIndex:
            double scaleForIndex(int index) {
              final double rel = ((index - page) / (pagesVisible / 2.0)).abs();
              final double denom = max(
                1e-6,
                zeroAtRel - edgeStart,
              ); // avoid div-by-zero
              final double t = ((rel - edgeStart) / denom).clamp(0.0, 1.0);
              return 1.0 - t;
            }

            // Report snapped value when the nearest index changes.
            final int nearestIndex = page.round();
            if (nearestIndex != _lastReportedIndex) {
              _lastReportedIndex = nearestIndex;
              final double newValue = nearestIndex / widget.ticksPerStep;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) {
                  return;
                }
                widget.onValueChange(newValue);
              });
            }

            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: leadTrailPad),
                  physics: MultiItemSnapScrollPhysics(
                    snapSize: tickWidth,
                    parent: const ClampingScrollPhysics(),
                  ),
                  itemExtent: tickWidth,
                  itemBuilder: (BuildContext context, int index) {
                    final bool isMajor = index % widget.ticksPerStep == 0;
                    final bool isMedium = index % 5 == 0;
                    final double scalex = scaleForIndex(index);
                    final double scaley = (0.5 + scalex).clamp(0.0, 1.0);

                    final double tickHeight = isMajor
                        ? heightLargeTick
                        : isMedium
                        ? 0.5 * (heightLargeTick + heightSmallTick)
                        : heightSmallTick;

                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        Transform(
                          alignment: Alignment.topCenter,
                          transform: Matrix4.diagonal3Values(
                            scalex,
                            scaley,
                            1.0,
                          ),
                          child: Container(
                            width: isMajor ? barWidth : barWidth / 2,
                            height: tickHeight,
                            decoration: BoxDecoration(
                              color: colorScheme.onSecondaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        if (isMajor)
                          Positioned(
                            bottom: 0,
                            width: tickWidth * widget.ticksPerStep,
                            left:
                                -0.5 * tickWidth * (widget.ticksPerStep - 0.75),
                            child: Container(
                              alignment: Alignment.center,
                              child: Transform(
                                alignment: Alignment.topCenter,
                                origin: Offset(
                                  0,
                                  -(1 - scaley) * heightLargeTick,
                                ),
                                transform: Matrix4.diagonal3Values(
                                  scalex,
                                  scalex,
                                  1.0,
                                ),
                                child: Text(
                                  (index / widget.ticksPerStep).toStringAsFixed(
                                    0,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .monospace
                                      .titleLarge!
                                      .apply(
                                        color: colorScheme.onSecondaryContainer,
                                      ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                Positioned(top: 0, child: marker),
              ],
            );
          },
        ),
      ),
    );
  }
}
