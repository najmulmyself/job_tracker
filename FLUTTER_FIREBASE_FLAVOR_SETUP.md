# 🔥 Flutter Firebase Flavor Setup Guide

A complete guide to setting up Flutter flavors (dev/prod) with Firebase. This guide covers Android, iOS, and Google Sign-In configuration.

---

## 📖 Table of Contents

1. [What Are Flavors & Why Use Them?](#1-what-are-flavors--why-use-them)
2. [Project Structure Overview](#2-project-structure-overview)
3. [Flutter Setup](#3-flutter-setup)
4. [Android Setup](#4-android-setup)
5. [iOS Setup](#5-ios-setup)
6. [Firebase Project Setup](#6-firebase-project-setup)
7. [Google Sign-In Setup](#7-google-sign-in-setup)
8. [Running the App](#8-running-the-app)
9. [VS Code Launch Configuration](#9-vs-code-launch-configuration)
10. [Common Issues & Solutions](#10-common-issues--solutions)

---

## 1. What Are Flavors & Why Use Them?

### The Problem

Without flavors, you have ONE app that connects to ONE backend. This means:

- Testing new features affects real users
- You can't have separate databases for testing
- Accidental data corruption in production
- No way to test push notifications without spamming real users

### The Solution: Flavors

Flavors let you build **multiple versions** of your app from the same codebase:

| Flavor | Package Name      | Use Case                  |
| ------ | ----------------- | ------------------------- |
| `dev`  | `com.yourapp.dev` | Development & testing     |
| `prod` | `com.yourapp.app` | Production for real users |

Each flavor can have:

- Different Firebase project
- Different app icon & name
- Different API endpoints
- Different feature flags

---

## 2. Project Structure Overview

```
your_app/
├── lib/
│   ├── main.dart              # Default entry (optional)
│   ├── main_dev.dart          # Dev flavor entry point
│   ├── main_prod.dart         # Prod flavor entry point
│   ├── config/
│   │   └── app_config.dart    # Flavor-specific configuration
│   └── ...
├── android/
│   └── app/
│       ├── build.gradle.kts   # Flavor definitions
│       └── src/
│           ├── main/          # Shared code & resources
│           ├── dev/           # Dev-specific (google-services.json)
│           └── prod/          # Prod-specific (google-services.json)
└── ios/
    └── Runner/
        ├── dev/               # Dev GoogleService-Info.plist
        └── prod/              # Prod GoogleService-Info.plist
```

---

## 3. Flutter Setup

### 3.1 Create Entry Points

**`lib/main_dev.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_config.dart';
import 'firebase_options_dev.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with DEV config
  AppConfig.initialize(AppConfig.dev);

  // Initialize Firebase with DEV options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

**`lib/main_prod.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_config.dart';
import 'firebase_options.dart';  // Production firebase options
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with PROD config
  AppConfig.initialize(AppConfig.prod);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

### 3.2 Create App Configuration

**`lib/config/app_config.dart`**

```dart
enum AppFlavor { dev, prod }

class AppConfig {
  final AppFlavor flavor;
  final String appName;
  final String apiBaseUrl;
  final bool enableLogging;
  final String googleWebClientId;  // Required for Google Sign-In

  AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.googleWebClientId,
  });

  static AppConfig? _instance;

  static AppConfig get instance {
    if (_instance == null) {
      throw Exception('AppConfig not initialized. Call AppConfig.initialize() first.');
    }
    return _instance!;
  }

  static void initialize(AppConfig config) {
    _instance = config;
  }

  // Development configuration
  static AppConfig get dev => AppConfig(
    flavor: AppFlavor.dev,
    appName: 'MyApp DEV',
    apiBaseUrl: 'https://dev-api.example.com',
    enableLogging: true,
    // Get from google-services.json → oauth_client → client_type: 3
    googleWebClientId: 'YOUR_DEV_WEB_CLIENT_ID.apps.googleusercontent.com',
  );

  // Production configuration
  static AppConfig get prod => AppConfig(
    flavor: AppFlavor.prod,
    appName: 'MyApp',
    apiBaseUrl: 'https://api.example.com',
    enableLogging: false,
    googleWebClientId: 'YOUR_PROD_WEB_CLIENT_ID.apps.googleusercontent.com',
  );

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;
}
```

---

## 4. Android Setup

### 4.1 Configure build.gradle.kts

**`android/app/build.gradle.kts`**

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Firebase plugin
}

android {
    namespace = "com.yourapp"  // Base namespace
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.yourapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 👇 FLAVOR CONFIGURATION
    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationId = "com.yourapp.dev"      // Unique package name
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "MyApp DEV")  // App name on device
            namespace = "com.yourapp.dev"
        }
        create("prod") {
            dimension = "environment"
            applicationId = "com.yourapp.app"      // Production package name
            resValue("string", "app_name", "MyApp")
            namespace = "com.yourapp.app"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
```

### 4.2 Why Different `applicationId` and `namespace`?

| Property        | Purpose                                                                    |
| --------------- | -------------------------------------------------------------------------- |
| `applicationId` | Unique identifier on Play Store & device. Different IDs = apps can coexist |
| `namespace`     | Java/Kotlin package for generated code (R class, BuildConfig)              |

**Important:** Both flavors can be installed simultaneously on the same device because they have different `applicationId`.

### 4.3 Create Flavor Directories

```bash
mkdir -p android/app/src/dev
mkdir -p android/app/src/prod
```

Each directory will contain the flavor-specific `google-services.json`.

### 4.4 Create Shared MainActivity

**Why?** The `namespace` changes per flavor, but you need ONE `MainActivity` that works for both.

**`android/app/src/main/kotlin/com/yourapp/MainActivity.kt`**

```kotlin
package com.yourapp  // Use base package, not flavor-specific

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

### 4.5 Update AndroidManifest.xml

**`android/app/src/main/AndroidManifest.xml`**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="@string/app_name"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name="com.yourapp.MainActivity"  <!-- 👈 Fully qualified name -->
            android:exported="true"
            ...
        </activity>
    </application>
</manifest>
```

**Why fully qualified name?** Using `.MainActivity` (relative) resolves based on `namespace`, which differs per flavor. Using `com.yourapp.MainActivity` (absolute) always finds the same class.

---

## 5. iOS Setup

### 5.1 Create Build Configurations

Open Xcode:

```bash
open ios/Runner.xcworkspace
```

1. Click **Runner** project in navigator
2. Select **Runner** under PROJECT (not TARGETS)
3. Go to **Info** tab
4. Under **Configurations**, click **+** to duplicate:

| Original | Create These              |
| -------- | ------------------------- |
| Debug    | Debug-dev, Debug-prod     |
| Release  | Release-dev, Release-prod |
| Profile  | Profile-dev, Profile-prod |

### 5.2 Create Schemes

1. **Product** → **Scheme** → **New Scheme...**
2. Create scheme named `dev`
3. Create scheme named `prod`

For each scheme, set the build configuration:

**dev scheme:**

- Run → Build Configuration: `Debug-dev`
- Archive → Build Configuration: `Release-dev`

**prod scheme:**

- Run → Build Configuration: `Debug-prod`
- Archive → Build Configuration: `Release-prod`

### 5.3 Set Bundle Identifiers

1. Select **Runner** under TARGETS
2. Go to **Build Settings**
3. Search for `PRODUCT_BUNDLE_IDENTIFIER`
4. Set per configuration:

| Configuration | Bundle Identifier |
| ------------- | ----------------- |
| Debug-dev     | com.yourapp.dev   |
| Release-dev   | com.yourapp.dev   |
| Profile-dev   | com.yourapp.dev   |
| Debug-prod    | com.yourapp.app   |
| Release-prod  | com.yourapp.app   |
| Profile-prod  | com.yourapp.app   |

### 5.4 Create GoogleService-Info.plist Directories

```bash
mkdir -p ios/Runner/dev
mkdir -p ios/Runner/prod
```

### 5.5 Add Build Script for Firebase Config

1. Select **Runner** target
2. Go to **Build Phases**
3. Click **+** → **New Run Script Phase**
4. Name it "Copy Firebase Config"
5. Drag it ABOVE "Compile Sources"
6. Add this script:

```bash
# Copy the correct GoogleService-Info.plist based on build configuration
PLIST_DESTINATION="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

if [[ "${CONFIGURATION}" == *"-dev"* ]]; then
    cp "${SRCROOT}/Runner/dev/GoogleService-Info.plist" "${PLIST_DESTINATION}"
    echo "Using DEV Firebase config"
elif [[ "${CONFIGURATION}" == *"-prod"* ]]; then
    cp "${SRCROOT}/Runner/prod/GoogleService-Info.plist" "${PLIST_DESTINATION}"
    echo "Using PROD Firebase config"
else
    echo "Warning: Unknown configuration ${CONFIGURATION}"
fi
```

---

## 6. Firebase Project Setup

### 6.1 Create Two Firebase Projects

Go to [Firebase Console](https://console.firebase.google.com):

1. **Project 1:** `yourapp-dev` (for development)
2. **Project 2:** `yourapp-prod` (for production)

**Why separate projects?**

- Isolated databases (dev mistakes don't affect prod)
- Separate analytics
- Different API quotas
- Test features without affecting real users

### 6.2 Add Android Apps

For **EACH** Firebase project:

1. Click **Add app** → **Android**
2. Enter the correct package name:
   - Dev project: `com.yourapp.dev`
   - Prod project: `com.yourapp.app`
3. Download `google-services.json`
4. Place in correct directory:
   - Dev: `android/app/src/dev/google-services.json`
   - Prod: `android/app/src/prod/google-services.json`

### 6.3 Add SHA-1 Fingerprint (Required for Google Sign-In)

**Get your debug SHA-1:**

```bash
cd android && ./gradlew signingReport
```

Look for output like:

```
Variant: devDebug
SHA1: 6B:D3:60:F6:6F:7E:28:AC:A3:E8:5D:76:EE:15:57:81:32:2F:93:54
```

**Add to Firebase:**

1. Go to Firebase Console → Project Settings
2. Select your Android app
3. Click **Add fingerprint**
4. Paste the SHA-1
5. **Re-download** `google-services.json` (it now includes the SHA-1)

**Do this for BOTH dev and prod projects!**

### 6.4 Add iOS Apps

For **EACH** Firebase project:

1. Click **Add app** → **iOS**
2. Enter the correct bundle ID:
   - Dev project: `com.yourapp.dev`
   - Prod project: `com.yourapp.app`
3. Download `GoogleService-Info.plist`
4. Place in correct directory:
   - Dev: `ios/Runner/dev/GoogleService-Info.plist`
   - Prod: `ios/Runner/prod/GoogleService-Info.plist`

### 6.5 Generate Firebase Options

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Generate for DEV
flutterfire configure \
  --project=yourapp-dev \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=com.yourapp.dev \
  --android-package-name=com.yourapp.dev

# Generate for PROD
flutterfire configure \
  --project=yourapp-prod \
  --out=lib/firebase_options.dart \
  --ios-bundle-id=com.yourapp.app \
  --android-package-name=com.yourapp.app
```

---

## 7. Google Sign-In Setup

### 7.1 Enable Google Sign-In in Firebase

For **EACH** Firebase project:

1. Go to **Authentication** → **Sign-in method**
2. Enable **Google**
3. Add your support email

### 7.2 Find Your Web Client ID

Open your `google-services.json` and find the `oauth_client` with `client_type: 3`:

```json
{
  "oauth_client": [
    {
      "client_id": "123456789-abc123.apps.googleusercontent.com",
      "client_type": 1,  // 👈 This is Android client (ignore)
      ...
    },
    {
      "client_id": "123456789-xyz789.apps.googleusercontent.com",
      "client_type": 3   // 👈 This is Web client (USE THIS!)
    }
  ]
}
```

### 7.3 Configure GoogleSignIn in Flutter

```dart
class AuthService {
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    _googleSignIn = GoogleSignIn(
      // 👇 This MUST be the Web Client ID (client_type: 3), NOT Android client
      serverClientId: AppConfig.instance.googleWebClientId,
      scopes: ['email'],
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
```

### 7.4 Why Web Client ID?

| Client Type                | Purpose                                       |
| -------------------------- | --------------------------------------------- |
| `client_type: 1` (Android) | Identifies your Android app to Google         |
| `client_type: 3` (Web)     | Used by Firebase to verify tokens server-side |

Firebase Auth uses the **Web Client ID** to validate the Google ID token on their servers. Using the wrong ID causes `ApiException: 10`.

---

## 8. Running the App

### Android

```bash
# Run dev flavor
flutter run --flavor dev -t lib/main_dev.dart

# Run prod flavor
flutter run --flavor prod -t lib/main_prod.dart

# Build APK
flutter build apk --flavor dev -t lib/main_dev.dart
flutter build apk --flavor prod -t lib/main_prod.dart
```

### iOS

```bash
# Run dev flavor
flutter run --flavor dev -t lib/main_dev.dart

# Run prod flavor
flutter run --flavor prod -t lib/main_prod.dart

# Build IPA
flutter build ipa --flavor dev -t lib/main_dev.dart
flutter build ipa --flavor prod -t lib/main_prod.dart
```

---

## 9. VS Code Launch Configuration

**`.vscode/launch.json`**

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug (Dev)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart",
      "args": ["--flavor", "dev"]
    },
    {
      "name": "Debug (Prod)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart",
      "args": ["--flavor", "prod"]
    },
    {
      "name": "Release (Dev)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart",
      "flutterMode": "release",
      "args": ["--flavor", "dev"]
    },
    {
      "name": "Release (Prod)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart",
      "flutterMode": "release",
      "args": ["--flavor", "prod"]
    }
  ]
}
```

---

## 10. Common Issues & Solutions

### ❌ Error: ApiException: 10 (DEVELOPER_ERROR)

**Cause:** Google Sign-In configuration mismatch

**Solutions:**

1. ✅ Add SHA-1 fingerprint to Firebase Console
2. ✅ Re-download `google-services.json` after adding SHA-1
3. ✅ Use Web Client ID (`client_type: 3`), not Android Client ID
4. ✅ Ensure package name in Firebase matches your flavor's `applicationId`
5. ✅ Run `flutter clean` after updating `google-services.json`

### ❌ Error: ClassNotFoundException MainActivity

**Cause:** `MainActivity` package doesn't match the namespace

**Solution:** Use fully qualified class name in `AndroidManifest.xml`:

```xml
<!-- ❌ Wrong -->
<activity android:name=".MainActivity" ...>

<!-- ✅ Correct -->
<activity android:name="com.yourapp.MainActivity" ...>
```

### ❌ Error: Xcode project does not define custom schemes

**Cause:** iOS schemes for flavors not created

**Solution:** Create schemes in Xcode:

1. Product → Scheme → New Scheme
2. Name it exactly `dev` and `prod`
3. Configure build configurations for each scheme

### ❌ Error: No matching client found for package name

**Cause:** Package name mismatch between app and Firebase

**Check:**

1. `applicationId` in `build.gradle.kts` matches Firebase Android app package name
2. You have `google-services.json` in the correct flavor directory (`src/dev/` or `src/prod/`)

### ❌ Error: GoogleService-Info.plist not found (iOS)

**Cause:** Build script not copying the correct plist

**Solution:**

1. Ensure plist files exist in `ios/Runner/dev/` and `ios/Runner/prod/`
2. Add the copy script in Xcode Build Phases
3. Make sure script runs BEFORE "Compile Sources"

---

## 📋 Checklist

Before deploying, verify:

### Android

- [ ] `build.gradle.kts` has both flavors defined
- [ ] `google-services.json` in `src/dev/` and `src/prod/`
- [ ] SHA-1 fingerprint added to both Firebase projects
- [ ] `MainActivity` uses base package name
- [ ] `AndroidManifest.xml` uses fully qualified MainActivity name

### iOS

- [ ] Build configurations created (Debug-dev, Release-dev, etc.)
- [ ] Schemes created (dev, prod)
- [ ] Bundle identifiers set per configuration
- [ ] `GoogleService-Info.plist` in `Runner/dev/` and `Runner/prod/`
- [ ] Build script copies correct plist

### Firebase

- [ ] Two separate Firebase projects
- [ ] Android apps added with correct package names
- [ ] iOS apps added with correct bundle IDs
- [ ] SHA-1 fingerprints added (Android)
- [ ] Google Sign-In enabled in Authentication
- [ ] `google-services.json` downloaded AFTER adding SHA-1

### Flutter

- [ ] `main_dev.dart` and `main_prod.dart` created
- [ ] `AppConfig` has correct Web Client IDs
- [ ] `firebase_options_dev.dart` and `firebase_options.dart` generated
- [ ] `GoogleSignIn` uses `serverClientId` from AppConfig

---

## 🎉 You're Done!

You now have a fully configured Flutter app with:

- ✅ Separate dev and prod environments
- ✅ Independent Firebase projects
- ✅ Google Sign-In working for both flavors
- ✅ Both apps can be installed on the same device

Happy coding! 🚀
