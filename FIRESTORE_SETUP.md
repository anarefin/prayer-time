# Firestore Database Setup Guide

## 🎯 Quick Fix for Your Current Issue

Your authentication is working, but Firestore documents don't exist or have wrong structure. Let's fix this!

## 📦 Required Firestore Collections

Your app needs **4 collections**:

1. **`users`** - User accounts with roles
2. **`areas`** - Geographical areas
3. **`mosques`** - Mosque information
4. **`prayer_times`** - Prayer schedules

## 🚀 Option 1: Automated Setup (RECOMMENDED)

### Step 1: Install Dependencies

```bash
cd /Users/ahmadnaqibularefin/Cursors/prayer-time
npm install firebase-admin
```

### Step 2: Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **prayer-time-df24c**
3. Click **⚙️ Settings** → **Project Settings**
4. Go to **Service Accounts** tab
5. Click **Generate new private key**
6. Download and save as `service-account-key.json` in your project root

### Step 3: Run Initialization Script

```bash
node init-firestore.js
```

This will:
- ✅ Create/update user documents for existing Firebase Auth users
- ✅ Create sample areas (Kuala Lumpur, Selangor, Putrajaya)
- ✅ Create sample mosques with locations
- ✅ Create today's prayer times
- ✅ Verify all collections

### Step 4: Test the App

After running the script, test immediately:

```bash
flutter run
```

Then try logging in:
- **Admin**: `arefin@arefin.com` / `arefin`
- **User**: `test@test.com` / `123456`

---

## 🔧 Option 2: Manual Setup via Firebase Console

If you prefer to set up manually:

### 1. Open Firestore Console

Go to: https://console.firebase.google.com/project/prayer-time-df24c/firestore

### 2. Create `users` Collection

Click **Start collection** → Name: `users`

**Add documents for existing users:**

#### Document 1: Admin User
- Document ID: `6fAVoF9OgtYKI70a2ZDDjyafEhE2`
- Fields:
  ```
  email: "arefin@arefin.com"          (string)
  role: "admin"                        (string)
  favorites: []                        (array)
  ```

#### Document 2: Test User
- Document ID: `DSpqEl1rjzZjWdOzxRVjQ8g1lNj2`
- Fields:
  ```
  email: "test@test.com"              (string)
  role: "user"                         (string)
  favorites: []                        (array)
  ```

### 3. Create `areas` Collection

Click **Start collection** → Name: `areas`

#### Document 1: Kuala Lumpur
- Document ID: `area_kl_001`
- Fields:
  ```
  name: "Kuala Lumpur"                (string)
  order: 1                             (number)
  ```

#### Document 2: Selangor
- Document ID: `area_selangor_001`
- Fields:
  ```
  name: "Selangor"                    (string)
  order: 2                             (number)
  ```

### 4. Create `mosques` Collection

Click **Start collection** → Name: `mosques`

#### Document 1: Masjid Wilayah
- Document ID: `mosque_kl_001`
- Fields:
  ```
  name: "Masjid Wilayah Persekutuan"  (string)
  address: "Jalan Duta, KL"           (string)
  areaId: "area_kl_001"                (string)
  latitude: 3.1569                     (number)
  longitude: 101.7123                  (number)
  ```

#### Document 2: Masjid Negara
- Document ID: `mosque_kl_002`
- Fields:
  ```
  name: "Masjid Negara"               (string)
  address: "Jalan Perdana, KL"        (string)
  areaId: "area_kl_001"                (string)
  latitude: 3.1419                     (number)
  longitude: 101.6911                  (number)
  ```

### 5. Create `prayer_times` Collection

Click **Start collection** → Name: `prayer_times`

