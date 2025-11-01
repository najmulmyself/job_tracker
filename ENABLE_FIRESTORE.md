# 🔥 Enable Firestore Database - REQUIRED!

## ⚠️ Current Error
```
Cloud Firestore API has not been used in project job-tracker-9389f before or it is disabled.
```

## ✅ Solution: Enable Firestore (2 minutes)

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **job-tracker-9389f**

### Step 2: Enable Firestore Database
1. In the left sidebar, click **"Firestore Database"**
2. Click **"Create database"** button

### Step 3: Choose Security Mode
1. Select **"Start in production mode"** (recommended)
   - We have security rules set up in the code
2. Or select **"Start in test mode"** (for development only)
   - Anyone can read/write for 30 days
   - ⚠️ Remember to update rules later!

### Step 4: Choose Location
1. Select a location close to you:
   - **us-central1** (Iowa) - Good for North America
   - **us-east1** (South Carolina)
   - **europe-west1** (Belgium) - Good for Europe
   - **asia-south1** (Mumbai) - Good for Asia
2. Click **"Enable"**
3. Wait 1-2 minutes for database creation

### Step 5: Set Security Rules (IMPORTANT!)

Once database is created:

1. Click on the **"Rules"** tab
2. Replace the content with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }
    
    // User documents
    match /users/{userId} {
      allow read, write: if isOwner(userId);
      
      // Job applications
      match /jobs/{jobId} {
        allow read, write: if isOwner(userId);
        
        // Cover letters
        match /coverLetters/{letterId} {
          allow read, write: if isOwner(userId);
        }
      }
      
      // Resumes
      match /resumes/{resumeId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

3. Click **"Publish"**

### Step 6: Enable Firebase Storage (While You're Here!)

1. In the left sidebar, click **"Storage"**
2. Click **"Get started"**
3. Select **"Start in production mode"**
4. Use the **same location** as Firestore
5. Click **"Done"**

#### Set Storage Rules:

1. Click on the **"Rules"** tab in Storage
2. Replace with:

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

3. Click **"Publish"**

### Step 7: Restart Your App

After enabling Firestore:

```bash
# Stop the app (in terminal press Ctrl+C or 'q')
# Then run again:
flutter run
```

Or just:
- Press `R` in terminal for hot restart
- Or restart from your IDE

## ✅ How to Verify It's Working

1. Launch the app
2. Sign in with Google
3. You should see the home screen ✅
4. No more Firestore errors ✅

In Firebase Console:
1. Go to **Firestore Database**
2. You should see a new collection: **users**
3. Inside, you'll see your user document with your UID

## 🔍 Troubleshooting

### Still getting errors?

1. **Wait 2-3 minutes** after enabling Firestore
   - Changes take time to propagate

2. **Check if Firestore is really enabled:**
   - Firebase Console → Firestore Database
   - Should show the database, not a "Create database" button

3. **Verify security rules are published:**
   - Firestore → Rules tab
   - Check "Last deployed" timestamp

4. **Clear app data and try again:**
   - Uninstall the app
   - Run `flutter clean`
   - Run `flutter run`

5. **Check internet connection:**
   - Firestore requires internet to work

## 📊 What Happens Next

Once Firestore is enabled:
- User profile saved automatically ✅
- Can add job applications ✅
- Data syncs across devices ✅
- Offline mode works ✅

## 💰 Cost

- **Free tier**: 50,000 reads/day, 20,000 writes/day
- **Storage**: 1GB free
- More than enough for personal use!

---

## 🎯 Quick Checklist

- [ ] Go to Firebase Console
- [ ] Click "Firestore Database"
- [ ] Click "Create database"
- [ ] Choose production mode
- [ ] Select location
- [ ] Click "Enable"
- [ ] Set security rules (copy from above)
- [ ] Publish rules
- [ ] Enable Storage (optional but recommended)
- [ ] Restart app
- [ ] Sign in with Google
- [ ] Success! 🎉

---

**Enable Firestore now to continue using the app!**

Your project ID: **job-tracker-9389f**
