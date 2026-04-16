import 'package:flutter/widgets.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

export 'package:trale/l10n-gen/app_localizations.dart';

/// Convenience extension on [BuildContext] for accessing [AppLocalizations].
///
/// Use `context.l10n.someKey` instead of `AppLocalizations.of(context)!.someKey`.
extension AppLocalizationsX on BuildContext {
  /// Returns the [AppLocalizations] instance for this [BuildContext].
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
