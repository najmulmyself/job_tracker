# 📋 Job Tracker - Quick Reference Guide

## 🎯 Essential Commands

### Setup & Installation
```bash
# Get dependencies
flutter pub get

# Clean build
flutter clean

# Check for issues
flutter doctor

# List connected devices
flutter devices
```

### Running the App
```bash
# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with hot reload
flutter run --hot

# Run in release mode
flutter run --release
```

### Building
```bash
# Build Android APK
flutter build apk

# Build Android App Bundle
flutter build appbundle

# Build iOS (Mac only)
flutter build ios

# Build for web
flutter build web
```

---

## 📁 Important File Locations

### Configuration Files
```
android/app/google-services.json          # Android Firebase config
ios/Runner/GoogleService-Info.plist       # iOS Firebase config
pubspec.yaml                               # Dependencies
lib/main.dart                              # App entry point
```

### Key Directories
```
lib/models/          # Data models
lib/screens/         # UI screens
lib/widgets/         # Reusable UI components
lib/providers/       # State management
lib/services/        # Business logic
lib/utils/           # Helper functions
```

---

## 🎨 Color Codes (Stage Indicators)

```dart
Interested:  #9C27B0  (Purple)
Applied:     #2196F3  (Blue)
Interview:   #FF9800  (Orange)
Offer:       #4CAF50  (Green)
Rejected:    #F44336  (Red)
```

---

## 🔥 Firebase Console URLs

### Main Console
https://console.firebase.google.com/

### Specific Services
- Authentication: `/project/YOUR_PROJECT/authentication/users`
- Firestore: `/project/YOUR_PROJECT/firestore`
- Storage: `/project/YOUR_PROJECT/storage`
- Settings: `/project/YOUR_PROJECT/settings/general`

---

## 📊 Database Structure Quick Reference

```
users/{userId}
  ├── uid: string
  ├── email: string
  ├── displayName: string
  ├── photoUrl: string?
  ├── defaultResumeId: string?
  ├── createdAt: timestamp
  └── updatedAt: timestamp

users/{userId}/jobs/{jobId}
  ├── id: string
  ├── userId: string
  ├── companyName: string
  ├── jobTitle: string
  ├── source: enum
  ├── salaryRange: string?
  ├── expectedSalary: string?
  ├── jobDescription: string
  ├── stage: enum
  ├── applicationDate: timestamp?
  ├── deadline: timestamp?
  ├── resumeId: string?
  ├── notes: string
  ├── isDraft: boolean
  ├── createdAt: timestamp
  └── updatedAt: timestamp

users/{userId}/resumes/{resumeId}
  ├── id: string
  ├── userId: string
  ├── name: string
  ├── fileUrl: string
  ├── fileName: string
  ├── fileSizeBytes: number
  ├── isDefault: boolean
  ├── uploadedAt: timestamp
  └── updatedAt: timestamp
```

---

## 🛠️ Common Tasks

### Add a New Screen
1. Create file in `lib/screens/`
2. Create widget class extending `StatelessWidget` or `StatefulWidget`
3. Add route in navigation
4. Update imports

### Add a New Model
1. Create file in `lib/models/`
2. Define class with fields
3. Add `fromJson` factory constructor
4. Add `toJson` method
5. Add `copyWith` method

### Add a New Provider
1. Create file in `lib/providers/`
2. Extend `ChangeNotifier`
3. Add state variables
4. Add methods
5. Call `notifyListeners()` on changes
6. Register in `main.dart` MultiProvider

### Add a New Service
1. Create file in `lib/services/`
2. Create class with methods
3. Implement business logic
4. Use in providers

---

## 🔐 Security Rules Templates

### Firestore Rules (Production)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }
    
    match /users/{userId} {
      allow read, write: if isOwner(userId);
      
      match /jobs/{jobId} {
        allow read, write: if isOwner(userId);
        
        match /coverLetters/{letterId} {
          allow read, write: if isOwner(userId);
        }
      }
      
      match /resumes/{resumeId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

### Storage Rules (Production)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null 
                         && request.auth.uid == userId
                         && request.resource.size < 10 * 1024 * 1024; // 10MB limit
    }
  }
}
```

---

## 📱 Testing Checklist

### Quick Test Flow
1. ✅ Launch app → Splash screen
2. ✅ Login → Google Sign-In
3. ✅ Home → Dashboard displays
4. ✅ Add Job → Form opens
5. ✅ Fill & Save → Job appears in list
6. ✅ Filter → Filters work
7. ✅ Detail → Opens job details
8. ✅ Profile → Shows user info
9. ✅ Sign Out → Returns to login

---

## 🐛 Debugging Tips

### View Logs
```bash
# Android
flutter logs

