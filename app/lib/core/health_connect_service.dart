import 'dart:io';

import 'package:health/health.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/preferences.dart';

/// Why a Health Connect import ended the way it did.
///
/// Every failure mode used to surface as `0`, which left "Imported 0
/// measurements." meaning anything from "Health Connect holds no weight
/// records" to "the read threw".
enum HealthConnectImportStatus {
  /// The read went through. The count may still be zero.
  success,

  /// Another import or export was still running, so this run did nothing.
  busy,

  /// Health Connect is not installed or not supported on this device.
  unavailable,

  /// Read permission for weight is missing.
  missingPermission,

  /// The read failed. The exception is in the log.
  failed,
}

/// Outcome of importing weight measurements from Health Connect.
class HealthConnectImportResult {
  /// Constructor.
  const HealthConnectImportResult(
    this.status, {
    this.count = 0,
    this.historyLimited = false,
  });

  /// Why the import ended the way it did.
  final HealthConnectImportStatus status;

  /// Number of measurements added to the local database.
  final int count;

  /// Whether Health Connect withheld everything older than 30 days.
  ///
  /// Health Connect only discloses the 30 days before the read permission was
  /// granted unless the app also holds `READ_HEALTH_DATA_HISTORY`, so a full
  /// history import without it silently comes back capped.
  final bool historyLimited;
}

/// Outcome of a bidirectional Health Connect sync.
class HealthConnectSyncResult {
  /// Constructor.
  const HealthConnectSyncResult({
    required this.importResult,
    required this.exported,
  });

  /// Outcome of the import half of the sync.
  final HealthConnectImportResult importResult;

  /// Number of measurements written to Health Connect.
  final int exported;
}

/// Service that coordinates Google Health Connect reads and writes.
class HealthConnectService {
  /// Singleton constructor.
  factory HealthConnectService() => _instance;
  HealthConnectService._internal();
  static final HealthConnectService _instance =
      HealthConnectService._internal();

  final Health _health = Health();

  /// Whether the service has been initialized.
  bool _initialized = false;

  /// Track if a sync operation is in progress to prevent concurrent operations.
  bool _syncing = false;

  /// Initialize the service.
  Future<void> init() async {
    if (_initialized) {
      return;
    }
    await _health.configure();
    _initialized = true;
  }

