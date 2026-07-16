# WEPSEED release ProGuard / R8 rules
# Flutter embedding + plugins ship consumer rules; these are extra safety nets.

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Keep line numbers for crash reports / symbolication
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-renamesourcefileattribute SourceFile

# WorkManager custom workers (entry-point registered from Dart)
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context,androidx.work.WorkerParameters);
}

# flutter_local_notifications / scheduled receivers
-keep class com.dexterous.** { *; }

# Play Core (sometimes referenced transitively; not required at runtime)
-dontwarn com.google.android.play.core.**
