allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
val defaultApiLevel = "21"
// Task to check if Go is installed
val checkGoInstallation = tasks.register("checkGoInstallation") {
    doLast {
        try {
            val process = ProcessBuilder("go", "version").start()
            process.waitFor()
            if (process.exitValue() != 0) {
                throw GradleException("Go is not installed. Please install Go before building the project.")
            }
        } catch (e: Exception) {
            throw GradleException("Go is not installed or not found in PATH.")
        }
    }
}

// Task to clone miru-core if not present
val cloneMiruCore = tasks.register("cloneMiruCore") {
    val miruCoreDir = file("../src/miru_core/miru_core")
        if (!miruCoreDir.exists()) {
            miruCoreDir.parentFile.mkdirs()
            println("Cloning miru-core...")
            exec {
                commandLine("git", "clone", "https://github.com/miru-project/miru-core.git", miruCoreDir.absolutePath)
            }
        } else {
            println("miru-core already cloned.")
        }
}

// build aar from gomobile bind
val buildaar = tasks.register("buildaar") {
    dependsOn(checkGoInstallation, cloneMiruCore)
    doLast {
        val miruCoreDir = file("../src/miru_core/miru_core/binary")
        val outputDir = file("../src/miru_core/android")
        outputDir.mkdirs()
        val aarFile = File(outputDir, "libmiru-core.aar")

        try {
            exec {
                workingDir = miruCoreDir
                commandLine("${System.getenv("HOME")}/go/bin/gomobile" , "bind", "-o", aarFile.absolutePath, "-target=android", "-androidapi", defaultApiLevel)
            }
        } catch (e: Exception) {
            println("Failed to execute gomobile: ${e.message}")
            throw e
        }
        println("Built AAR file at ${aarFile.absolutePath}")
    }
}
// // Task to build Go library for Android
// val buildGoLib = tasks.register("buildGoLib") {
//     dependsOn(checkGoInstallation, cloneMiruCore)
//     doLast {
//         val abiList = listOf("arm64-v8a", "x86_64", "armeabi-v7a")
//         val androidExt = project.rootProject.subprojects.find { it.name == "app" }?.extensions?.findByName("android")
//         val ndkDir = androidExt?.let { it.javaClass.getMethod("getNdkDirectory").invoke(it) as? File } ?: throw GradleException("Could not determine NDK directory from android plugin.")
//         val apiLevel = System.getenv("ANDROID_NATIVE_API_LEVEL") ?: defaultApiLevel
//         val miruCoreDir = file("../src/miru_core/miru_core")
//         abiList.forEach { abi ->
//             val (goarch, ndkTarget) = when (abi) {
//                 "arm64-v8a" -> "arm64" to "aarch64-linux-android"
//                 "x86_64" -> "amd64" to "x86_64-linux-android"
//                 "armeabi-v7a" -> "arm" to "armv7a-linux-androideabi"
//                 else -> return@forEach
//             }
//             val outputDir = file("../src/miru_core/android/$abi")
//             outputDir.mkdirs()
//             val goOutput = File(outputDir, "libmiru_core.so")
//             val clangPath = "${ndkDir.absolutePath}/toolchains/llvm/prebuilt/linux-x86_64/bin/${ndkTarget}${apiLevel}-clang"
//             exec {
//                 workingDir = miruCoreDir
//                 environment("CGO_ENABLED", "1")
//                 environment("GOOS", "android")
//                 environment("GOARCH", goarch)
//                 environment("CC", clangPath)
//                 commandLine("go", "build", "-o", goOutput.absolutePath, "-ldflags=-s -w", "-trimpath", "-buildmode=c-shared", "main.go")
//             }
//             println("Built Go library for $abi at ${goOutput.absolutePath}")
//         }
//     }
// }

subprojects {
    if (project.name == "app") {
        tasks.matching { it.name == "preBuild" }.configureEach {
            // dependsOn(buildGoLib)
            dependsOn(buildaar)
        }
    }
}

