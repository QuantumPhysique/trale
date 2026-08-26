# Keep Flutter engine classes accessed via JNI by path_provider_android
-keep class io.flutter.util.PathUtils { *; }

# androidx.window's extension and sidecar APIs are implemented by the device
# vendor at runtime, so R8 never sees them. Pulled in by android_file_picker.
-dontwarn androidx.window.extensions.**
-dontwarn androidx.window.sidecar.**
