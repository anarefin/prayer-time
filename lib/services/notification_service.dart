import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/prayer_time.dart';
import '../utils/constants.dart';

/// Service for handling local and push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can be extended to navigate to specific screen
    // For now, we just log it
    print('Notification tapped: ${response.payload}');
  }

  /// Check notification permission status
  Future<PermissionStatus> checkNotificationPermission() async {
    return await Permission.notification.status;
  }

  /// Request notification permission
  Future<PermissionStatus> requestNotificationPermission() async {
    return await Permission.notification.request();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final permission = await checkNotificationPermission();
    return permission == PermissionStatus.granted;
  }

  /// Schedule notifications for all prayer times
  Future<void> schedulePrayerNotifications(PrayerTime prayerTime) async {
    if (!_isInitialized) await initialize();

    final prayers = prayerTime.getAllPrayers();
    int notificationId = prayerTime.date.millisecondsSinceEpoch ~/ 1000;

    for (var entry in prayers.entries) {
      final prayerName = entry.key;
      final prayerDateTime = entry.value;

      // Schedule notification 15 minutes before prayer time
      final notificationTime = prayerDateTime.subtract(
        const Duration(minutes: NotificationSettings.minutesBeforePrayer),
      );

      // Only schedule if the time is in the future
      if (notificationTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: notificationId++,
          title: '$prayerName Prayer Time',
          body:
              '$prayerName prayer is in ${NotificationSettings.minutesBeforePrayer} minutes at ${PrayerTime.formatTime(prayerDateTime)}',
          scheduledTime: notificationTime,
          payload: 'prayer_$prayerName',
        );
      }
    }
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationSettings.channelId,
            NotificationSettings.channelName,
            channelDescription: NotificationSettings.channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationSettings.channelId,
          NotificationSettings.channelName,
          channelDescription: NotificationSettings.channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Get active notifications (Android only)
  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (_notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>() !=
        null) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()!
              .getActiveNotifications() ??
          [];
    }
    return [];
  }
}

