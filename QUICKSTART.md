# Job Tracker - Quick Start Guide

## 🎉 Welcome to Job Tracker!

This guide will help you get your app running in 10 minutes.

## ✅ Prerequisites Checklist

Before starting, make sure you have:
- [ ] Flutter installed (run `flutter doctor`)
- [ ] Android Studio or Xcode installed
- [ ] A Google account for Firebase
- [ ] A device or emulator ready

## 🚀 5-Minute Setup

### Step 1: Get the Code (30 seconds)
```bash
cd job_tracker
flutter pub get
```

### Step 2: Create Firebase Project (2 minutes)

1. Go to https://console.firebase.google.com/
2. Click "Create a project"
3. Name it "Job Tracker"
4. Disable Google Analytics (optional)
5. Click "Create project"

### Step 3: Add Android App (2 minutes)

1. Click Android icon in Firebase Console
2. Package name: `com.example.job_tracker`
3. Download `google-services.json`
4. Copy to: `android/app/google-services.json`

### Step 4: Add iOS App (2 minutes)

1. Click iOS icon in Firebase Console
2. Bundle ID: `com.example.jobTracker`
3. Download `GoogleService-Info.plist`
4. Copy to: `ios/Runner/GoogleService-Info.plist`

### Step 5: Enable Services (2 minutes)

In Firebase Console:

**Authentication:**
1. Go to Authentication → Sign-in method
2. Enable "Google"
3. Add your email as support email
4. Save

**Firestore:**
1. Go to Firestore Database
2. Create database → Production mode
3. Choose location (us-central1 recommended)
4. Create

**Storage:**
1. Go to Storage
2. Get started → Production mode
3. Done

### Step 6: Run the App! (1 minute)

```bash
flutter run
```

That's it! 🎉

## 📱 First Time Usage

### 1. Sign In
- Tap "Sign in with Google"
- Choose your Google account
- Allow permissions

### 2. Add Your First Job
- Tap the floating "+" button
- Fill in:
  - Company name (e.g., "Google")
  - Job title (e.g., "Software Engineer")
  - Job description (paste the JD)
- Tap "Save Job"

### 3. Track Your Applications
- View all jobs in the "All Jobs" tab
- Filter by stage
- Sort by deadline
- Update stages as you progress

### 4. Upload Resume
- Go to Profile (top-right icon)
- Tap "Upload Resume"
- Select PDF file
- Set as default

## 🎯 Key Features to Try

### Dashboard Stats
- See total applications, interviews, drafts
- Quick access to recent applications

### Smart Filters
- Filter by: Interested, Applied, Interview, Offer, Rejected
- Sort by: Date, Deadline, Company
- View drafts only

### Deadline Reminders
- Set deadlines for applications
- Get notified 24 hours before
- Never miss a deadline!

### Drafts Auto-Save
- Start filling a form
- Exit anytime - it's saved as draft
- Resume later from Dashboard

## 🔧 Troubleshooting

### "Sign in failed"
- Make sure you enabled Google Sign-In in Firebase Console
- Check your internet connection
- For Android: Add SHA-1 certificate to Firebase

### "Permission denied" in Firestore
- Wait 1-2 minutes after creating database
- Try signing out and back in

### App won't build
```bash
flutter clean
flutter pub get
flutter run
```

### iOS build issues
```bash
cd ios
pod install
cd ..
flutter run
```

## 📚 Next Steps

Once you're comfortable with the basics:

1. **Customize your profile**
   - Upload multiple resume variants
   - Set a default resume

2. **Use advanced filters**
   - Combine filters for powerful searches
   - Save filter combinations

3. **Track deadlines**
   - Set realistic deadlines
   - Enable notifications

4. **Prepare for Phase 2**
   - Check ROADMAP.md for AI features
   - Get ready for AI-powered cover letters!

## 💡 Pro Tips

### Efficient Job Tracking
1. Add jobs immediately when you find them
2. Use "Interested" stage for jobs you're researching
3. Move to "Applied" when you submit
4. Add interview dates in notes
5. Update stages promptly

### Organization
1. Use consistent company names
2. Add salary info for later comparison
3. Use notes for follow-up tasks
4. Tag resume variants clearly

### Notifications
1. Enable all permissions for notifications
2. Set deadlines as soon as you know them
3. Check drafts daily

## 🆘 Getting Help

### Common Questions

**Q: Can I use this offline?**
A: Yes! Data syncs when you're back online.

**Q: Is my data secure?**
A: Yes, Firebase security rules ensure only you can access your data.

**Q: Can I export my data?**
A: PDF export coming in future update.

**Q: How much does it cost?**
A: Free! Firebase free tier is more than enough.

### Resources

- Full documentation: README.md
- Firebase setup: FIREBASE_SETUP.md
- Future features: ROADMAP.md

### Need More Help?

- Check error messages carefully
- Run `flutter doctor` for system issues
- Ensure Firebase is properly configured
- Try the troubleshooting steps above

## 🎊 You're All Set!

Start tracking your job applications and land your dream job! 🚀

---

**Made with ❤️ using Flutter**

Happy job hunting! 🎯
