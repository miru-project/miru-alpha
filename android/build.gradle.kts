// build aar from gomobile bind
import org.gradle.process.ExecOperations
import javax.inject.Inject

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
// // Task to check if Go is installed
// val checkGoInstallation = tasks.register("checkGoInstallation") {
//     doLast {
//         try {
//             val process = ProcessBuilder("go", "version").start()
//             process.waitFor()
//             println("Go version: ${process.inputStream.bufferedReader().readText().trim()}")
//             if (process.exitValue() != 0) {
//                 throw GradleException("Go is not installed. Please install Go before building the project.")
//             }
//         } catch (e: Exception) {
//             throw GradleException("Go is not installed or not found in PATH.")
//         }
//         try{
//             val process = ProcessBuilder("go","install","golang.org/x/mobile/cmd/gomobile@latest").start()
//             process.waitFor()
//             println("go mobile installed")
//         }catch(e:Exception){
//             throw GradleException("Failed to install gomobile: ${e.message}", e)
//         }
//         try {
//             val proc = ProcessBuilder("/home/noonecare/go/bin/gomobile", "version")
//             val env = proc.environment()
//             val process = proc.start()
//             val goBin = "/home/noonecare/go/bin"
//             val currentPath = System.getenv("PATH") ?: ""
//             val sep = java.io.File.pathSeparator
//             env["PATH"] = if (currentPath.isBlank()) goBin else "$currentPath$sep$goBin"
//             println("Gomobile version: ${process.inputStream.bufferedReader().readText().trim()}")
//             process.waitFor()
//             println("Gomobile error: ${process.errorStream.bufferedReader().readText().trim()}")
//             if (process.exitValue() != 0) {
//                 println("Gomobile error: ${process.errorStream.bufferedReader().readText().trim()}")
//                 throw GradleException(process.errorStream.bufferedReader().readText().trim())
//             }
//         } catch (e: Exception) {
//             throw GradleException(e.message ?: "Gomobile is not installed or not found in PATH.")
//              e.printStackTrace()
//         }

//         try{
//             val process = ProcessBuilder("/home/noonecare/go/bin/gomobile","bind","-ldflags=\"-s -w\"", "-o", aarFile.absolutePath, "-target=android", "-androidapi", defaultApiLevel).start()
//             process.waitFor()
//             println("go mobile installed")
//         }catch(e:Exception){
//             throw GradleException("Failed to install gomobile: ${e.message}", e)
//         }
//     }
// }

// val executeGoMobile = tasks.register("executeGoMobile") {
//     doLast {
//         try {
//             val process = ProcessBuilder("/home/noonecare/go/bin/gomobile", "init")
//             val env = process.environment()
//             // env.put("PATH","/home/noonecare/go/bin")
//             val goBin = "/home/noonecare/go/bin"
//             val currentPath = System.getenv("PATH") ?: ""
//             val sep = java.io.File.pathSeparator
//             env["PATH"] = if (currentPath.isBlank()) goBin else "$currentPath$sep$goBin"
//             println("Using PATH: ${env["PATH"]}")
//             val start = process.start()
//             start.waitFor()
//             if (start.exitValue() != 0) {
//                 throw GradleException("Failed to initialize gomobile. Ensure gomobile is installed and configured correctly.")
//             }
//         } catch (e: Exception) {
//             throw GradleException("Failed to execute gomobile: ${e.message}", e)
//         }
//     }
// }

val prepareFfmpeg = tasks.register("prepareFfmpeg") {
    doLast {
        val libPath = rootProject.file("../src/ffmpeg_merge/android")
        println("Lib path: ${libPath.absolutePath}")
        val ffmpegUrl = "https://sourceforge.net/projects/avbuild/files/android/ffmpeg-8.0-android-lite-lto.tar.xz/download"
        val ffmpegArchive = File(libPath, "ffmpeg.tar.xz")
        val ffmpegRoot = File(libPath, "ffmpeg-8.0-android-lite-lto")

        if (!ffmpegArchive.exists()) {
            println("Downloading FFmpeg from $ffmpegUrl to ${ffmpegArchive.absolutePath}")
            try {
                java.net.URL(ffmpegUrl).openStream().use { input ->
                    ffmpegArchive.outputStream().use { output ->
                        input.copyTo(output)
                    }
                }
            } catch (e: Exception) {
                throw GradleException("Failed to download FFmpeg: ${e.message}", e)
            }
        } else {
            println("FFmpeg archive already exists at ${ffmpegArchive.absolutePath}")
        }

        if (!ffmpegRoot.exists()) {
            println("Extracting FFmpeg to ${libPath.absolutePath}")
            try {
                project.exec {
                    // -xJf handles .tar.xz extraction on Linux
                    commandLine("tar", "-xJf", ffmpegArchive.absolutePath, "-C", libPath.absolutePath)
                }
            } catch (e: Exception) {
                throw GradleException("Failed to extract FFmpeg archive: ${e.message}", e)
            }
        } else {
            println("FFmpeg already extracted at ${ffmpegRoot.absolutePath}")
        }
    }
}

