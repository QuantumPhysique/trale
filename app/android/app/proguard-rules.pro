# Keep Flutter engine classes accessed via JNI by path_provider_android
-keep class io.flutter.util.PathUtils { *; }

# Kotlin types in the JNI signatures of shared_preferences_android 2.5+; drop
# once the plugin ships them (flutter/flutter#194649).
-keep class kotlin.Unit { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep class kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt { *; }

# androidx.window's extension and sidecar APIs are implemented by the device
# vendor at runtime, so R8 never sees them. Pulled in by android_file_picker.
-dontwarn androidx.window.extensions.**
-dontwarn androidx.window.sidecar.**
