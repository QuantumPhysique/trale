# Trale+ 🏋️

A complete fitness journal app for tracking weight, workouts, photos, thoughts, and emotions - all while respecting your privacy.

## Features ✨

### Track Everything
- **Weight & BMI**: Log your weight and height with automatic BMI calculation
- **Progress Photos**: Up to 3 photos per day with EXIF metadata stripped for privacy
- **Workouts**: Text-based workout logging with custom tags
- **Thoughts**: Free-form daily journal entries
- **Emotions**: Select up to 4 emotions from 8 core feelings

### Privacy First 🔒
- All data stays on your device (no cloud sync)
- Photo EXIF data automatically stripped (GPS, device info removed)
- No analytics or tracking
- No permissions beyond camera and photos
- Open source and verifiable

### Beautiful & Modern
- Material Design 3
- Dark mode support
- Smooth animations
- Intuitive sectioned entry interface

## Installation

### F-Droid
Coming soon!

### Manual Installation
1. Download the latest APK from [Releases](https://github.com/heets99/trale-plus/releases)
2. Install on your Android device
3. Grant camera and photos permissions when prompted

## Screenshots

[Add screenshots here]

## Development

### Requirements
- Flutter 3.16+
- Android SDK 21+

### Setup
```bash
git clone https://github.com/heets99/trale-plus.git
cd trale-plus
git checkout plus
flutter pub get
flutter run
```

### Testing
```bash
flutter test
```

### Building
```bash
flutter build apk --release
```

## Privacy Policy

Trale+ is designed with privacy at its core:

- **Local Storage**: All data is stored locally on your device using SQLite database
- **No Network**: App does not require or use internet connectivity
- **EXIF Stripping**: Photos are processed to remove all metadata (GPS location, device info, timestamps)
- **No Tracking**: No analytics, crash reporting, or telemetry
- **Open Source**: Code is publicly auditable

### Permissions Used

- **Camera**: To capture progress photos
- **Photos (Android 13+) / Storage (Android 12 and below)**: To select images from gallery

## Roadmap 🚀

### Future Features
- Data visualization and charts
- Goal setting and tracking
- Exercise library
- Meal logging
- Calendar view
- Data import functionality
- Widget for home screen

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Credits

Based on the original [trale](https://github.com/QuantumPhysique/trale) app by QuantumPhysique.

Extended to include comprehensive fitness journal features while maintaining the privacy-first philosophy.

## Support

Found a bug or have a feature request? Please open an issue.

##### Will this app stay gratis?
This app will always be gratis on F-Droid with all features.
Once leaving beta, a small fee will be added on the Google Play Store.

##### Could you please add feature X?
At this stage we are focusing on improving stability before adding new features.
Feel free to open a new <a href="https://github.com/QuantumPhysique/trale/issues">issue</a> or a pull request.

##### Can I contribute?
- Implementing new functionality. If you are new to Flutter you should first [get started](https://flutter.dev/docs/get-started/install).
- Open an issue and help us find bugs, or just give us some feedback.
- Share the app with your friends :)

You can help [translate trale on Hosted Weblate](https://hosted.weblate.org/engage/trale/).

<a href="https://hosted.weblate.org/engage/trale/">
<img src="https://hosted.weblate.org/widget/trale/horizontal-auto.svg" alt="Oversettelsesstatus" />
</a>

## Disclaimer
Anorexia is a serious disease.
Especially due to the many negative examples on social media, anorexia is increasingly becoming a problem for society as a whole.
As part of our contribution to prevention, no target weight below 50 kg / 110 lb / 7.9 st is possible.

This app is still in <b>beta</b> stage and may contain bugs.
If you encounter a bug or if you are missing a feature, please <a href="https://github.com/QuantumPhysique/trale/issues">open a new issue</a>.

## Contributors

<a href="https://github.com/QuantumPhysique/trale/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=QuantumPhysique/trale" />
</a>

Made with [contrib.rocks](https://contrib.rocks).

## License
The project is licensed [GNU AGPLv3+](https://github.com/QuantumPhysique/trale/blob/main/LICENSE).
