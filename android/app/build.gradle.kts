import java.io.FileInputStream
import java.io.FileNotFoundException
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}


fun getApiKey(name:String): String? {
    val fl = rootProject.file("key.properties")

    if (fl.exists()) {
        val properties = Properties()
        properties.load(FileInputStream(fl))
        return properties.getProperty(name)
    } else {
        return null
    }
}

val keystorePath = System.getenv("KEYSTORE") ?: getApiKey("storeFile") ?: "keystore.jks"
val storeFileRef = file(keystorePath)
val storePasswordRef: String? = System.getenv("KEYSTORE_PASSWORD") ?: getApiKey("storePassword")
val keyAliasRef: String? = System.getenv("KEY_ALIAS") ?:getApiKey("keyAlias")
val keyPasswordRef: String? = System.getenv("KEY_PASSWORD") ?: getApiKey("keyPassword")


android {
    namespace = "com.miru.alpha"
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
        applicationId = "com.miru.alpha"
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

     signingConfigs {
        create("release") {
            keyAlias = keyAliasRef
            keyPassword = keyPasswordRef
            storeFile = file(keystorePath)
            storePassword = storePasswordRef
        }
    }

    buildTypes {
        release {
            val releaseSigning = signingConfigs.findByName("release")
            signingConfig = if (releaseSigning?.keyPassword != null) {
                println("release sign config applied")
                releaseSigning
            } else {
                println("debug sign config applied")
                signingConfigs.getByName("debug")
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