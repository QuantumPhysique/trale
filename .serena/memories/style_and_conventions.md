# Code Style and Conventions

## Language
- Dart with Flutter framework
- SDK version: >=3.9.0 <4.0.0
- Flutter version: >=3.38.5

## Linting Rules
Based on flutter_lints with additional rules:
- Always declare return types
- Strong mode with no implicit casts or dynamic
- Treat missing required params and returns as warnings
- Exclude generated i18n files from analysis

## Naming Conventions
- Follow standard Dart naming: camelCase for variables/methods, PascalCase for classes/types
- Use meaningful names, avoid abbreviations

## Code Organization
- Use provider for state management
- Localize strings using flutter_localizations
- Store data with Drift(SQLite)
- Follow Material Design 3 guidelines

## Best Practices
- Privacy-focused: No data collection, minimal permissions
- Use const constructors where possible
- Prefer immutable data structures
- Handle localization properly