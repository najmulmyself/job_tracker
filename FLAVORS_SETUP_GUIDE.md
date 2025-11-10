# Flutter Flavors Setup Guide

## Overview

This guide will help you set up separate DEV and PROD environments for your Job Tracker app with different Firebase projects.

## What You Need to Do

### Step 1: Create a Second Firebase Project (DEV)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project" or use the existing project selector
3. Create a new project called: **"Job Tracker DEV"**
4. Enable Google Analytics (optional)
5. Wait for project creation

### Step 2: Add iOS App to DEV Firebase Project

1. In your **DEV** Firebase project, click "Add app" → iOS
2. iOS bundle ID: `com.najmul.jobtracker.dev` (note the `.dev` suffix)
3. App nickname: "Job Tracker DEV"
4. Download `GoogleService-Info.plist`
5. Rename it to: `GoogleService-Info-dev.plist`
6. Save it for later

### Step 3: Add Android App to DEV Firebase Project

1. In your **DEV** Firebase project, click "Add app" → Android
2. Android package name: `com.najmul.jobtracker.dev` (note the `.dev` suffix)
3. App nickname: "Job Tracker DEV"
4. Download `google-services.json`
5. Rename it to: `google-services-dev.json`
6. Save it for later

### Step 4: Update iOS Bundle IDs

Edit: `ios/Runner.xcodeproj/project.pbxproj`

Find all occurrences of:

```
PRODUCT_BUNDLE_IDENTIFIER = com.example.jobTracker;
```

Replace with configurations for both flavors (this will be done via Xcode schemes)

**OR** use Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to "Signing & Capabilities"
4. Create two schemes: "dev" and "prod"
5. Set bundle IDs:
   - dev: `com.najmul.jobtracker.dev`
   - prod: `com.najmul.jobtracker`

### Step 5: Update Android Package Names

Edit: `android/app/build.gradle`

Add flavor configurations:

```gradle
android {
    // ... existing config

    flavorDimensions "environment"
    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "Job Tracker DEV"
        }
        prod {
            dimension "environment"
            resValue "string", "app_name", "Job Tracker"
        }
    }
}
```

### Step 6: Setup Firebase Configuration Files

**For Android:**

1. Place your PROD `google-services.json` in: `android/app/src/prod/`
2. Place your DEV `google-services-dev.json` as `google-services.json` in: `android/app/src/dev/`

**For iOS:**

1. Place your PROD `GoogleService-Info.plist` in: `ios/Runner/`
2. Place your DEV `GoogleService-Info-dev.plist` in a separate location
3. Use Xcode schemes to copy the correct plist for each flavor

### Step 7: Generate Firebase Options Files

Run these commands:

```bash
# For DEV Firebase project
flutterfire configure --project=job-tracker-dev --out=lib/firebase_options_dev.dart --ios-bundle-id=com.najmul.jobtracker.dev --android-package-name=com.najmul.jobtracker.dev

# For PROD Firebase project (if needed)
flutterfire configure --project=job-tracker-prod --out=lib/firebase_options.dart --ios-bundle-id=com.najmul.jobtracker --android-package-name=com.najmul.jobtracker
```

### Step 8: Enable Firebase Services in DEV Project

In your **DEV** Firebase Console:

1. **Authentication** → Enable Google Sign-In
2. **Firestore Database** → Create database (test mode for dev)
3. **Storage** → Create storage bucket

## Running the App

### Development Mode

```bash
# Run on connected device/simulator
flutter run --flavor dev -t lib/main_dev.dart

# Build APK
flutter build apk --flavor dev -t lib/main_dev.dart

# Build iOS
flutter build ios --flavor dev -t lib/main_dev.dart
```

### Production Mode

```bash
# Run on connected device/simulator
flutter run --flavor prod -t lib/main_prod.dart

# Build APK
flutter build apk --flavor prod -t lib/main_prod.dart

# Build iOS
flutter build ios --flavor prod -t lib/main_prod.dart
```

### VS Code

Use the debug dropdown to select:

- "Development" - Runs DEV flavor
- "Production" - Runs PROD flavor

## What This Achieves

✅ **Separate Databases**: DEV and PROD have completely isolated Firestore databases
✅ **Separate Auth**: Different user accounts in DEV vs PROD
✅ **Separate Storage**: Files uploaded in DEV don't affect PROD
✅ **Visual Distinction**: DEV shows debug banner, different app name
✅ **Safe Testing**: Break things in DEV without affecting production users
✅ **Easy Switching**: Change flavor to switch between environments

## Firebase Security Rules

Remember to set up proper security rules for PROD:

**Firestore (PROD):**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /jobs/{jobId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /resumes/{resumeId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

**Firestore (DEV):**

```javascript
// Can be more permissive for testing
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Quick Reference

| Environment | Firebase Project | Bundle ID                 | Package Name              | App Name        |
| ----------- | ---------------- | ------------------------- | ------------------------- | --------------- |
| DEV         | job-tracker-dev  | com.najmul.jobtracker.dev | com.najmul.jobtracker.dev | Job Tracker DEV |
| PROD        | job-tracker-prod | com.najmul.jobtracker     | com.najmul.jobtracker     | Job Tracker     |

## Troubleshooting

**Issue**: Can't find firebase_options_dev.dart
**Solution**: Run `flutterfire configure` command for DEV project

**Issue**: Bundle ID conflict on iOS
**Solution**: Make sure Xcode schemes are properly configured with different bundle IDs

**Issue**: Google Sign-In not working
**Solution**: Ensure SHA-1 fingerprints are added to both Firebase projects (Android)

**Issue**: Both apps can't be installed simultaneously
**Solution**: Package names must be different (one has `.dev` suffix)

## Next Steps

1. Follow this guide step by step
2. Test both flavors on your device
3. Verify data is isolated between environments
4. Start using DEV for all testing
5. Only touch PROD for real job applications

---

Need help? Check the Firebase Console or Flutter documentation.
