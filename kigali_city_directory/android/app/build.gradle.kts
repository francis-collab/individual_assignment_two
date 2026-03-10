plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Add the Google services Gradle plugin (required for google-services.json)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.kigali_city_directory"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID[](https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.kigali_city_directory"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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

dependencies {
    // Import the Firebase BoM (Bill of Materials) - this manages versions for all Firebase libraries
    implementation(platform("com.google.firebase:firebase-bom:34.10.0"))

    // Add Firebase products you actually use
    // When using the BoM, do NOT specify versions here
    implementation("com.google.firebase:firebase-analytics")     // example - keep or remove
    implementation("com.google.firebase:firebase-auth")          // required for Authentication
    implementation("com.google.firebase:firebase-firestore")     // required for Cloud Firestore

    // Add more if needed later, examples:
    // implementation("com.google.firebase:firebase-storage")
    // implementation("com.google.firebase:firebase-messaging")
    // https://firebase.google.com/docs/android/setup#available-libraries
}