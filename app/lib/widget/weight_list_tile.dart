import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/measurement_formatter.dart';
import 'package:trale/widget/add_weight_dialog.dart';

/// A grouped list tile showing a single weight measurement that reveals
/// edit and delete buttons on long press.
///
/// Long-pressing shrinks the tile horizontally, exposing the action buttons
/// in the freed space on the right — the tile's own content stays fully
/// visible rather than sliding off-screen. Tapping the tile while revealed
/// collapses it again. At most one tile is revealed at a time, and scrolling
/// the enclosing list collapses the revealed tile.
@immutable
class WeightListTile extends StatefulWidget {
  /// Creates a [WeightListTile].
  const WeightListTile({super.key, required this.measurement});

  /// The measurement to display.
  final SortedMeasurement measurement;

  /// Collapses the currently revealed tile, if any.
  ///
  /// Call this when the surrounding screen changes (e.g. a navigation-bar
  /// tab switch) so revealed action buttons do not linger out of view.
  static void collapseOpen() => _RevealRegistry.instance.collapseOpen();

  @override
  State<WeightListTile> createState() => _WeightListTileState();
}

class _WeightListTileState extends State<WeightListTile>
    with SingleTickerProviderStateMixin {
  /// Width of a single revealed action button.
  static const double _kButtonWidth = 56.0;

  /// Total width of the revealed action area (delete + gap + edit).
  static const double _kRevealWidth = 2 * _kButtonWidth + QPLayout.space;

  // M3 Expressive spring used for the reveal/collapse animation.
  static const Cubic _kExpressive = Cubic(0.39, 1.21, 0.22, 1.0);

  late final AnimationController _ctrl;
  late final Animation<double> _reveal;

  // Cached tear-off so the registry can compare collapse callbacks by
  // identity.
  late final VoidCallback _collapse = _reverse;

  // The scroll view this tile lives in; scrolling it collapses the reveal.
  ScrollPosition? _scrollPosition;

  final MeasurementDatabase database = MeasurementDatabase();

  bool get _revealed => _ctrl.value > 0.5;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: QPLayout.transitionNormal,
    );
    _ctrl.addStatusListener(_onStatus);
    _reveal = CurvedAnimation(parent: _ctrl, curve: _kExpressive);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ScrollPosition? pos = Scrollable.maybeOf(context)?.position;
    if (pos != _scrollPosition) {
      _scrollPosition?.isScrollingNotifier.removeListener(_onScroll);
      _scrollPosition = pos;
      _scrollPosition?.isScrollingNotifier.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollPosition?.isScrollingNotifier.removeListener(_onScroll);
    _ctrl.removeStatusListener(_onStatus);
    _RevealRegistry.instance.unregister(_collapse);
    _ctrl.dispose();
    super.dispose();
  }

  // Keeps the global registry in sync with this tile's reveal state, so that
  // opening another tile collapses this one (and vice versa).
  void _onStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        _RevealRegistry.instance.register(_collapse);
      case AnimationStatus.dismissed:
        _RevealRegistry.instance.unregister(_collapse);
      case AnimationStatus.reverse:
        break;
    }
  }

  // Collapses the reveal as soon as the enclosing list starts scrolling.
  void _onScroll() {
    if (_revealed && (_scrollPosition?.isScrollingNotifier.value ?? false)) {
      _ctrl.reverse();
    }
  }

  void _reverse() => _ctrl.reverse();

  void _toggle() {
    if (_revealed) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
  }

  Future<void> _edit() async {
    final bool changed = await showAddWeightDialog(
      context: context,
      weight: widget.measurement.measurement.weight,
      date: widget.measurement.measurement.date,
      editMode: true,
    );
    if (changed) {
      await database.deleteMeasurement(widget.measurement);
    }
    if (mounted) {
      _ctrl.reverse();
    }
  }

  void _delete() {
    final SortedMeasurement deletedSortedMeasurement = widget.measurement;
    database.deleteMeasurement(widget.measurement); // fire-and-forget
    final SnackBar snackBar = SnackBar(
      content: Text(context.l10n.measurementDeleted),
      behavior: SnackBarBehavior.floating,
      width: MediaQuery.of(context).size.width / 3 * 2,
      persist: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(QPTheme.of(context)!.borderRadius),
        ),
      ),
      action: SnackBarAction(
        label: context.l10n.undo,
        onPressed: () {
          database.insertMeasurement(
            deletedSortedMeasurement.measurement,
          ); // fire-and-forget
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final MeasurementFormatter formatter = MeasurementFormatter.fromContext(
      context,
    );

    return AnimatedBuilder(
      animation: _reveal,
      builder: (BuildContext context, Widget? child) {
        final double t = _reveal.value.clamp(0.0, 1.0);
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // The tile shrinks to make room, keeping its content visible.
              Expanded(child: child!),
              SizedBox(width: QPLayout.space * t),
              // The action buttons are revealed from the right like a
              // curtain.
              SizedBox(
                width: _kRevealWidth * t,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.centerRight,
                    minWidth: _kRevealWidth,
                    maxWidth: _kRevealWidth,
                    child: SizedBox(
                      width: _kRevealWidth,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: _ActionButton(
                              icon: PhosphorIconsFill.trash,
                              onTap: _delete,
                              color: cs.tertiaryContainer,
                              iconColor: cs.onTertiaryContainer,
                            ),
                          ),
                          const SizedBox(width: QPLayout.space),
                          Expanded(
                            child: _ActionButton(
                              icon: PhosphorIconsFill.pencilSimple,
                              onTap: _edit,
                              color: cs.secondaryContainer,
                              iconColor: cs.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: QPGroupedListTile(
          title: Text(
            '${formatter.dayToString(widget.measurement.measurement)} '
            '${formatter.timeToString(widget.measurement.measurement)}',
            style: Theme.of(context).textTheme.monospace.bodyLarge,
          ),
          trailing: Text(
            formatter.weightToString(widget.measurement.measurement),
            style: Theme.of(context).textTheme.monospace.bodyLarge,
          ),
          onTap: () {
            if (_revealed) {
              _reverse();
            }
          },
          onLongPress: _toggle,
        ),
      ),
    );
  }
}

/// Tracks the single currently-revealed [WeightListTile].
///
/// Keeping at most one tile open lets opening a new tile, or an external
/// event such as a screen change, collapse whichever tile is currently
/// revealed.
class _RevealRegistry {
  _RevealRegistry._();

  /// Shared instance.
  static final _RevealRegistry instance = _RevealRegistry._();

  VoidCallback? _collapse;

  /// Marks [collapse]'s tile as the open one, collapsing any previous tile.
  void register(VoidCallback collapse) {
    if (!identical(_collapse, collapse)) {
      _collapse?.call();
      _collapse = collapse;
    }
  }

  /// Clears [collapse] as the open tile if it is the current one.
  void unregister(VoidCallback collapse) {
    if (identical(_collapse, collapse)) {
      _collapse = null;
    }
  }

  /// Collapses the open tile, if any.
  void collapseOpen() {
    final VoidCallback? collapse = _collapse;
    _collapse = null;
    collapse?.call();
  }
}

/// A tonal pill with an icon shown when a tile's actions are revealed.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(child: Icon(icon, color: iconColor)),
      ),
    );
  }
}