// abstract class BuildAarTask : DefaultTask() {
//     @get:Inject
//     abstract val execOperations: ExecOperations

//     // @TaskAction
//     // fun buildAar() {
//     //     val miruCoreDir = project.file("../src/miru_core/miru-core/binary")
//     //     val outputDir = project.file("../src/miru_core/android")
//     //     outputDir.mkdirs()
//     //     val aarFile = File(outputDir, "libmiru-core.aar")
//     //     val defaultApiLevel = "21" // fallback, or get from project if needed
//     //      val isWindows = System.getProperty("os.name").toLowerCase().contains("windows")
//     //      val goBinPath = if (isWindows) {
//     //         "${System.getenv("USERPROFILE")}\\go\\bin"
//     //     } else {
//     //         "${System.getenv("HOME")}/go/bin"
//     //     }
//     //      val pathSeparator = if (isWindows) ";" else ":"
//     //      val updatedPath = "$goBinPath$pathSeparator${System.getenv("PATH") ?: ""}"
//     //     // try {
//     //     //     execOperations.exec {
//     //     //         workingDir = miruCoreDir
//     //     //         standardOutput = System.out
//     //     //         // environment("PATH", goBinPath)
//     //     //         environment("PATH", "/usr/bin/go/bin")
//     //     //         commandLine("gomobile", "init")
//     //     //         println("Initialized gomobile")
//     //     //         println("gomobile" + " bind"+" -ldflags=\"-s -w\" "+ " -o "+ aarFile.absolutePath+ " -target=android "+ " -androidapi "+ defaultApiLevel)
//     //     //         commandLine("/home/noonecare/go/bin/gomobile", "bind","-ldflags=\"-s -w\"", "-o", aarFile.absolutePath, "-target=android", "-androidapi", defaultApiLevel)
//     //     //     }   

//     //     //     // execOperations.exec {
//     //     //     //     workingDir = miruCoreDir
//     //     //     //     standardOutput = System.out
//     //     //     //     environment("PATH", goBinPath)
                

//     //     //     //     println("gomobile" + " bind"+" -ldflags=\"-s -w\" "+ " -o "+ aarFile.absolutePath+ " -target=android "+ " -androidapi "+ defaultApiLevel)
//     //     //     //     commandLine("gomobile", "bind","-ldflags=\"-s -w\"", "-o", aarFile.absolutePath, "-target=android", "-androidapi", defaultApiLevel)
//     //     //     // }
//     //     // } catch (e: Exception) {
            
            
//     //     //     val gobindPath = if (isWindows) {
//     //     //         "${System.getenv("USERPROFILE")}\\go\\bin\\gomobind.exe"
//     //     //     } else {
//     //     //         "${System.getenv("HOME")}/go/bin/gobind"
//     //     //     }
//     //     //     println("============================================================")
//     //     //     println("# Note: Ensure that gomobile is installed and available in your PATH or install gomobile")
//     //     //     println("Diagnosis: ")
//     //     //     println("============================================================")
//     //     //     // println("gomobile exists? ${project.file(gomobilePath).exists()}")
//     //     //     println("gobind exists? ${project.file(gobindPath).exists()}")
//     //     //     println("Failed to execute gomobile: ${e.message}")
//     //     //     throw e
            
//     //     // }
//     //     // println("Built AAR file at ${aarFile.absolutePath}")
//     // }
// }

// val buildaar = tasks.register("buildaar") {
//     dependsOn(checkGoInstallation)
//     dependsOn(executeGoMobile)
// }

subprojects {
    if (project.name == "app") {
        tasks.matching { it.name == "preBuild" }.configureEach {
            // dependsOn(buildaar)
            dependsOn(prepareFfmpeg)
        }
    }
}
