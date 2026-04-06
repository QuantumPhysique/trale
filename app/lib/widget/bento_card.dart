import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter_m3shapes_extended/flutter_m3shapes_extended.dart';
import 'package:trale/core/font.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/animate_in_effect.dart';

/// The internal layout mode selected by each [BentoCard] constructor.
enum _BentoCardMode { custom, text, textEmphasized, textInline }

/// A card widget for use within a [BentoGrid].
///
/// Specifies how many grid columns ([columnSpan]) and rows ([rowSpan])
/// the card occupies. The actual pixel size is computed by the parent
/// [BentoGrid] based on available width, column count, and bento padding.
///
/// Named constructors provide common card layouts:
/// - [BentoCard.new] — fully custom child widget.
/// - [BentoCard.text] — small label + value text rows.
/// - [BentoCard.shaped] — custom child with an M3E shape and optional
///   rotation; always square ([span] × [span] grid cells).
/// - [BentoCard.hero] — large display number with a subtitle, built on top
///   of [BentoCard.shaped].
class BentoCard extends StatelessWidget {
  /// Default constructor with a custom child widget.
  const BentoCard({
    required Widget this.child,
    this.columnSpan = 6,
    this.rowSpan = 2,
    this.backgroundColor,
    this.delayInMilliseconds = 0,
    this.pillShape = false,
    super.key,
  }) : _mode = _BentoCardMode.custom,
       _label = null,
       _value = null,
       _m3eShape = null,
       _rotateDuration = Duration.zero,
       _valueFlex = 1,
       _reversed = false;

  /// Two centered text rows: a small label on top and a bold value below.
  ///
  /// Replaces the old `DefaultStatCard` pattern used by calorie deficit,
  /// diff-from-target, max-streak, and measurement-frequency cards.
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
       _label = label,
       _value = value,
       _m3eShape = null,
       _rotateDuration = Duration.zero,
       _valueFlex = 1,
       _reversed = false;

  /// Vertical card with a small label and a large emphasized value.
  ///
  /// By default ([reversed] = false) the label is above and the value below,
  /// matching the min-weight card pattern. With [reversed] = true the value
  /// is on top (like the max-weight card).
  ///
  /// [valueFlex] controls the space ratio of the value region (default 2).
  const BentoCard.textEmphasized({
    required String label,
    required String value,
    int valueFlex = 2,
    bool reversed = false,
    this.columnSpan = 6,
    this.rowSpan = 2,
    this.backgroundColor,
    this.delayInMilliseconds = 0,
    this.pillShape = false,
    super.key,
  }) : _mode = _BentoCardMode.textEmphasized,
       child = null,
       _label = label,
       _value = value,
       _m3eShape = null,
       _rotateDuration = Duration.zero,
       _valueFlex = valueFlex,
       _reversed = reversed;

  /// Horizontal card with a label and a large value placed side by side.
  ///
  /// By default ([reversed] = false) the label is on the left and the large
  /// value on the right (BMI card pattern). With [reversed] = true the value
  /// is on the left (time-since-first pattern).
  ///
  /// [valueFlex] controls the relative width of the value side (default 2).
  const BentoCard.textInline({
    required String label,
    required String value,
    int valueFlex = 2,
    bool reversed = false,
    this.columnSpan = 6,
    this.rowSpan = 2,
    this.backgroundColor,
    this.delayInMilliseconds = 0,
    this.pillShape = false,
    super.key,
  }) : _mode = _BentoCardMode.textInline,
       child = null,
       _label = label,
       _value = value,
       _m3eShape = null,
       _rotateDuration = Duration.zero,
       _valueFlex = valueFlex,
       _reversed = reversed;

  /// Square card ([span] × [span] grid cells) with a custom child, an
  /// optional M3E shape background, and optional continuous rotation.
  ///
  /// [m3eShape] and [rotateDuration] are exclusive to this constructor and
  /// [BentoCard.hero], which is built on top of it.
  const BentoCard.shaped({
    required Widget this.child,
    int span = 6,
    this.backgroundColor,
    this.delayInMilliseconds = 0,
    this.pillShape = false,
    Shapes? m3eShape,
    Duration rotateDuration = Duration.zero,
    super.key,
  }) : _mode = _BentoCardMode.custom,
       _label = null,
       _value = null,
       columnSpan = span,
       rowSpan = span,
       _m3eShape = m3eShape,
       _rotateDuration = rotateDuration,
       _valueFlex = 1,
       _reversed = false;

