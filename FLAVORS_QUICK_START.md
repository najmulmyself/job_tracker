# 🔥 Firebase Flavors - Quick Start

## ✅ What's Been Set Up

I've configured your project with **DEV** and **PROD** flavors to keep your development and production data completely separate!

### Files Created:

- ✅ `lib/config/app_config.dart` - Flavor configuration
- ✅ `lib/main_dev.dart` - DEV entry point
- ✅ `lib/main_prod.dart` - PROD entry point
- ✅ `.vscode/launch.json` - VS Code debug configurations
- ✅ `run_dev.sh` - Quick DEV launcher
- ✅ `run_prod.sh` - Quick PROD launcher
- ✅ `FLAVORS_SETUP_GUIDE.md` - Complete setup guide
- ✅ Android flavor configuration in `build.gradle.kts`
- ✅ Directory structure for Firebase configs

## 🚀 What You Need to Do Next

### Step 1: Create DEV Firebase Project (5 minutes)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "**Add Project**"
3. Name: **"Job Tracker DEV"**
4. Complete the setup

### Step 2: Add Apps to DEV Project

**For Android:**

- Package name: `com.example.job_tracker.dev`
- Download `google-services.json`
- Place in: `android/app/src/dev/google-services.json`

**For iOS:**

- Bundle ID: `com.example.job_tracker.dev`
- Download `GoogleService-Info.plist`
- Rename to `GoogleService-Info-dev.plist`
- Place in: `ios/Runner/GoogleService-Info-dev.plist`

### Step 3: Generate Firebase Options

Run this command:

```bash
flutterfire configure \
  --project=your-dev-project-id \
  --out=lib/firebase_options_dev.dart \
  --platforms=android,ios \
  --android-package-name=com.example.job_tracker.dev \
  --ios-bundle-id=com.example.job_tracker.dev
```

Replace `your-dev-project-id` with your actual Firebase project ID.

### Step 4: Move PROD Firebase Config

```bash
# Move existing google-services.json to prod folder
mv android/app/google-services.json android/app/src/prod/google-services.json

# If you have iOS GoogleService-Info.plist
cp ios/Runner/GoogleService-Info.plist ios/Runner/GoogleService-Info-prod.plist
```

### Step 5: Enable Services in DEV Firebase

In your DEV Firebase Console:

1. ✅ **Authentication** → Enable Google Sign-In
2. ✅ **Firestore** → Create database (test mode)
3. ✅ **Storage** → Create bucket

## 🎮 How to Use

### Development (Your Daily Driver)

**Via Terminal:**

```bash
./run_dev.sh
```

**Via Command:**

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

**Via VS Code:**

- Press F5
- Select "Development" from dropdown

### Production (Real Data - Be Careful!)

**Via Terminal:**

```bash
./run_prod.sh
```

**Via Command:**

```bash
flutter run --flavor prod -t lib/main_prod.dart
```

**Via VS Code:**

- Press F5
- Select "Production" from dropdown

## 🎯 What This Achieves

| Feature              | DEV             | PROD          |
| -------------------- | --------------- | ------------- |
| **App Name**         | Job Tracker DEV | Job Tracker   |
| **Bundle ID**        | ...dev          | ...jobtracker |
| **Firebase Project** | Separate        | Separate      |
| **Firestore**        | Test data       | Real data     |
| **Auth Users**       | Test accounts   | Real accounts |
| **Debug Banner**     | ✅ Visible      | ❌ Hidden     |
| **Can Install Both** | ✅ Yes          | ✅ Yes        |

## 🛡️ Safety Features

✅ **Isolated Data**: DEV and PROD never mix  
✅ **Visual Distinction**: DEV shows debug banner  
✅ **Different Package Names**: Both apps can be installed  
✅ **Protected Files**: Firebase configs in .gitignore  
✅ **Easy Switching**: Just change launch configuration

## 📝 Daily Workflow

```
1. Work in DEV flavor (./run_dev.sh)
2. Test with fake data
3. Break things without worry
4. Once tested, switch to PROD
5. Only touch PROD for real applications
```

## ⚠️ Important Notes

- **NEVER** commit Firebase config files
- **ALWAYS** test in DEV first
- **PROD** is for real job applications only
- Firebase configs are in `.gitignore`
- Each flavor has its own database

## 🔍 Troubleshooting

**Error: firebase_options_dev.dart not found**

- Run the `flutterfire configure` command above

**Error: google-services.json missing**

- Place the file in the correct flavor folder
- `android/app/src/dev/` for DEV
- `android/app/src/prod/` for PROD

**Can't sign in with Google**

- Add SHA-1 fingerprint to Firebase Console
- Enable Google Sign-In in Authentication

## 📚 Full Documentation

For detailed setup instructions, see: **[FLAVORS_SETUP_GUIDE.md](./FLAVORS_SETUP_GUIDE.md)**

---

**Need Help?** Check the detailed guide or Firebase Console documentation.
