# Building Release APK/AAB for Play Store

This guide explains how to build a release version of the Prayer Time app for publishing to Google Play Store.

## Prerequisites

1. Flutter SDK installed and configured
2. Android SDK and tools installed
3. Java JDK 17 or higher
4. Firebase project configured (already done)

## Step 1: Generate Signing Key

Create a keystore for signing your app:

```bash
keytool -genkey -v -keystore ~/prayer-time-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias prayer-time
```

You'll be prompted for:
- Keystore password (remember this!)
- Key password (remember this!)
- Your name, organization, etc.

**IMPORTANT:** Keep this keystore file safe! You'll need it for all future updates.

## Step 2: Create key.properties

Create a file at `android/key.properties`:

```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=prayer-time
storeFile=<path-to-your-keystore>/prayer-time-key.jks
```

Example:
```properties
storePassword=mySecurePassword123
keyPassword=mySecurePassword123
keyAlias=prayer-time
storeFile=/Users/yourusername/prayer-time-key.jks
```

**IMPORTANT:** Never commit this file to version control! It's already in .gitignore.

## Step 3: Update build.gradle.kts

Add signing configuration to `android/app/build.gradle.kts`:

```kotlin
// Add this after the android { block starts
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...
    
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
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

## Step 4: Create ProGuard Rules

Create `android/app/proguard-rules.pro`:

```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Gson (used by Firebase)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Your models (adjust package name if different)
-keep class com.prayertime.bangladesh.** { *; }
```

## Step 5: Build Release APK

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Or build split APKs (recommended for Play Store)
flutter build apk --split-per-abi --release
```

The APK will be located at:
- `build/app/outputs/flutter-apk/app-release.apk` (universal)
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (32-bit ARM)
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (64-bit ARM)
- `build/app/outputs/flutter-apk/app-x86_64-release.apk` (64-bit x86)

## Step 6: Build App Bundle (AAB) for Play Store

**Recommended for Play Store:**

```bash
flutter build appbundle --release
```

The AAB will be located at:
- `build/app/outputs/bundle/release/app-release.aab`

## Step 7: Test Release Build

Before uploading to Play Store, test the release build:

```bash
# Install on connected device
flutter install --release

# Or install specific APK
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## Step 8: Upload to Play Store

1. Go to [Google Play Console](https://play.google.com/console)
2. Create a new app or select existing app
3. Navigate to "Release" > "Production"
4. Click "Create new release"
5. Upload the AAB file (`app-release.aab`)
6. Fill in release notes
7. Review and roll out

## File Sizes

Expected file sizes:
- Universal APK: ~40-50 MB
- Split APKs: ~20-30 MB each
- AAB: ~35-45 MB

## Troubleshooting

### Build fails with signing error
- Check that `key.properties` exists and has correct paths
- Verify keystore password is correct
- Ensure keystore file path is absolute

### App crashes on release but works in debug
- Check ProGuard rules
- Test with `--profile` mode first: `flutter run --profile`
- Check Firebase configuration is correct

### Large APK size
- Use split APKs: `flutter build apk --split-per-abi --release`
- Enable ProGuard (already configured)
- Remove unused resources

### Firebase not working in release
- Ensure `google-services.json` is in the correct location
- Verify Firebase configuration in build.gradle
- Check ProGuard rules include Firebase

## Version Management

To update version for new releases:

1. Update `pubspec.yaml`:
```yaml
version: 1.0.1+2  # version+buildNumber
```

2. Or update in `android/app/build.gradle.kts`:
```kotlin
versionCode = 2
versionName = "1.0.1"
```

## Security Checklist

- [ ] Keystore file is backed up securely
- [ ] key.properties is NOT committed to git
- [ ] Firebase security rules are properly configured
- [ ] API keys are not exposed in code
- [ ] ProGuard is enabled for release builds
- [ ] App is tested thoroughly on release build

## Play Store Requirements

Before publishing:
- [ ] Privacy policy URL is live
- [ ] Support email is active
- [ ] All required screenshots uploaded
- [ ] Feature graphic uploaded
- [ ] Hi-res icon uploaded
- [ ] App description is complete
- [ ] Content rating completed
- [ ] Target audience set
- [ ] Data safety form completed

## Useful Commands

```bash
# Check APK size
ls -lh build/app/outputs/flutter-apk/

# Analyze APK
flutter build apk --analyze-size

# Build with verbose output
flutter build apk --release --verbose

# Clean build cache
flutter clean
flutter pub get

# Check for outdated dependencies
flutter pub outdated
```

## Next Steps After Publishing

1. Monitor crash reports in Play Console
2. Respond to user reviews
3. Plan feature updates
4. Monitor app performance metrics
5. Keep dependencies updated
6. Regular security updates

## Support

For build issues, check:
- Flutter documentation: https://flutter.dev/docs/deployment/android
- Firebase documentation: https://firebase.google.com/docs/flutter/setup
- Play Store documentation: https://support.google.com/googleplay/android-developer

