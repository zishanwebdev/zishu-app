import 'package:flutter/material.dart';
import 'package:zishu_ai/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  bool _isInitialized = false;
  List<Map<String, dynamic>> _notifications = [];

  bool get isInitialized => _isInitialized;
  List<Map<String, dynamic>> get notifications => _notifications;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _notificationService.initialize();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notificationService.showNotification(
      title: title,
      body: body,
      payload: payload,
      id: DateTime.now().millisecondsSinceEpoch % 100000,
    );
    
    _notifications.insert(0, {
      'title': title,
      'body': body,
      'timestamp': DateTime.now(),
      'payload': payload,
    });
    notifyListeners();
  }

  Future<void> clearNotifications() async {
    await _notificationService.cancelAllNotifications();
    _notifications.clear();
    notifyListeners();
  }
}
