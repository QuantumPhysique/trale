import 'package:flutter/foundation.dart';

/// Centralized logging utility for trale.
///
/// In debug builds, all levels are printed via [debugPrint].
/// Use [AppLogger.error] or [AppLogger.warning] for user-facing issues that
/// should also be visible in profile/release builds when diagnosing problems.
class AppLogger {
  AppLogger._();

  /// Log a debug-level message (debug builds only).
  static void debug(String message, {String? tag}) {
    assert(() {
      debugPrint(_format('DEBUG', tag, message));
      return true;
    }());
  }

  /// Log a warning. Printed in all build modes.
  static void warning(String message, {String? tag, Object? error}) {
    final String extra = error != null ? ': $error' : '';
    debugPrint(_format('WARNING', tag, '$message$extra'));
  }

  /// Log an error. Printed in all build modes.
  static void error(String message, {String? tag, Object? error}) {
    final String extra = error != null ? ': $error' : '';
    debugPrint(_format('ERROR', tag, '$message$extra'));
  }

  static String _format(String level, String? tag, String message) {
    final String prefix = tag != null ? '[$level/$tag]' : '[$level]';
    return '$prefix $message';
  }
}
