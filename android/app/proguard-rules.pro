# ─── Wovzo Mobile R8 / ProGuard Rules ──────────────────────────────────────────
# Preserve Flutter Engine classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.internal.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.embedding.** { *; }

# Preserve Dio HTTP Client classes
-keep class com.dio.** { *; }

# Ignore missing optional Play Core references in Flutter Engine
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Preserve Gson / JSON models if reflective serialization is used
-keepattributes Signature
-keepattributes *Annotation*
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
