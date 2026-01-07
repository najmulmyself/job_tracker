# 🎨 Flutter Flavor Setup Guide

This guide will help you complete the flavor setup for the Job Tracker app.

## 📋 Overview

Your app is configured with two flavors:

- **dev** - Development environment (com.jobtracker.dev)
- **prod** - Production environment (com.jobtracker.app)

## ✅ Completed Configuration

The following has been set up for you:

1. ✅ Android flavor configuration in `build.gradle.kts`
2. ✅ iOS directory structure for flavors
3. ✅ Main entry points (`main_dev.dart` and `main_prod.dart`)
4. ✅ App configuration (`AppConfig`)
5. ✅ VS Code launch configurations

## 🔥 Firebase Setup Required

### Step 1: Download Firebase Configuration Files

#### For Android:

1. **Development Environment:**

   - Go to [Firebase Console](https://console.firebase.google.com)
   - Select **Job Tracker Dev** project
   - Go to Project Settings → Your apps → Android app
   - Download `google-services.json`
   - Place it at: `android/app/src/dev/google-services.json`

2. **Production Environment:**
   - Select **Job Tracker** (production) project
   - Download `google-services.json`
   - Place it at: `android/app/src/prod/google-services.json`

#### For iOS:

1. **Development Environment:**

   - Go to Firebase Console → **Job Tracker Dev** project
   - Download `GoogleService-Info.plist`
   - Place it at: `ios/Runner/dev/GoogleService-Info.plist`

2. **Production Environment:**
   - Go to Firebase Console → **Job Tracker** project
   - Download `GoogleService-Info.plist`
   - Place it at: `ios/Runner/prod/GoogleService-Info.plist`

### Step 2: Generate Firebase Options Files

Run these commands to generate Flutter Firebase configuration:

```bash
# Install FlutterFire CLI if you haven't already
dart pub global activate flutterfire_cli

# For Development
flutterfire configure \
  --project=job-tracker-dev-2cc94 \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=com.jobtracker.dev \
  --android-package-name=com.jobtracker.dev

# For Production
flutterfire configure \
  --project=job-tracker-a27ca \
  --out=lib/firebase_options.dart \
  --ios-bundle-id=com.jobtracker.app \
  --android-package-name=com.jobtracker.app
```

## 🍎 iOS Flavor Configuration

iOS requires additional setup in Xcode. Run the setup helper:

```bash
./ios/setup_flavors.sh
```

Or follow these manual steps:

### Manual iOS Setup:

1. **Open Xcode:**

   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Create Build Configurations:**

   - Click on the **Runner** project in Project Navigator
   - Select **Runner** target → **Info** tab
   - Under **Configurations**, duplicate existing configs:
     - Duplicate `Debug` → name it `Debug-dev`
     - Duplicate `Debug` → name it `Debug-prod`
     - Duplicate `Release` → name it `Release-dev`
     - Duplicate `Release` → name it `Release-prod`

3. **Set Bundle Identifiers:**

   - Click on **Runner** project → **Build Settings** tab
   - Search for "Product Bundle Identifier"
   - For each configuration, set:
     - `Debug-dev` & `Release-dev`: `com.jobtracker.dev`
     - `Debug-prod` & `Release-prod`: `com.jobtracker.app`

4. **Create Schemes:**

   - Click **Product** → **Scheme** → **Manage Schemes...**
   - Click **+** to add a new scheme
   - Create `dev` scheme:
     - Name: `dev`
     - Build Configuration (Run): `Debug-dev`
     - Build Configuration (Archive): `Release-dev`
   - Create `prod` scheme:
     - Name: `prod`
     - Build Configuration (Run): `Debug-prod`
     - Build Configuration (Archive): `Release-prod`

5. **Add Run Script for Firebase Config:**

   - Select **Runner** target → **Build Phases** tab
   - Click **+** → **New Run Script Phase**
   - Move it **BEFORE** "Compile Sources"
   - Add this script:

   ```bash
   PLIST_DESTINATION="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

   if [ "${CONFIGURATION}" == "Debug-dev" ] || [ "${CONFIGURATION}" == "Release-dev" ]; then
     cp "${SRCROOT}/Runner/dev/GoogleService-Info.plist" "${PLIST_DESTINATION}"
   elif [ "${CONFIGURATION}" == "Debug-prod" ] || [ "${CONFIGURATION}" == "Release-prod" ]; then
     cp "${SRCROOT}/Runner/prod/GoogleService-Info.plist" "${PLIST_DESTINATION}"
   fi
   ```

6. **Update Info.plist Display Name (Optional):**
   - Open `ios/Runner/Info.plist`
   - Add or modify:
   ```xml
   <key>CFBundleDisplayName</key>
   <string>$(APP_DISPLAY_NAME)</string>
   ```
   - In Build Settings, add User-Defined Setting `APP_DISPLAY_NAME`:
     - For dev configs: `Job Tracker DEV`
     - For prod configs: `Job Tracker`

## 🚀 Running the App

### From VS Code:

- Press `F5` and select:
  - **Development** - runs dev flavor
  - **Production** - runs prod flavor

### From Terminal:

```bash
# Run Development
flutter run --flavor dev -t lib/main_dev.dart

# Run Production
flutter run --flavor prod -t lib/main_prod.dart

# Run on specific device
flutter run --flavor dev -t lib/main_dev.dart -d <device-id>
```

### Building Release Versions:

```bash
# Build Android APK - Dev
flutter build apk --flavor dev -t lib/main_dev.dart

# Build Android APK - Prod
flutter build apk --flavor prod -t lib/main_prod.dart

# Build iOS - Dev
flutter build ios --flavor dev -t lib/main_dev.dart

# Build iOS - Prod
flutter build ios --flavor prod -t lib/main_prod.dart

# Build Android App Bundle (for Play Store) - Prod
flutter build appbundle --flavor prod -t lib/main_prod.dart
```

## 🔍 Verify Setup

Run these commands to verify everything is set up correctly:

```bash
# List all flavors
flutter build apk --flavor dev -t lib/main_dev.dart --dry-run

# Check if Firebase is configured
flutter pub get
```

## 📱 Installing Both Versions

Since dev and prod have different package names, you can install both on the same device:

- Dev: `com.jobtracker.dev` → "Job Tracker DEV"
- Prod: `com.jobtracker.app` → "Job Tracker"

## 🐛 Troubleshooting

### Android Issues:

**Problem:** `google-services.json` not found

- **Solution:** Ensure files are in correct directories:
  - `android/app/src/dev/google-services.json`
  - `android/app/src/prod/google-services.json`

**Problem:** Package name mismatch

- **Solution:** Verify package names in Firebase Console match:
  - Dev: `com.jobtracker.dev`
  - Prod: `com.jobtracker.app`

### iOS Issues:

**Problem:** Build fails with "No such file GoogleService-Info.plist"

- **Solution:**
  1. Ensure files are in correct directories
  2. Verify the Run Script phase is present
  3. Clean build: `flutter clean && cd ios && pod install`

**Problem:** Wrong Firebase project connecting

- **Solution:**
  1. Check Run Script phase is copying correct file
  2. Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`
  3. Rebuild the app

### General Issues:

**Problem:** `firebase_options_dev.dart` or `firebase_options.dart` not found

- **Solution:** Run the `flutterfire configure` commands from Step 2

**Problem:** Multiple Firebase apps error

- **Solution:** Check that `main_dev.dart` uses `firebase_dev.DefaultFirebaseOptions` and `main_prod.dart` uses `firebase_prod.DefaultFirebaseOptions`

## 📚 Additional Resources

- [Flutter Flavors Documentation](https://docs.flutter.dev/deployment/flavors)
- [Firebase FlutterFire Documentation](https://firebase.flutter.dev/docs/overview)
- [Android Product Flavors](https://developer.android.com/studio/build/build-variants)
- [iOS Schemes and Build Configurations](https://developer.apple.com/documentation/xcode/configuring-a-new-target-in-your-project)

## 🎯 Next Steps

1. ✅ Complete Firebase setup (download config files)
2. ✅ Run `flutterfire configure` commands
3. ✅ Set up iOS in Xcode
4. ✅ Test both flavors on physical devices
5. ✅ Set up CI/CD for automated builds (optional)

---

**Need Help?** Check the troubleshooting section or refer to the official Flutter documentation.
