# 🔥 Firebase Projects Summary

## Your Firebase Configuration

### DEV Environment

- **Project ID:** `job-tracker-dev-79ca2`
- **Project Name:** Job Tracker DEV
- **Config File:** `lib/firebase_options_dev.dart`
- **Android Package:** `com.example.job_tracker` (+ `.dev` suffix = `com.example.job_tracker.dev`)
- **iOS Bundle ID:** `com.example.jobTracker` (+ `.dev` suffix = `com.example.jobTracker.dev`)
- **Use Case:** Testing, development, breaking things safely

### PROD Environment

- **Project ID:** `job-tracker-9389f`
- **Project Name:** Job Tracker
- **Config File:** `lib/firebase_options.dart`
- **Android Package:** `com.example.job_tracker`
- **iOS Bundle ID:** `com.example.jobTracker`
- **Use Case:** Real job applications, production data

## Quick Commands

### Run DEV

```bash
./run_dev.sh
# OR
flutter run --flavor dev -t lib/main_dev.dart
```

### Run PROD

```bash
./run_prod.sh
# OR
flutter run --flavor prod -t lib/main_prod.dart
```

## Next Steps

### For DEV Project (job-tracker-dev-79ca2)

1. ✅ Firebase options generated
2. ✅ Apps registered (Android + iOS)
3. 📋 Download configs:
   - Android: `google-services.json` → `android/app/src/dev/`
   - iOS: `GoogleService-Info.plist` → rename to `GoogleService-Info-dev.plist`
4. 📋 Enable services:
   - Authentication (Google Sign-In)
   - Firestore Database (test mode)
   - Storage

### For PROD Project (job-tracker-9389f)

1. ✅ Firebase options generated
2. ✅ Apps registered (Android + iOS)
3. 📋 Download configs:
   - Android: `google-services.json` → `android/app/src/prod/`
   - iOS: `GoogleService-Info.plist` → rename to `GoogleService-Info-prod.plist`
4. 📋 Enable services (if not already done):
   - Authentication (Google Sign-In)
   - Firestore Database (production mode)
   - Storage

## Firebase Console Links

**DEV:** https://console.firebase.google.com/project/job-tracker-dev-79ca2  
**PROD:** https://console.firebase.google.com/project/job-tracker-9389f

## Data Isolation

| Feature    | DEV           | PROD          |
| ---------- | ------------- | ------------- |
| Firestore  | Separate DB   | Separate DB   |
| Auth Users | Test accounts | Real accounts |
| Storage    | Test files    | Real files    |
| Analytics  | Separate      | Separate      |

✅ **Complete isolation** - Your DEV and PROD data will never mix!

## App Installation

Both apps can be installed on the same device:

- **DEV:** Shows as "Job Tracker DEV" with debug banner
- **PROD:** Shows as "Job Tracker" without debug banner

## Security Reminder

🔒 Both `firebase_options.dart` and `firebase_options_dev.dart` are in `.gitignore`  
🔒 Download config files from Firebase Console (don't share them publicly)  
🔒 Set proper Firestore security rules for PROD
