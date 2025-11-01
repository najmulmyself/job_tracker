# 🎯 Job Tracker - Setup Checklist

Use this checklist to ensure everything is properly configured.

## ✅ Pre-Setup Checklist

### Development Environment
- [ ] Flutter SDK installed (version 3.9.2+)
  - Run: `flutter --version`
  - Should show: Flutter 3.9.2 or higher
- [ ] Dart SDK included with Flutter
- [ ] Android Studio OR Xcode installed
- [ ] VS Code (optional but recommended)
- [ ] Git installed

### Verify Flutter Installation
```bash
flutter doctor
```
All items should have green checkmarks ✓

### Device/Emulator Ready
- [ ] Android device connected OR Android emulator running
- [ ] iOS device connected (Mac only) OR iOS simulator running (Mac only)
- Run: `flutter devices` to verify

---

## 📦 Project Setup Checklist

### 1. Clone & Dependencies
- [ ] Project cloned/downloaded
- [ ] Navigate to project directory
- [ ] Run: `flutter pub get`
- [ ] No errors in terminal
- [ ] All packages downloaded successfully

---

## 🔥 Firebase Setup Checklist

### Create Firebase Project
- [ ] Go to https://console.firebase.google.com/
- [ ] Click "Create a project" or use existing
- [ ] Project name: "Job Tracker" (or your choice)
- [ ] Google Analytics: Enabled (optional)
- [ ] Project created successfully

### Android App Configuration
- [ ] In Firebase Console, click Android icon (⚙️)
- [ ] Package name: `com.example.job_tracker`
  - Verify in: `android/app/build.gradle.kts`
- [ ] App nickname: "Job Tracker Android"
- [ ] SHA-1 certificate added (for Google Sign-In)
  - Get with: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
  - Copy SHA-1 and paste in Firebase
- [ ] Downloaded `google-services.json`
- [ ] Placed file in: `android/app/google-services.json`
- [ ] Verified file location (should be next to build.gradle.kts)

### iOS App Configuration (Mac Only)
- [ ] In Firebase Console, click iOS icon (⚙️)
- [ ] Bundle ID: `com.example.jobTracker`
  - Verify in: `ios/Runner/Info.plist`
- [ ] App nickname: "Job Tracker iOS"
- [ ] Downloaded `GoogleService-Info.plist`
- [ ] Placed file in: `ios/Runner/GoogleService-Info.plist`
- [ ] Verified file location
- [ ] Opened `ios/Runner.xcworkspace` in Xcode
- [ ] Added file to project in Xcode (right-click Runner → Add Files)

### Enable Firebase Services

#### Authentication
- [ ] In Firebase Console → Authentication
- [ ] Click "Get started"
- [ ] Click "Sign-in method" tab
- [ ] Find "Google" provider
- [ ] Click "Google" → Enable toggle → ON
- [ ] Project support email: [Your email]
- [ ] Save

#### Firestore Database
- [ ] In Firebase Console → Firestore Database
- [ ] Click "Create database"
- [ ] Start in: **Production mode**
- [ ] Location: Choose nearest (e.g., us-central1)
- [ ] Click "Enable"
- [ ] Database created (shows "Cloud Firestore" with empty collection)

#### Firebase Storage
- [ ] In Firebase Console → Storage
- [ ] Click "Get started"
- [ ] Start in: **Production mode**
- [ ] Location: Same as Firestore
- [ ] Click "Done"
- [ ] Storage bucket created (shows empty files list)

#### Cloud Messaging (Optional)
- [ ] In Firebase Console → Cloud Messaging
- [ ] Note Server key (for future use)
- [ ] iOS APNs certificate uploaded (if using iOS)

### Update Security Rules

#### Firestore Rules
- [ ] In Firestore → Rules tab
- [ ] Replace with:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```
- [ ] Click "Publish"

#### Storage Rules
- [ ] In Storage → Rules tab
- [ ] Replace with:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```
- [ ] Click "Publish"

---

## 🚀 Build & Run Checklist

### Clean Build
- [ ] Run: `flutter clean`
- [ ] Run: `flutter pub get`
- [ ] No errors shown

### Android Build
- [ ] Device/emulator connected: `flutter devices`
- [ ] Run: `flutter run`
- [ ] App builds successfully
- [ ] App launches on device
- [ ] No red errors in console

### iOS Build (Mac Only)
- [ ] Run: `cd ios && pod install && cd ..`
- [ ] Pods installed successfully
- [ ] Simulator/device connected: `flutter devices`
- [ ] Run: `flutter run`
- [ ] App builds successfully
- [ ] App launches on device/simulator

---

## 🧪 Testing Checklist

### First Launch
- [ ] App opens without crashing
- [ ] Splash screen displays
- [ ] Redirects to login screen
- [ ] UI looks correct (no layout issues)

### Authentication
- [ ] "Sign in with Google" button visible
- [ ] Button responds to tap
- [ ] Google account picker appears
- [ ] Can select Google account
- [ ] Sign-in completes successfully
- [ ] Redirects to home screen
- [ ] User profile icon appears in app bar

### Home Screen
- [ ] Dashboard tab loads
- [ ] Stats cards visible (Total, Applied, Interviews, Drafts)
- [ ] All show "0" initially
- [ ] "All Jobs" tab accessible
- [ ] "Add Job" floating button visible
- [ ] Empty state shows: "No jobs yet"

### Add Job Functionality
- [ ] Tap floating "+" button
- [ ] Job form screen opens
- [ ] All fields visible:
  - [ ] Company Name (required)
  - [ ] Job Title (required)
  - [ ] Source dropdown (works)
  - [ ] Job Description (required)
  - [ ] Application Stage dropdown (works)
