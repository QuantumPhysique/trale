# Trale+ Build Status

## Current Version
**2.0.0+2** (Version Name: 2.0.0, Version Code: 2)

## Package Name
**com.heets.traleplus**

## Latest Build

### Debug APK
- **Status**: ✅ Successfully built
- **Location**: `app/build/app/outputs/flutter-apk/app-debug.apk`
- **Size**: ~160 MB
- **Build Date**: 2026-01-05
- **Purpose**: Testing and verification only (not for production)

### Release APK
- **Status**: ⚠️ Requires signing configuration
- **Missing**: Release keystore (trale-plus-release.jks)
- **Missing**: key.properties file with signing credentials

## Pre-Release Status

### ✅ Completed
1. **Code Quality**
   - flutter analyze completed (878 mostly stylistic issues)
   - flutter test passed (8/8 tests: 4 database + 4 widget)
   - Memory leak fixed in DailyEntryScreen
   - EXIF stripping verified in TruncatingImagePicker

2. **Version & Metadata**
   - pubspec.yaml updated to 2.0.0+2
   - Application ID changed to com.heets.traleplus
   - AndroidManifest.xml updated with "Trale+" branding
   - strings.xml created with app description
   - CHANGELOG.md updated for v2.0.0
   - README.md comprehensive documentation

3. **Privacy Verification**
   - No network permissions in manifest
   - EXIF data stripped from all photos
   - SQLite database local only
   - No analytics or tracking code
   - No user accounts required

4. **Documentation**
   - RELEASE_GUIDE.md created with full checklist
   - STORE_LISTING.md created with marketing content
   - key.properties.template provided
   - Build instructions documented

5. **Build System**
   - ProGuard/R8 minification configured
   - Release signing configuration in build.gradle
   - Keystore security in .gitignore
   - Multi-ABI support configured

### ⏳ Remaining Tasks

1. **Release Signing Setup**
   ```powershell
   # Generate keystore
   cd t:\trale-plus\app\android\app
   keytool -genkey -v -keystore trale-plus-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias trale-plus
   
   # Create key.properties (from template)
   cp android\key.properties.template android\key.properties
   # Edit key.properties with actual passwords
   ```

2. **Build Release APK**
   ```powershell
   cd t:\trale-plus\app
   flutter build apk --release
   # Or for App Bundle (Play Store):
   flutter build appbundle --release
   ```

3. **Test Release APK**
   ```powershell
   # Install on device
   adb install build\app\outputs\flutter-apk\app-release.apk
   
   # Test all critical paths:
   # - First launch & database init
   # - Entry creation with photos
   # - Data export
   # - Settings changes
   # - Delete all data
   ```

4. **Marketing Assets**
   - [ ] 7-8 screenshots (1080x1920)
   - [ ] Feature graphic (1024x500)
   - [ ] App icon for store (512x512)
   - [ ] Promotional video (optional)

5. **Store Listing**
   - [ ] Complete Play Console setup
   - [ ] Fill in app description (from STORE_LISTING.md)
   - [ ] Upload screenshots
   - [ ] Set pricing (Free)
   - [ ] Select category (Health & Fitness)
   - [ ] Content rating questionnaire
   - [ ] Privacy policy link

6. **Final Verification**
   ```powershell
   # Verify APK signature
   jarsigner -verify -verbose -certs app-release.apk
   
   # Check permissions
   aapt dump permissions app-release.apk
   
   # Size analysis
   flutter build apk --release --target-platform android-arm64 --analyze-size
   ```

7. **Release Preparation**
   - [ ] Create GitHub release tag v2.0.0
   - [ ] Attach APK to GitHub release
   - [ ] Write release notes
   - [ ] Update website/blog
   - [ ] Prepare social media posts

## Quick Start for Release Build

If you're ready to create the production release:

1. **Generate Keystore** (one-time setup):
   ```powershell
   cd t:\trale-plus\app\android\app
   keytool -genkey -v -keystore trale-plus-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias trale-plus
   ```
   - Use a strong password (save in password manager!)
   - Fill in organization details

2. **Configure Signing**:
   ```powershell
   cd t:\trale-plus\app
   # Copy template
   Copy-Item android\key.properties.template android\key.properties
   # Edit android\key.properties with your actual:
   #   - storePassword
   #   - keyPassword
   #   - keyAlias (trale-plus)
   #   - storeFile (app/trale-plus-release.jks)
   ```

3. **Build Release**:
   ```powershell
   flutter build apk --release
   ```

4. **Install & Test**:
   ```powershell
   adb install build\app\outputs\flutter-apk\app-release.apk
   ```

## Known Issues

### Build Warnings (Non-Critical)
- 878 flutter analyze issues (mostly missing docs, style)
- Kotlin compiler warnings in plugins (share_plus, file_picker, file_saver)
- Path resolution warnings (plugin issue, not ours)

These warnings don't affect functionality and are mostly from third-party plugins.

### What Was Fixed
- ✅ Memory leak in DailyEntryScreen (mounted check added)
- ✅ Widget tests updated from counter app to fitness journal
- ✅ Application ID changed from de.quantumphysique.trale to com.heets.traleplus

## Next Steps

**For Testing/Development:**
- Use the debug APK: `app/build/app/outputs/flutter-apk/app-debug.apk`
- Can be installed immediately with: `adb install app-debug.apk`

**For Production Release:**
1. Create release keystore (see Quick Start above)
2. Build release APK
3. Test thoroughly on multiple devices
4. Create marketing materials
5. Submit to Google Play Store

## Support

For questions or issues with the build process:
- Check RELEASE_GUIDE.md for detailed instructions
- See STORE_LISTING.md for marketing guidance
- Review Flutter deployment docs: https://flutter.dev/docs/deployment/android

---

**Last Updated**: 2026-01-05  
**Build Status**: Debug ✅ | Release ⚠️ (awaiting signing setup)  
**Ready for Store**: ❌ (needs release APK, screenshots, listing)