  /// Check if Health Connect is available on the device.
  Future<bool> isAvailable() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      return await _health.isHealthConnectAvailable();
    } catch (e) {
      QPAppLogger.error(
        'Failed to check Health Connect availability',
        tag: 'HealthConnectService',
        error: e,
      );
      return false;
    }
  }

  /// Check if active read/write permissions for weight are granted.
  Future<bool> hasPermissions({required bool read, required bool write}) async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final List<HealthDataType> types = <HealthDataType>[
        HealthDataType.WEIGHT,
      ];
      final List<HealthDataAccess> permissions = <HealthDataAccess>[
        if (read && write)
          HealthDataAccess.READ_WRITE
        else if (read)
          HealthDataAccess.READ
        else if (write)
          HealthDataAccess.WRITE,
      ];
      final bool? has = await _health.hasPermissions(
        types,
        permissions: permissions,
      );
      return has ?? false;
    } catch (e) {
      QPAppLogger.error(
        'Failed to check Health Connect permissions',
        tag: 'HealthConnectService',
        error: e,
      );
      return false;
    }
  }

  /// Request read/write permissions for weight.
  Future<bool> requestPermissions({
    required bool read,
    required bool write,
  }) async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final List<HealthDataType> types = <HealthDataType>[
        HealthDataType.WEIGHT,
      ];
      final List<HealthDataAccess> permissions = <HealthDataAccess>[
        if (read && write)
          HealthDataAccess.READ_WRITE
        else if (read)
          HealthDataAccess.READ
        else if (write)
          HealthDataAccess.WRITE,
      ];
      return await _health.requestAuthorization(
        types,
        permissions: permissions,
      );
    } catch (e) {
      QPAppLogger.error(
        'Failed to request Health Connect permissions',
        tag: 'HealthConnectService',
        error: e,
      );
      return false;
    }
  }

  /// Revoke all Health Connect permissions.
  Future<void> revokePermissions() async {
    if (!Platform.isAndroid) {
      return;
    }
    try {
      await _health.revokePermissions();
    } catch (e) {
      QPAppLogger.error(
        'Failed to revoke Health Connect permissions',
        tag: 'HealthConnectService',
        error: e,
      );
    }
  }

  /// Whether this device can grant access to data older than 30 days.
  Future<bool> isHistoryAccessAvailable() async {
    if (!Platform.isAndroid) {
      return false;
    }
    return _health.isHealthDataHistoryAvailable();
  }

  /// Whether access to data older than 30 days has been granted.
  Future<bool> hasHistoryAccess() async {
    if (!Platform.isAndroid) {
      return false;
    }
    return _health.isHealthDataHistoryAuthorized();
  }

  /// Request access to data older than 30 days.
  ///
  /// Shows the Health Connect permission dialog.
  Future<bool> requestHistoryAccess() async {
    if (!Platform.isAndroid) {
      return false;
    }
    return _health.requestHealthDataHistoryAuthorization();
  }

  /// Whether Health Connect will disclose data older than 30 days.
  ///
  /// Asks for the permission when [request] is true and it has not been
  /// granted yet.
  Future<bool> _ensureHistoryAccess({required bool request}) async {
    if (!await isHistoryAccessAvailable()) {
      return false;
    }
    if (await hasHistoryAccess()) {
      return true;
    }
    return request && await requestHistoryAccess();
  }

  /// Import weight measurements from Health Connect.
  /// Discards records generated by Trale unless [ignoreOwnOrigin] is true.
  /// Prevents local duplicate entries.
  /// If [days] is null, fetches the full available history, which Health
  /// Connect only hands over once the history permission is granted — asked
  /// for when [requestHistory] is true.
  Future<HealthConnectImportResult> importMeasurements({
    int? days,
    bool ignoreOwnOrigin = false,
    bool requestHistory = false,
  }) async {
    if (_syncing) {
      return const HealthConnectImportResult(HealthConnectImportStatus.busy);
    }
    _syncing = true;
    try {
      return await _importMeasurements(
        days: days,
        ignoreOwnOrigin: ignoreOwnOrigin,
        requestHistory: requestHistory,
      );
    } finally {
      _syncing = false;
    }
  }

  Future<HealthConnectImportResult> _importMeasurements({
    int? days,
    bool ignoreOwnOrigin = false,
    bool requestHistory = false,
  }) async {
    if (!Platform.isAndroid) {
      return const HealthConnectImportResult(
        HealthConnectImportStatus.unavailable,
      );
    }
    try {
      final bool available = await isAvailable();
      if (!available) {
        return const HealthConnectImportResult(
          HealthConnectImportStatus.unavailable,
        );
      }

      final bool hasRead = await hasPermissions(read: true, write: false);
      if (!hasRead) {
        QPAppLogger.warning(
          'No read permissions for Health Connect',
          tag: 'HealthConnectService',
        );
        return const HealthConnectImportResult(
          HealthConnectImportStatus.missingPermission,
        );
      }

      // Health Connect caps every read at the 30 days before the read
      // permission was granted, so a full history read that is not backed by
      // the history permission comes back silently truncated.
      bool historyLimited = false;
      if (days == null) {
        historyLimited = !await _ensureHistoryAccess(request: requestHistory);
      }

      final DateTime now = DateTime.now();
      final DateTime startTime = days != null
          ? now.subtract(Duration(days: days))
          : DateTime.fromMillisecondsSinceEpoch(0);

      final List<HealthDataPoint> dataPoints = await _health
          .getHealthDataFromTypes(
            types: <HealthDataType>[HealthDataType.WEIGHT],
            startTime: startTime,
            endTime: now,
          );

      final List<Measurement> newMeasurements = <Measurement>[];
      for (final HealthDataPoint point in dataPoints) {
        // Discard entries where package origin is de.quantumphysique.trale
        // to prevent duplicate import of exported measurements.
        if (!ignoreOwnOrigin &&
            point.sourcePlatform == HealthPlatformType.googleHealthConnect &&
            (point.sourceId == 'de.quantumphysique.trale' ||
                point.sourceName == 'de.quantumphysique.trale')) {
          continue;
        }

        double? weightInKg;
        final dynamic val = point.value;
        if (val is NumericHealthValue) {
          weightInKg = val.numericValue.toDouble();
        } else if (val is num) {
          weightInKg = val.toDouble();
        } else if (val != null) {
          weightInKg = double.tryParse(val.toString());
        }

        if (weightInKg == null || weightInKg <= 0 || !weightInKg.isFinite) {
          continue;
        }

        final DateTime date = point.dateFrom;
        final Measurement m = Measurement(
          weight: weightInKg,
          date: date,
          isMeasured: true,
        );
        newMeasurements.add(m);
      }

      final int count = newMeasurements.isEmpty
          ? 0
          : await MeasurementDatabase().insertMeasurementList(newMeasurements);
      return HealthConnectImportResult(
        HealthConnectImportStatus.success,
        count: count,
        historyLimited: historyLimited,
      );
    } catch (e) {
      QPAppLogger.error(
        'Failed to import measurements from Health Connect',
        tag: 'HealthConnectService',
        error: e,
      );
      return const HealthConnectImportResult(HealthConnectImportStatus.failed);
    }
  }

  /// Export a single measurement to Health Connect.
  Future<bool> exportMeasurement(Measurement m) async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final bool available = await isAvailable();
      if (!available) {
        return false;
      }

      final bool hasWrite = await hasPermissions(read: false, write: true);
      if (!hasWrite) {
        QPAppLogger.warning(
          'No write permissions for Health Connect',
          tag: 'HealthConnectService',
        );
        return false;
      }

      final DateTime date = m.date;
      return await _health.writeHealthData(
        value: m.weight,
        type: HealthDataType.WEIGHT,
        startTime: date,
        endTime: date,
      );
    } catch (e) {
      QPAppLogger.error(
        'Failed to export measurement to Health Connect',
        tag: 'HealthConnectService',
        error: e,
      );
      return false;
    }
  }

  /// Export all local Trale weight records to Health Connect.
  Future<int> exportAllMeasurements() async {
    if (_syncing) {
      return 0;
    }
    _syncing = true;
    try {
      return await _exportAllMeasurements();
    } finally {
      _syncing = false;
    }
  }

  Future<int> _exportAllMeasurements() async {
    if (!Platform.isAndroid) {
      return 0;
    }
    try {
      final bool available = await isAvailable();
      if (!available) {
        return 0;
      }

      final bool hasWrite = await hasPermissions(read: false, write: true);
      if (!hasWrite) {
        QPAppLogger.warning(
          'No write permissions for Health Connect',
          tag: 'HealthConnectService',
        );
        return 0;
      }

      final List<Measurement> all = MeasurementDatabase().measurements;
      int successCount = 0;
      for (final Measurement m in all) {
        final bool success = await exportMeasurement(m);
        if (success) {
          successCount++;
        }
      }
      return successCount;
    } catch (e) {
      QPAppLogger.error(
        'Failed to export all measurements to Health Connect',
        tag: 'HealthConnectService',
        error: e,
      );
      return 0;
    }
  }

  /// Perform a bidirectional sync of recent data (last 30 days).
  /// Imports external logs and exports local unsynced logs.
  Future<HealthConnectSyncResult> sync() async {
    if (_syncing) {
      return const HealthConnectSyncResult(
        importResult: HealthConnectImportResult(HealthConnectImportStatus.busy),
        exported: 0,
      );
    }
    _syncing = true;
    try {
      HealthConnectImportResult importResult = const HealthConnectImportResult(
        HealthConnectImportStatus.success,
      );
      int exported = 0;

      if (Preferences().healthConnectImportEnabled) {
        importResult = await _importMeasurements(days: 30);
      }
      if (Preferences().healthConnectExportEnabled) {
        exported = await _exportAllMeasurements();
      }

      return HealthConnectSyncResult(
        importResult: importResult,
        exported: exported,
      );
    } finally {
      _syncing = false;
    }
  }
}
