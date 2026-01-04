# 🔧 Fix Google Sign-In Error (ApiException: 10)

## ❌ Current Error
```
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)
```

**Error Code 10 = DEVELOPER_ERROR** - This means your SHA-1 certificate fingerprint is missing from Firebase.

---

## ✅ Complete Fix Checklist

### 📋 Step 1: Add SHA-1 to DEV Firebase Project (2 minutes)

1. **Open DEV Firebase Console**:
   - URL: https://console.firebase.google.com/project/job-tracker-dev-79ca2/settings/general

2. **Navigate to your Android app**:
   - Scroll to **"Your apps"** section
   - Find: `com.example.job_tracker.dev`
   - Click the **⚙️ gear icon** next to it

3. **Add SHA-1 fingerprint**:
   - Scroll down to **"SHA certificate fingerprints"**
   - Click **"Add fingerprint"**
   - Paste this:
     ```
     6B:D3:60:F6:6F:7E:28:AC:A3:E8:5D:76:EE:15:57:81:32:2F:93:54
     ```
   - Click **"Save"**

---

### 🔐 Step 2: Enable Google Sign-In Provider (1 minute)

1. **Go to Authentication**:
   - URL: https://console.firebase.google.com/project/job-tracker-dev-79ca2/authentication/providers

2. **Enable Google Provider**:
   - Click **"Get started"** (if Authentication isn't enabled yet)
   - Click on **"Google"** in the providers list
   - Toggle **"Enable"** to ON
   - Enter your **support email** (your email address)
   - Click **"Save"**

---

### 📥 Step 3: Download Updated google-services.json (1 minute)

1. **Back in Project Settings**:
   - URL: https://console.firebase.google.com/project/job-tracker-dev-79ca2/settings/general

2. **Download the file**:
   - Scroll to your Android app (`com.example.job_tracker.dev`)
   - Click **"Download google-services.json"**

3. **Replace the existing file**:
   - Save to: `android/app/src/dev/google-services.json`
   - ⚠️ **Important**: Make sure it's in the `dev` folder, not `main`!

---

### 🧹 Step 4: Clean and Rebuild (2 minutes)

Run these commands in your terminal:

```bash
# Clean the build
flutter clean

# Get dependencies
flutter pub get

# Run the dev flavor
./run_dev.sh
```

Or manually:
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

---

### 🧪 Step 5: Test Google Sign-In

1. Launch the app (dev flavor)
2. Tap **"Sign in with Google"**
3. Select your Google account
4. ✅ Sign-in should work!

---

## 🔍 Troubleshooting

### If it still doesn't work:

#### ✓ Verify SHA-1 was added correctly
- Go to Firebase Console → Project Settings
- Check "SHA certificate fingerprints" section
- Your SHA-1 should be listed there

#### ✓ Verify Google Sign-In is enabled
- Go to Firebase Console → Authentication → Sign-in method
- Google provider should show as "Enabled"

#### ✓ Verify google-services.json location
```
android/app/src/
├── dev/
│   └── google-services.json    ← Should be here for dev flavor
├── prod/
│   └── google-services.json    ← For prod flavor
└── main/
    └── AndroidManifest.xml
```

#### ✓ Clear app data
- On your device: Settings → Apps → [D] Job Tracker → Storage → Clear data
- Or uninstall and reinstall the app

#### ✓ Wait a few minutes
- Firebase changes can take 1-5 minutes to propagate
- Try again after waiting

---

## 📝 Your Configuration Details

### SHA-1 Fingerprint (Debug)
```
6B:D3:60:F6:6F:7E:28:AC:A3:E8:5D:76:EE:15:57:81:32:2F:93:54
```

### Firebase Projects
- **DEV**: job-tracker-dev-79ca2
  - Package: `com.example.job_tracker.dev`
  - Console: https://console.firebase.google.com/project/job-tracker-dev-79ca2

- **PROD**: job-tracker-9389f
  - Package: `com.example.job_tracker`
  - Console: https://console.firebase.google.com/project/job-tracker-9389f

### Debug Keystore Location
```
/Users/najmulmyself/.android/debug.keystore
```

---

## 🚀 For Production Release

When you build a release APK, you'll need to:

1. **Generate a release keystore**:
   ```bash
   keytool -genkey -v -keystore ~/release.keystore -alias job-tracker -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **Get the release SHA-1**:
   ```bash
   keytool -list -v -keystore ~/release.keystore -alias job-tracker
   ```

3. **Add release SHA-1 to Firebase**:
   - Follow the same steps as above
   - Add the release SHA-1 to PROD Firebase project

4. **Download updated google-services.json**:
   - Replace `android/app/src/prod/google-services.json`

---

## ✅ Success Indicators

You'll know it's working when:
- ✓ No "ApiException: 10" error
- ✓ Google account picker appears
- ✓ Can select your account
- ✓ Returns to app successfully
- ✓ User profile/email shows in app

---

## 📚 Related Documentation

- [FIX_GOOGLE_SIGNIN.md](./FIX_GOOGLE_SIGNIN.md) - Original fix guide
- [FIREBASE_SETUP.md](./FIREBASE_SETUP.md) - Firebase setup guide
- [FLAVORS_QUICK_START.md](./FLAVORS_QUICK_START.md) - Flavors guide

---

**Last Updated**: 2025-12-17
