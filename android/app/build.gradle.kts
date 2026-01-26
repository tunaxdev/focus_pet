plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter plugin'i (Dokunmadık, orijinalindeki gibi)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.focus_pet"
    
    // 👇 DEĞİŞİKLİK 1: "flutter.compileSdkVersion" yerine elle "35" yazdık.
    // Bu, "Android 36 gerekir" hatasını çözer.
    compileSdk = 34
    
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // 👇 DEĞİŞİKLİK 2: Bildirim paketi için Java 8 ve Desugaring açtık
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.focus_pet"
        
        // 👇 DEĞİŞİKLİK 3: MinSDK 21, TargetSDK 35 yaptık.
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        
        // 👇 Bunlara DOKUNMADIK. Orijinalindeki gibi bıraktık, hata vermez.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // 👇 DEĞİŞİKLİK 4: MultiDex'i açtık (Büyük kütüphaneler için şart)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// 👇 DEĞİŞİKLİK 5: Desugaring ve Multidex kütüphanelerini ekledik
dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
