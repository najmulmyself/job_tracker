# 🔥 Firestore Database Setup - REQUIRED!

## ⚠️ Current Issue

The app is trying to access Firestore but the database hasn't been created yet.

Error: `[cloud_firestore/unavailable] The service is currently unavailable`

## ✅ Solution - Create Firestore Database (2 minutes)

### Step 1: Create Firestore Database

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your **Job Tracker** project
3. In the left sidebar, click **"Firestore Database"**
4. Click **"Create database"** button

### Step 2: Choose Security Rules Mode

You'll see two options:

**Option 1: Production Mode (Recommended for now)**

- Select **"Start in production mode"**
- Click **"Next"**

**Why?** We'll add proper security rules in the next step.

### Step 3: Choose Location

1. Select a location closest to your users

   - **Recommended:** `us-central1` (Iowa) - Good for North America
   - **Asia:** `asia-southeast1` (Singapore)
   - **Europe:** `europe-west1` (Belgium)

   ⚠️ **Important:** Location cannot be changed later!

2. Click **"Enable"**

3. Wait 30-60 seconds for database creation ⏳

### Step 4: Update Security Rules

After database is created:

1. Click the **"Rules"** tab
2. Replace the rules with this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user owns the data
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

### Step 5: Enable Firebase Storage (Optional but Recommended)

For resume uploads:

1. In left sidebar, click **"Storage"**
2. Click **"Get started"**
3. Select **"Start in production mode"**
4. Choose **same location** as Firestore
5. Click **"Done"**

#### Update Storage Rules:

1. Click **"Rules"** tab
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

## 🧪 Test the App

After setting up Firestore:

1. **Hot restart** the app (press `R` in terminal)
   OR close and relaunch
2. Try signing in with Google again

3. You should see:
   - ✅ Sign-in succeeds
   - ✅ No Firestore errors
   - ✅ Home screen loads

## 🔍 Verify Firestore is Working

After signing in:

1. Go back to Firebase Console
2. Click **"Firestore Database"**
3. You should see a `users` collection with your user document

## 📊 What Data Gets Stored?

### In Firestore:

```
users/{userId}
  - uid: string
  - email: string
  - displayName: string
  - photoUrl: string
  - defaultResumeId: string
  - createdAt: timestamp
  - updatedAt: timestamp

users/{userId}/jobs/{jobId}
  - All job application data

users/{userId}/resumes/{resumeId}
  - Resume metadata
```

### In Storage:

```
users/{userId}/resumes/
  - resume_file_1.pdf
  - resume_file_2.pdf
```

## 🔧 Troubleshooting

### Error: "Missing or insufficient permissions"

**Solution:** Check security rules are published correctly

1. Go to Firestore → Rules
2. Make sure rules allow authenticated users
3. Click "Publish" again

### Error: "PERMISSION_DENIED"

**Solution:**

1. Make sure you're signed in
2. Check security rules have `request.auth != null`
3. Try signing out and back in

### Error: "Firestore unavailable"

**Solutions:**

1. **Wait 1-2 minutes** - Database might still be initializing
2. Check your internet connection
3. Verify Firestore is enabled in Firebase Console
4. Try hot restart: Press `R` in terminal

### App still crashes

1. Stop the app completely
2. Run:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## ✅ Success Checklist

- [ ] Firestore Database created
- [ ] Location selected (can't change later!)
- [ ] Security rules published
- [ ] Firebase Storage enabled (optional)
- [ ] Storage rules published (optional)
- [ ] App hot restarted
- [ ] Sign in works without errors
- [ ] User document appears in Firestore

## 📈 What's Next?

Once Firestore is set up:

1. ✅ Add your first job application
2. ✅ Upload a resume
3. ✅ Set deadlines
4. ✅ Track your applications

All data will automatically sync to Firestore! 🎉

---

## 🆘 Still Having Issues?

### Quick Checklist:

1. ✅ Firebase project created
2. ✅ Android app added with SHA-1
3. ✅ google-services.json downloaded and placed correctly
4. ✅ Firestore database created
5. ✅ Security rules published
6. ✅ Google Sign-In enabled in Authentication

If all checked but still not working:

- Check Firebase Console status page
- Verify billing is enabled (free tier is fine)
- Try creating a new test document manually in Firestore
- Check device internet connection

---

**Set up Firestore now to get your Job Tracker fully functional!** 🚀
