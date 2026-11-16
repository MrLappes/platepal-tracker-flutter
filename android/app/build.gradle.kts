import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // Flutter applies the Kotlin Android plugin itself while
    // android.builtInKotlin=false (AGP 9 migration path).
    // The Flutter Gradle Plugin must be applied after the Android plugin.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.platepal.platepaltracker"
    compileSdk = flutter.compileSdkVersion
    // NDK r28+ produces 16 KB-aligned native libraries (Android 15 requirement).
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.platepal.platepaltracker"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26  // Required for health package
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }    
    signingConfigs {
        create("release") {
            if (keystoreProperties.containsKey("storeFile")) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Use the release signing config for production builds
            signingConfig = if (keystoreProperties.containsKey("storeFile")) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // Add these for better compatibility
            ndk {
                debugSymbolLevel = "SYMBOL_TABLE"
            }
        }
    }

    // Add this to handle native libraries
    packaging {
        jniLibs {
            pickFirsts += listOf("**/libc++_shared.so", "**/libjsc.so")
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
    // enableEdgeToEdge() in MainActivity (Android 15 edge-to-edge).
    implementation("androidx.activity:activity:1.9.3")
}
