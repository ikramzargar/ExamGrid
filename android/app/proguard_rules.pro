# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# FlutterFire plugins
-keep class io.flutter.plugins.firebase.** { *; }
-dontwarn io.flutter.plugins.firebase.**

# FlutterSecureStorage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Needed for Flutter plugins in general
-keep class io.flutter.plugin.** { *; }
-dontwarn io.flutter.plugin.**