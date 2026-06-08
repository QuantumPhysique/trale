import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A generic splash screen for quantumphysique-based apps.
///
/// [QPSplash] runs an async [onInit] callback, colours the system navigation
/// bar to match the app's Material 3 surface, and then navigates to the
/// widget produced by [homeBuilder] once initialisation completes.
///
/// An optional [child] (e.g. a logo or animation) is displayed centred on the
/// splash surface. When omitted a [CircularProgressIndicator] is shown.
///
/// ```dart
/// // In main() / initial route:
/// QPSplash(
///   onInit: () async {
///     await MyDatabase().reinit();
///   },
///   homeBuilder: (_) => const Home(),
/// )
/// ```
class QPSplash extends StatefulWidget {
  /// Creates a [QPSplash].
  const QPSplash({
    required this.onInit,
    required this.homeBuilder,
    this.child,
    super.key,
  });

  /// Async work to perform while the splash is shown (e.g. database init,
  /// notification rescheduling).  The splash navigates to [homeBuilder] as
  /// soon as this future completes.
  final Future<void> Function() onInit;

  /// Builds the home widget that replaces the splash after [onInit] finishes.
  final WidgetBuilder homeBuilder;

  /// Widget displayed in the centre of the splash screen.
  ///
  /// Defaults to a [CircularProgressIndicator] when `null`.
  final Widget? child;

  @override
  State<QPSplash> createState() => _QPSplashState();
}

class _QPSplashState extends State<QPSplash> {
  late final Future<void> _init;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _init = widget.onInit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Colour the system navigation bar to match the Material 3 surface tint.
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: ElevationOverlay.colorWithOverlay(
          Theme.of(context).colorScheme.surface,
          Theme.of(context).colorScheme.primary,
          3.0,
        ),
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Theme.of(context).brightness,
      ),
    );

    if (!_navigated) {
      _navigated = true;
      _init.then((_) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop();
        Navigator.of(
          context,
        ).push(MaterialPageRoute<Widget>(builder: widget.homeBuilder));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: widget.child ?? const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
