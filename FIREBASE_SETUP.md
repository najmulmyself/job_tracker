# Firebase Configuration Instructions

## 🔥 Setting Up Firebase for Job Tracker

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select existing project
3. Enter project name (e.g., "Job Tracker")
4. Enable Google Analytics (optional)
5. Click "Create project"

### Step 2: Add Android App

1. In Firebase Console, click the Android icon
2. Register app:
   - **Android package name**: `com.example.job_tracker` (or your package name from `android/app/build.gradle.kts`)
   - **App nickname**: Job Tracker (optional)
   - **Debug signing certificate SHA-1**: Get it using:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
3. Click "Register app"
4. Download `google-services.json`
5. Place the file in: `android/app/google-services.json`

### Step 3: Add iOS App

1. In Firebase Console, click the iOS icon
2. Register app:
   - **iOS bundle ID**: `com.example.jobTracker` (from `ios/Runner/Info.plist`)
   - **App nickname**: Job Tracker (optional)
   - **App Store ID**: Leave blank for now
3. Click "Register app"
4. Download `GoogleService-Info.plist`
5. Place the file in: `ios/Runner/GoogleService-Info.plist`
6. Open `ios/Runner.xcworkspace` in Xcode
7. Right-click on Runner → Add Files to "Runner"
8. Select `GoogleService-Info.plist` and make sure "Copy items if needed" is checked

### Step 4: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable **Google Sign-In**:
   - Click on "Google" provider
   - Enable the toggle
   - Select a support email
   - Click "Save"

### Step 5: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Select **Production mode**
4. Choose a location (select closest to your users)
5. Click "Enable"

6. **Security Rules** (Update after setup):
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
         
         match /jobs/{jobId} {
           allow read, write: if request.auth != null && request.auth.uid == userId;
           
           match /coverLetters/{letterId} {
             allow read, write: if request.auth != null && request.auth.uid == userId;
           }
         }
         
         match /resumes/{resumeId} {
           allow read, write: if request.auth != null && request.auth.uid == userId;
         }
       }
     }
   }
   ```

### Step 6: Enable Firebase Storage

1. In Firebase Console, go to **Storage**
2. Click "Get started"
3. Start in **Production mode**
4. Choose same location as Firestore
5. Click "Done"

6. **Security Rules** (Update after setup):
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

### Step 7: Enable Cloud Messaging (Optional)

1. In Firebase Console, go to **Cloud Messaging**
2. Note your **Server Key** and **Sender ID**
3. For iOS, upload your APNs certificate

### Step 8: Update Android Configuration

1. Open `android/app/build.gradle.kts`
2. Verify the package name matches Firebase
3. Ensure Google Services plugin is applied

### Step 9: Update iOS Configuration

1. Open `ios/Runner/Info.plist`
2. Add URL Scheme for Google Sign-In:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
         <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
       </array>
     </dict>
   </array>
   ```

3. Get `REVERSED_CLIENT_ID` from `GoogleService-Info.plist`

### Step 10: Verify Installation

Run these commands to verify setup:

```bash
# Get dependencies
flutter pub get

# Clean build
flutter clean

# Run on device
flutter run
```

## ⚠️ Important Notes

1. **Never commit Firebase config files to public repositories**
   - Add to `.gitignore`:
     ```
     # Firebase
     android/app/google-services.json
     ios/Runner/GoogleService-Info.plist
     ```

2. **For production**, update security rules to be more restrictive

3. **Enable App Check** for additional security in production

4. **Set up Firebase budget alerts** to avoid unexpected costs

5. **Enable Firebase crashlytics** for error tracking (optional)

## 🔧 Troubleshooting

### Android Issues:
- **SHA-1 certificate error**: Make sure you added the correct SHA-1 to Firebase
- **Build fails**: Run `flutter clean` and rebuild
- **Google Sign-In fails**: Check package name matches in all places

### iOS Issues:
- **Sign-In fails**: Verify `REVERSED_CLIENT_ID` is correct in Info.plist
- **Build fails in Xcode**: Run `pod install` in `ios/` directory
- **CocoaPods issues**: Run `pod repo update`

### General Issues:
- **Offline mode not working**: Check Firestore persistence settings
- **Notifications not working**: Verify permissions are requested and granted

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Google Sign-In Setup](https://firebase.google.com/docs/auth/flutter/federated-auth)

## ✅ Checklist

- [ ] Firebase project created
- [ ] Android app added to Firebase
- [ ] iOS app added to Firebase
- [ ] `google-services.json` placed in correct location
- [ ] `GoogleService-Info.plist` placed in correct location
- [ ] Google Sign-In enabled in Firebase Console
- [ ] Firestore database created
- [ ] Firebase Storage enabled
- [ ] Security rules updated
- [ ] App tested on both Android and iOS
- [ ] Offline persistence working
- [ ] Notifications working

---

Need help? Check the [Firebase Console](https://console.firebase.google.com/) or Flutter documentation.
