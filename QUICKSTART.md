# Quick Start Guide

Get the Prayer Time app running in 10 minutes!

## Prerequisites Checklist
- [ ] Flutter SDK installed (3.10.4+)
- [ ] Android Studio or VS Code with Flutter extensions
- [ ] Firebase account
- [ ] Physical device or emulator ready

## Step 1: Clone & Install (2 minutes)

```bash
# Clone the repository
git clone <repository-url>
cd prayer-time

# Install dependencies
flutter pub get
```

## Step 2: Firebase Setup (5 minutes)

### Quick Firebase Configuration

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project" → Enter "prayer-time-app" → Create

2. **Add Android App**
   - Click Android icon
   - Package name: `com.prayertime.prayer_time`
   - Download `google-services.json`
   - Move to `android/app/`

3. **Add iOS App** (if testing on iOS)
   - Click iOS icon
   - Bundle ID: `com.prayertime.prayerTime`
   - Download `GoogleService-Info.plist`
   - Add to Xcode project in `ios/Runner/`

4. **Enable Firestore**
   - Go to Firestore Database → Create database
   - Start in production mode
   - Choose nearest region → Enable

5. **Deploy Security Rules**
   - Go to Rules tab
   - Copy from `firestore.rules` file
   - Publish

6. **Enable Authentication**
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"
   - Save

## Step 3: Run the App (1 minute)

```bash
# Check devices
flutter devices

# Run on connected device
flutter run
```

## Step 4: Create Admin User (2 minutes)

1. **Register in App**
   - Open the app
   - Register a new user with email and password

2. **Make User Admin**
   - Go to Firebase Console
   - Navigate to Firestore Database → users collection
   - Find your user document
   - Edit: Change `role` from `"user"` to `"admin"`
   - Save

3. **Login as Admin**
   - In the app, tap the admin icon (top right)
   - Login with your credentials
   - You should see the Admin Dashboard

## Step 5: Add Initial Data (Optional)

### Using Admin Panel

1. **Add an Area**
   - Dashboard → Manage Areas
   - Tap "+" button
   - Name: "City Center", Order: 1
   - Save

2. **Add a Mosque**
   - Dashboard → Manage Mosques
   - Tap "+" button
   - Fill in details:
     - Name: "Test Mosque"
     - Address: "123 Main St"
     - Area: Select "City Center"
     - Latitude: `3.1390` (or your location)
     - Longitude: `101.6869`
   - Save

3. **Set Prayer Times**
   - Dashboard → Manage Prayer Times
   - Select mosque and date
   - Set times:
     - Fajr: 05:30
     - Dhuhr: 13:00
     - Asr: 16:30
     - Maghrib: 19:15
     - Isha: 20:30
   - Save

## Quick Test Checklist

### Public User Features
- [ ] View areas on home screen
- [ ] Tap area to see mosques
- [ ] View mosque prayer times
- [ ] Change date to see different times
- [ ] Open Qibla compass (grant location permission)
- [ ] Register/login a regular user
- [ ] Add mosque to favorites
- [ ] View favorites screen

### Admin Features
- [ ] Login as admin
- [ ] View dashboard statistics
- [ ] Add/edit/delete area
- [ ] Add/edit/delete mosque
- [ ] Set prayer times for a date
- [ ] Logout

## Troubleshooting

### App won't run
```bash
# Clean and reinstall
flutter clean
flutter pub get
flutter run
```

### Firebase not connected
- Verify `google-services.json` is in `android/app/`
- Verify `GoogleService-Info.plist` is in `ios/Runner/` (for iOS)
- Check Firebase Console for project setup completion

### Can't add data
- Ensure you're logged in as admin
- Check Firestore rules are deployed
- Verify admin role in Firestore users collection

### Location permission issues
- Grant location permission when prompted
- For Android: Check AndroidManifest.xml has permissions
- For iOS: Check Info.plist has usage descriptions

## What's Next?

Now that you have the app running:

1. **Explore Features**
   - Test all user flows
   - Try admin functionality
   - Check notifications

2. **Add Real Data**
   - Add actual areas in your region
   - Add real mosques with accurate coordinates
   - Set accurate prayer times

3. **Customize**
   - Update app name in `pubspec.yaml`
   - Change package name if needed
   - Customize theme colors in `lib/utils/theme.dart`

4. **Learn More**
   - Read [README.md](README.md) for full documentation
   - Check [TESTING_GUIDE.md](TESTING_GUIDE.md) for test scenarios
   - Review [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) for production

## Common Commands

```bash
# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Build APK
flutter build apk

# Build App Bundle (for Play Store)
flutter build appbundle

# Run tests
flutter test

# Check for issues
flutter doctor
```

## Getting Help

If you're stuck:
1. Check error messages in terminal
2. Review Firebase Console for backend issues
3. Read detailed setup in [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
4. Check logs: `flutter logs`

## Success Criteria

You're all set if:
- ✅ App launches without errors
- ✅ Can view areas and mosques
- ✅ Can login as admin
- ✅ Can add/edit data as admin
- ✅ Qibla compass works
- ✅ Can favorite mosques (as user)

Congratulations! Your Prayer Time app is running! 🎉

