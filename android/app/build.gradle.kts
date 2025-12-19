import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.prayertime.prayer_time"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.prayertime.prayer_time"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        
        // Multidex support for older devices
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Enable code shrinking, obfuscation, and optimization
            isMinifyEnabled = true
            isShrinkResources = true
            
            // ProGuard rules file
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Signing configuration
            // Note: Create android/key.properties file with your keystore details
            // See: https://docs.flutter.dev/deployment/android#signing-the-app
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                signingConfig = signingConfigs.create("release") {
                    keyAlias = keystoreProperties["keyAlias"] as String? ?: ""
                    keyPassword = keystoreProperties["keyPassword"] as String? ?: ""
                    storeFile = file(keystoreProperties["storeFile"] as String? ?: "")
                    storePassword = keystoreProperties["storePassword"] as String? ?: ""
                }
            } else {
                // Fallback to debug signing for development
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}

// Configure Kotlin to use JVM target 21 to match Java
tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21)
    }
}
