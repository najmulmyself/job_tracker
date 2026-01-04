# 🔍 Google Sign-In Configuration Verification

## Current Status: ❌ Still Getting ApiException: 10

Even after adding SHA-1 and updating google-services.json, the error persists. Let's verify everything step by step.

---

## ✅ Verification Checklist

### 1. Verify SHA-1 in Firebase Console

1. **Open Firebase Console**:
   - Go to: https://console.firebase.google.com/project/job-tracker-dev-79ca2/settings/general

2. **Check SHA-1 Fingerprints**:
   - Scroll to "Your apps" → Android app (`com.example.job_tracker.dev`)
   - Click the gear icon ⚙️
   - Scroll to "SHA certificate fingerprints"
   - **Verify this SHA-1 is listed**:
     ```
     6B:D3:60:F6:6F:7E:28:AC:A3:E8:5D:76:EE:15:57:81:32:2F:93:54
     ```
   - ✅ If it's there, proceed to step 2
   - ❌ If it's NOT there, add it and download new google-services.json

---

### 2. Verify OAuth 2.0 Client in Google Cloud Console

**This is the critical step that's often missed!**

The SHA-1 fingerprint needs to be added to the **Google Cloud Console** OAuth client, not just Firebase.

1. **Find your Google Cloud Project ID**:
   - In Firebase Console, go to Project Settings
   - Note the "Project ID": `job-tracker-dev-79ca2`

2. **Open Google Cloud Console**:
   - Go to: https://console.cloud.google.com/apis/credentials?project=job-tracker-dev-79ca2

3. **Find the OAuth 2.0 Client**:
   - Look for "OAuth 2.0 Client IDs"
   - You should see a client for "Web client (auto created by Google Service)"
   - **Click on it to edit**

4. **Verify/Add SHA-1 Certificate**:
   - In the OAuth client settings, there should be a section for "SHA-1 certificate fingerprints"
   - **Check if your SHA-1 is listed**:
     ```
     6B:D3:60:F6:6F:7E:28:AC:A3:E8:5D:76:EE:15:57:81:32:2F:93:54
     ```
   - If NOT listed, **this is the problem!**
   - Add it and save

---

### 3. Alternative: Create Android OAuth Client Manually

If the automatic client doesn't have the SHA-1, create a new one:

1. **In Google Cloud Console** (https://console.cloud.google.com/apis/credentials?project=job-tracker-dev-79ca2):
   - Click "**+ CREATE CREDENTIALS**"
   - Select "**OAuth client ID**"

2. **Configure the client**:
   - Application type: **Android**
   - Name: `Job Tracker Android (Dev)`
   - Package name: `com.example.job_tracker.dev`
   - SHA-1 certificate fingerprint:
     ```
     6B:D3:60:F6:6F:7E:28:AC:A3:E8:5D:76:EE:15:57:81:32:2F:93:54
     ```
   - Click **CREATE**

3. **Download new google-services.json**:
   - Go back to Firebase Console
   - Download the updated `google-services.json`
   - Replace `android/app/src/dev/google-services.json`

---

### 4. Verify google-services.json Content

Run this command to check if the OAuth client is in your google-services.json:

```bash
cat android/app/src/dev/google-services.json | jq '.client[0].oauth_client'
```

You should see:
- At least 2 OAuth clients
- One with `"client_type": 1` (Android)
- One with `"client_type": 3` (Web)
- The Android client should have your package name and certificate hash

**Expected output**:
```json
[
  {
    "client_id": "xxx.apps.googleusercontent.com",
    "client_type": 1,
    "android_info": {
      "package_name": "com.example.job_tracker.dev",
      "certificate_hash": "6bd360f66f7e28aca3e88576ee155781322f9354"
    }
  },
  {
    "client_id": "xxx.apps.googleusercontent.com",
    "client_type": 3
  }
]
```

---

### 5. Verify Google Sign-In is Enabled in Firebase

1. **Go to Authentication**:
   - URL: https://console.firebase.google.com/project/job-tracker-dev-79ca2/authentication/providers

2. **Check Google Provider**:
   - Status should be: **Enabled**
   - Support email should be set
   - If not enabled, enable it now

---

### 6. Wait for Propagation

After making changes in Google Cloud Console or Firebase:
- **Wait 5-10 minutes** for changes to propagate
- Google's servers need time to sync the configuration

---

## 🔧 Common Issues & Solutions

### Issue 1: SHA-1 Only in Firebase, Not in Google Cloud Console

**Problem**: You added SHA-1 to Firebase, but it didn't automatically create/update the OAuth client in Google Cloud Console.

**Solution**: Manually add SHA-1 to the OAuth 2.0 client in Google Cloud Console (see step 2 above).

---

### Issue 2: Wrong Package Name

**Problem**: The package name in Firebase doesn't match your app's package name.

**Verify**:
- Firebase package name: `com.example.job_tracker.dev`
- App package name (from build.gradle.kts): `com.example.job_tracker` + `.dev` suffix = `com.example.job_tracker.dev`

**Solution**: They must match exactly!

---

### Issue 3: Multiple Google Cloud Projects

**Problem**: Your Firebase project is linked to a different Google Cloud project than you think.

**Solution**:
1. In Firebase Console → Project Settings
2. Note the "Project ID"
3. Use that exact project ID when accessing Google Cloud Console

---

### Issue 4: OAuth Consent Screen Not Configured

**Problem**: The OAuth consent screen isn't set up.

**Solution**:
1. Go to: https://console.cloud.google.com/apis/credentials/consent?project=job-tracker-dev-79ca2
2. Configure the OAuth consent screen
3. Add your email as a test user (for development)

---

## 🎯 Next Steps

1. **Verify OAuth Client in Google Cloud Console** (Step 2 above) - **THIS IS MOST LIKELY THE ISSUE**

2. **If SHA-1 is missing from OAuth client**:
   - Add it to the existing OAuth client, OR
   - Create a new Android OAuth client with the SHA-1

3. **Download fresh google-services.json**:
   ```bash
   # After updating Google Cloud Console
   # Download from Firebase Console and replace:
   # android/app/src/dev/google-services.json
   ```

4. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter run --flavor dev -t lib/main_dev.dart
   ```

5. **Test again**

---

## 📚 Resources

- **Firebase Console (DEV)**: https://console.firebase.google.com/project/job-tracker-dev-79ca2
- **Google Cloud Console (DEV)**: https://console.cloud.google.com/apis/credentials?project=job-tracker-dev-79ca2
- **OAuth Consent Screen**: https://console.cloud.google.com/apis/credentials/consent?project=job-tracker-dev-79ca2

---

## 🆘 If Still Not Working

If you've verified all the above and it still doesn't work:

1. **Check Google Play Services** on your device:
   - Make sure Google Play Services is up to date
   - Settings → Apps → Google Play Services → Update

2. **Try on a different device** or emulator

3. **Check for error details**:
   - Look for more detailed error messages in logcat
   - Check if there are any network issues

4. **Regenerate everything**:
   - Delete the Android app from Firebase
   - Re-add it with the correct package name and SHA-1
   - Download new google-services.json
   - Rebuild the app

---

**Last Updated**: 2025-12-17 02:40 AM
