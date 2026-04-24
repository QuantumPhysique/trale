import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/src/app/qp_notification_service.dart';
import 'package:quantumphysique/src/notifier/qp_notifier.dart';
import 'package:quantumphysique/src/preferences/qp_preferences.dart';
import 'package:quantumphysique/src/types/first_day_localizations_delegate.dart';
import 'package:quantumphysique/src/types/logger.dart';
import 'package:quantumphysique/src/types/strings.dart';

/// Root widget for a quantumphysique-based application.
///
/// [QPApp] handles the async initialisation sequence (preferences, optional
/// notifications, build-number changelog check) and then renders a
/// [MaterialApp] driven by [QPNotifier].
///
/// Type parameter [N] must be a concrete [QPNotifier] subclass.
class QPApp<N extends QPNotifier> extends StatefulWidget {
  /// Creates a [QPApp].
  const QPApp({
    required this.notifier,
    required this.buildRoutes,
    required this.buildStrings,
    required this.localizationsDelegates,
    required this.supportedLocales,
    this.notificationService,
    this.onExtraInit,
    this.onGenerateTitle,
    this.initialRoute = '/',
    this.onboardingBuilder,
    super.key,
  });

  /// The app's [QPNotifier] instance.
  final N notifier;

  /// Builds the named-route map for [MaterialApp].
  final Map<String, WidgetBuilder> Function() buildRoutes;

  /// Builds the [QPStrings] for the current locale.
  ///
  /// Called lazily on the first build after the locale is established.
  final QPStrings Function(BuildContext) buildStrings;

  /// Localisation delegates forwarded to [MaterialApp].
  ///
  /// [QPFirstDayLocalizationsDelegate] is injected automatically.
  final Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates;

  /// Supported locales forwarded to [MaterialApp].
  final Iterable<Locale> supportedLocales;

  /// Optional notification service. When provided, [init] is called during
  /// startup.
  final QPNotificationService? notificationService;

  /// Optional async hook called after preferences and notifications are ready,
  /// before the app is shown (e.g. Hive initialisation).
  final Future<void> Function()? onExtraInit;

  /// Forwarded to [MaterialApp.onGenerateTitle].
  final String Function(BuildContext)? onGenerateTitle;

  /// Initial route for [MaterialApp].
  final String initialRoute;

  /// Optional builder for the onboarding screen.
  ///
  /// When provided and [QPPreferences.showOnBoarding] is `true`, QPApp
  /// overrides the initial route with the widget returned by this builder.
  /// The host app is responsible for setting [QPPreferences.showOnBoarding]
  /// to `false` when the user finishes onboarding.
  final WidgetBuilder? onboardingBuilder;

  @override
  State<QPApp<N>> createState() => _QPAppState<N>();
}

class _QPAppState<N extends QPNotifier> extends State<QPApp<N>> {
  bool _ready = false;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 1. Wait for preferences.
    await widget.notifier.prefs.loaded;

    // 2. Check whether onboarding should be shown.
    if (widget.onboardingBuilder != null) {
      _showOnboarding = widget.notifier.prefs.showOnBoarding;
    }

    // 3. Initialise notifications if requested.
    if (widget.notificationService != null) {
      try {
        await widget.notificationService!.init();
      } catch (e) {
        QPAppLogger.error(
          'QPNotificationService init failed',
          tag: 'QPApp',
          error: e,
        );
      }
    }

    // 3. App-specific extra initialisation (e.g. Hive).
    await widget.onExtraInit?.call();

    // 4. Build-number check — show changelog on first run after update.
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      final int? buildNumber = int.tryParse(info.buildNumber);
      if (buildNumber == null) {
        QPAppLogger.warning(
          'Failed to parse build number: ${info.buildNumber}',
          tag: 'QPApp',
        );
      } else if (buildNumber > widget.notifier.lastBuildNumber) {
        widget.notifier.showChangelog = true;
        widget.notifier.lastBuildNumber = buildNumber;
      }
    } catch (e) {
      QPAppLogger.warning(
        'Could not read package info',
        tag: 'QPApp',
        error: e,
      );
    }

    if (mounted) {
      setState(() => _ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox.shrink();
    }

    // Expose the notifier as both the concrete subtype N and as QPNotifier so
    // that QP pages (which use Provider.of<QPNotifier>) work out-of-the-box
    // when an app uses a QPNotifier subclass.  Both providers point to the
    // same object so state is always consistent.
    return MultiProvider(
      providers: <ChangeNotifierProvider<ChangeNotifier>>[
        ChangeNotifierProvider<N>.value(value: widget.notifier),
        ChangeNotifierProvider<QPNotifier>.value(value: widget.notifier),
      ],
      child: Consumer<N>(
        builder: (BuildContext ctx, N notifier, _) {
          return DynamicColorBuilder(
            builder: (ColorScheme? light, ColorScheme? dark) {
              notifier.setColorScheme(light, dark);
              final Map<String, WidgetBuilder> routes = widget.buildRoutes();
              if (_showOnboarding) {
                routes[widget.initialRoute] = widget.onboardingBuilder!;
              }
              return MaterialApp(
                theme: notifier.lightTheme,
                darkTheme: notifier.darkTheme,
                themeMode: notifier.themeMode,
                locale: notifier.locale,
                localizationsDelegates: <LocalizationsDelegate<dynamic>>[
                  ...widget.localizationsDelegates,
                  QPFirstDayLocalizationsDelegate(firstDay: notifier.firstDay),
                ],
                supportedLocales: widget.supportedLocales,
                routes: routes,
                initialRoute: widget.initialRoute,
                onGenerateTitle: widget.onGenerateTitle,
              );
            },
          );
        },
      ),
    );
  }
}
