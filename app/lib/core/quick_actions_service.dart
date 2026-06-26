import 'package:quick_actions/quick_actions.dart';

/// Shortcut type identifier for the "add weight" home-screen app shortcut.
const String addWeightShortcutType = 'action_add_weight';

/// Manages Android home-screen app shortcuts (long-press on the launcher icon).
///
/// Bridges the native shortcut callback to the Flutter UI: when the app is
/// cold-started via a shortcut it stores a pending request that the home page
/// consumes once it is ready; when the app is already running it forwards the
/// tap to a registered live [handler].
class QuickActionsService {
  /// Returns the singleton instance.
  factory QuickActionsService() => _instance;
  QuickActionsService._();
  static final QuickActionsService _instance = QuickActionsService._();

  final QuickActions _quickActions = const QuickActions();

  /// Whether an "add weight" shortcut was triggered but not yet handled.
  bool pendingAddWeight = false;

  /// Live handler invoked when a shortcut is tapped while the app is running.
  void Function()? _handler;

  /// Initialise the platform channel and register the shortcut callback.
  ///
  /// Call once during app start-up. On cold start the callback fires before
  /// any UI exists, so the request is stored in [pendingAddWeight].
  void init() {
    _quickActions.initialize((String type) {
      if (type != addWeightShortcutType) {
        return;
      }
      final void Function()? handler = _handler;
      if (handler != null) {
        handler();
      } else {
        pendingAddWeight = true;
      }
    });
  }

  /// Register the home-screen shortcut items.
  ///
  /// Call from a context where a localized [title] is available so the entry
  /// in the launcher menu is translated.
  Future<void> setShortcuts({required String title}) async {
    await _quickActions.setShortcutItems(<ShortcutItem>[
      ShortcutItem(
        type: addWeightShortcutType,
        localizedTitle: title,
        icon: 'ic_shortcut_add',
      ),
    ]);
  }

  /// Register a live [handler] for shortcut taps and flush any pending request.
  void registerHandler(void Function() handler) {
    _handler = handler;
    if (pendingAddWeight) {
      pendingAddWeight = false;
      handler();
    }
  }

  /// Remove the live handler, e.g. when the consuming widget is disposed.
  void unregisterHandler() {
    _handler = null;
  }
}
