plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "edu.wustl.onl.envoylocalproxy"
    compileSdk = 33

    defaultConfig {
        applicationId = "edu.wustl.onl.envoylocalproxy"
        minSdk = 31
        targetSdk = 33
        versionCode = 2
        versionName = "2.0"
        multiDexEnabled = true
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
    buildFeatures {
        viewBinding = true
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.core:core-ktx:1.9.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    //implementation("io.envoyproxy.envoymobile:envoy:0.5.0.20231204") //nothing will listen because of new listener implementation
    //implementation("io.envoyproxy.envoymobile:envoy-xds:0.5.0.20231204") // not tested with xDS
    implementation("io.envoyproxy.envoymobile:envoy:0.5.0.20221205") // ->problem with release mode -- Also our working version
    //implementation(files("libs/envoy.aar"))
    implementation("androidx.recyclerview:recyclerview:1.3.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.1")
    implementation("androidx.lifecycle:lifecycle-livedata-ktx:2.6.1")
    implementation ("androidx.fragment:fragment-ktx:1.6.1")

    implementation("com.google.protobuf:protobuf-javalite:3.25.1")
}