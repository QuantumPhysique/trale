# Package Name Consistency Fix

## Problem

The application was being renamed from `de.quantumphysique.trale` to `com.heets.traleplus`, but the renaming was incomplete. While the `applicationId` in `build.gradle` was updated to `com.heets.traleplus`, several other critical files still referenced the old package name `de.quantumphysique.trale`, causing build failures and package conflicts.

## Symptoms
- Build errors related to package name mismatches
- Namespace conflicts between different configuration files
- MainActivity not found errors
- General Android build failures

## Root Cause

The package name change was only partially applied:
- ✅ `applicationId` in `build.gradle` was updated to `com.heets.traleplus`
- ❌ `namespace` in `build.gradle` still had `de.quantumphysique.trale`
- ❌ `package` in AndroidManifest.xml files still had `de.quantumphysique.trale`
- ❌ MainActivity.kt was in the wrong directory structure and had wrong package declaration

## Files Fixed

### 1. app/android/app/build.gradle

**Line 101:** Changed namespace declaration

```gradle
// Before:
namespace 'de.quantumphysique.trale'

// After:
namespace 'com.heets.traleplus'
```

### 2. app/android/app/src/main/AndroidManifest.xml

**Line 2:** Changed package declaration

```xml
<!-- Before: -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="de.quantumphysique.trale">

<!-- After: -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.heets.traleplus">
```

### 3. app/android/app/src/debug/AndroidManifest.xml

**Line 2:** Changed package declaration

```xml
<!-- Before: -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="de.quantumphysique.trale">

<!-- After: -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.heets.traleplus">
```

### 4. app/android/app/src/profile/AndroidManifest.xml

**Line 2:** Changed package declaration

```xml
<!-- Before: -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="de.quantumphysique.trale">

<!-- After: -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.heets.traleplus">
```

### 5. MainActivity.kt

**Location:** Moved from `app/android/app/src/main/kotlin/de/quantumphysique/trale/MainActivity.kt` to `app/android/app/src/main/kotlin/com/heets/traleplus/MainActivity.kt`

**Line 1:** Changed package declaration

```kotlin
// Before:
package de.quantumphysique.trale

// After:
package com.heets.traleplus
```

## Verification

After the fix, all package references are consistent:
- ✅ `applicationId`: `com.heets.traleplus`
- ✅ `namespace`: `com.heets.traleplus`
- ✅ `package` (all manifests): `com.heets.traleplus`
- ✅ MainActivity package: `com.heets.traleplus`
- ✅ MainActivity location: `com/heets/traleplus/`

No references to `de.quantumphysique.trale` remain in the codebase.

## Testing

To verify the build works:

```bash
cd app
flutter pub get
flutter analyze
flutter build apk --debug
```

## Impact

This fix resolves:
- ✅ Build failures related to package name conflicts
- ✅ Android Gradle build errors
- ✅ MainActivity resolution errors
- ✅ Inconsistencies between debug/release/profile builds

## Date Fixed

2026-01-05

## Related Files
- app/android/app/build.gradle
- app/android/app/src/main/AndroidManifest.xml
- app/android/app/src/debug/AndroidManifest.xml
- app/android/app/src/profile/AndroidManifest.xml
- app/android/app/src/main/kotlin/com/heets/traleplus/MainActivity.kt
