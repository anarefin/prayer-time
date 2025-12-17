# Deployment Checklist

Complete guide for deploying the Prayer Time app to production and app stores.

## Table of Contents
1. [Pre-Deployment](#pre-deployment)
2. [Firebase Production Setup](#firebase-production-setup)
3. [Android Deployment](#android-deployment)
4. [iOS Deployment](#ios-deployment)
5. [App Store Assets](#app-store-assets)
6. [Post-Deployment](#post-deployment)
7. [Monitoring](#monitoring)

## Pre-Deployment

### Code Quality Checklist
- [ ] All features tested and working
- [ ] No linter errors: `flutter analyze`
- [ ] No console warnings or errors
- [ ] All TODOs resolved or documented
- [ ] Code reviewed and approved
- [ ] Version number updated in `pubspec.yaml`

### Configuration Checklist
- [ ] App name finalized
- [ ] Package name/bundle ID set correctly
- [ ] App icons created and added
- [ ] Splash screen configured
- [ ] Firebase production project set up
- [ ] Security rules deployed
- [ ] Admin users created

### Testing Checklist
- [ ] All test cases passed (see [TESTING_GUIDE.md](TESTING_GUIDE.md))
- [ ] Tested on physical Android device
- [ ] Tested on physical iOS device (if applicable)
- [ ] Performance tested with real data
- [ ] Security rules verified
- [ ] Permissions work correctly

## Firebase Production Setup

### 1. Create Production Project
```
Option A: Use separate production Firebase project
Option B: Use same project with production collections
```

**Recommended: Option A (Separate Project)**

1. Create new Firebase project: `prayer-time-production`
2. Configure Android and iOS apps
3. Download new config files
4. Replace in project:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

### 2. Firestore Setup
- [ ] Create database in production mode
- [ ] Select appropriate region (closest to users)
- [ ] Deploy security rules from `firestore.rules`
- [ ] Create indices if needed
- [ ] Set up backup schedule

### 3. Authentication Setup
- [ ] Enable Email/Password authentication
- [ ] Configure email templates (optional)
- [ ] Set up admin users
- [ ] Test authentication flow

### 4. Cloud Messaging (Optional)
- [ ] Upload APNs certificate/key (iOS)
- [ ] Configure server key (Android)
- [ ] Test push notifications

### 5. Security Hardening
- [ ] Review and test security rules
- [ ] Enable App Check (optional but recommended)
- [ ] Set up alerts for suspicious activity
- [ ] Configure rate limiting

## Android Deployment

### 1. Update App Information

**android/app/build.gradle.kts:**
```kotlin
android {
    namespace = "com.prayertime.prayer_time"
    compileSdk = 34
    
    defaultConfig {
        applicationId = "com.prayertime.prayer_time"
        minSdk = 21
        targetSdk = 34
        versionCode = 1  // Increment for each release
        versionName = "1.0.0"  // Update version
    }
}
```

### 2. Create Keystore

```bash
keytool -genkey -v -keystore ~/prayer-time-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias prayer-time-key
```

Save keystore file securely and backup!

### 3. Configure Signing

Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=prayer-time-key
storeFile=/path/to/prayer-time-key.jks
```

Add to `.gitignore`:
```
**/android/key.properties
```

Update `android/app/build.gradle.kts`:
```kotlin
// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### 4. Build Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### 5. Build App Bundle (Recommended for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 6. Test Release Build

```bash
# Install APK on device
flutter install --release

# Or manually
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 7. Google Play Store Submission

#### Prepare Assets
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Screenshots (at least 2, max 8)
  - Phone: 16:9 or 9:16 ratio
  - Tablet: 4:3 or 3:4 ratio (optional)
- [ ] Privacy policy URL
- [ ] App description (short and long)

#### Create Play Console Account
1. Go to [Google Play Console](https://play.google.com/console)
2. Pay $25 one-time registration fee
3. Complete account setup

#### Create App
1. Click "Create app"
2. Fill in app details:
   - Name: Prayer Time
   - Language: English (and others)
   - Type: App
   - Category: Lifestyle
   - Price: Free
3. Complete app declarations
4. Upload APK/App Bundle
5. Complete store listing
6. Set content rating
7. Set target audience
8. Submit for review

### 8. ProGuard Configuration (Optional)

Create `android/app/proguard-rules.pro`:
```proguard
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
```

## iOS Deployment

### 1. Xcode Configuration

Open `ios/Runner.xcworkspace` in Xcode:

**Update Info.plist:**
- Bundle Identifier: `com.prayertime.prayerTime`
- Display Name: Prayer Time
- Version: 1.0.0
- Build: 1

**Configure Signing:**
1. Select Runner target
2. Signing & Capabilities
3. Select your Team
4. Enable "Automatically manage signing"

### 2. App Store Connect Setup

#### Create App ID
1. Go to [Apple Developer](https://developer.apple.com)
2. Certificates, IDs & Profiles → Identifiers
3. Create App ID: `com.prayertime.prayerTime`
4. Enable capabilities as needed

#### Create App in App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. My Apps → + → New App
3. Platform: iOS
4. Bundle ID: Select created ID
5. SKU: PRAYERTIME001
6. Name: Prayer Time

### 3. Build for Release

```bash
flutter build ios --release
```

Or in Xcode:
1. Product → Scheme → Runner
2. Product → Destination → Any iOS Device
3. Product → Archive
4. Wait for build to complete

### 4. Upload to App Store

**Via Xcode:**
1. Window → Organizer
2. Select archive
3. Click "Distribute App"
4. Choose "App Store Connect"
5. Follow prompts
6. Upload

**Via Transporter (Alternative):**
1. Build IPA: `flutter build ipa`
2. Open Transporter app
3. Drag IPA file
4. Upload

### 5. App Store Submission

#### Prepare Assets
- [ ] App icon (1024x1024 PNG, no alpha)
- [ ] Screenshots for all required sizes:
  - 6.5" iPhone (1242x2688 or 1284x2778)
  - 5.5" iPhone (1242x2208)
  - iPad Pro (2048x2732)
- [ ] Privacy policy URL
- [ ] App description
- [ ] Keywords
- [ ] Support URL
- [ ] Marketing URL (optional)

#### Complete App Information
1. App Information
2. Pricing and Availability
3. Version Information
4. App Privacy (data collection disclosure)
5. Content Rights
6. Age Rating

#### Submit for Review
1. Add screenshots
2. Write description
3. Select build
4. Complete questionnaire
5. Submit for Review

### 6. iOS Permissions

Ensure `Info.plist` has usage descriptions:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to calculate the Qibla direction.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to your location to calculate the Qibla direction.</string>
```

## App Store Assets

### Icons
Generate all required sizes:
- Android: 48, 72, 96, 144, 192 dp
- iOS: 20, 29, 40, 60, 76, 83.5, 1024 pt

**Use [App Icon Generator](https://appicon.co)**

### Screenshots
Capture from:
- Home screen (area selection)
- Mosque list
- Prayer times display
- Qibla compass
- Admin dashboard (optional)

**Tools:**
- Simulator/Emulator screenshot
- [Mockup generators](https://www.mockuphone.com)
- Professional editing

### Description Template

**Short Description (80 chars):**
```
View accurate prayer times for mosques in your area with Qibla compass
```

**Long Description:**
```
Prayer Time - Your Complete Islamic Prayer Companion

FEATURES:
• View prayer times for mosques in your area
• Accurate Qibla direction with real-time compass
• Save your favorite mosques
• Prayer time notifications
• Search for mosques by name or location
• Support for multiple regions

FOR USERS:
Browse mosques by geographical area, check daily prayer times, and find the Qibla direction instantly. Save your favorite mosques for quick access and enable notifications to never miss a prayer.

FOR ADMINISTRATORS:
Mosque administrators can easily manage areas, mosques, and prayer times through the secure admin portal.

PERMISSIONS:
• Location: For Qibla compass direction
• Notifications: For prayer time reminders

100% free with no ads or in-app purchases.

Support: support@prayertime.com
Privacy Policy: https://yourwebsite.com/privacy
```

### Keywords
```
prayer, salah, muslim, islam, mosque, masjid, qibla, compass, azan, adhan, times, namaz
```

## Post-Deployment

### Initial Launch Checklist
- [ ] App approved and live on store(s)
- [ ] Test download and installation
- [ ] Verify all features work in production
- [ ] Monitor crash reports
- [ ] Check Firebase usage
- [ ] Respond to initial user feedback

### Marketing
- [ ] Create social media presence
- [ ] Prepare promotional materials
- [ ] Reach out to Islamic communities
- [ ] Get reviews from beta testers
- [ ] Submit to app review sites

### User Support
- [ ] Set up support email
- [ ] Create FAQ page
- [ ] Prepare response templates
- [ ] Monitor app store reviews
- [ ] Gather user feedback

## Monitoring

### Firebase Console
**Daily checks:**
- [ ] Authentication metrics
- [ ] Firestore usage
- [ ] Error logs
- [ ] Performance metrics

**Weekly checks:**
- [ ] Database growth
- [ ] API usage
- [ ] Cost analysis
- [ ] User retention

### App Store Analytics
- [ ] Downloads
- [ ] Active users
- [ ] Crash rate
- [ ] User ratings
- [ ] Reviews

### Performance Monitoring
- [ ] App load time
- [ ] API response time
- [ ] Screen render time
- [ ] Memory usage
- [ ] Battery usage

## Maintenance Plan

### Regular Updates
**Monthly:**
- [ ] Update prayer times
- [ ] Review and respond to feedback
- [ ] Fix reported bugs
- [ ] Update dependencies

**Quarterly:**
- [ ] Major feature additions
- [ ] UI/UX improvements
- [ ] Performance optimization
- [ ] Security audit

**Annually:**
- [ ] Comprehensive review
- [ ] Technology stack update
- [ ] Complete redesign consideration

### Version Management
```
Major.Minor.Patch (e.g., 1.2.3)
- Major: Breaking changes
- Minor: New features
- Patch: Bug fixes
```

## Emergency Procedures

### Critical Bug
1. Identify and reproduce issue
2. Fix in hotfix branch
3. Test thoroughly
4. Build emergency release
5. Submit expedited review
6. Monitor deployment

### Security Issue
1. Assess severity
2. Disable affected features if needed
3. Deploy security patch immediately
4. Notify users if data compromised
5. Document incident
6. Improve security measures

## Rollback Plan

If issues arise:
1. Stop promoting new version
2. Fix critical issues
3. Build new version
4. Submit update
5. Communicate with users

## Legal Compliance

### Privacy Policy
- [ ] Created and published
- [ ] Covers data collection
- [ ] Explains data usage
- [ ] GDPR compliant (if EU users)
- [ ] COPPA compliant (if children <13)

### Terms of Service
- [ ] Created and published
- [ ] User responsibilities
- [ ] Limitation of liability
- [ ] Account termination policy

### App Store Policies
- [ ] Comply with Play Store policies
- [ ] Comply with App Store guidelines
- [ ] No prohibited content
- [ ] Accurate representation

## Final Checklist

Before going live:
- [ ] All features complete and tested
- [ ] Firebase production configured
- [ ] Release builds created and signed
- [ ] Store listings complete
- [ ] Screenshots and assets uploaded
- [ ] Privacy policy published
- [ ] Support channels ready
- [ ] Monitoring tools configured
- [ ] Backup and recovery plan
- [ ] Team trained on support procedures

---

**Deployment Completed By**: _______________
**Date**: _______________
**Version**: _______________
**Store Links**:
- Google Play: _______________
- App Store: _______________

