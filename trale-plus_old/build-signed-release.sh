#!/bin/bash

# This script sets up the signing keystore from environment variables
# and builds a signed release APK.
# 
# Required environment variables:
# - KEYSTORE (base64 encoded keystore file)
# - SIGNING_KEY_ALIAS
# - SIGNING_KEY_PASSWORD
# - SIGNING_STORE_PASSWORD

set -e

echo "🔍 Checking for required environment variables..."

if [ -z "$KEYSTORE" ]; then
  echo "❌ Error: KEYSTORE environment variable is not set"
  exit 1
fi

if [ -z "$SIGNING_KEY_ALIAS" ]; then
  echo "❌ Error: SIGNING_KEY_ALIAS environment variable is not set"
  exit 1
fi

if [ -z "$SIGNING_KEY_PASSWORD" ]; then
  echo "❌ Error: SIGNING_KEY_PASSWORD environment variable is not set"
  exit 1
fi

if [ -z "$SIGNING_STORE_PASSWORD" ]; then
  echo "❌ Error: SIGNING_STORE_PASSWORD environment variable is not set"
  exit 1
fi

echo "✅ All required environment variables are set"

echo ""
echo "🔐 Decoding keystore from KEYSTORE secret..."
echo "$KEYSTORE" | base64 -d > app/android/release.jks

if [ ! -f app/android/release.jks ]; then
  echo "❌ Error: Failed to create keystore file"
  exit 1
fi

echo "🔍 Validating keystore..."
if ! keytool -list -v -keystore app/android/release.jks -storepass "$SIGNING_STORE_PASSWORD" > /dev/null 2>&1; then
  echo "❌ Error: Keystore validation failed - keytool could not list keystore"
  rm -f app/android/release.jks
  exit 1
fi

if ! keytool -list -v -keystore app/android/release.jks -storepass "$SIGNING_STORE_PASSWORD" | grep -q "Alias name: $SIGNING_KEY_ALIAS"; then
  echo "❌ Error: Expected alias '$SIGNING_KEY_ALIAS' not found in keystore"
  rm -f app/android/release.jks
  exit 1
fi

echo "✅ Keystore decoded and validated successfully"

echo ""
echo "📦 Getting Flutter dependencies..."
cd app
flutter --disable-analytics
flutter pub get

echo ""
echo "🔨 Building signed release APK..."
export SIGNING_STORE_FILE="../release.jks"
flutter build apk --release

echo ""
echo "✅ Build completed successfully!"
echo ""
echo "📱 APK location:"
ls -lh build/app/outputs/flutter-apk/*.apk

echo ""
echo "🧹 Cleaning up keystore file..."
rm -f android/release.jks
echo "✅ Cleanup complete"