  /// Large hero number on top with a subtitle below (vertical layout).
  ///
  /// Built on top of [BentoCard.shaped]: uses a square [span] × [span]
  /// footprint and supports [m3eShape] and [rotateDuration].
  ///
  /// [valueFlex] and [labelFlex] control the space ratio between the
  /// display number and the subtitle (defaults: 2 and 1).
  /// [textColor] overrides the automatically derived text color.
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

  // -- Common fields --

  /// Child widget supplied by the default and [BentoCard.shaped] constructors.
  /// `null` for named-constructor modes that build their own content.
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

  // -- Private fields set by [BentoCard.shaped] (and [BentoCard.hero]) --

  /// Optional Material 3 Expressive shape.
  ///
  /// When set, overrides [pillShape] and the default bento border shape.
  /// Only available via [BentoCard.shaped] and [BentoCard.hero].
  final Shapes? _m3eShape;

  /// Duration for one full rotation of the M3E shape background.
  ///
  /// [Duration.zero] (default) disables rotation.
  /// Only takes effect when [_m3eShape] is set.
  /// Only available via [BentoCard.shaped] and [BentoCard.hero].
  final Duration _rotateDuration;

  // -- Private fields set by named constructors --

  final _BentoCardMode _mode;
  final String? _label;
  final String? _value;
  final int _valueFlex;
  final bool _reversed;

  // -- Build helpers --

  Widget _buildText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding / 2,
      ),
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
    final Widget labelWidget = Expanded(
      child: Align(
        alignment: Alignment.center,
        child: AutoSizeText(
          _label!,
          style: Theme.of(context).textTheme.bodyLarge!.onSurface(context),
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
    );
    final Widget valueWidget = Expanded(
      flex: _valueFlex,
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
              ),
          maxLines: 1,
        ),
      ),
    );
    return Padding(
      padding: EdgeInsets.all(TraleTheme.of(context)!.padding / 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _reversed
            ? <Widget>[valueWidget, labelWidget]
            : <Widget>[labelWidget, valueWidget],
      ),
    );
  }

  Widget _buildTextInline(BuildContext context) {
    final Widget labelWidget = Expanded(
      child: Align(
        alignment: Alignment.center,
        child: AutoSizeText(
          _label!,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.0),
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
    );
    final Widget valueWidget = Expanded(
      flex: _valueFlex,
      child: Align(
        alignment: Alignment.center,
        child: AutoSizeText(
          _value!,
          style: Theme.of(context).textTheme.emphasized.displayLarge!.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 200,
          ),
          maxLines: 1,
        ),
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _reversed
          ? <Widget>[valueWidget, labelWidget]
          : <Widget>[labelWidget, valueWidget],
    );
  }

  @override
  Widget build(BuildContext context) {
    final TraleTheme theme = TraleTheme.of(context)!;
    final Color bgColor =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer;

    final ShapeBorder shape = _m3eShape != null
        ? M3EShapeBorder(shape: _m3eShape)
        : pillShape
        ? const StadiumBorder()
        : theme.bentoBorderShape;

    final Widget content = switch (_mode) {
      _BentoCardMode.custom => child!,
      _BentoCardMode.text => _buildText(context),
      _BentoCardMode.textEmphasized => _buildTextEmphasized(context),
      _BentoCardMode.textInline => _buildTextInline(context),
    };

    // Rotating M3E shape: shape background spins, content stays.
    // Circular clip with padding, rotating shape behind content.
    // Content is constrained to the inscribed square of the circle
    // (side = diameter / √2) so text never reaches the oval edge.
    if (_rotateDuration > Duration.zero && _m3eShape != null) {
      return AnimateInEffect(
        delayInMilliseconds: delayInMilliseconds,
        durationInMilliseconds: theme.transitionDuration.slow.inMilliseconds,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double side = constraints.biggest.shortestSide;
            final double padding = theme.padding / 2;
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
      );
    }

    return AnimateInEffect(
      delayInMilliseconds: delayInMilliseconds,
      durationInMilliseconds: theme.transitionDuration.slow.inMilliseconds,
      child: Card(
        shape: shape,
        color: bgColor,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.hardEdge,
        child: content,
      ),
    );
  }
}

/// Hero content widget: large display number with a subtitle below.
///
/// Used internally by [BentoCard.hero].
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
      padding: EdgeInsets.all(TraleTheme.of(context)!.padding / 2),
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

/// A continuously rotating M3E shape background.
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
      child: SizedBox.expand(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: M3EShapeBorder(shape: widget.shape),
            color: widget.color,
          ),
        ),
      ),
    );
  }
}
