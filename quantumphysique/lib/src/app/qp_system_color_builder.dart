import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/services.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:material_ui/material_ui.dart';
import 'package:quantumphysique/src/theme/qp_system_colors.dart';
import 'package:quantumphysique/src/types/logger.dart';

/// Queries the operating system for its colours and rebuilds when they arrive.
///
/// This is a replacement for `DynamicColorBuilder` from `dynamic_color`, which
/// converts the Android core palette to a [ColorScheme] before handing it over
/// and, in doing so, fills the `surfaceContainer*` roles from the accent colour
/// instead of the system's neutral palette. [QPSystemColorBuilder] passes the
/// palettes themselves through so [QPSystemColors] can resolve every role from
/// them.
///
/// [builder] is called with `null` until the platform answers, and stays `null`
/// on platforms that report no colours at all (Android below 12).
class QPSystemColorBuilder extends StatefulWidget {
  /// Creates a [QPSystemColorBuilder].
  const QPSystemColorBuilder({required this.builder, super.key});

  /// Builds the child widget with the colours the system reported.
  final Widget Function(QPSystemColors? systemColors) builder;

  @override
  State<QPSystemColorBuilder> createState() => _QPSystemColorBuilderState();
}

class _QPSystemColorBuilderState extends State<QPSystemColorBuilder> {
  QPSystemColors? _systemColors;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    // Android 12+: the full core palette.
    try {
      // ignore: deprecated_member_use
      final CorePalette? core = await DynamicColorPlugin.getCorePalette();
      if (!mounted) {
        return;
      }
      if (core != null) {
        setState(() {
          _systemColors = QPSystemColors.fromCorePalette(core);
        });
        return;
      }
    } on PlatformException catch (e) {
      QPAppLogger.warning(
        'Failed to obtain the system core palette',
        tag: 'QPSystemColorBuilder',
        error: e,
      );
    }

    // macOS, Windows, Linux: a single accent colour.
    try {
      final Color? accent = await DynamicColorPlugin.getAccentColor();
      if (!mounted) {
        return;
      }
      if (accent != null) {
        setState(() {
          _systemColors = QPSystemColors.fromAccent(accent);
        });
        return;
      }
    } on PlatformException catch (e) {
      QPAppLogger.warning(
        'Failed to obtain the system accent colour',
        tag: 'QPSystemColorBuilder',
        error: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(_systemColors);
}
