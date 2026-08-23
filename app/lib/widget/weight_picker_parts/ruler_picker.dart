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
  Future<void> _scrollToValue(double value) async {
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
    return _scrollController.animateTo(
      target,
      duration:
          QPTheme.of(context)?.transitionDuration.normal ??
          QPLayout.transitionNormal,
      curve: Curves.easeOutCubic,
    );
  }

  /// Weight change of a single stepper tap, in the currently selected unit.
  double get _stepSize => 1 / widget.ticksPerStep;

  /// Highest value the ruler may be stepped to, in the selected unit.
  double get _maxValue =>
      maxWeightKg /
      Provider.of<TraleNotifier>(context, listen: false).unit.scaling;

  /// Value the pending stepper animation is heading for.
  ///
  /// Taps arriving faster than the scroll animation would otherwise start
  /// over from the still moving offset, so that two taps add up to less than
  /// two ticks. Counting from the last target instead keeps them exact.
  double? _stepTarget;

  /// Whether the value can still be moved by [steps] ticks.
  bool _canStep(int steps) {
    final double value = _stepTarget ?? _scrolledValue;
    return steps < 0 ? value > 0 : value < _maxValue;
  }

  /// Moves the value by [steps] ticks, just like scrolling there would.
  Future<void> _stepBy(int steps) async {
    final double target = ((_stepTarget ?? _scrolledValue) + steps * _stepSize)
        .clamp(0.0, _maxValue);
    _stepTarget = target;
    await _scrollToValue(target);
    // A drag interrupting the animation completes it too, so the target is
    // only stale if no newer tap has replaced it in the meantime.
    if (_stepTarget == target) {
      _stepTarget = null;
    }
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        QPWidgetGroup(
          // The bottom margin is dropped: the stepper row below supplies
          // the whole gap itself, via its own top margin.
          padding: const EdgeInsets.only(top: QPLayout.smallPadding),
          children: <Widget>[
            AnimatedBuilder(
              animation: _collapse,
              builder: (BuildContext context, _) {
                // With the ruler collapsed the bar is no longer a tile stacked
                // on top of it, so it morphs from the flush tile corners into
                // the pill shape a standalone element has in this design.
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
                    builder:
                        (BuildContext context, BoxConstraints constraints) =>
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
        ),
        // The steppers are part of the ruler and collapse along with it: while
        // typing, the keyboard offers the same fine adjustment.
        SizeTransition(
          sizeFactor: _collapse,
          alignment: AlignmentDirectional.topStart,
          child: _stepperRow(context, colorScheme),
        ),
      ],
    );
  }

  /// The `-` / `+` pair below the ruler.
  ///
  /// It repeats the grouped icon button design of the chart's zoom controls,
  /// but takes the colour of the ruler so that both read as one control. The
  /// gap to the ruler is [QPLayout.bentoPadding], matching the tight spacing
  /// between bento cells rather than the wider gap used between unrelated
  /// widget groups elsewhere in the dialog.
  Widget _stepperRow(BuildContext context, ColorScheme colorScheme) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[
      QPWidgetGroup(
        direction: Axis.horizontal,
        padding: const EdgeInsets.only(
          top: QPLayout.bentoPadding,
          bottom: QPLayout.smallPadding,
        ),
        children: <Widget>[
          _stepperButton(
            context,
            colorScheme,
            icon: PhosphorIconsRegular.minus,
            steps: -1,
            tooltip: context.l10n.decreaseWeight,
          ),
          _stepperButton(
            context,
            colorScheme,
            icon: PhosphorIconsRegular.plus,
            steps: 1,
            tooltip: context.l10n.increaseWeight,
          ),
        ],
      ),
    ],
  );

  /// A single stepper button moving the value by [steps] ticks.
  Widget _stepperButton(
    BuildContext context,
    ColorScheme colorScheme, {
    required IconData icon,
    required int steps,
    required String tooltip,
  }) => QPGroupedWidget(
    color: colorScheme.secondaryContainer,
    child: IconButton(
      onPressed: _canStep(steps) ? () => _stepBy(steps) : null,
      color: colorScheme.onSecondaryContainer,
      disabledColor: colorScheme.onSecondaryContainer.withValues(alpha: 0.38),
      tooltip: tooltip,
      icon: PPIcon(icon, context, color: colorScheme.onSecondaryContainer),
    ),
  );
}
