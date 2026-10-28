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

// fvp's FindMDK.cmake links mdk's bundled libffmpeg.so into libfvp.so purely
// so gradle packages it; mdk embeds FFmpeg statically and libfvp.so uses no
// symbols from it (mdk dlopens only libass.so for subtitles, which stays).
// Strip that dependency and drop the surplus file: ~8 MB per ABI, per APK.
gradle.projectsEvaluated {
    val fvp = rootProject.subprojects.find { it.name == "fvp" } ?: return@projectsEvaluated
    fvp.tasks.matching { it.name.startsWith("buildCMake") }.configureEach {
        doLast {
            val patchelf = listOf("/usr/bin/patchelf", "patchelf").firstOrNull { p ->
                try {
                    ProcessBuilder(p, "--version").start().waitFor() == 0
                } catch (_: Exception) {
                    false
                }
            } ?: run {
                println("patchelf not found: keeping mdk's bundled libffmpeg.so")
                return@doLast
            }
            val buildDir = fvp.layout.buildDirectory.get().asFile
            buildDir.walkTopDown().forEach { f ->
                when {
                    f.name == "libfvp.so" && f.path.contains("/obj/") -> {
                        val rc = ProcessBuilder(
                            patchelf, "--remove-needed", "libffmpeg.so", f.absolutePath,
                        ).start().waitFor()
                        if (rc == 0) {
                            println("patchelf: dropped libffmpeg.so from ${f.relativeTo(buildDir)}")
                        } else {
                            println("patchelf failed on ${f.relativeTo(buildDir)} (rc=$rc)")
                        }
                    }
                    f.name == "libffmpeg.so" -> {
                        f.delete()
                        println("removed surplus ${f.relativeTo(buildDir)}")
                    }
                }
            }
        }
    }
}
