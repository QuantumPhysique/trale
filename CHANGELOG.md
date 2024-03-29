# Changelog

All notable changes to this project will be documented in this file.

The format is inspired by [Keep aChangelog](https://keepachangelog.com/en/1.0.0/), and
[Element](https://github.com/vector-im/element-android) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

[//]: # (Available sections in changelog)
[//]: # (### API changes warning ⚠️:)
[//]: # (### Added Features and Improvements 🙌:)
[//]: # (### Bugfix 🐛:)
[//]: # (### Other changes:)


## [Unreleased]
### Other changes:
- Add backup reminder, see settings for more options


## [0.6.1] - 2024-03-21
### Added Features and Improvements 🙌:
- All new and improved interpolation API, the predictions are now more reliable
- Using the latest flutter 3.19 with upgraded deps
- Compile against Android 14 (SDK34)
- Hello World! Thx to the community, the app is now available in Lithuanian, Chinese and Spanish 🎉

### Bugfix 🐛:
- Fix bug, when reloading theme
- Fix bug that the interpolation was not shown for disabled smoothing, #25

### Other changes:
- Disabling interpolation, will now use sigma=2days for extrapolation prediction
- Removed v0.6.0 due to critical bug when user targe weight was set.


## [0.5.0] - 2024-01-25
### Added Features and Improvements 🙌:
- Hello World! Thx to the community, the app is now available in Czech, Korean, Norwegian, and Polish 🎉
- Improved readme, screenshots, and app description (fastlane)


## [0.4.7] - 2024-01-18
### Added Features and Improvements 🙌:
- Accelerated import

### Bugfix 🐛:
- Fix bug, that allowed target weights below 50kg


## [0.4.6] - 2024-01-08
### Bugfix 🐛:
- Fix bug, when using lb and st units

### Other changes:
- Fix version error in 0.4.5
- Fix f-droid metadata


## [0.4.6] - 2024-01-08
### Bugfix 🐛:
- Fix bug, when using lb and st units

### Other changes:
- Fix version error in 0.4.5
- Fix f-droid metadata


## [0.4.4] - 2023-12-20
### Bugfix 🐛:
- Fix bug, which prevented loading the app without measurements

### Other changes:
- Upgrade dependencies


## [0.4.3] - 2023-11-26
### Added Features and Improvements 🙌:
- Using the latest flutter 3.16 with upgraded deps

### Other changes:
- Prepare for predictive back gesture
- Removed splash animation to fix adding to f-droid, see #1
- Fixed list of used dependencies in about screen


## [0.4.2] - 2023-11-14
### Other changes:
- Remove build-id from rive to enable reproducible builds


## [0.4.1] - 2023-10-30
### Other changes:
- Upgrade dependencies
- Setup Proguard optimization


## [0.4.0] - 2023-10-25
### API changes warning ⚠️:
- App id changed to `de.quantumphysique.trale`, upgrading is not possible!

### Added Features and Improvements 🙌:
- Prepare F-Droid launch

### Other changes:
- Add github actions
- Upgrade dependencies
- Minor UI improvements

### Bugfix 🐛:
- Fix missing permission to open links
- Fixed overlapping monthly ticks and added years


## [0.3.1] - 2023-09-08
### Added Features and Improvements 🙌:
- Add basic animation

### Bugfix 🐛:
- Overview screen now updates upon adding first measurement


## [0.3.0] - 2023-09-05
### Added Features and Improvements 🙌:
- Add support for themed app icon (android 13)
- Using latest flutter 3.13 version with improved Material You theme
- Update measurement list
- Add import and export feature

### Bugfix 🐛:
- Fix broken theme selection


## [0.2.2] - 2022-10-18
### Added Features and Improvements 🙌:
- All new measurment screen including now achievemts

### Bugfix 🐛:
- Show current slope on start screen widget instead of 30 days average

### Other changes:
- Added linear regression for history prediction


## [0.2.1] - 2022-07-09
### Added Features and Improvements 🙌:
- Added nice splash screen
- Adjust icon in drawer to theme and add slogan
- New and fresher app icon

### Bugfix 🐛:
- Fix showing date labels for ranges larger than 7 months

### Other changes:
- Improve text on onboarding screen
- Add German meta data
- Remove unused files


## [0.2.0] - 2022-06-09
### Added Features and Improvements 🙌:
- Completely rewritten UI based on Material Design 3 and Flutter 3
- Improved prediction based on weighted linear regression
- Many new themes, improved zoom levels, many fixed bugs and so much more.

### Other changes:
- Added fastelone to publish app


## [0.1.0] - 2022-03-01
- initial release


[Unreleased]: https://github.com/quantumphysique/trale/compare/v0.6.1...main
[0.6.1]: https://github.com/quantumphysique/trale/compare/v0.5.0...v0.6.1
[0.5.0]: https://github.com/quantumphysique/trale/compare/v0.4.7...v0.5.0
[0.4.7]: https://github.com/quantumphysique/trale/compare/v0.4.6...v0.4.7
[0.4.6]: https://github.com/quantumphysique/trale/compare/v0.4.4...v0.4.6
[0.4.4]: https://github.com/quantumphysique/trale/compare/v0.4.3...v0.4.4
[0.4.3]: https://github.com/quantumphysique/trale/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/quantumphysique/trale/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/quantumphysique/trale/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/quantumphysique/trale/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/quantumphysique/trale/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/quantumphysique/trale/compare/v0.2.2...v0.3.0
[0.2.2]: https://github.com/quantumphysique/trale/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/quantumphysique/trale/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/quantumphysique/trale/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/quantumphysique/trale/-/tree/v0.1.0
