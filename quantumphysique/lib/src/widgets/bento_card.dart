import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter_m3shapes_extended/flutter_m3shapes_extended.dart';
import 'package:quantumphysique/src/types/font.dart';
import 'package:quantumphysique/src/widgets/animate_in_effect.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';

/// The internal layout mode selected by each [BentoCard] constructor.
enum _BentoCardMode { custom, text, textEmphasized, textInline }

/// A card widget for use within a [BentoGrid].
class BentoCard extends StatelessWidget {
  /// Default constructor with a custom child widget.
  const BentoCard({
    required Widget this.child,
    this.columnSpan = 6,
    this.rowSpan = 2,
    this.backgroundColor,
    this.delayInMilliseconds = 0,
    this.pillShape = false,
    this.onTap,
    super.key,
  }) : _mode = _BentoCardMode.custom,
       _label = null,
       _value = null,
       _sublabel = null,
       _textColor = null,
       _m3eShape = null,
       _rotateDuration = Duration.zero,
       _reversed = false;

  /// Two centered text rows: a small label on top and a bold value below.
  const BentoCard.text({
    required String label,
    required String value,
    this.columnSpan = 6,
    this.rowSpan = 2,
    this.backgroundColor,
    this.delayInMilliseconds = 0,
    this.pillShape = false,
    super.key,
  }) : _mode = _BentoCardMode.text,
       child = null,
       onTap = null,
       _label = label,
       _value = value,
       _sublabel = null,
       _textColor = null,
       _m3eShape = null,
       _rotateDuration = Duration.zero,
       _reversed = false;

  /// Vertical card with a small label and a large emphasized value.
  const BentoCard.textEmphasized({
    required String label,
    required String value,
    String? sublabel,
    bool reversed = false,
    Color? textColor,
    this.columnSpan = 6,
    this.rowSpan = 2,
    this.backgroundColor,
    this.delayInMilliseconds = 0,
    this.pillShape = false,
    super.key,
  }) : _mode = _BentoCardMode.textEmphasized,
       child = null,
       onTap = null,
       _label = label,
       _value = value,
       _sublabel = sublabel,
       _textColor = textColor,
       _m3eShape = null,
       _rotateDuration = Duration.zero,
       _reversed = reversed;

  /// Horizontal card with a label and a large value placed side by side.
  const BentoCard.textInline({
    required String label,
    required String value,
    bool reversed = false,
    Color? textColor,
    this.columnSpan = 6,
    this.rowSpan = 2,
    this.backgroundColor,
    this.delayInMilliseconds = 0,
    this.pillShape = false,
    super.key,
  }) : _mode = _BentoCardMode.textInline,
       child = null,
       onTap = null,
       _label = label,
       _value = value,
       _sublabel = null,
       _textColor = textColor,
       _m3eShape = null,
       _rotateDuration = Duration.zero,
       _reversed = reversed;

  /// Square card with a custom child, optional M3E shape background,
  /// and optional continuous rotation.
  const BentoCard.shaped({
    required Widget this.child,
    int span = 6,
    this.backgroundColor,
    this.delayInMilliseconds = 0,
    this.pillShape = false,
    this.onTap,
    Shapes? m3eShape,
    Duration rotateDuration = Duration.zero,
    super.key,
  }) : _mode = _BentoCardMode.custom,
       _label = null,
       _value = null,
       _sublabel = null,
       _textColor = null,
       columnSpan = span,
       rowSpan = span,
       _m3eShape = m3eShape,
       _rotateDuration = rotateDuration,
       _reversed = false;

  /// Large hero number on top with a subtitle below.
  factory BentoCard.hero({
    required String label,
    required String value,
    Color? textColor,
    int valueFlex = 2,
    int labelFlex = 1,
    int span = 6,
    Color? backgroundColor,
    int delayInMilliseconds = 0,
    bool pillShape = false,
    Shapes? m3eShape,
    Duration rotateDuration = Duration.zero,
    Key? key,
  }) {
    return BentoCard.shaped(
      span: span,
      backgroundColor: backgroundColor,
      delayInMilliseconds: delayInMilliseconds,
      pillShape: pillShape,
      m3eShape: m3eShape,
      rotateDuration: rotateDuration,
      key: key,
      child: _HeroContent(
        label: label,
        value: value,
        textColor: textColor,
        valueFlex: valueFlex,
        labelFlex: labelFlex,
      ),
    );
  }

  /// Child widget for the default and [BentoCard.shaped] constructors.
  final Widget? child;

  /// Number of grid columns this card spans.
  final int columnSpan;

  /// Number of grid rows this card spans.
  final int rowSpan;

  /// Background color. Defaults to [ColorScheme.surfaceContainer].
  final Color? backgroundColor;

  /// Delay before the entrance animation starts.
  final int delayInMilliseconds;

  /// Whether to use a pill (stadium) shape instead of the bento border shape.
  final bool pillShape;

  /// Optional tap callback.
  final VoidCallback? onTap;

  final Color? _textColor;
  final Shapes? _m3eShape;
  final Duration _rotateDuration;
  final _BentoCardMode _mode;
  final String? _label;
  final String? _value;
  final String? _sublabel;
  final bool _reversed;

  // ── Build helpers ─────────────────────────────────────────────────────────

