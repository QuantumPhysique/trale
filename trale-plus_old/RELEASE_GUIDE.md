# Trale+ Release Guide

## Pre-Release Checklist

### 1. Privacy Verification ✅
- [x] EXIF data stripped from photos (verified in `TruncatingImagePicker` class)
- [x] No network calls (offline-first architecture)
- [x] SQLite database local only
- [x] No analytics/tracking code

### 2. Version Information ✅
- [x] Version updated to 2.0.0+2 in pubspec.yaml
- [x] CHANGELOG.md updated with v2.0.0 notes
- [x] Application ID changed to com.heets.traleplus

### 3. App Metadata ✅
- [x] AndroidManifest.xml updated with "Trale+" label
- [x] strings.xml created with app name and description
- [x] README.md updated with complete documentation

### 4. Code Quality ✅
- [x] `flutter analyze` completed (878 mostly stylistic issues)
- [x] `flutter test` passed (8/8 tests)
- [x] Memory leak fixed in DailyEntryScreen

### 5. Release Signing Setup

#### Generate Release Keystore (Required for Production)

```powershell
# Navigate to android/app directory
cd t:\trale-plus\app\android\app

# Generate keystore (replace values with your own)
keytool -genkey -v -keystore trale-plus-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias trale-plus

# You will be prompted for:
# - Keystore password (choose a strong password)
# - Key password (choose a strong password)
# - Your name
# - Organization unit
# - Organization
# - City
# - State
# - Country code
```

#### Create key.properties File

Create `android/key.properties` (add to .gitignore!):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=trale-plus
storeFile=app/trale-plus-release.jks
```

**IMPORTANT:** Never commit key.properties or the .jks file to version control!

Add to `.gitignore`:
```
android/key.properties
android/app/*.jks
```

### 6. Build Release APK

```powershell
# Navigate to app directory
cd t:\trale-plus\app

# Build release APK (requires signing configuration)
flutter build apk --release

# Build for specific ABI with size analysis
flutter build apk --release --target-platform android-arm64 --analyze-size

# Build App Bundle for Play Store (recommended)
flutter build appbundle --release
```

Output locations:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### 7. Marketing Assets

#### Screenshots Needed (1080x1920 recommended)
1. **Home Screen** - Daily entry list with monthly view
2. **Entry Creation** - Photo picker and weight/exercise fields
3. **Statistics** - Progress charts and trends
4. **Settings** - Privacy-focused settings screen
5. **Data Export** - JSON export feature

#### Feature Graphic (1024x500)
- App name: "Trale+"
- Tagline: "Privacy-First Fitness Journal"
- Key features visible

#### App Icon
- Already created at `assets/launcher/`
- 512x512 version needed for Play Store

### 8. Store Listing Content

#### Short Description (80 chars max)
```
Privacy-first fitness journal. Track weight, workouts, photos & emotions offline.
```

#### Full Description (4000 chars max)
```
Trale+ is your completely private fitness companion. All data stays on your device - no cloud, no tracking, no accounts.

📊 TRACK YOUR PROGRESS
• Daily weight monitoring with visual trends
• Exercise logging with reps and sets
• Progress photos with automatic EXIF removal
• Mood and notes for holistic tracking

🔒 PRIVACY FIRST
• 100% offline - no internet required
• No user accounts or sign-ups
• No analytics or tracking
• Data export for full control

📈 INSIGHTS & STATISTICS
• Monthly weight trends
• Exercise progress tracking
• Visual charts and graphs
• Long-term progress visualization

✨ FEATURES
• Clean Material Design 3 interface
• Dark mode support
• Metric and Imperial units
• JSON data export
• Photo compression
• Easy data management

Perfect for:
• Weight loss journeys
• Muscle building tracking
• Fitness accountability
• Body transformation documentation
• Mental health awareness

Your fitness journey, your data, your control.
```

#### What's New (500 chars)
```
Version 2.0.0 - Major Update!

✨ New Features:
• Complete settings screen
• Data export to JSON
• Storage information
• About & privacy policy
• Imperial/metric units

🐛 Bug Fixes:
• Fixed memory leak in entry screen
• Improved performance
• Better error handling

🔒 Privacy:
• EXIF data removed from photos
• 100% offline operation
• No tracking or analytics
```

### 9. Final Testing Scenarios

#### Critical Path Testing
1. **First Launch**
   - [ ] App opens without crash
   - [ ] Default settings applied
   - [ ] Database initialized

2. **Daily Entry Creation**
   - [ ] Create entry with all fields
   - [ ] Add photo (verify EXIF stripped)
   - [ ] Save and verify persistence

3. **Data Management**
   - [ ] Export data to JSON
   - [ ] Verify JSON structure
   - [ ] Share functionality works

4. **Settings**
   - [ ] Change height/weight units
   - [ ] Toggle dark mode
   - [ ] View storage info
   - [ ] Delete all data works

5. **Edge Cases**
   - [ ] Large photo handling
   - [ ] Many entries (100+)
   - [ ] Low storage scenario
   - [ ] Date boundary transitions

### 10. Verification Commands

```powershell
# Analyze APK size
flutter build apk --release --analyze-size --target-platform android-arm64

# Verify no network permissions (should only show CAMERA, READ_MEDIA)
aapt dump permissions build\app\outputs\flutter-apk\app-release.apk

# Check APK signature
jarsigner -verify -verbose -certs build\app\outputs\flutter-apk\app-release.apk

# Install on device
adb install build\app\outputs\flutter-apk\app-release.apk

# Monitor logs during testing
adb logcat | Select-String "traleplus"
```

## Post-Release Checklist

### Immediate (Day 1)
- [ ] Monitor crash reports
- [ ] Check user reviews
- [ ] Verify download stats
- [ ] Test on multiple devices

### Week 1
- [ ] Respond to user feedback
- [ ] Document reported issues
- [ ] Plan hotfix if critical bugs

### Month 1
- [ ] Analyze usage patterns
- [ ] Plan next feature sprint
- [ ] Update documentation
- [ ] Create tutorial content

## Rollback Plan

If critical issues discovered:

1. **Unpublish from Store** (if possible)
2. **Communicate Issue** on social media/website
3. **Fix Critical Bug** immediately
4. **Test Thoroughly**
5. **Release Hotfix** version 2.0.1
6. **Update Store Listing** with apology/explanation

## Support Channels

- GitHub Issues: https://github.com/Turun/trale-plus
- Email: [Your support email]
- Website: [Your website]

## Notes

### Known Limitations
- SQLite database has theoretical limit of 140 TB (not a practical concern)
- Photos compressed to max 1920x1920 (configurable)
- Dates limited to Dart DateTime range (year 1-9999)

### Future Enhancements
- Cloud backup (optional, encrypted)
- Multiple user profiles
- Advanced statistics
- Custom exercise templates
- Meal tracking
- Integration with fitness devices

---

## Current Status

- ✅ Debug APK built successfully: `build/app/outputs/flutter-apk/app-debug.apk`
- ⏳ Release signing setup needed
- ⏳ Marketing assets to be created
- ⏳ Store listing content to be finalized

## Next Steps

1. Create release keystore
2. Configure key.properties
3. Build release APK
4. Test release APK on physical device
5. Create marketing screenshots
6. Prepare store listing
7. Submit to Google Play Store
