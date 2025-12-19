# Quick Start Guide - Publishing to Play Store

## ✅ What's Already Done

1. ✅ App icons created and configured
2. ✅ Splash screen implemented
3. ✅ Play Store assets generated
4. ✅ Android manifest configured
5. ✅ Build configuration optimized
6. ✅ Connectivity issues fixed

## 🚀 Quick Steps to Publish

### Step 1: Test the App (5 minutes)

```bash
# Run the app to verify everything works
flutter clean
flutter pub get
flutter run
```

Test:
- App icon and splash screen display correctly
- District selection works after going offline/online
- All features function properly

### Step 2: Generate Signing Key (2 minutes)

```bash
keytool -genkey -v -keystore ~/prayer-time-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias prayer-time
```

**IMPORTANT:** Save the passwords securely!

### Step 3: Configure Signing (3 minutes)

Create `android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=prayer-time
storeFile=/Users/yourusername/prayer-time-key.jks
```

Update `android/app/build.gradle.kts` - add before `android {`:

```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Add inside `android {` block:

```kotlin
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

### Step 4: Build Release (5 minutes)

```bash
# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Step 5: Create Play Store Listing (30 minutes)

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app
3. Fill in app details:
   - **App name:** Prayer Time - Bangladesh
   - **Category:** Lifestyle
   - **Content rating:** Everyone

4. Upload assets from `playstore_assets/`:
   - Hi-res icon: `hi_res_icon.png`
   - Feature graphic: `feature_graphic.png`
   - Screenshots: `screenshot_1.png`, `screenshot_2.png`, `screenshot_3.png`

5. Copy description from `PLAY_STORE_LISTING.md`

6. Set up privacy policy (required):
   - Host privacy policy online
   - Add URL to Play Store listing

### Step 6: Upload and Publish (10 minutes)

1. Go to "Release" → "Production"
2. Create new release
3. Upload `app-release.aab`
4. Add release notes
5. Review and publish

## 📋 Pre-Publish Checklist

### Required
- [ ] App tested thoroughly
- [ ] Signing key generated and backed up
- [ ] Release build created successfully
- [ ] Privacy policy hosted online
- [ ] Support email active
- [ ] All Play Store assets uploaded
- [ ] App description complete

### Recommended
- [ ] Beta testing completed
- [ ] Firebase Crashlytics enabled
- [ ] Firebase Analytics enabled
- [ ] Real screenshots taken (replace mockups)
- [ ] App tested on multiple devices
- [ ] All permissions tested

## 🎯 Key Files Location

### App Assets
```
assets/images/
├── app_icon.png              # Main app icon
├── app_icon_foreground.png   # Adaptive icon
└── splash_logo.png           # Splash screen
```

### Play Store Assets
```
playstore_assets/
├── hi_res_icon.png           # 512x512 icon
├── feature_graphic.png       # 1024x500 banner
├── screenshot_1.png          # Home screen
├── screenshot_2.png          # Prayer times
└── screenshot_3.png          # Qibla compass
```

### Build Output
```
build/app/outputs/
├── bundle/release/
│   └── app-release.aab       # Upload this to Play Store
└── flutter-apk/
    └── app-release.apk       # For testing
```

## 🔧 Common Issues

### Issue: Build fails with signing error
**Solution:** Check `key.properties` file exists and paths are correct

### Issue: App crashes on release
**Solution:** Test with `flutter run --release` first

### Issue: Icons not showing
**Solution:** Run `dart run flutter_launcher_icons` again

### Issue: Splash screen not working
**Solution:** Run `dart run flutter_native_splash:create` again

## 📞 Need Help?

1. Check `BUILD_RELEASE.md` for detailed instructions
2. Review `PLAY_STORE_LISTING.md` for listing content
3. See `FIXES_SUMMARY.md` for what was changed

## 🎉 After Publishing

1. Monitor reviews and ratings
2. Respond to user feedback
3. Track crashes in Play Console
4. Plan feature updates
5. Keep app updated regularly

## ⏱️ Estimated Time

- First-time setup: ~1 hour
- Subsequent updates: ~15 minutes

## 💡 Tips

1. **Test release build locally first**
   ```bash
   flutter install --release
   ```

2. **Check APK size**
   ```bash
   flutter build apk --analyze-size
   ```

3. **Use internal testing track first**
   - Upload to internal track
   - Test with small group
   - Then promote to production

4. **Take real screenshots**
   - Use actual app on device
   - Show real mosque data
   - Better than mockups

5. **Monitor first 24 hours**
   - Check for crashes
   - Review initial feedback
   - Be ready to hotfix if needed

---

**Ready to publish?** Follow the steps above and your app will be live on Play Store! 🚀

For detailed information, see:
- `BUILD_RELEASE.md` - Complete build guide
- `PLAY_STORE_LISTING.md` - Listing content
- `FIXES_SUMMARY.md` - Recent changes

