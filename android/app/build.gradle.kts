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
    namespace = "miru.alpha"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        // Updated to Java 17 to be compatible with plugin class files compiled with JDK 17.
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // Updated to use the new Kotlin DSL. The `jvmToolchain` method configures the JVM target version.
    kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "miru.alpha"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 28
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName


         ndk {
            abiFilters.addAll(listOf("arm64-v8a", "armeabi-v7a","x86_64"))
        }

        // Compressing on native lib is needed :(  or it will become 1.5 time of uncompressed size.
        // Updated to use the new packaging DSL as packagingOptions is deprecated.
        packaging {
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

    lint {
        checkReleaseBuilds = false
    }
}

flutter {
    source = "../.."
}
dependencies{
    implementation(files("../../src/miru_core/android/libmiru-core.aar"))
}