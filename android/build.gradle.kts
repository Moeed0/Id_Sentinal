buildscript {
    extra.apply {
        set("kotlin_version", "1.9.10")
    }

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.24")
        classpath("com.android.tools.build:gradle:8.6.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
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
subprojects {
    configurations.all {
        resolutionStrategy {
            force(
                "androidx.core:core:1.12.0",
                "androidx.core:core-ktx:1.12.0",
                "androidx.activity:activity:1.8.2",
                "androidx.activity:activity-ktx:1.8.2",
                "androidx.browser:browser:1.8.0"
            )
        }
    }
}
