# Prayer Time App

A production-ready Flutter mobile application for Muslims to view prayer times for mosques in their area, complete with full admin functionality for managing mosques and prayer times.

## 📱 Features

### For Users
- **Browse Mosques**: View mosques organized by geographical area
- **Prayer Times**: Check daily prayer times with date selection
- **Next Prayer Highlighting**: See which prayer is coming next
- **Favorites**: Save your favorite mosques (requires login)
- **Qibla Compass**: Find the direction to Mecca using real-time GPS
- **Notifications**: Get reminders before prayer times
- **Search**: Find mosques by name or location
- **User Authentication**: Register and login to access personalized features

### For Administrators
- **Dashboard**: Overview with statistics
- **Manage Areas**: Add, edit, and delete geographical areas
- **Manage Mosques**: Full CRUD operations for mosques
- **Set Prayer Times**: Configure prayer times for specific dates
- **Secure Access**: Role-based authentication system

## 🏗️ Architecture

### Design Pattern
- **State Management**: Provider pattern
- **Architecture**: Service-oriented with clear separation of concerns
- **Data Flow**: Reactive streams from Firebase Firestore

### Project Structure
```
lib/
├── main.dart              # App initialization and routing
├── models/                # Data models (4 files)
│   ├── area.dart
│   ├── mosque.dart
│   ├── prayer_time.dart
│   └── user_model.dart
├── services/              # Business logic layer (4 files)
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── location_service.dart
│   └── notification_service.dart
├── providers/             # State management (4 files)
│   ├── auth_provider.dart
│   ├── mosque_provider.dart
│   ├── prayer_time_provider.dart
│   └── favorites_provider.dart
├── screens/               # UI screens (13 total)
│   ├── admin/            # Admin screens (6 files)
│   └── public/           # Public screens (5 files)
├── widgets/               # Reusable components (5 files)
└── utils/                 # Constants and themes (2 files)
```

## 🔧 Technology Stack

### Core
- **Flutter**: 3.10.4+
- **Dart**: 3.10.4+

### Firebase Services
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging

### State Management
- Provider 6.1.1

### Location & Sensors
- Geolocator 11.0.0
- Flutter Compass 0.8.0
- Permission Handler 11.1.0

### Notifications
- Flutter Local Notifications 16.3.0

### Utilities
- Intl 0.19.0 (date/time formatting)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.4 or higher)
- Dart SDK (3.10.4 or higher)
- Firebase account
- Android Studio / VS Code with Flutter extensions
- Physical device or emulator for testing

### Quick Start
1. See [QUICKSTART.md](markdowns/QUICKSTART.md) for a 10-minute setup guide
2. See [FIREBASE_SETUP.md](markdowns/FIREBASE_SETUP.md) for detailed Firebase configuration

### Installation Steps

1. **Clone the repository**
```bash
git clone <repository-url>
cd prayer-time
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
   - Follow [FIREBASE_SETUP.md](markdowns/FIREBASE_SETUP.md)
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

4. **Run the app**
```bash
flutter run
```

## 📊 Database Schema

### Collections

#### areas
```json
{
  "name": "string",
  "order": "number"
}
```

#### mosques
```json
{
  "name": "string",
  "address": "string",
  "areaId": "string",
  "latitude": "number",
  "longitude": "number"
}
```

#### prayer_times
Document ID format: `{mosqueId}_{date}`
```json
{
  "mosqueId": "string",
  "date": "yyyy-MM-dd",
  "fajr": "HH:mm",
  "dhuhr": "HH:mm",
  "asr": "HH:mm",
  "maghrib": "HH:mm",
  "isha": "HH:mm"
}
```

#### users
```json
{
  "email": "string",
  "role": "admin" | "user",
  "favorites": ["mosqueId1", "mosqueId2"]
}
```

## 🔐 Security

### Firestore Security Rules
- Public read access for areas, mosques, and prayer times
- Admin-only write access for areas, mosques, and prayer times
- Users can only modify their own data
- Role-based authentication enforced at database level

### Admin Setup
To create an admin user:
1. Register a user through the app
2. In Firebase Console → Firestore → users collection
3. Find the user document and set `role: "admin"`

## 🧪 Testing

See [TESTING_GUIDE.md](markdowns/TESTING_GUIDE.md) for comprehensive testing scenarios including:
- Admin workflows
- User workflows
- Edge cases
- Permission handling

## 📦 Deployment

See [DEPLOYMENT_CHECKLIST.md](markdowns/DEPLOYMENT_CHECKLIST.md) for:
- Android build configuration
- iOS build configuration
- App store submission requirements
- Production environment setup

## 🎨 Theme & Design

- **Material Design 3**: Modern, clean interface
- **Islamic Color Palette**: Teal and green primary colors
- **Responsive Layout**: Works on various screen sizes
- **Accessibility**: High contrast, readable fonts

## 📄 License

MIT License - See LICENSE file for details

## 🤝 Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

For issues and questions:
- Create an issue in the repository
- Check existing documentation
- Review Firebase logs for backend issues

## 🔄 Version History

- **v1.0.0** (December 2024) - Initial release
  - Complete user and admin functionality
  - Firebase integration
  - Qibla compass
  - Push notifications

## 📚 Additional Documentation

All documentation files are located in the `markdowns/` directory:

- [FIREBASE_SETUP.md](markdowns/FIREBASE_SETUP.md) - Firebase configuration guide
- [QUICKSTART.md](markdowns/QUICKSTART.md) - Quick setup in 10 minutes
- [TESTING_GUIDE.md](markdowns/TESTING_GUIDE.md) - Testing scenarios and procedures
- [DEPLOYMENT_CHECKLIST.md](markdowns/DEPLOYMENT_CHECKLIST.md) - Deployment guide

For database management scripts, see the `database-management/` directory.

## 🌟 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Islamic community for requirements and feedback