  Widget _buildText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: QPLayout.padding / 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AutoSizeText(
            _label!,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          AutoSizeText(
            _value!,
            style: Theme.of(context).textTheme.emphasized.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTextEmphasized(BuildContext context) {
    const double pad = QPLayout.padding / 2;
    final Widget labelWidget = Padding(
      padding: _reversed
          ? const EdgeInsets.only(left: pad, right: pad, bottom: pad)
          : const EdgeInsets.only(left: pad, right: pad, top: pad),
      child: AutoSizeText(
        _label!,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge!.onSurface(context).copyWith(color: _textColor),
        maxLines: 2,
        textAlign: TextAlign.center,
      ),
    );
    final Widget valueWidget = Expanded(
      child: Padding(
        padding: _reversed
            ? const EdgeInsets.only(left: pad / 2, right: pad / 2, top: pad / 2)
            : const EdgeInsets.only(
                left: pad / 2,
                right: pad / 2,
                bottom: pad / 2,
              ),
        child: Align(
          alignment: Alignment.center,
          child: AutoSizeText(
            _value!,
            style: Theme.of(context).textTheme.emphasized.bodyMedium!
                .onSurface(context)
                .copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 200,
                  height: 0.7,
                  color: _textColor,
                ),
            maxLines: 1,
          ),
        ),
      ),
    );
    final List<Widget> children = _reversed
        ? <Widget>[valueWidget, labelWidget]
        : <Widget>[labelWidget, valueWidget];
    if (_sublabel != null) {
      final Widget sublabelWidget = Padding(
        padding: _reversed
            ? const EdgeInsets.only(left: pad, right: pad, top: pad)
            : const EdgeInsets.only(left: pad, right: pad, bottom: pad),
        child: AutoSizeText(
          _sublabel,
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.onSurface(context).copyWith(color: _textColor),
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      );
      if (_reversed) {
        children.insert(0, sublabelWidget);
      } else {
        children.add(sublabelWidget);
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildTextInline(BuildContext context) {
    final Color labelColor =
        _textColor ?? Theme.of(context).colorScheme.onSurface;
    final Widget valueWidget = Expanded(
      child: Align(
        alignment: Alignment.center,
        child: AutoSizeText(
          _value!,
          style: Theme.of(context).textTheme.emphasized.displayLarge!.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 200,
            color: _textColor,
          ),
          maxLines: 1,
        ),
      ),
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Widget labelWidget = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth / 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: QPLayout.padding),
            child: AutoSizeText(
              _label!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(height: 1.0, color: labelColor),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _reversed
              ? <Widget>[valueWidget, labelWidget]
              : <Widget>[labelWidget, valueWidget],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer;

    final ShapeBorder shape = _m3eShape != null
        ? M3EShapeBorder(shape: _m3eShape)
        : pillShape
        ? const StadiumBorder()
        : QPLayout.bentoBorderShape;

    final Widget content = switch (_mode) {
      _BentoCardMode.custom => child!,
      _BentoCardMode.text => _buildText(context),
      _BentoCardMode.textEmphasized => _buildTextEmphasized(context),
      _BentoCardMode.textInline => _buildTextInline(context),
    };

    if (_rotateDuration > Duration.zero && _m3eShape != null) {
      return GestureDetector(
        onTap: onTap,
        child: QPAnimateInEffect(
          delayInMilliseconds: delayInMilliseconds,
          durationInMilliseconds: QPLayout.transitionSlow.inMilliseconds,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double side = constraints.biggest.shortestSide;
              const double padding = QPLayout.padding / 2;
              final double diameter = side - padding * 2;
              final double innerSide = diameter / math.sqrt2;
              return Center(
                child: SizedBox(
                  width: diameter,
                  height: diameter,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      _RotatingShape(
                        shape: _m3eShape,
                        color: bgColor,
                        duration: _rotateDuration,
                      ),
                      ClipOval(
                        child: SizedBox(
                          width: innerSide,
                          height: innerSide,
                          child: content,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return QPAnimateInEffect(
      delayInMilliseconds: delayInMilliseconds,
      durationInMilliseconds: QPLayout.transitionSlow.inMilliseconds,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: shape,
          color: bgColor,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.hardEdge,
          child: content,
        ),
      ),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.label,
    required this.value,
    this.textColor,
    this.valueFlex = 2,
    this.labelFlex = 1,
  });

  final String label;
  final String value;
  final Color? textColor;
  final int valueFlex;
  final int labelFlex;

  @override
  Widget build(BuildContext context) {
    final Color color = textColor ?? Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(QPLayout.padding / 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: valueFlex,
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                value,
                style: Theme.of(context).textTheme.emphasized.displayLarge!
                    .copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 200,
                    ),
                maxLines: 1,
              ),
            ),
          ),
          Expanded(
            flex: labelFlex,
            child: Align(
              alignment: Alignment.topCenter,
              child: AutoSizeText(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: color, height: 1.0),
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RotatingShape extends StatefulWidget {
  const _RotatingShape({
    required this.shape,
    required this.color,
    required this.duration,
  });

  final Shapes shape;
  final Color color;
  final Duration duration;

  @override
  State<_RotatingShape> createState() => _RotatingShapeState();
}

class _RotatingShapeState extends State<_RotatingShape>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: SizedBox.expand(
          key: ValueKey<Shapes>(widget.shape),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: M3EShapeBorder(shape: widget.shape),
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
