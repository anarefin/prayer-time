# Firebase Setup Guide

Complete step-by-step guide to configure Firebase for the Prayer Time app.

## Table of Contents
1. [Create Firebase Project](#create-firebase-project)
2. [Android Configuration](#android-configuration)
3. [iOS Configuration](#ios-configuration)
4. [Firestore Database Setup](#firestore-database-setup)
5. [Security Rules](#security-rules)
6. [Authentication Setup](#authentication-setup)
7. [Cloud Messaging (Optional)](#cloud-messaging-optional)
8. [Testing Connection](#testing-connection)

## Create Firebase Project

### Step 1: Create Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `prayer-time-app` (or your preferred name)
4. Click "Continue"
5. (Optional) Enable Google Analytics
6. Click "Create project"
7. Wait for project creation (1-2 minutes)
8. Click "Continue" when ready

## Android Configuration

### Step 1: Register Android App
1. In Firebase Console, click the Android icon
2. Enter package name: `com.prayertime.prayer_time`
   - **IMPORTANT**: This must match your `android/app/build.gradle.kts` package name
3. (Optional) Enter app nickname: `Prayer Time Android`
4. (Optional) Enter SHA-1 for debug signing
5. Click "Register app"

### Step 2: Download Config File
1. Download `google-services.json`
2. Move it to `android/app/` directory
   ```bash
   mv ~/Downloads/google-services.json android/app/
   ```

### Step 3: Verify Build Configuration
The project is already configured, but verify these files:

**android/build.gradle.kts** should have:
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.4.0")
}
```

**android/app/build.gradle.kts** should have:
```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

### Step 4: Skip SDK Installation
Click "Next" through SDK installation steps (already handled by Flutter)

## iOS Configuration

### Step 1: Register iOS App
1. In Firebase Console, click the iOS icon
2. Enter bundle ID: `com.prayertime.prayerTime`
   - **IMPORTANT**: This must match your Xcode project bundle identifier
3. (Optional) Enter app nickname: `Prayer Time iOS`
4. (Optional) Enter App Store ID
5. Click "Register app"

### Step 2: Download Config File
1. Download `GoogleService-Info.plist`
2. Open Xcode project: `ios/Runner.xcworkspace`
3. Drag `GoogleService-Info.plist` into the Runner folder
4. Ensure "Copy items if needed" is checked
5. Click "Finish"

### Step 3: Skip SDK Installation
Click "Next" through SDK installation steps (already handled by Flutter)

## Firestore Database Setup

### Step 1: Create Database
1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Select "Start in production mode" (we'll add custom rules)
4. Choose database location (closest to your users)
5. Click "Enable"

### Step 2: Create Collections
Create these collections (they'll be auto-created by the app, but you can create them manually):
- `areas`
- `mosques`
- `prayer_times`
- `users`

### Step 3: Add Sample Data (Optional)
You can manually add sample data or use the admin panel after setup.

**Example Area Document:**
```json
{
  "name": "Kuala Lumpur",
  "order": 1
}
```

**Example Mosque Document:**
```json
{
  "name": "Masjid Jamek",
  "address": "Jalan Tun Perak, 50050 Kuala Lumpur",
  "areaId": "YOUR_AREA_ID",
  "latitude": 3.148460,
  "longitude": 101.694755
}
```

## Security Rules

### Step 1: Deploy Security Rules
1. Go to Firestore Database → Rules
2. Replace default rules with the content from `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    match /areas/{areaId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    match /mosques/{mosqueId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    match /prayer_times/{prayerTimeId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    match /users/{userId} {
      allow read: if isOwner(userId) || isAdmin();
      allow create: if isAuthenticated() && isOwner(userId);
      allow update: if isOwner(userId);
      allow delete: if isOwner(userId) || isAdmin();
    }
  }
}
```

3. Click "Publish"

### Step 2: Test Rules (Optional)
Use the Rules Playground in Firebase Console to test your security rules.

## Authentication Setup

### Step 1: Enable Email/Password Authentication
1. Go to Authentication → Sign-in method
2. Click "Email/Password"
3. Enable the first toggle (Email/Password)
4. Click "Save"

### Step 2: Create Admin User
**Option A: Through App (Recommended)**
1. Run the app
2. Register a new user
3. Go to Firebase Console → Firestore → users collection
4. Find the user document
5. Click Edit
6. Change `role` field from `"user"` to `"admin"`
7. Click "Update"

**Option B: Manually in Firebase**
1. Go to Authentication → Users
2. Click "Add user"
3. Enter email and password
4. Click "Add user"
5. Copy the User UID
6. Go to Firestore Database → users collection
7. Add document with document ID = User UID
8. Add fields:
   ```
   email: "admin@example.com"
   role: "admin"
   favorites: []
   ```
9. Click "Save"

## Cloud Messaging (Optional)

If you want push notifications (not just local notifications):

### Android
1. Go to Project Settings → Cloud Messaging
2. Note the Server Key
3. (Optional) Configure for advanced features

### iOS
1. Upload APNs authentication key or certificate
2. Enter Team ID and Key ID
3. Click "Upload"

## Testing Connection

### Step 1: Run the App
```bash
flutter run
```

### Step 2: Check Logs
Look for successful Firebase initialization:
```
✓ Firebase initialization successful
✓ Firestore connected
```

### Step 3: Test Authentication
1. Try to register a new user
2. Check Firebase Console → Authentication → Users
3. Verify user appears in the list

### Step 4: Test Firestore
1. Try to view areas/mosques (should work)
2. Try to add data without admin (should fail)
3. Login as admin user
4. Try to add an area (should succeed)
5. Check Firebase Console → Firestore
6. Verify data appears

## Troubleshooting

### Common Issues

**1. "Firebase not initialized"**
- Ensure `google-services.json` is in `android/app/`
- Ensure `GoogleService-Info.plist` is in `ios/Runner/`
- Clean and rebuild: `flutter clean && flutter pub get`

**2. "Permission denied" errors**
- Check Firestore security rules
- Verify user has correct role
- Check user is authenticated

**3. Android build fails**
- Verify package name matches in all files
- Check `google-services.json` is correct
- Try `cd android && ./gradlew clean`

**4. iOS build fails**
- Open Xcode and check for errors
- Verify bundle identifier matches
- Clean build folder in Xcode: Product → Clean Build Folder

**5. "Cannot connect to Firestore"**
- Check internet connection
- Verify Firestore is enabled in Firebase Console
- Check security rules allow read access

## Next Steps

After Firebase setup:
1. ✅ Run the app and test basic functionality
2. ✅ Create an admin user
3. ✅ Populate some initial data
4. ✅ Test admin and user flows
5. ✅ See [TESTING_GUIDE.md](TESTING_GUIDE.md) for comprehensive testing

## Additional Resources

- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)

