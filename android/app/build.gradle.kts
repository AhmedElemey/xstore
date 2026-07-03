import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun isReleaseBuildTask(): Boolean =
    gradle.startParameter.taskNames.any { task ->
        val t = task.lowercase()
        (t.contains("assemble") || t.contains("bundle") || t.contains("package")) &&
            t.contains("release")
    }

fun requireReleaseSigningProperties(): Properties {
    if (!keystorePropertiesFile.exists()) {
        throw GradleException(
            """
            Release build requires android/key.properties, but the file was not found.

            Create android/key.properties with:
              storePassword=<keystore-password>
              keyPassword=<key-password>
              keyAlias=<key-alias>
              storeFile=app/release.keystore

            Generate the keystore locally with keytool and keep both files out of git.
            See: https://docs.flutter.dev/deployment/android#signing-the-app
            """.trimIndent(),
        )
    }

    val requiredKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
    val missingKeys = requiredKeys.filter { keystoreProperties.getProperty(it).isNullOrBlank() }
    if (missingKeys.isNotEmpty()) {
        throw GradleException(
            "android/key.properties is missing required properties: ${missingKeys.joinToString()}",
        )
    }

    val storeFile = rootProject.file(keystoreProperties.getProperty("storeFile")!!)
    if (!storeFile.exists()) {
        throw GradleException(
            """
            Release keystore not found at: ${storeFile.absolutePath}

            Generate a keystore locally, place it at that path (or update storeFile in
            android/key.properties), and retry the release build.
            """.trimIndent(),
        )
    }

    return keystoreProperties
}

val releaseSigningProperties: Properties? =
    if (isReleaseBuildTask()) requireReleaseSigningProperties() else null

android {
    namespace = "com.xstore.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.xstore.app"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "xStore Dev")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "xStore")
        }
    }

    signingConfigs {
        if (releaseSigningProperties != null) {
            create("release") {
                keyAlias = releaseSigningProperties.getProperty("keyAlias")
                keyPassword = releaseSigningProperties.getProperty("keyPassword")
                storePassword = releaseSigningProperties.getProperty("storePassword")
                storeFile = rootProject.file(releaseSigningProperties.getProperty("storeFile")!!)
            }
        }
    }

    buildTypes {
        release {
            if (releaseSigningProperties != null) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.11.0"))
    implementation("com.google.firebase:firebase-analytics")
}
