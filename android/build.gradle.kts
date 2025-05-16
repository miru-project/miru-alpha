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



abstract class BuildAarTask : DefaultTask() {
    @get:Inject
    abstract val execOperations: ExecOperations

    @TaskAction
    fun buildAar() {
        val miruCoreDir = project.file("../src/miru_core/miru-core/binary")
        val outputDir = project.file("../src/miru_core/android")
        outputDir.mkdirs()
        val aarFile = File(outputDir, "libmiru-core.aar")
        val defaultApiLevel = "21" // fallback, or get from project if needed

        try {
            execOperations.exec {
                workingDir = miruCoreDir
                commandLine("${System.getenv("HOME")}/go/bin/gomobile", "bind", "-o", aarFile.absolutePath, "-target=android", "-androidapi", defaultApiLevel)
            }
        } catch (e: Exception) {
            println("Failed to execute gomobile: ${e.message}")
            throw e
        }
        println("Built AAR file at ${aarFile.absolutePath}")
    }
}

val buildaar = tasks.register("buildaar", BuildAarTask::class) {
    dependsOn(checkGoInstallation)
}

subprojects {
    if (project.name == "app") {
        tasks.matching { it.name == "preBuild" }.configureEach {
            // dependsOn(buildGoLib)
            dependsOn(buildaar)
        }
    }
}

