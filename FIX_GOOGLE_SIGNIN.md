# Fix Google Sign-In Error (ApiException: 10)

## Problem

Getting `PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)`

**Error Code 10 = DEVELOPER_ERROR** - Missing SHA-1 fingerprint configuration.

## Your SHA-1 Fingerprint

```
SHA1: 6B:D3:60:F6:6F:7E:28:AC:A3:E8:5D:76:EE:15:57:81:32:2F:93:54
```

---

## Quick Fix Steps

### 1. Add SHA-1 to DEV Firebase Project

1. Go to: https://console.firebase.google.com/project/job-tracker-dev-79ca2/settings/general
2. Scroll to "Your apps" section
3. Find your Android app: `com.example.job_tracker.dev`
4. Click the gear icon (⚙️) next to it
5. Scroll down to "SHA certificate fingerprints"
6. Click **"Add fingerprint"**
7. Paste: `6B:D3:60:F6:6F:7E:28:AC:A3:E8:5D:76:EE:15:57:81:32:2F:93:54`
8. Click **Save**

### 2. Add SHA-1 to PROD Firebase Project

1. Go to: https://console.firebase.google.com/project/job-tracker-9389f/settings/general
2. Scroll to "Your apps" section
3. Find your Android app: `com.example.job_tracker`
4. Click the gear icon (⚙️) next to it
5. Scroll down to "SHA certificate fingerprints"
6. Click **"Add fingerprint"**
7. Paste: `6B:D3:60:F6:6F:7E:28:AC:A3:E8:5D:76:EE:15:57:81:32:2F:93:54`
8. Click **Save**

### 3. Download Updated google-services.json Files

**For DEV:**

1. In Firebase Console (job-tracker-dev-79ca2), click **Download google-services.json**
2. Save to: `android/app/src/dev/google-services.json`

**For PROD:**

1. In Firebase Console (job-tracker-9389f), click **Download google-services.json**
2. Save to: `android/app/src/prod/google-services.json`

### 4. Enable Google Sign-In in Firebase

**For DEV (job-tracker-dev-79ca2):**

1. Go to: https://console.firebase.google.com/project/job-tracker-dev-79ca2/authentication/providers
2. Click **"Get started"** if needed
3. Click **"Google"** provider
4. Toggle **"Enable"**
5. Enter project support email (your email)
6. Click **Save**

**For PROD (job-tracker-9389f):**

1. Go to: https://console.firebase.google.com/project/job-tracker-9389f/authentication/providers
2. Click **"Get started"** if needed
3. Click **"Google"** provider
4. Toggle **"Enable"**
5. Enter project support email (your email)
6. Click **Save**

### 5. Test the Fix

```bash
# Clean build
flutter clean
flutter pub get

# Run DEV flavor
./run_dev.sh

# Try Google Sign-In again
```

---

## Why This Happens

Google Sign-In requires your app's SHA-1 fingerprint to verify that sign-in requests are coming from your app. The `flutterfire configure` command registers your app but doesn't automatically add the SHA-1 fingerprint.

## Directory Structure After Fix

```
android/app/src/
├── dev/
│   └── google-services.json    ← DEV Firebase config
├── prod/
│   └── google-services.json    ← PROD Firebase config
└── main/
    └── AndroidManifest.xml
```

---

## Quick Links

- **DEV Firebase Console**: https://console.firebase.google.com/project/job-tracker-dev-79ca2
- **PROD Firebase Console**: https://console.firebase.google.com/project/job-tracker-9389f
- **Your Debug Keystore**: `/Users/najmulmyself/.android/debug.keystore`

## For Production Release

When building a release APK, you'll need to add the release SHA-1 fingerprint too:

```bash
# Get release SHA-1 (when you create a release keystore)
keytool -list -v -keystore path/to/release.keystore -alias your-key-alias
```

Then add that SHA-1 to Firebase Console as well.
