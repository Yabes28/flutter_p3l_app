plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") version "4.4.2" apply false
}

android {
    namespace = "com.example.flutter_p3l_app"
    compileSdk = flutter.compileSdkVersion
    apply(plugin = "com.google.gms.google-services") // ✅ WAJIB

    ndkVersion = "27.0.12077973"
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_p3l_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")

            isShrinkResources = false
            proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    // ✅ Firebase BOM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:33.14.0"))

    // ✅ Salah satu SDK Firebase, misalnya Analytics
    implementation("com.google.firebase:firebase-analytics")

    // Tambah nanti: messaging, auth, dll
}


flutter {
    source = "../.."
}
