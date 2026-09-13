import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Play Store upload signing. See android/key.properties.example for the
// expected format - key.properties itself is untracked (see .gitignore)
// since it holds the actual keystore path/passwords.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Building an actual release artifact (APK or AAB) without a real upload
// key would silently produce a debug-signed "release" build - exactly the
// mistake this configuration exists to prevent. Any other task (debug
// builds, `flutter analyze`/`test`, IDE sync) is unaffected even when
// key.properties doesn't exist, e.g. on a fresh clone that hasn't been
// given the keystore yet.
val isBuildingRelease = gradle.startParameter.taskNames.any {
    it.contains("Release", ignoreCase = true)
}
if (!hasReleaseSigning && isBuildingRelease) {
    throw GradleException(
        "Cannot build a release artifact: android/key.properties is missing.\n" +
            "Create it (see android/key.properties.example) pointing at a real " +
            "upload keystore before running a release build. Debug builds and " +
            "`flutter analyze`/`flutter test` do not need this file."
    )
}

android {
    namespace = "com.arrowescape.game"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications (it uses java.time APIs
        // internally that need desugaring to run on older Android versions).
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.arrowescape.game"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { rootProject.file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Real upload-key signing when key.properties is present (the
            // normal case for anyone actually cutting a release); falls
            // back to the debug key only so that project configuration
            // itself doesn't fail for non-release tasks on a machine that
            // doesn't have the keystore - see the release-task guard above,
            // which is what actually stops an unsigned release from being
            // built.
            signingConfig = if (hasReleaseSigning) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
