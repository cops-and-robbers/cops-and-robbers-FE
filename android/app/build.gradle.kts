import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// local.properties에서 API 키 읽기
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

// .env에서 API 호스트 읽기 (network_security_config.xml 자동 생성용)
val envFile = rootProject.file("../.env")
val envProps = Properties()
if (envFile.exists()) {
    envProps.load(FileInputStream(envFile))
}
val apiHost: String = envProps.getProperty("API_BASE_URL", "")
    .replace(Regex("^https?://"), "")
    .replace(Regex(":[0-9]+.*$"), "")

android {
    namespace = "com.elipair.copsandrobbers"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // 빌드 시 생성되는 network_security_config.xml 리소스 경로 추가
    sourceSets {
        getByName("main") {
            res.srcDirs("src/main/res", "${layout.buildDirectory.get()}/generated/res/networkSecurity")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.elipair.copsandrobbers"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // AndroidManifest.xml의 ${GOOGLE_MAPS_API_KEY} placeholder에 값 주입
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] =
            localProperties.getProperty("GOOGLE_MAPS_API_KEY") ?: ""
    }

    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

// .env의 API_BASE_URL에서 호스트를 읽어 network_security_config.xml 자동 생성
tasks.register("generateNetworkSecurityConfig") {
    val outputDir = file("${layout.buildDirectory.get()}/generated/res/networkSecurity/xml")
    outputs.dir(outputDir)
    doLast {
        outputDir.mkdirs()
        File(outputDir, "network_security_config.xml").writeText(
            """<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="false">$apiHost</domain>
        <domain includeSubdomains="false">10.0.2.2</domain>
        <domain includeSubdomains="false">localhost</domain>
        <domain includeSubdomains="false">127.0.0.1</domain>
    </domain-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>""".trimIndent()
        )
    }
}

tasks.named("preBuild") {
    dependsOn("generateNetworkSecurityConfig")
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