# iOS (Mac only)
flutter logs -d <ios-device-id>
```

### Debug in VS Code
1. Press F5 or Run → Start Debugging
2. Set breakpoints in code
3. Use Debug Console

### Print Debugging
```dart
print('Debug message: $variable');
debugPrint('Debug: $data');
```

### Check Firebase Status
```dart
// In code
FirebaseFirestore.instance.settings.persistenceEnabled
print('Firebase initialized: ${Firebase.apps.isNotEmpty}');
```

---

## 🎯 Performance Tips

### Optimize Firestore Queries
```dart
// Use .limit() for large collections
.limit(20)

// Use indexes for complex queries
// (Firebase will prompt in console)

// Use .where() before .orderBy()
.where('stage', isEqualTo: stage)
.orderBy('updatedAt', descending: true)
```

### Optimize Images
```dart
// Use cached network images
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### Lazy Loading Lists
```dart
// Use ListView.builder instead of ListView
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(items[index]);
  },
)
```

---

## 📦 Useful Packages (Future)

### UI Enhancements
```yaml
flutter_animate: ^4.5.0        # Easy animations
shimmer: ^3.0.0                # Loading shimmer effect
cached_network_image: ^3.3.1   # Image caching
```

### Utilities
```yaml
connectivity_plus: ^5.0.2      # Check internet
share_plus: ^7.2.2             # Share functionality
url_launcher: ^6.2.4           # Open URLs
```

### Analytics
```yaml
firebase_analytics: ^10.8.9    # Google Analytics
sentry_flutter: ^7.18.0        # Error tracking
```

---

## 🔄 Update Checklist

### Minor Updates
1. Update version in `pubspec.yaml`
2. Update dependencies
3. Test thoroughly
4. Build and deploy

### Major Updates
1. Review breaking changes
2. Update dependencies one by one
3. Fix deprecated APIs
4. Run `flutter pub outdated`
5. Test all features
6. Update documentation

---

## 🌐 Deployment Checklist

### Android (Google Play)
- [ ] Update `android/app/build.gradle.kts` version
- [ ] Generate release APK: `flutter build apk --release`
- [ ] OR generate App Bundle: `flutter build appbundle`
- [ ] Test on real device
- [ ] Upload to Play Console
- [ ] Fill store listing
- [ ] Submit for review

### iOS (App Store)
- [ ] Update `ios/Runner/Info.plist` version
- [ ] Open Xcode workspace
- [ ] Archive for release
- [ ] Upload to App Store Connect
- [ ] Fill store listing
- [ ] Submit for review

---

## 📞 Quick Links

| Resource | URL |
|----------|-----|
| Flutter Docs | https://flutter.dev/docs |
| Firebase Console | https://console.firebase.google.com |
| Pub.dev (Packages) | https://pub.dev |
| Flutter Packages | https://pub.dev/flutter |
| Material Icons | https://fonts.google.com/icons |
| Dart API | https://api.dart.dev |

---

## 💡 Pro Tips

1. **Use Hot Reload**: Press `r` in terminal for hot reload
2. **Use Hot Restart**: Press `R` in terminal for hot restart
3. **Format Code**: `dart format lib/` or use IDE formatter
4. **Analyze Code**: `dart analyze` to find issues
5. **Test on Real Devices**: Emulators don't catch everything
6. **Use Version Control**: Commit often with clear messages
7. **Read Error Messages**: They usually tell you what's wrong
8. **Check Logs**: Most issues show up in logs
9. **Update Regularly**: Keep Flutter and packages up to date
10. **Backup Firebase**: Export data regularly

---

## 🎓 Learning Resources

### Official
- Flutter Codelabs: https://flutter.dev/codelabs
- Flutter YouTube: https://www.youtube.com/flutterdev
- Firebase YouTube: https://www.youtube.com/Firebase

### Community
- r/FlutterDev: https://reddit.com/r/FlutterDev
- Flutter Community: https://flutter.dev/community
- Stack Overflow: Tag `flutter`

---

## ⚡ Keyboard Shortcuts

### VS Code
| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + Space` | Show suggestions |
| `F5` | Start debugging |
| `Shift + F5` | Stop debugging |
| `Cmd/Ctrl + Shift + P` | Command palette |
| `Cmd/Ctrl + .` | Quick fix |
| `Alt + Shift + F` | Format document |

### Flutter DevTools
| Shortcut | Action |
|----------|--------|
| `r` | Hot reload |
| `R` | Hot restart |
| `h` | Help |
| `q` | Quit |
| `p` | Toggle performance overlay |

---

**Keep this guide handy for quick reference! 📚**
