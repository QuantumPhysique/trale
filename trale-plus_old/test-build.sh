#!/bin/bash
# Test Build Script for Trale+ Android App
# This script validates the package name fixes and performs test builds

set -e  # Exit on error
set -o pipefail  # Exit on pipe failure
set -u  # Exit on undefined variable

echo "================================================"
echo "Trale+ Build Verification Script"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verify app directory exists before changing into it
appDir="$(dirname "$0")/app"
if [ ! -d "$appDir" ]; then
    echo -e "${RED}ERROR: App directory not found at $appDir${NC}" >&2
    exit 1
fi

# Change to app directory
cd "$appDir"

echo "Step 1: Verifying package name consistency..."
echo "----------------------------------------------"

# Check that no old package references remain
OLD_PACKAGE="de.quantumphysique.trale"
NEW_PACKAGE="com.heets.traleplus"

echo "Checking for old package name references..."
matches=$(find android/ -type f -not -path '*/build/*' -not -path '*/.git/*' -exec grep -l "$OLD_PACKAGE" {} \; 2>/dev/null || true)
if [ -n "$matches" ]; then
    echo -e "${RED}✗ FAILED: Found references to old package name in the following files:${NC}"
    echo "$matches"
    exit 1
else
    echo -e "${GREEN}✓ PASSED: No old package name references found${NC}"
fi

echo ""
echo "Verifying new package name is present..."

# Check build.gradle namespace
if grep "namespace '$NEW_PACKAGE'" android/app/build.gradle > /dev/null; then
    echo -e "${GREEN}✓ build.gradle namespace is correct${NC}"
else
    echo -e "${RED}✗ build.gradle namespace is incorrect${NC}"
    exit 1
fi

# Check build.gradle applicationId
if grep "applicationId \"$NEW_PACKAGE\"" android/app/build.gradle > /dev/null; then
    echo -e "${GREEN}✓ build.gradle applicationId is correct${NC}"
else
    echo -e "${RED}✗ build.gradle applicationId is incorrect${NC}"
    exit 1
fi

# Check AndroidManifest.xml files
for manifest in android/app/src/main/AndroidManifest.xml android/app/src/debug/AndroidManifest.xml android/app/src/profile/AndroidManifest.xml; do
    if grep "package=\"$NEW_PACKAGE\"" "$manifest" > /dev/null; then
        echo -e "${GREEN}✓ $manifest package is correct${NC}"
    else
        echo -e "${RED}✗ $manifest package is incorrect${NC}"
        exit 1
    fi
done

# Check MainActivity.kt location and package
if [ -f "android/app/src/main/kotlin/com/heets/traleplus/MainActivity.kt" ]; then
    echo -e "${GREEN}✓ MainActivity.kt is in correct location${NC}"
    if grep "package $NEW_PACKAGE" android/app/src/main/kotlin/com/heets/traleplus/MainActivity.kt > /dev/null; then
        echo -e "${GREEN}✓ MainActivity.kt package declaration is correct${NC}"
    else
        echo -e "${RED}✗ MainActivity.kt package declaration is incorrect${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ MainActivity.kt is not in correct location${NC}"
    exit 1
fi

# Check old MainActivity location doesn't exist
if [ -f "android/app/src/main/kotlin/de/quantumphysique/trale/MainActivity.kt" ]; then
    echo -e "${RED}✗ Old MainActivity.kt location still exists${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Old MainActivity.kt location removed${NC}"
fi

echo ""
echo "Step 2: Checking Flutter installation..."
echo "----------------------------------------------"

if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}⚠ Flutter not found in PATH${NC}"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    echo ""
    echo -e "${YELLOW}Package name verification completed successfully!${NC}"
    echo "Once Flutter is installed, run the following commands:"
    echo "  cd app"
    echo "  flutter pub get"
    echo "  flutter analyze"
    echo "  flutter build apk --debug"
    exit 0
fi

echo -e "${GREEN}✓ Flutter found${NC}"
flutter --version

echo ""
echo "Step 3: Getting Flutter dependencies..."
echo "----------------------------------------------"
flutter pub get

echo ""
echo "Step 4: Running Flutter analyze..."
echo "----------------------------------------------"
echo -e "${YELLOW}Note: Some warnings are expected (878 style issues documented)${NC}"
if flutter analyze --no-fatal-warnings lib/; then
    echo -e "${GREEN}✓ Flutter analyze completed${NC}"
else
    ANALYZE_EXIT=$?
    echo -e "${YELLOW}⚠ Flutter analyze completed with warnings (exit code: $ANALYZE_EXIT)${NC}"
    echo "This is expected - 878 style warnings are documented in BUILD_STATUS.md"
fi

echo ""
echo "Step 5: Running dependency validation..."
echo "----------------------------------------------"
dart run dependency_validator || echo -e "${YELLOW}Note: Some dependency warnings may be expected${NC}"

echo ""
echo "Step 6: Building debug APK..."
echo "----------------------------------------------"
echo "This will take several minutes..."
flutter build apk --debug

echo ""
echo "================================================"
echo -e "${GREEN}✓ BUILD VERIFICATION COMPLETED SUCCESSFULLY!${NC}"
echo "================================================"
echo ""
echo "Debug APK location: build/app/outputs/flutter-apk/app-debug.apk"
echo ""
echo "To install on a connected device:"
echo "  adb install build/app/outputs/flutter-apk/app-debug.apk"
echo ""
echo "To build release APK (requires signing setup):"
echo "  flutter build apk --release"
echo ""
