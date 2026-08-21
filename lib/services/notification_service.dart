import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zishu_ai/utils/constants.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android Initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS Initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    if (!_isInitialized) await initialize();

    final hasPermission = await _checkPermission();
    if (!hasPermission) return;

    const androidDetails = AndroidNotificationDetails(
      'zishu_channel',
      'Zishu Notifications',
      channelDescription: 'Notifications from Zishu AI',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    
    final result = await Permission.notification.request();
    return result.isGranted;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    // Can open app or perform action
    print('Notification tapped: ${response.payload}');
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
