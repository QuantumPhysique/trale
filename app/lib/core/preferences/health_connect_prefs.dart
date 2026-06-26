part of '../preferences.dart';

/// Extension grouping health connect settings on [Preferences].
extension HealthConnectPrefsExtension on Preferences {
  /// get healthConnectEnabled
  bool get healthConnectEnabled =>
      prefs.getBool('healthConnectEnabled') ?? false;

  /// set healthConnectEnabled
  set healthConnectEnabled(bool enabled) =>
      prefs.setBool('healthConnectEnabled', enabled);

  /// get healthConnectImportEnabled
  bool get healthConnectImportEnabled =>
      prefs.getBool('healthConnectImportEnabled') ?? false;

  /// set healthConnectImportEnabled
  set healthConnectImportEnabled(bool enabled) =>
      prefs.setBool('healthConnectImportEnabled', enabled);

  /// get healthConnectExportEnabled
  bool get healthConnectExportEnabled =>
      prefs.getBool('healthConnectExportEnabled') ?? false;

  /// set healthConnectExportEnabled
  set healthConnectExportEnabled(bool enabled) =>
      prefs.setBool('healthConnectExportEnabled', enabled);
}
