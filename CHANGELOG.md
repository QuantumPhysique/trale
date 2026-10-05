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

### Added Features and Improvements 🙌:
- New goal "Maintain weight": keep your weight within 1% of your target weight (#454)
- A new target weight now starts at your current weight
- The interpolation preview of your own data now uses the zoom of the main chart

### Bugfix 🐛:
- Fixed the chart not updating right away after changing the unit
- Fixed saving an unchanged target weight restarting the "since goal" statistics
- Fixed the empty target weight field asking for a target date

### Other Changes:
- The chart no longer shades the gap between your weight and your target weight
- The area below the trend line in the chart has a new colour
- Minor improvements to the code base


## [1.4.1] - 2026-09-14

That's one small step for mankind, one giant leap for trale: 200 stars on Github! Thx to all the great people supporting this app 🎉

### Bugfix 🐛:
- Fixed the reminder still firing when the weight was already logged that day
- Fixed dates showing a leading zero, e.g. "014/09", in French and Italian (#533)


## [1.4.0] - 2026-09-09

### Added Features and Improvements 🙌:
- Tapping a reminder opens the add weight dialog right away
- The "system" colour palette now uses the full Material You palette of Android

### Bugfix 🐛:
- Fixed the launch screen always being white instead of following dark mode (#507)
- Fixed the Health Connect import reaching back only 30 days (#508)
- Fixed the Health Connect import not saying why nothing was imported (#508)

### Other Changes:
- Improved the wording of the translation banner and the reminder settings


## [1.3.1] - 2026-08-31

### Added Features and Improvements 🙌:
- Use the latest Flutter (3.47) with upgraded deps

### Other Changes:
- Improved translation

### Bugfix 🐛:
- Fixed the language selection showing "error" instead of العربية for Arabic (#515)
- Fixed the height field in the personalization settings losing focus after every digit (#509)
- Fixed the done key of the keyboard doing nothing in the height field
- Fixed the user dialog overlapping when the keyboard opens (#509)


## [1.3.0] - 2026-08-26

### Added Features and Improvements 🙌:
- Reworked the measurement list: entries are now grouped by month and can be
  filtered by year and month (#460)
- Weight can now be typed on the keyboard: tap the value above the ruler in
  the add weight and target weight dialogs (#484)
- Added `-` and `+` buttons below the ruler to adjust the weight one step at
  a time

### Other Changes:
- Improved translation

### Bugfix 🐛:
- Fixed the export writing microseconds in the timestamp of the latest measurement (#489)
- Fixed reminders firing at the wrong hour


## [1.2.0] - 2026-07-01

### Added Features and Improvements 🙌:
- Added Health Connect integration to synchronize weight measurements on Android (#475)
- Added quick action to add a new weight even faster (#468)

### Other Changes:
- New Material Expressive look for button groups
- Improved translation


## [1.1.0] - 2026-06-14

### Added Features and Improvements 🙌:
- Përshëndetje botë! Thx to the community, the app is now available in Albanian 🎉
- Use the latest Flutter (3.44)

### Other Changes:
- Improved translation
- Minor improvements to the code base


## [1.0.3] - 2026-05-02

### Bugfix 🐛:
- Fixed the F-Droid release


## [1.0.0] - 2026-04-29

Dear Tralers🐺,

trale v1.0 is out now, and we couldn't be more excited!🎉

A huge thank you to every user, contributor, and translator: every commit, bug report, and idea mattered. A special shout-out to our Ko-fi sponsors: gh.com/lquenti, George, franciscoteca, ghStzyxh, Toasty2004, Peppin, Billy, and all anonymous donors. Knowing you're out there kept us motivated throughout the entire journey.

We can't wait to continue this journey with you.

### Added Features and Improvements 🙌:
- A brand-new stats page with lots of new stats widgets
- Set a target date for your weight goal (#189)
- Reminder notifications for daily weight logging
- Major performance improvements throughout the app
- 0.05 kg/st/lb entry steps for finer control
- Height can now be entered in imperial units (#326)
- Preview the interpolation on your own data
- Changelog now viewable in the app
- Tooltip shown while scrolling the chart
- Use the latest Flutter (3.41)

### Other Changes:
- Minor improvements to the code base

### Bugfix 🐛:
- Fixed importing OpenScale CSV files (#452, #455)
- Fixed the calendar with a custom first day of the week (#417, #418)
- Fixed a pop-up staying open after deleting measurements
- Fixed updating the target weight in the user dialog


## [0.15.1] - 2026-02-03

### Other Changes:
- Improved translation
- Removed the white matte from the app icon


## [0.15.0] - 2026-01-27

### Added Features and Improvements 🙌:
- New app icon 🐺
- All new F-Droid store page with Material You Expressive (ready) Design 🎉

### Other Changes:
- Improved chart animation
- Improved translation

### Bugfix 🐛:
- Fixed negative time estimates when the weight does not change (#314)
- Fixed the backup reminder not going away (#394)
- Fixed the animation re-triggering when returning from settings to the overview tab (#402)


## [0.14.0] - 2026-01-06

Welcome 2026! To help you shed those extra pounds gained over Christmas, we have completely revamped the app 🎆

This release is the foundation for the upcoming version 1.0. Now that the UI has been redesigned, we will focus again on new functionality in the next releases.

### Added Features and Improvements 🙌:
- Material You Expressive (ready) Design throughout the whole app 🎉
- Redesigned, more responsive weight picker
- Improved and all new Settings pages
- Use the latest Flutter (3.38) with upgraded deps

### Other Changes:
- New font
- All new animations
- Removed the outdated onboarding screen
- Minor improvements to the code base

### Bugfix 🐛:
- Fixed selecting the zh-Hant variant
- Fixed missing hints on which imports are supported (#338, #357)


## [0.13.2] - 2025-09-14
### Other Changes:
- Added larger zoom levels for longtime users

### Bugfix 🐛:
- Fixed several bugs of the zoom buttons (#333, #334)
- Fixed the scrollbar not being draggable
- Fixed misaligned measurements when using the am/pm format


## [0.13.1] - 2025-09-10
### Bugfix 🐛:
- Fixed the F-Droid release (#342)


## [0.13.0] - 2025-09-07
### Added Features and Improvements 🙌:
- Added zoom buttons, identical to double-tap
- Added iso8601 date format (#325)
- Target Android 16 (SDK 36)
- Use the latest Flutter (3.35) with upgraded deps

### Other Changes:
- Improved translation

### Bugfix 🐛:
- Fixed a typo in the about screen (#328)


## [0.12.1] - 2025-08-13
### Bugfix 🐛:
- Fixed the F-Droid release (#312)


## [0.12.0] - 2025-08-12
### Added Features and Improvements 🙌:
- 3 brand new color themes
- Trale offers now 7 color scheme variants. Check out the settings page 🎉

### Other Changes:
- Upgraded deps
- Minor improvements to the code base

### Bugfix 🐛:
- Fixed the BMI widget for st and lb (#301)


## [0.11.2] - 2025-07-15
### Added Features and Improvements 🙌:
- Added a BMI widget (#239)
- Use the latest Flutter (3.32) with upgraded deps

### Other Changes:
- Improved translation
- Improved the change icon on the measurement screen (#263)
- Added a hint that the user's height is in centimeters


## [0.11.1] - 2025-05-10
### Added Features and Improvements 🙌:
- Improved Material You design
- Use the latest Flutter (3.29.3) with upgraded deps

### Other Changes:
- Improved translation


## [0.11.0] - 2025-03-30
### Added Features and Improvements 🙌:
- ஹலோ வேர்ல்ட்! Thx to the community, the app is now available in Tamil 🎉
- Use predictive back gesture
- The minimum target weight now follows your height (BMI) instead of a fixed value
- Added experimental high contrast mode

### Other Changes:
- Improved translation
- Minor improvements to the code base

### Bugfix 🐛:
- Fixed the system color scheme for monochrome colors (#236)
- Fixed a wrong font color in some places
- Fixed the target label overlapping with the line
- Fixed reaching the goal being estimated as 0 days


## [0.10.1] - 2025-03-03
### Bugfix 🐛:
- Fixed a wrongly assigned button in the import screen


## [0.10.0] - 2025-03-04
### Added Features and Improvements 🙌:
- Hello World! Thx to the community, the app is now available in Russian and Vietnamese 🎉
- Reworked import/export: Allowing now to save to files and import from openScale and Withings

### Other Changes:
- Minor speed improvements

### Bugfix 🐛:
- Fixed the unclear label of the gain weight mode
- Fixed the label of the Dutch language


## [0.9.3] - 2025-02-25
### Added Features and Improvements 🙌:
- Hallo wereld! Thx to the community, the app is now available in Dutch 🎉

### Bugfix 🐛:
- Fixed the shared file always being empty


## [0.9.2] - 2025-02-15
### Added Features and Improvements 🙌:
- Здравей, свят! Thx to the community, the app is now available in Bulgarian 🎉
- Use the latest Flutter (3.29) with upgraded deps
- Added experimental mode to gain weight


## [0.9.1] - 2025-01-31
### Added Features and Improvements 🙌:
- Target Android 15 (SDK 35)

### Other Changes:
- Design improvements
- Improved translation
- Minor improvements to the code base

### Bugfix 🐛:
- Fixed the target weight showing in the interpolation preview


## [0.9.0] - 2025-01-08
### Added Features and Improvements 🙌:
- Hello World! Thx to the community, the app is now available in Estonian and Slovenian 🎉
- Allow setting the first day of the week, thx to @olker159
- Use the latest Flutter (3.27) with upgraded deps

### Other Changes:
- Improved and restructured settings page

### Bugfix 🐛:
- Fixed the estimate of the current and max streak (#183)


## [0.8.1] - 2024-11-14
### Bugfix 🐛:
- Fixed the F-Droid release


## [0.8.0] - 2024-11-10
### Added Features and Improvements 🙌:
- Extensively revised UI with lots of statistics to keep you engaged in achieving your dream weight 🎉

### Other Changes:
- Changed font and icons to improve overall accessibility
- Improved translation
- Added a backup reminder, see settings for more options
- Upgraded deps
- Minor improvements to the code base

### Bugfix 🐛:
- Fixed a small icon being shown in the F-Droid store (German)


## [0.7.2] - 2024-09-22
### Added Features and Improvements 🙌:
- Pozdrav svijete! Thx to the community, the app is now available in Croatian 🎉
- Use the latest Flutter (3.24) with upgraded deps

### Bugfix 🐛:
- Fixed Ukrainian showing as a supported language


## [0.7.1] - 2024-07-03
### Added Features and Improvements 🙌:
- Merhaba dünya! Thx to the community, the app is now available in Turkish 🎉

### Other Changes:
- Upgraded deps
- Improved readability of the target weight label

### Bugfix 🐛:
- Fixed the broken color of the line chart
- Fixed adding measurements older than 2 years
- Fixed the target weight shown in st/lb
- Fixed saving an unmodified measurement deleting it


## [0.7.0] - 2024-05-29
### Added Features and Improvements 🙌:
- Hello World! Thx to the community, the app is now available in French, Finnish, and Italian 🎉
- Use the latest Flutter (3.22) with upgraded deps

### Other Changes:
- Improved translation


## [0.6.2] - 2024-04-02
### Bugfix 🐛:
- Fixed the app not starting (#70)

## [0.6.1] - 2024-03-21
### Added Features and Improvements 🙌:
- More reliable predictions
- Use the latest Flutter (3.19) with upgraded deps
- Target Android 14 (SDK 34)
- Hello World! Thx to the community, the app is now available in Lithuanian, Chinese, and Spanish 🎉

### Bugfix 🐛:
- Fixed reloading the theme
- Fixed the interpolation not being shown with smoothing disabled (#25)

### Other Changes:
- Predictions with smoothing disabled now use a 2-day window
- Removed v0.6.0 due to critical bug when user target weight was set.


## [0.5.0] - 2024-01-25
### Added Features and Improvements 🙌:
- Hello World! Thx to the community, the app is now available in Czech, Korean, Norwegian, and Polish 🎉
- Improved readme, screenshots, and app description


## [0.4.7] - 2024-01-18
### Added Features and Improvements 🙌:
- Faster import

### Bugfix 🐛:
- Fixed target weights below 50 kg being allowed


## [0.4.6] - 2024-01-08
### Bugfix 🐛:
- Fixed using lb and st units

### Other Changes:
- Fixed the F-Droid release


## [0.4.6] - 2024-01-08
### Bugfix 🐛:
- Fixed using lb and st units

### Other Changes:
- Fixed the F-Droid release


## [0.4.4] - 2023-12-20
### Bugfix 🐛:
- Fixed the app not loading without measurements

### Other Changes:
- Upgraded deps


## [0.4.3] - 2023-11-26
### Added Features and Improvements 🙌:
- Use the latest Flutter (3.16) with upgraded deps

### Other Changes:
- Removed the splash animation (#1)
- Fixed the list of used dependencies in the about screen
- Minor improvements to the code base


## [0.4.2] - 2023-11-14
### Other Changes:
- Minor improvements to the code base


## [0.4.1] - 2023-10-30
### Other Changes:
- Upgraded deps
- Minor improvements to the code base


## [0.4.0] - 2023-10-25
### API Changes Warning ⚠️:
- App id changed to `de.quantumphysique.trale`, upgrading is not possible!

### Added Features and Improvements 🙌:
- Prepare F-Droid launch

### Other Changes:
- Upgraded deps
- Minor UI improvements
- Minor improvements to the code base

### Bugfix 🐛:
- Fixed the missing permission to open links
- Fixed overlapping monthly ticks in the chart, which now also show years


## [0.3.1] - 2023-09-08
### Added Features and Improvements 🙌:
- Added basic animation

### Bugfix 🐛:
- Fixed the overview screen not updating after adding the first measurement


## [0.3.0] - 2023-09-05
### Added Features and Improvements 🙌:
- Added support for themed app icon (Android 13)
- Use the latest Flutter (3.13) with an improved Material You theme
- Updated measurement list
- Added import and export feature

### Bugfix 🐛:
- Fixed the broken theme selection


## [0.2.2] - 2022-10-18
### Added Features and Improvements 🙌:
- All new measurement screen including now achievements

### Bugfix 🐛:
- Fixed the start screen widget showing the 30 days average instead of the current slope

### Other Changes:
- More accurate history prediction


## [0.2.1] - 2022-07-09
### Added Features and Improvements 🙌:
- Added nice splash screen
- Adjust icon in drawer to theme and add slogan
- New and fresher app icon

### Bugfix 🐛:
- Fixed date labels for ranges larger than 7 months

### Other Changes:
- Improved text on onboarding screen
- Added a German store description
- Minor improvements to the code base


## [0.2.0] - 2022-06-09
### Added Features and Improvements 🙌:
- Completely rewritten UI based on Material Design 3 and Flutter 3
- Improved prediction based on weighted linear regression
- Many new themes, improved zoom levels, many fixed bugs and so much more.

### Other Changes:
- Minor improvements to the code base


## [0.1.0] - 2022-03-01
### Added Features and Improvements 🙌:
- initial release


[Unreleased]: https://github.com/quantumphysique/trale/compare/v1.4.0...main
[1.4.0]: https://github.com/quantumphysique/trale/compare/v1.3.1...v1.4.0
[1.3.1]: https://github.com/quantumphysique/trale/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/quantumphysique/trale/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/quantumphysique/trale/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/quantumphysique/trale/compare/v1.0.3...v1.1.0
[1.0.2]: https://github.com/quantumphysique/trale/compare/v1.0.0...v1.0.3
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
