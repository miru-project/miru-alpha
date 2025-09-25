plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.miru_new"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.miru.miru_new"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName


         ndk {
            abiFilters.addAll(listOf("arm64-v8a", "armeabi-v7a","x86_64"))
        }

        // Compressing on native lib is needed :(  or it will become 1.5 time of uncompressed size.
        packagingOptions {
            jniLibs {
                useLegacyPackaging = true
            }
        }
    }
   splits {
        abi {
            isEnable = true
            reset()
            include("arm64-v8a", "x86_64", "armeabi-v7a")
            isUniversalApk = true
        }
    }
    // splits {
    //     abi {
    //         isEnable = false
    //     }
    // }

    // Native libs for miru-core 
    // sourceSets.all {
    //     jniLibs.srcDirs("${project.rootDir}/../src/miru_core/android")
    // }

    // buildTypes {
    //     release {
    //         signingConfig = signingConfigs.getByName("debug")
    //         // Enable code shrinking, resource shrinking and R8/ProGuard rules to reduce APK/AAB size.
    //         isMinifyEnabled = true
    //         isShrinkResources = true
    //     }
    // }
    
    externalNativeBuild {
        cmake {
            path("../../android/CMakeLists.txt")
            version = "3.22.1"
        }
    }
}

flutter {
    source = "../.."
}
dependencies{
    implementation(files("../../src/miru_core/android/libmiru-core.aar"))
}