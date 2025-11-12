# app

Trale - an android app to track your weight.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Material 3 Expressive Color System

Trale now supports the Material 3 Expressive color system. The `TraleTheme` class provides access to the following color roles:

### Fixed Colors
These colors remain consistent across light and dark themes:
- `primaryFixed`, `secondaryFixed`, `tertiaryFixed`
- `primaryFixedDim`, `secondaryFixedDim`, `tertiaryFixedDim`
- `onPrimaryFixed`, `onSecondaryFixed`, `onTertiaryFixed`
- `onPrimaryFixedVariant`, `onSecondaryFixedVariant`, `onTertiaryFixedVariant`

### Usage Example
```dart
Container(
  color: TraleTheme.of(context)!.primaryFixed,
  child: Text(
    'Fixed color text',
    style: TextStyle(color: TraleTheme.of(context)!.onPrimaryFixed),
  ),
)
```

For more information about Material 3 color roles, see: https://m3.material.io/styles/color/roles

## Developing

### Get untranslated strings
```
flutter gen-l10n
```

### Get unused translations
```
# print which will be deleted
dart run translations_cleaner list-unused-terms
# delete strings
dart run translations_cleaner clean-translations
```

### Regenerate Hive Classes
```bash
flutter packages pub run build_runner build
```

### Run Dart Code Metric
```bash
dart run dart_code_metrics:metrics analyze lib
dart run dart_code_metrics:metrics check-unused-files lib
dart run dart_code_metrics:metrics check-unused-l10n lib
dart run dart_code_metrics:metrics check-unused-code lib
```

### Generate APKS
```bash
traleVersion="0.11.1"
bundletool build-apks --bundle trale-${traleVersion}.aab --output trale-${traleVersion}.apks --ks ~/path/to/key.jks --ks-key-alias=key
```
