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
class RulerPickerState extends State<RulerPicker> {
  late final ScrollController _scrollController;

  /// Width in logical pixels of each ruler tick.
  // Tick visuals
  final double tickWidth = 10.0;

  /// Current weight value selected by the picker.
  late num weightValue = widget.value;

  @override
  void initState() {
    super.initState();

    final int initialIndex = (widget.value * widget.ticksPerStep).round();
    _scrollController = ScrollController(
      initialScrollOffset: initialIndex * tickWidth,
    );

    // External commands to jump/change value
    widget.controller.addListener(() {
      if (!_scrollController.hasClients) {
        return;
      }
      final int targetIndex = (widget.controller.value * widget.ticksPerStep)
          .round();
      _scrollController.animateTo(
        targetIndex * tickWidth,
        duration:
            QPTheme.of(context)?.transitionDuration.normal ??
            const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _weightLabelWidget(BuildContext context, double weight, Color color) {
    final TraleNotifier notifier = Provider.of<TraleNotifier>(
      context,
      listen: false,
    );
    final int precision =
        notifier.unitPrecision.precision ?? notifier.unit.precision;
    final Text valueLabel = Text(
      '${weight.toStringAsFixed(precision)} '
      '${notifier.unit.name}',
      style: Theme.of(
        context,
      ).textTheme.emphasized.monospace.headlineLarge?.apply(color: color),
    );

    final double padding = QPTheme.of(context)!.padding;
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(top: 0.75 * padding, bottom: 0.5 * padding),
      child: valueLabel,
    );
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

    final double offset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    final double page = offset / tickWidth;
    final int nearestIndex = page.round();

    final double newValue = nearestIndex / widget.ticksPerStep;

    return QPWidgetGroup(
      children: <Widget>[
        QPGroupedWidget(
          color: colorScheme.secondary,
          child: _weightLabelWidget(context, newValue, colorScheme.onSecondary),
        ),
        QPGroupedWidget(
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
      ],
    );
  }
}
