part of '../weight_picker.dart';

/// Restricts typed input to a positive decimal number of limited size.
class _DecimalInputFormatter extends TextInputFormatter {
  _DecimalInputFormatter({required this.integerDigits, required this.decimals})
    : _pattern = RegExp('^\\d{0,$integerDigits}([.,]\\d{0,$decimals})?\$');

  /// Maximum number of digits before the decimal separator.
  final int integerDigits;

  /// Maximum number of digits after the decimal separator.
  final int decimals;

  final RegExp _pattern;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.text.isEmpty || _pattern.hasMatch(newValue.text)
      ? newValue
      : oldValue;
}

/// The value bar displayed above the ruler of a [RulerPicker].
///
/// Tapping it replaces the label with a numeric text field so that a weight
/// can be typed instead of scrolled to. Both states reserve the same amount
/// of space, so switching between them never resizes the enclosing dialog.
class _WeightValueField extends StatefulWidget {
  const _WeightValueField({
    required this.value,
    required this.ticksPerStep,
    required this.shape,
    required this.editing,
    required this.onEditingStarted,
    required this.onDraftChanged,
    required this.onCommitted,
  });

  /// Value shown while not editing, in the currently selected unit.
  final double value;

  /// Tick grid of the ruler below, which typed input is snapped onto.
  final int ticksPerStep;

  /// Outline of the bar, morphing along with the collapse of the ruler.
  final ShapeBorder shape;

  /// Whether the text field is shown instead of the label.
  final bool editing;

  /// Called when the user taps the bar to start typing.
  final VoidCallback onEditingStarted;

  /// Called for every valid intermediate input, without moving the ruler.
  ///
  /// This keeps the enclosing dialog in sync while typing, so that saving
  /// with the keyboard still open stores what the field shows.
  final ValueChangedCallback onDraftChanged;

  /// Called when the input is committed; `null` when it was not parsable.
  final ValueChanged<double?> onCommitted;

  @override
  State<_WeightValueField> createState() => _WeightValueFieldState();
}

class _WeightValueFieldState extends State<_WeightValueField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _WeightValueField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editing && !oldWidget.editing) {
      _prefillAndFocus();
    } else if (!widget.editing && oldWidget.editing) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  TraleNotifier get _notifier =>
      Provider.of<TraleNotifier>(context, listen: false);

  TraleUnitPrecision get _precision => _notifier.unitPrecision;

  int get _decimals => _notifier.unit.decimals(_precision);

  /// Digits before the decimal separator needed for [maxWeightKg].
  int get _integerDigits =>
      (maxWeightKg / _notifier.unit.scaling).floor().toString().length;

  void _prefillAndFocus() {
    _controller.text = widget.value.toStringAsFixed(_decimals);
    // Select everything so that the first keystroke replaces the old value.
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    _focusNode.requestFocus();
  }

  // Losing focus commits, e.g. when the ruler below is touched.
  void _onFocusChanged() {
    if (!_focusNode.hasFocus && widget.editing) {
      _commit();
    }
  }

  double? _parse(String value) =>
      _notifier.unit.parseWeight(value, _precision, grid: widget.ticksPerStep);

  void _commit() => widget.onCommitted(_parse(_controller.text));

  void _onChanged(String value) {
    final double? draft = _parse(value);
    if (draft != null) {
      widget.onDraftChanged(draft);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle valueStyle = Theme.of(context)
        .textTheme
        .emphasized
        .monospace
        .headlineLarge!
        .apply(color: colorScheme.onSecondary);

    return Semantics(
      button: !widget.editing,
      label: context.l10n.enterWeightManually,
      child: Material(
        type: MaterialType.transparency,
        shape: widget.shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.editing ? null : widget.onEditingStarted,
          customBorder: widget.shape,
          splashColor: colorScheme.onSecondary.withValues(alpha: 0.12),
          highlightColor: colorScheme.onSecondary.withValues(alpha: 0.1),
          hoverColor: colorScheme.onSecondary.withValues(alpha: 0.08),
          child: Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(
              top: (QPLayout.padding + QPLayout.smallPadding) / 2,
              bottom: QPLayout.smallPadding,
            ),
            child: widget.editing
                ? _input(context, colorScheme, valueStyle)
                : Text(
                    '${widget.value.toStringAsFixed(_decimals)} '
                    '${_notifier.unit.name}',
                    style: valueStyle,
                  ),
          ),
        ),
      ),
    );
  }

  /// The text field shown in place of the label while editing.
  Widget _input(
    BuildContext context,
    ColorScheme colorScheme,
    TextStyle valueStyle,
  ) {
    // Reserve room for the widest value the unit allows, so that the field
    // does not resize with every keystroke. It stays [Flexible] so a narrow
    // dialog shrinks it instead of overflowing.
    final Size valueSize = sizeOfText(
      text: "${'8' * _integerDigits}.${'8' * _decimals}",
      context: context,
      style: valueStyle,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: SizedBox(
            width: valueSize.width,
            height: valueSize.height,
            child: TextSelectionTheme(
              // Without this the selection falls back to the global primary
              // colour, which does not belong on the secondary coloured bar.
              data: TextSelectionThemeData(
                cursorColor: colorScheme.onSecondary,
                selectionHandleColor: colorScheme.onSecondary,
                selectionColor: colorScheme.onSecondary.withValues(alpha: 0.3),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: valueStyle,
                textAlign: TextAlign.center,
                cursorColor: colorScheme.onSecondary,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                inputFormatters: <TextInputFormatter>[
                  _DecimalInputFormatter(
                    integerDigits: _integerDigits,
                    decimals: _decimals,
                  ),
                ],
                decoration: const InputDecoration(
                  filled: false,
                  isCollapsed: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: _onChanged,
                onSubmitted: (String _) => _commit(),
              ),
            ),
          ),
        ),
        Text(' ${_notifier.unit.name}', style: valueStyle, maxLines: 1),
      ],
    );
  }
}
