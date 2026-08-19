part of '../weight_picker.dart';

/// A ruler-style picker widget for selecting weight values.

class RulerPickerController extends ValueNotifier<double> {
  /// Creates a controller with the given initial [value].
  RulerPickerController({double value = 0.0}) : super(value);
}

/// Callback invoked when the picker value changes.
typedef ValueChangedCallback = void Function(num value);

/// A horizontal ruler-style picker for selecting numeric values.
class RulerPicker extends StatefulWidget {
  /// Creates a [RulerPicker].
  RulerPicker({
    required this.onValueChange,
    required this.ticksPerStep,
    required this.value,
    this.marker,
    this.height = 90,
    this.backgroundColor = Colors.white,
    RulerPickerController? controller,
    super.key,
  }) : controller = controller ?? RulerPickerController(value: value);

  /// Callback invoked on value change.
  final ValueChangedCallback onValueChange;

  /// Height of the picker widget.
  final double height;

  /// Number of ticks per integer step.
  final int ticksPerStep;

  /// Background colour of the picker.
  final Color backgroundColor;

  /// Optional custom marker widget.
  final Widget? marker;

  /// The current value of the picker.
  final double value;

  /// Controller for external value changes.
  final RulerPickerController controller;

  @override
  State<StatefulWidget> createState() => RulerPickerState();
}

/// State for [RulerPicker].
class RulerPickerState extends State<RulerPicker>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;

  /// Drives the collapse of the ruler while the weight is typed.
  ///
  /// 1 means fully expanded, 0 fully collapsed. The ruler stays in the tree
  /// while collapsed ([SizeTransition] only clips it) so that the scroll
  /// position survives and can be animated to the typed value.
  late final AnimationController _collapseController;
  late final Animation<double> _collapse;

  /// Scroll distances longer than this many ticks are jumped, not animated.
  ///
  /// Animating over hundreds of ticks would report every crossed value to the
  /// enclosing dialog, rebuilding it on every frame of the animation.
  static const int _maxAnimatedTicks = 40;

  /// Width in logical pixels of each ruler tick.
  // Tick visuals
  final double tickWidth = 10.0;

  /// Current weight value selected by the picker.
  late num weightValue = widget.value;

  /// Whether the value is currently being typed instead of scrolled to.
  bool _editing = false;

  @override
  void initState() {
    super.initState();

    final int initialIndex = (widget.value * widget.ticksPerStep).round();
    _scrollController = ScrollController(
      initialScrollOffset: initialIndex * tickWidth,
    );

    _collapseController = AnimationController(
      vsync: this,
      duration: QPLayout.transitionNormal,
      value: 1,
    );
    _collapse = CurvedAnimation(
      parent: _collapseController,
      curve: Curves.easeOutCubic,
    );

    // External commands to jump/change value
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant RulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The default controller is rebuilt with the widget, so the listener has
    // to follow it — otherwise external value changes stop working after the
    // first rebuild of the enclosing dialog.
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _collapseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() => _scrollToValue(widget.controller.value);

  /// Value the ruler currently points at.
  double get _scrolledValue {
    final double offset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    return (offset / tickWidth).round() / widget.ticksPerStep;
  }

  /// Moves the ruler onto [value], animating short distances only.
  void _scrollToValue(double value) {
    if (!_scrollController.hasClients) {
      return;
    }
    final int targetIndex = (value * widget.ticksPerStep).round();
    final double target = targetIndex * tickWidth;
    if ((target - _scrollController.offset).abs() >
        _maxAnimatedTicks * tickWidth) {
      _scrollController.jumpTo(target);
      return;
    }
    _scrollController.animateTo(
      target,
      duration:
          QPTheme.of(context)?.transitionDuration.normal ??
          QPLayout.transitionNormal,
      curve: Curves.easeOutCubic,
    );
  }

  void _startEditing() {
    setState(() => _editing = true);
    _collapseController.reverse();
  }

  void _commitEditing(double? value) {
    setState(() => _editing = false);
    _collapseController.forward();
    if (value == null) {
      // Invalid input: fall back to what the ruler still points at, so that
      // the dialog never keeps a draft the user cannot see any more.
      widget.onValueChange(_scrolledValue);
      return;
    }
    widget.onValueChange(value);
    _scrollToValue(value);
  }

  void _updateWeightValue(num newValue) {
    widget.onValueChange(newValue);
    setState(() {
      weightValue = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return QPWidgetGroup(
      children: <Widget>[
        AnimatedBuilder(
          animation: _collapse,
          builder: (BuildContext context, _) {
            // With the ruler collapsed the bar is no longer a tile stacked on
            // top of it, so it morphs from the flush tile corners into the
            // pill shape a standalone element has in this design.
            final ShapeBorder shape = ShapeBorder.lerp(
              const StadiumBorder(),
              QPLayout.innerBorderShape,
              _collapse.value,
            )!;
            return QPGroupedWidget(
              color: colorScheme.secondary,
              shape: shape,
              child: _WeightValueField(
                value: _scrolledValue,
                ticksPerStep: widget.ticksPerStep,
                shape: shape,
                editing: _editing,
                onEditingStarted: _startEditing,
                onDraftChanged: widget.onValueChange,
                onCommitted: _commitEditing,
              ),
            );
          },
        ),
        SizeTransition(
          sizeFactor: _collapse,
          alignment: AlignmentDirectional.topStart,
          child: QPGroupedWidget(
            color: colorScheme.secondaryContainer,
            child: SizedBox(
              height: widget.height,
              width: MediaQuery.of(context).size.width,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) =>
                    _WeightSlider(
                      constraints: constraints,
                      scrollController: _scrollController,
                      ticksPerStep: widget.ticksPerStep,
                      onValueChange: _updateWeightValue,
                      tickWidth: tickWidth,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
