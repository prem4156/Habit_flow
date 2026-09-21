import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';

/// Singleton service for scheduling daily alarm notifications.
///
/// Uses [flutter_local_notifications] to push a daily notification
/// at a user-configured [TimeOfDay] reminding them of their quests.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const int _dailyReminderId = 1001;

  /// Initialize the notification plugin and timezone data.
  /// Must be called once before any scheduling (typically in `main()`).
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz_data.initializeTimeZones();
    // Use the device-local timezone
    tz.setLocalLocation(tz.getLocation(_resolveLocalTimezone()));

    // Android init settings — use the app's launcher icon
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS / macOS init settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    debugPrint('[NotificationService] Initialized successfully.');
  }

  /// Attempt to resolve the local timezone name.
  /// Falls back to UTC if detection fails.
  String _resolveLocalTimezone() {
    try {
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      // Try to find a matching timezone from the database
      for (final location in tz.timeZoneDatabase.locations.values) {
        final tzNow = tz.TZDateTime.now(location);
        if (tzNow.timeZoneOffset == offset) {
          return location.name;
        }
      }
    } catch (_) {}
    return 'Asia/Kolkata'; // Sensible default for the user
  }

  /// Handle notification tap — currently just a debug log.
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('[NotificationService] Notification tapped: ${response.payload}');
  }

  /// Request notification permission on Android 13+ and iOS.
  Future<bool> requestPermission() async {
    // Android 13+ requires explicit permission
    final status = await Permission.notification.request();
    if (status.isGranted) {
      debugPrint('[NotificationService] Notification permission granted.');
      return true;
    }
    debugPrint('[NotificationService] Notification permission denied: $status');
    return false;
  }

  /// Schedule a daily notification at the given [time].
  ///
  /// The notification repeats every day at the exact same time.
  /// If a daily reminder was already scheduled, it is replaced.
  Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      debugPrint('[NotificationService] Not initialized. Call initialize() first.');
      return;
    }

    // Cancel any existing daily reminder first
    await cancelDailyReminder();

    // Build the next occurrence of the given time
    final scheduledDate = _nextInstanceOfTime(time);

    // Notification channel for Android (with alarm-style importance)
    const androidDetails = AndroidNotificationDetails(
      'habit_flow_daily_reminder',
      'Daily Quest Reminder',
      channelDescription: 'Reminds you of your daily quests at the scheduled time.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      _dailyReminderId,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_quest_reminder',
    );

    debugPrint(
      '[NotificationService] Scheduled daily reminder at '
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} '
      '(next fire: $scheduledDate)',
    );
  }

  /// Cancel the daily reminder notification.
  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
    debugPrint('[NotificationService] Daily reminder cancelled.');
  }

  /// Compute the next [tz.TZDateTime] for the given [TimeOfDay].
  ///
  /// If the time has already passed today, it returns tomorrow at the same time.
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Send an immediate test notification (useful for debugging).
  Future<void> showTestNotification() async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'habit_flow_test',
      'Test Notifications',
      channelDescription: 'Test notification channel.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      0,
      '⚔ [SYSTEM] Test Alert',
      'The System is watching. Your daily quests await, Hunter.',
      details,
    );
  }
}
