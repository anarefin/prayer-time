# 🚀 Quick Firestore Setup - 3 Steps!

Your authentication works, but Firestore needs data. Let's fix this in **3 simple steps**:

---

## Step 1: Install Node Package

```bash
cd /Users/ahmadnaqibularefin/Cursors/prayer-time
npm install firebase-admin
```

---

## Step 2: Get Service Account Key

1. Open: https://console.firebase.google.com/project/prayer-time-df24c/settings/serviceaccounts/adminsdk

2. Click **"Generate new private key"**

3. Download the JSON file

4. Save it as `service-account-key.json` in your project folder:
   ```
   /Users/ahmadnaqibularefin/Cursors/prayer-time/service-account-key.json
   ```

---

## Step 3: Run Setup Script

```bash
node init-firestore.js
```

Expected output:
```
🚀 Starting Firestore initialization...

📦 Initializing areas collection...
   ✓ Queued: area_kl_001
   ✓ Queued: area_selangor_001
   ✅ Created 2 documents in areas

📦 Initializing mosques collection...
   ✓ Queued: mosque_kl_001
   ✓ Queued: mosque_kl_002
   ✅ Created 2 documents in mosques

📦 Initializing prayer_times collection...
   ✓ Queued: mosque_kl_001_2024-12-18
   ✅ Created 1 documents in prayer_times

✅ Initialization complete!
```

---

## ✅ Test Now!

After running the script, test your app:

```bash
flutter run
```

### Try These:

**1. Admin Login:**
- Email: `arefin@arefin.com`
- Password: `arefin`
- Should: Navigate to Admin Dashboard ✅

**2. User Login:**
- Email: `test@test.com`  
- Password: `123456`
- Should: Show "Signed in successfully" ✅

**3. View Mosques:**
- Go to Home tab
- Select "Kuala Lumpur"
- Should: Show 2 mosques ✅

---

## 🐛 Troubleshooting

### Can't find service-account-key.json?

Make sure file is in the project root:
```
/Users/ahmadnaqibularefin/Cursors/prayer-time/service-account-key.json
```

Not in a subfolder!

### Permission denied?

The service account key has full permissions automatically. If you get errors:

1. Check the key file is valid JSON
2. Make sure you downloaded it from the correct Firebase project
3. Try redownloading the key

### Script runs but app still shows errors?

1. Clear app and restart:
   ```bash
   flutter run --clear
   ```

2. Check Firestore Console:
   https://console.firebase.google.com/project/prayer-time-df24c/firestore

   You should see 4 collections:
   - ✅ users
   - ✅ areas  
   - ✅ mosques
   - ✅ prayer_times

---

## 🎉 That's It!

After these 3 steps, your authentication will work perfectly! The error was simply missing Firestore documents.

---

## Alternative: Manual Setup (No Script)

If you prefer not to use the script, follow the manual instructions in `FIRESTORE_SETUP.md`.

You'll need to create collections manually in Firebase Console, but the result is the same.

---

**Ready? Start with Step 1!** 👆