#### Document 1: Today's prayer times for Masjid Wilayah
- Document ID: `mosque_kl_001_2024-12-18` (use today's date)
- Fields:
  ```
  mosqueId: "mosque_kl_001"           (string)
  date: "2024-12-18"                   (string, YYYY-MM-DD format)
  fajr: "05:45"                        (string, HH:mm format)
  dhuhr: "13:15"                       (string, HH:mm format)
  asr: "16:30"                         (string, HH:mm format)
  maghrib: "19:15"                     (string, HH:mm format)
  isha: "20:30"                        (string, HH:mm format)
  ```

#### Document 2: Today's prayer times for Masjid Negara
- Document ID: `mosque_kl_002_2024-12-18` (use today's date)
- Fields:
  ```
  mosqueId: "mosque_kl_002"           (string)
  date: "2024-12-18"                   (string, YYYY-MM-DD format)
  fajr: "05:45"                        (string, HH:mm format)
  dhuhr: "13:15"                       (string, HH:mm format)
  asr: "16:30"                         (string, HH:mm format)
  maghrib: "19:15"                     (string, HH:mm format)
  isha: "20:30"                        (string, HH:mm format)
  ```

---

## 🔍 Verify Your Setup

After setup (automated or manual), verify in Firebase Console:

```
✅ users collection:
   - Has 2 documents (your admin and test user)
   - Each has: email, role, favorites

✅ areas collection:
   - Has at least 1 area
   - Each has: name, order

✅ mosques collection:
   - Has at least 1 mosque
   - Each has: name, address, areaId, latitude, longitude

✅ prayer_times collection:
   - Has at least 1 prayer time document
   - Each has: mosqueId, date, fajr, dhuhr, asr, maghrib, isha
```

---

## 📋 Document Structure Reference

### User Document
```json
{
  "email": "user@example.com",
  "role": "user",              // "admin" or "user"
  "favorites": []              // Array of mosque IDs
}
```

### Area Document
```json
{
  "name": "Kuala Lumpur",
  "order": 1                   // For sorting
}
```

### Mosque Document
```json
{
  "name": "Masjid Wilayah Persekutuan",
  "address": "Jalan Duta, 50480 Kuala Lumpur",
  "areaId": "area_kl_001",     // Reference to area
  "latitude": 3.1569,
  "longitude": 101.7123
}
```

### Prayer Time Document
```json
{
  "mosqueId": "mosque_kl_001", // Reference to mosque
  "date": "2024-12-18",        // YYYY-MM-DD
  "fajr": "05:45",             // HH:mm
  "dhuhr": "13:15",
  "asr": "16:30",
  "maghrib": "19:15",
  "isha": "20:30"
}
```

**Important**: Prayer time document ID must be `{mosqueId}_{date}`

---

## 🐛 Troubleshooting

### Issue: "Failed to initialize Firebase Admin"

**Solution**:
```bash
# Download service account key from Firebase Console
# Save as service-account-key.json
# Then run:
node init-firestore.js
```

### Issue: "Permission denied" when running script

**Solution**:
1. Check Firestore rules are deployed:
   ```bash
   firebase deploy --only firestore:rules
   ```
2. Service account has full permissions (automatic)

### Issue: App still shows errors after setup

**Solutions**:

1. **Clear app data and restart**:
   ```bash
   flutter run --clear
   ```

2. **Check Firestore in Console**:
   - Go to Firestore Database
   - Verify all 4 collections exist
   - Verify documents have correct structure

3. **Check app logs**:
   ```bash
   flutter logs | grep -i "firestore\|error"
   ```

4. **Verify user documents match Firebase Auth UIDs**:
   - Go to Authentication tab
   - Note the user UIDs
   - Make sure `users` collection has documents with those exact UIDs

---

## 📱 Testing Checklist

After setup, test these:

### ✅ Admin Login
1. Tap admin icon
2. Login with `arefin@arefin.com` / `arefin`
3. Should navigate to Admin Dashboard
4. No errors

### ✅ User Features  
1. Go to Favorites tab
2. Login with `test@test.com` / `123456`
3. Should see "Signed in successfully"
4. Can view areas
5. Can view mosques
6. Can add to favorites

### ✅ Prayer Times
1. Select an area
2. Select a mosque
3. Should see today's prayer times
4. No errors

---

## 🎯 Next Steps After Setup

Once Firestore is initialized:

1. **Add more areas**: Go to admin panel → Areas → Add
2. **Add more mosques**: Admin panel → Mosques → Add
3. **Add prayer times**: Admin panel → Prayer Times → Add
4. **Test user favorites**: Login as user → favorite some mosques

---

## 📞 Need Help?

If you encounter issues:

1. **Check Firebase Console**: https://console.firebase.google.com
2. **View Firestore data**: Firestore Database tab
3. **Check Authentication**: Authentication tab
4. **View app logs**: `flutter logs`

---

## 🔐 Security Notes

- ✅ Firestore rules already configured (in `firestore.rules`)
- ✅ Service account key is gitignored (don't commit it!)
- ✅ Users can only read/write their own data
- ✅ Only admins can manage areas, mosques, and prayer times

---

## 📊 Files Created

- `firestore-schema.json` - Complete data structure reference
- `firestore-sample-data.json` - Sample data for testing
- `init-firestore.js` - Automated setup script
- `FIRESTORE_SETUP.md` - This guide

---

**Ready to initialize? Run:**

```bash
npm install firebase-admin
node init-firestore.js
```

🎉 **Your app will work perfectly after this!**

