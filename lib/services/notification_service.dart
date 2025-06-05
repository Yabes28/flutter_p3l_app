import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
    );

    await _notifications.initialize(
      settings,
    );
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reusemart_channel', // Channel ID
      'ReuseMart Notifications', // Channel Name
      channelDescription: 'Channel untuk notifikasi ReuseMart',
      importance: Importance.max, // WAJIB untuk pop-up
      priority: Priority.high,    // WAJIB untuk pop-up
      playSound: true,
      enableVibration: true,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }
}
