plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ejupishaban.tokerrgjik"
    compileSdk = 36  // Updated to support latest plugins
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Updated from 11 to 17
        targetCompatibility = JavaVersion.VERSION_17  // Updated from 11 to 17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()  // Updated from 11 to 17
        languageVersion = "1.9"  // Set Kotlin language version for Sentry compatibility
    }

    defaultConfig {
        // Unique Application ID for Tokerrgjik
        applicationId = "com.ejupishaban.tokerrgjik"
        // Application configuration
        minSdk = 24  // Android 7.0 and above
        targetSdk = 36  // Latest Android
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
