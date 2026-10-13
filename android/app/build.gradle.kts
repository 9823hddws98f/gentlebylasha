import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: create android/key.properties (never commit it) with
// storePassword, keyPassword, keyAlias and storeFile (path to the upload keystore).
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

// A release build signed with debug keys can't be uploaded and fails silently
// later, so stop right away when the upload key is missing.
val releaseTaskRequested = gradle.startParameter.taskNames.any { it.contains("Release") }
if (releaseTaskRequested && keystoreProperties.isEmpty) {
    throw GradleException(
        "android/key.properties is missing. Release builds must be signed with the " +
            "upload key: add key.properties (storePassword, keyPassword, keyAlias, storeFile)."
    )
}

// Host of the App Links for shared tracks/playlists. Must match APP_URL in the
// app (lib/utils/app_config.dart) and serve /.well-known/assetlinks.json.
// Override with -PappLinkHost=example.com when the app gets its own domain.
val appLinkHost = (project.findProperty("appLinkHost") as String?) ?: "gentle-mu.vercel.app"

android {
    namespace = "com.mezz.gentle"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.mezz.gentle"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appLinkHost"] = appLinkHost
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("androidx.work:work-runtime-ktx:2.10.1")
    implementation("androidx.window:window:1.3.0")
    implementation("androidx.window:window-java:1.3.0")
}
