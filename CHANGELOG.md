# Changelog

All notable changes to this project will be documented in this file.

The format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and
[Element](https://github.com/vector-im/element-android) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

[//]: # (Available sections in changelog)
[//]: # (### API Changes Warning ⚠️:)
[//]: # (### Added Features and Improvements 🙌:)
[//]: # (### Bugfix 🐛:)
[//]: # (### Other Changes:)
## [Unreleased]

## [1.0.0] - 2026-04-29

Dear Tralers,

the day has finally come: trale 1.0 is out now! We are super excited and hope you are, too!🎉

Seeing so many of you use Trale makes us incredibly happy, and knowing you're out there is what helped us stick to it. We want to thank every single user for being part of this journey.

We want to give a massive shout-out to our sponsors. Your financial support has been tremendous and is the main reason we were able to make so much progress over the last few months.

We also owe a huge thanks to every single contributor and anyone who ever submitted feedback. Every single commit, translation, bug report, and idea mattered.

Thanks so much, and we really hope you enjoy 1.0!

### Added Features and Improvements 🙌:
- A brand-new stats page with lots of new stats widgets
- Set a target date for your weight goal
- Reminder notifications for daily weight logging
- Major performance improvements throughout the app
- 0.05 kg/st/lb entry steps for finer control
- Height can now be entered in imperial units
- Preview the interpolation on your own data
- Changelog now viewable in the app
- Tooltip shown while scrolling the chart

### Other Changes:
- Shared app framework extracted into the 'quantumphysique' package
- Use the latest Flutter (3.41)

### Bugfix 🐛:
- Fixed a broken import when importing OpenScales CSV and made the import function more robust (#452, #455)
- Fixed broken calendar when choosing the 'Custom first day of week' option (#417, #418)
- Fix persisting pop-up when deleting measurements
- Fix for updating target weight in the user dialogue


## [0.15.1] - 2026-02-03

### Other Changes:
- Improved translation
- Remove white matte in app icon


## [0.15.0] - 2026-01-27

### Added Features and Improvements 🙌:
- New app icon 🐺
- All new F-droid store page with Material You Expressive (ready) Design 🎉

### Other Changes:
- Improved chart animation
- Improved translation

### Bugfix 🐛:
- Fix bug on negative time estimates when the slope is zero, #314
- Fix persisting Backup reminder, #394
- Fix Animation re-triggering when returning from settings to overview tab #402


## [0.14.0] - 2026-01-06

Welcome 2026! To help you shed those extra pounds gained over Christmas, we have completely revamped the app 🎆

This release is the foundation for the upcoming version 1.0. Now that the UI has been redesigned, we will focus again on new functionality in the next releases.

### Added Features and Improvements 🙌:
- Material You Expressive (ready) Design throughout the whole app 🎉
- Redesigned, more responsive weight picker
- Improved and all new Settings pages

### Other Changes:
- Using the latest flutter 3.38
- New font family: RobotoFlex
- All new animations to align with M3E design guidelines
- Remove outdated onboarding screen
- Upgrade dependencies and building envs

### Bugfix 🐛:
- Fix bug which prevents selecting zh-Hant variant
- Add hints to explain which imports are supported, #338 and #357


## [0.13.2] - 2025-09-14
### Other Changes:
- Added larger zoom levels for longtime users

### Bugfix 🐛:
- Fix several bugs of zoom buttons, #334 and #333
- Fix bug that scrollbar is not dragable
- Fix misaligned measurements when using am/pm format


## [0.13.1] - 2025-09-10
### Bugfix 🐛:
- Fix Fdroid build, #342


## [0.13.0] - 2025-09-07
### Added Features and Improvements 🙌:
- Added zoom buttons, identical to double-tap
- Added iso8601 date format, #325

### Other Changes:
- Target Android 16 (SDK 36)
- Using the latest flutter 3.35 with upgraded deps
- Improved translation

### Bugfix 🐛:
- Fix typo in about screen, #328


## [0.12.1] - 2025-08-13
### Bugfix 🐛:
- Fix Fdroid build, #312


## [0.12.0] - 2025-08-12
### Added Features and Improvements 🙌:
- 3 brand new color themes
- Trale offers now 7 color scheme variants. Check out the settings page 🎉

### Other Changes:
- Upgrade dependencies
- Upgrade building envs (Kotlin, Gradle, Android Application, and NDK)

### Bugfix 🐛:
- Fix `java heap space` error (CI) by increasing jvm memory
- Fix BMI widget for st and lbs, #301


## [0.11.2] - 2025-07-15
### Added Features and Improvements 🙌:
- Thx to the community, many translations have been improved 🎉
- Using the latest flutter 3.32 with upgraded deps
- Add a BMI widget, #239

### Other Changes:
- Improve change icon on measurement screen, #263
- Add a hint that the user's height is in centimeters

### Bugfix 🐛:
- Replace `auto_size_text` dependency to support latest flutter version


## [0.11.1] - 2025-05-10
### Added Features and Improvements 🙌:
- Thx to the community, many translations have been improved 🎉
- Improved material you design

### Other Changes:
- Using the latest flutter 3.29.3 with upgraded deps


## [0.11.0] - 2025-03-30
### Added Features and Improvements 🙌:
- ஹலோ வேர்ல்ட்! Thx to the community, the app is now available in Tamil 🎉
- Use predictive back gesture
- Incorporate user height to calculate BMI-based minimum target weight, replacing the predefined value.
- Added experimental high contrast mode

### Other Changes:
- Update translations
- Minor improvements

### Bugfix 🐛:
- Fix system color scheme for monochrome colors, #236
- Fix using wrong font color in some places
- Fix target label overlapping with line
- Fix returning achieving goal in 0 days


## [0.10.1] - 2025-03-03
### Bugfix 🐛:
- Fix wrongly assign button action in import screen


## [0.10.0] - 2025-03-04
### Added Features and Improvements 🙌:
- Hello World! Thx to the community, the app is now available in Russian and Vietnamese 🎉
- Reworked import/export: Allowing now to save to files and import from openScale and Withings

### Other Changes:
- Minor speed improvements

### Bugfix 🐛:
- Make label of gain weight mode more clear
- Fix label for Dutch language


## [0.9.3] - 2025-02-25
### Added Features and Improvements 🙌:
- Hello World! Thx to the community, the app is now available in Dutch 🎉

### Bugfix 🐛:
- Fixes a bug that caused the shared file to always be empty.


## [0.9.2] - 2025-02-15
### Added Features and Improvements 🙌:
- Hello World! Thx to the community, the app is now available in Bulgarian 🎉
- Using the latest flutter 3.29 with upgraded deps
- Added experimental mode to gain weight


## [0.9.1] - 2025-01-31
### Other Changes:
- Target SDK35 and use gradle 8.10
- Design improvements
- Thx to the community, added localizations for Italian, Estonian, and Chinese

### Bugfix 🐛:
- Removed target weight from the interpolation preview


## [0.9.0] - 2025-01-08
### Added Features and Improvements 🙌:
- Hello World! Thx to the community, the app is now available in Estonian and Slovenian 🎉
- Allow setting the first day of the week, thx to @olker159
- Using the latest flutter 3.27 with upgraded deps

### Other Changes:
- Improved and restructured settings page

### Bugfix 🐛:
- Fixed the estimation of the current/max streak, see #183


## [0.8.1] - 2024-11-14
### Bugfix 🐛:
- Remove DependencyInfoBlock


## [0.8.0] - 2024-11-10
### Added Features and Improvements 🙌:
- Extensively revised UI with lots of statistics to keep you engaged in achieving your dream weight 🎉

### Other Changes:
- Changed font and icons to improve overall accessibility
- Thx to the community, Spanish and French translation were improved
- Add backup reminder, see settings for more options
- Minor clean up of deprecated flutter code
- Upgraded deps

### Bugfix 🐛:
- Fixed a bug that caused a small icon to be displayed in the F-Droid store (German).


## [0.7.2] - 2024-09-22
### Added Features and Improvements 🙌:
- Hello World! Thx to the community, the app is now available in Croatian 🎉
- Using the latest flutter 3.24 with upgraded deps

### Bugfix 🐛:
- Fix showing ukraine as supported language


## [0.7.1] - 2024-07-03
### Added Features and Improvements 🙌:
- Hello World! Thx to the community, the app is now available in Turkish 🎉

### Other Changes:
- Upgraded dependencies
- Improve readability of target weight label

### Bugfix 🐛:
- Fix broken color of linechart
- Allow adding measurements older than 2 years
- Fix bug of showing target weight correctly using st/lb
- Fixed a bug where saving an unmodified measurement resulted in it being deleted


## [0.7.0] - 2024-05-29
### Added Features and Improvements 🙌:
- Hello World! Thx to the community, the app is now available in French, Finnish, and Italian 🎉
- Using the latest flutter 3.22 with upgraded deps

### Other Changes:
- Improved translations


## [0.6.2] - 2024-04-02
### Bugfix 🐛:
- Fix bug that prevents app to start, #70

## [0.6.1] - 2024-03-21
### Added Features and Improvements 🙌:
- All new and improved interpolation API, the predictions are now more reliable
- Using the latest flutter 3.19 with upgraded deps
- Compile against Android 14 (SDK34)
- Hello World! Thx to the community, the app is now available in Lithuanian, Chinese, and Spanish 🎉

### Bugfix 🐛:
- Fix bug, when reloading theme
- Fix bug that the interpolation was not shown for disabled smoothing, #25

### Other Changes:
- Disabling interpolation, will now use sigma=2days for extrapolation prediction
- Removed v0.6.0 due to critical bug when user target weight was set.


## [0.5.0] - 2024-01-25
### Added Features and Improvements 🙌:
- Hello World! Thx to the community, the app is now available in Czech, Korean, Norwegian, and Polish 🎉
- Improved readme, screenshots, and app description (fastlane)


## [0.4.7] - 2024-01-18
### Added Features and Improvements 🙌:
- Accelerated import

### Bugfix 🐛:
- Fix bug, that allowed target weights below 50 kg


## [0.4.6] - 2024-01-08
### Bugfix 🐛:
- Fix bug, when using lb and st units

### Other Changes:
- Fix version error in 0.4.5
- Fix f-droid metadata


## [0.4.6] - 2024-01-08
### Bugfix 🐛:
- Fix bug, when using lb and st units

### Other Changes:
- Fix version error in 0.4.5
- Fix f-droid metadata


## [0.4.4] - 2023-12-20
### Bugfix 🐛:
- Fix bug, which prevented loading the app without measurements

### Other Changes:
- Upgrade dependencies


## [0.4.3] - 2023-11-26
### Added Features and Improvements 🙌:
- Using the latest flutter 3.16 with upgraded deps

### Other Changes:
- Prepare for predictive back gesture
- Removed splash animation to fix adding to f-droid, see #1
- Fixed list of used dependencies in about screen


## [0.4.2] - 2023-11-14
### Other Changes:
- Remove build-id from rive to enable reproducible builds


## [0.4.1] - 2023-10-30
### Other Changes:
- Upgrade dependencies
- Setup Proguard optimization


## [0.4.0] - 2023-10-25
### API Changes Warning ⚠️:
- App id changed to `de.quantumphysique.trale`, upgrading is not possible!

### Added Features and Improvements 🙌:
- Prepare F-Droid launch

### Other Changes:
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
- Using the latest flutter 3.13 version with improved Material You theme
- Update measurement list
- Add import and export feature

### Bugfix 🐛:
- Fix broken theme selection


## [0.2.2] - 2022-10-18
### Added Features and Improvements 🙌:
- All new measurement screen including now achievements

### Bugfix 🐛:
- Show current slope on start screen widget instead of 30 days average

### Other Changes:
- Added linear regression for history prediction


## [0.2.1] - 2022-07-09
### Added Features and Improvements 🙌:
- Added nice splash screen
- Adjust icon in drawer to theme and add slogan
- New and fresher app icon

### Bugfix 🐛:
- Fix showing date labels for ranges larger than 7 months

### Other Changes:
- Improve text on onboarding screen
- Add German meta data
- Remove unused files


## [0.2.0] - 2022-06-09
### Added Features and Improvements 🙌:
- Completely rewritten UI based on Material Design 3 and Flutter 3
- Improved prediction based on weighted linear regression
- Many new themes, improved zoom levels, many fixed bugs and so much more.

### Other Changes:
- Added fastlane to publish app


## [0.1.0] - 2022-03-01
### Added Features and Improvements 🙌:
- initial release


[Unreleased]: https://github.com/quantumphysique/trale/compare/v1.0.0...main
[1.0.0]: https://github.com/quantumphysique/trale/compare/v0.15.1...v1.0.0
[0.15.1]: https://github.com/quantumphysique/trale/compare/v0.15.0...v0.15.1
[0.15.0]: https://github.com/quantumphysique/trale/compare/v0.14.0...v0.15.0
[0.14.0]: https://github.com/quantumphysique/trale/compare/v0.13.2...v0.14.0
[0.13.2]: https://github.com/quantumphysique/trale/compare/v0.13.1...v0.13.2
[0.13.1]: https://github.com/quantumphysique/trale/compare/v0.13.0...v0.13.1
[0.13.0]: https://github.com/quantumphysique/trale/compare/v0.12.1...v0.13.0
[0.12.1]: https://github.com/quantumphysique/trale/compare/v0.12.0...v0.12.1
[0.12.0]: https://github.com/quantumphysique/trale/compare/v0.11.2...v0.12.0
[0.11.2]: https://github.com/quantumphysique/trale/compare/v0.11.1...v0.11.2
[0.11.1]: https://github.com/quantumphysique/trale/compare/v0.11.0...v0.11.1
[0.11.0]: https://github.com/quantumphysique/trale/compare/v0.10.1...v0.11.0
[0.10.1]: https://github.com/quantumphysique/trale/compare/v0.10.0...v0.10.1
[0.10.0]: https://github.com/quantumphysique/trale/compare/v0.9.3...v0.10.0
[0.9.3]: https://github.com/quantumphysique/trale/compare/v0.9.2...v0.9.3
[0.9.2]: https://github.com/quantumphysique/trale/compare/v0.9.1...v0.9.2
[0.9.1]: https://github.com/quantumphysique/trale/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/quantumphysique/trale/compare/v0.8.1...v0.9.0
[0.8.1]: https://github.com/quantumphysique/trale/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/quantumphysique/trale/compare/v0.7.2...v0.8.0
[0.7.2]: https://github.com/quantumphysique/trale/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/quantumphysique/trale/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/quantumphysique/trale/compare/v0.6.2...v0.7.0
[0.6.2]: https://github.com/quantumphysique/trale/compare/v0.6.1...v0.6.2
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
