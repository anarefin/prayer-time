# Bangladesh Data Seeding Guide

## Problem: Firestore Permission Denied

If you see the error `[cloud_firestore/permission-denied]`, it means:
1. Firestore security rules haven't been deployed yet
2. The app can't read the districts collection

## Solution: Deploy Rules and Seed Data

### Step 1: Deploy Firestore Security Rules

```bash
cd /Users/ahmadnaqibularefin/Cursors/prayer-time

# Deploy the security rules to Firebase
firebase deploy --only firestore:rules
```

This will upload your `firestore.rules` file which allows public read access to districts.

### Step 2: Seed Districts and Areas

**Option A: Using Node.js Script (Recommended)**

```bash
# Install dependencies if not already installed
npm install

# Run the seeding script
node seed-bangladesh-data.js
```

This will populate:
- ✅ 64 Bangladesh districts across 8 divisions
- ✅ Sample areas for major cities (Dhaka, Chittagong, Sylhet, etc.)

**Option B: Let the App Seed Automatically**

The app has auto-seeding built in (`lib/services/district_seeding_service.dart`), but it only seeds districts, not areas.

Just run the app and it will seed districts on first launch.

**Option C: Manual Upload via Firebase Console**

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to Firestore Database
4. Create collections manually:
   - Collection: `districts`
   - Collection: `areas`

### Step 3: Verify the Data

After seeding, verify in Firebase Console:

1. **Districts Collection** should have ~64 documents
2. **Areas Collection** should have sample areas

### Step 4: Test the App

```bash
flutter run
```

The app should now:
- ✅ Load districts without permission errors
- ✅ Show district selection screen
- ✅ Navigate through District → Area → Mosque flow

## Complete Script Options

### Seed Everything at Once

```bash
# This seeds districts + areas
node seed-bangladesh-data.js
```

### Force Re-seed (Delete and Re-create)

If you need to reset the data:

```javascript
// Create: force-reseed.js
const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function deleteCollection(collectionName) {
  const batch = db.batch();
  const snapshot = await db.collection(collectionName).get();
  
  snapshot.docs.forEach(doc => {
    batch.delete(doc.ref);
  });
  
  await batch.commit();
  console.log(`Deleted ${collectionName} collection`);
}

async function main() {
  await deleteCollection('districts');
  await deleteCollection('areas');
  console.log('Collections deleted. Now run: node seed-bangladesh-data.js');
}

main();
```

## Firestore Rules Explained

Your `firestore.rules` file allows:

```javascript
// Districts - Anyone can read, only admins can write
match /districts/{districtId} {
  allow read: if true;  // ← This allows the app to read districts
  allow write: if isAdmin();
}

// Areas - Anyone can read, only admins can write
match /areas/{areaId} {
  allow read: if true;  // ← This allows the app to read areas
  allow write: if isAdmin();
}
```

## Troubleshooting

### Error: "Permission denied"
**Solution:** Deploy Firestore rules
```bash
firebase deploy --only firestore:rules
```

### Error: "Districts already exist"
**Solution:** This is normal. The script skips seeding if data exists.

### Error: "service-account-key.json not found"
**Solution:** Download service account key from Firebase Console:
1. Go to Project Settings → Service Accounts
2. Click "Generate New Private Key"
3. Save as `service-account-key.json` in project root

### Error: "Cannot find module 'firebase-admin'"
**Solution:** Install dependencies
```bash
npm install firebase-admin
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `firebase deploy --only firestore:rules` | Deploy security rules |
| `node seed-bangladesh-data.js` | Seed districts + areas |
| `firebase firestore:delete districts --recursive` | Delete all districts |
| `firebase firestore:delete areas --recursive` | Delete all areas |
| `flutter run` | Test the app |

## What Gets Seeded

### Districts (64 total)
- Dhaka Division: 13 districts
- Chittagong Division: 11 districts
- Rajshahi Division: 8 districts
- Khulna Division: 10 districts
- Barishal Division: 6 districts
- Sylhet Division: 4 districts
- Rangpur Division: 8 districts
- Mymensingh Division: 4 districts

### Sample Areas (68 total)
- Dhaka: 10 areas (Gulshan, Banani, Dhanmondi, Mirpur, Uttara, etc.)
- Chittagong: 6 areas (Agrabad, Pahartali, Halishahar, etc.)
- Sylhet: 4 areas
- Rajshahi: 4 areas
- Khulna: 4 areas
- Barishal: 3 areas
- Rangpur: 3 areas
- Mymensingh: 3 areas

You can add more areas later through the admin panel!

