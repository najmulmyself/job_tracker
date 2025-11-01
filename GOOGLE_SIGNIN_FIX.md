# 🔑 Google Sign-In Setup - IMPORTANT!

## Your SHA-1 Certificate Fingerprint

```
6B:D3:60:F6:6F:7E:28:AC:A3:E8:5D:76:EE:15:57:81:32:2F:93:54
```

## ⚠️ Current Issue

Google Sign-In is failing because the SHA-1 fingerprint is not added to Firebase.

## ✅ Solution - Follow These Steps:

### Step 1: Add SHA-1 to Firebase (2 minutes)

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your **Job Tracker** project
3. Click the **⚙️ Settings icon** → **Project Settings**
4. Scroll to **"Your apps"** section
5. Find **Android app** (com.example.job_tracker)
   - If you haven't added an Android app yet:
     - Click **"Add app"** → Choose Android
     - Package name: `com.example.job_tracker`
     - App nickname: "Job Tracker Android"
     - Click "Register app"
6. Click **"Add fingerprint"** button
7. **Paste this SHA-1:**
   ```
   6B:D3:60:F6:6F:7E:28:AC:A3:E8:5D:76:EE:15:57:81:32:2F:93:54
   ```
8. Click **"Save"**

### Step 2: Download Updated google-services.json (1 minute)

1. Still in **Project Settings**
2. Scroll to your Android app
3. Click **"google-services.json"** download button
4. Save the file
5. **Replace** the existing file at:
   ```
   android/app/google-services.json
   ```
   ⚠️ Make sure it's in the correct location!

### Step 3: Verify the File (30 seconds)

Check that `android/app/google-services.json` contains:

- Your project info
- OAuth client information
- Multiple client entries

### Step 4: Clean and Rebuild (1 minute)

Run these commands:

```bash
flutter clean
flutter pub get
flutter run
```

## 🧪 Test Google Sign-In

1. Launch the app
2. Tap "Sign in with Google"
3. Select your Google account
4. Sign in should work! ✅

## 🔍 Troubleshooting

### If sign-in still fails:

1. **Verify SHA-1 was added:**

   - Go to Firebase Console
   - Project Settings → Your apps → Android app
   - Check SHA-1 fingerprints list

2. **Verify google-services.json:**

   - Make sure it's the latest version
   - Check it's in `android/app/` directory
   - Not in `android/` or any other location

3. **Clear app data:**

   - On device: Settings → Apps → Job Tracker → Storage → Clear data
   - Or uninstall and reinstall

4. **Check OAuth consent screen:**

   - Firebase Console → Authentication → Settings
   - Make sure Google provider is enabled
   - Check support email is set

5. **Wait a few minutes:**
   - Firebase changes can take 1-5 minutes to propagate

## ✅ Success Indicators

You'll know it's working when:

- No "ApiException: 10" error
- Google account picker appears
- Can select account
- Returns to app successfully
- User profile shows in app

## 📝 For Production Release

When you create a release build, you'll need to:

1. Generate release keystore
2. Get SHA-1 from release keystore
3. Add that SHA-1 to Firebase too
4. Download updated google-services.json

---

**Your debug SHA-1 (copy this):**

```
6B:D3:60:F6:6F:7E:28:AC:A3:E8:5D:76:EE:15:57:81:32:2F:93:54
```

Add it to Firebase now, then download the updated google-services.json file!