- [ ] "Save Job" button visible
- [ ] "Save Draft" button in app bar

### Save First Job
- [ ] Fill in required fields
- [ ] Tap "Save Job"
- [ ] Success message shows
- [ ] Returns to home screen
- [ ] Job appears in list
- [ ] Stats update (Total shows 1)
- [ ] Job card displays correctly

### Job Card Features
- [ ] Job title and company visible
- [ ] Stage badge shows correct color
- [ ] Tap card to open details
- [ ] Detail screen shows all info
- [ ] Back button works

### Filters & Sorting
- [ ] All Jobs tab → Filter chips work
- [ ] Can filter by stage
- [ ] Can sort by different criteria
- [ ] "Clear All" resets filters
- [ ] Drafts toggle works

### Profile Screen
- [ ] Tap profile icon (top-right)
- [ ] Profile screen opens
- [ ] User info displays (photo, name, email)
- [ ] "My Resumes" section visible
- [ ] "Sign Out" button visible

### Sign Out
- [ ] Tap "Sign Out"
- [ ] Returns to login screen
- [ ] Can sign back in

### Offline Mode
- [ ] Turn off internet
- [ ] App still works
- [ ] Can add/edit jobs
- [ ] Turn on internet
- [ ] Data syncs automatically

---

## 🔧 Troubleshooting Checklist

### Build Fails
- [ ] Run: `flutter clean`
- [ ] Run: `flutter pub get`
- [ ] Delete `build` folder
- [ ] Try again: `flutter run`

### Google Sign-In Fails (Android)
- [ ] SHA-1 certificate added to Firebase
- [ ] Package name matches exactly
- [ ] Internet connection active
- [ ] Google Play Services installed on device

### Google Sign-In Fails (iOS)
- [ ] Bundle ID matches Firebase
- [ ] `REVERSED_CLIENT_ID` added to Info.plist
- [ ] URL scheme configured correctly

### Firestore Permission Denied
- [ ] Security rules published
- [ ] User signed in successfully
- [ ] Wait 1-2 minutes after creating database

### App Crashes
- [ ] Check console for error messages
- [ ] Verify all Firebase config files in place
- [ ] Ensure Firebase services enabled
- [ ] Check device logs

### iOS Build Issues
- [ ] Run: `cd ios && pod repo update && pod install && cd ..`
- [ ] Clean Xcode build: Product → Clean Build Folder
- [ ] Try running from Xcode directly

---

## 📱 Platform-Specific Checks

### Android
- [ ] `google-services.json` in correct location
- [ ] Package name consistent everywhere
- [ ] Min SDK version: 21 (in build.gradle.kts)
- [ ] Google Play Services available on device

### iOS
- [ ] `GoogleService-Info.plist` in correct location
- [ ] Bundle ID consistent everywhere
- [ ] Deployment target: iOS 12.0+
- [ ] URL scheme configured in Info.plist

---

## 🎉 Success Criteria

Your app is ready when:
- [ ] ✅ Builds without errors
- [ ] ✅ Google Sign-In works
- [ ] ✅ Can add a job
- [ ] ✅ Job appears in list
- [ ] ✅ Can filter and sort jobs
- [ ] ✅ Stats update correctly
- [ ] ✅ Offline mode works
- [ ] ✅ Can sign out and back in
- [ ] ✅ No crashes or major bugs

---

## 📚 Final Steps

### Git Setup (Optional but Recommended)
- [ ] Initialize git: `git init`
- [ ] Add `.gitignore` (already included)
- [ ] First commit: `git add . && git commit -m "Initial commit"`
- [ ] Create GitHub repo (optional)
- [ ] **NEVER** commit Firebase config files to public repos!

### Documentation
- [ ] Read README.md
- [ ] Review FIREBASE_SETUP.md
- [ ] Check ROADMAP.md for future features
- [ ] Bookmark QUICKSTART.md

### Backups
- [ ] Export Firestore data (Settings → Import/Export)
- [ ] Note Firebase project ID
- [ ] Save API keys securely
- [ ] Backup code to cloud/external drive

---

## 🎊 You're Done!

If all checkboxes are marked, congratulations! 🎉

Your Job Tracker app is:
- ✅ Fully configured
- ✅ Running smoothly
- ✅ Ready for use
- ✅ Prepared for Phase 2 (AI features)

### What's Next?

1. **Start Using the App**
   - Add your real job applications
   - Set deadlines
   - Upload resumes
   - Track your progress

2. **Customize**
   - Adjust colors in `app_theme.dart`
   - Add more job sources
   - Customize notifications

3. **Phase 2 Preparation**
   - Review ROADMAP.md
   - Choose AI provider (Gemini recommended)
   - Get API keys when ready

---

## 🆘 Still Having Issues?

### Quick Fixes
1. `flutter doctor` - Check for issues
2. `flutter clean` - Clean build
3. Restart IDE
4. Restart device/emulator
5. Check Firebase Console for service status

### Common Issues
- **Build errors**: Missing dependencies
  - Fix: `flutter pub get`
  
- **Sign-in fails**: Firebase config
  - Fix: Verify SHA-1 (Android) or Bundle ID (iOS)
  
- **Data not saving**: Firestore rules
  - Fix: Check security rules in Firebase Console
  
- **Offline not working**: Settings
  - Fix: Verify persistence enabled in code

### Resources
- Flutter Docs: https://flutter.dev/docs
- Firebase Docs: https://firebase.google.com/docs
- GitHub Issues: Create issue in repo

---

**Happy Job Hunting! 🚀**

Made with ❤️ using Flutter
