import 'package:trale/core/health_connect_service.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

/// Message describing the outcome of a Health Connect import.
///
/// Import used to report a bare count, so every failure — Health Connect
/// missing, permission withheld, read throwing — read as "Imported 0
/// measurements." and left nothing to act on.
String healthConnectImportMessage(
  AppLocalizations l10n,
  HealthConnectImportResult result,
) {
  switch (result.status) {
    case HealthConnectImportStatus.busy:
      return l10n.healthConnectBusy;
    case HealthConnectImportStatus.unavailable:
      return l10n.healthConnectNotAvailable;
    case HealthConnectImportStatus.missingPermission:
      return l10n.healthConnectImportPermissionRequired;
    case HealthConnectImportStatus.failed:
      return l10n.healthConnectImportError;
    case HealthConnectImportStatus.success:
      final String message = result.count == 0
          ? l10n.healthConnectImportNothingFound
          : l10n.healthConnectImportSuccess(count: result.count);
      if (!result.historyLimited) {
        return message;
      }
      return l10n.healthConnectHistoryLimited(result: message);
  }
}

/// Message describing the outcome of a Health Connect sync.
///
/// A failed import is worth more than the counts, so it wins over the
/// combined success message.
String healthConnectSyncMessage(
  AppLocalizations l10n,
  HealthConnectSyncResult result,
) {
  final HealthConnectImportResult importResult = result.importResult;
  if (importResult.status != HealthConnectImportStatus.success) {
    return healthConnectImportMessage(l10n, importResult);
  }
  return l10n.healthConnectSyncSuccess(
    importCount: importResult.count,
    exportCount: result.exported,
  );
}
