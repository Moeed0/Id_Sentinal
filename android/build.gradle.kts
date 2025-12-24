buildscript {
    extra.apply {
        set("kotlin_version", "1.9.22")
    }

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
        classpath("com.android.tools.build:gradle:8.1.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library") ||
            plugins.hasPlugin("com.android.application")
        ) {
            extensions.findByName("android")?.let { androidExt ->
                when (androidExt) {
                    is com.android.build.gradle.LibraryExtension -> {
                        androidExt.compileSdk = 36
                    }
                    is com.android.build.gradle.AppExtension -> {
                        androidExt.compileSdkVersion(36)
                    }
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")

    val namespaces = mapOf(
        "device_apps" to "fr.g123k.deviceapps",
        "telephony" to "com.shounakmulay.telephony"
    )

    if (namespaces.containsKey(name)) {
        val targetNamespace = namespaces[name]
        fun configureNamespace() {
            try {
                extensions.configure<com.android.build.gradle.LibraryExtension> {
                    namespace = targetNamespace
                }
            } catch (e: Exception) {
                println("Could not configure namespace for $name: $e")
            }
        }

        if (state.executed) {
            configureNamespace()
        } else {
            afterEvaluate {
                configureNamespace()
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}