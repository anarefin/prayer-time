// App-wide constants and configurations

/// Mecca coordinates for Qibla direction calculation
class MeccaCoordinates {
  static const double latitude = 21.4225;
  static const double longitude = 39.8262;
}

/// Prayer names
class PrayerNames {
  static const String fajr = 'Fajr';
  static const String dhuhr = 'Dhuhr';
  static const String asr = 'Asr';
  static const String maghrib = 'Maghrib';
  static const String isha = 'Isha';

  static const List<String> all = [fajr, dhuhr, asr, maghrib, isha];
}

/// User roles
class UserRoles {
  static const String admin = 'admin';
  static const String user = 'user';
}

/// Collection names in Firestore
class Collections {
  static const String areas = 'areas';
  static const String mosques = 'mosques';
  static const String prayerTimes = 'prayer_times';
  static const String users = 'users';
}

/// App text constants
class AppTexts {
  static const String appName = 'Prayer Time';
  static const String loading = 'Loading...';
  static const String error = 'An error occurred';
  static const String noData = 'No data available';
  static const String retry = 'Retry';
}

/// Notification settings
class NotificationSettings {
  static const int minutesBeforePrayer = 15;
  static const String channelId = 'prayer_times_channel';
  static const String channelName = 'Prayer Times';
  static const String channelDescription = 'Notifications for upcoming prayer times';
}

