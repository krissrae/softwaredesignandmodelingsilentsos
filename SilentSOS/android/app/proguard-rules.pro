# Keep WorkManager classes to prevent them from being stripped by ProGuard/R8
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }

