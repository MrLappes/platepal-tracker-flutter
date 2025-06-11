# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# OpenAI/HTTP related
-keep class io.flutter.plugin.common.** { *; }
-dontwarn io.flutter.plugin.common.**

# Health package
-keep class ** extends io.flutter.plugin.common.PluginRegistry$Registrar { *; }

# SharedPreferences
-keep class android.content.SharedPreferences** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all classes that are used by reflection
-keep class * extends java.lang.annotation.Annotation { *; }

# Gson specific classes
-keep class com.google.gson.stream.** { *; }

# Application classes that will be serialized/deserialized over Gson
-keep class com.platepal.platepaltracker.** { *; }

# Keep generic signature of Call, Response (R8 full mode strips signatures from non-kept items).
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response

# With R8 full mode generic signatures are stripped for classes that are not
# kept. Suspend functions are wrapped in continuations where the type argument
# is used.
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation
