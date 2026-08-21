import 'package:flutter_background/flutter_background.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zishu_ai/services/notification_service.dart';
import 'package:zishu_ai/utils/constants.dart';

class BackgroundService {
  static const int _alarmId = 1;
  bool _isEnabled = false;
  final NotificationService _notificationService = NotificationService();

  Future<void> initialize() async {
    await FlutterBackground.initialize();
    
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: AppConstants.appName,
      notificationText: 'Always listening for commands...',
      notificationImportant: true,
      notificationColor: 0xFF3B82F6,
    );
    
    await FlutterBackground.setAndroidConfiguration(androidConfig);
  }

  Future<void> enableBackgroundListening() async {
    if (_isEnabled) return;
    
    final hasPermission = await FlutterBackground.hasPermissions;
    if (!hasPermission) {
      final granted = await FlutterBackground.requestPermissions();
      if (!granted) return;
    }
    
    await FlutterBackground.enableBackgroundExecution();
    
    await AndroidAlarmManager.periodic(
      const Duration(minutes: 1),
      _alarmId,
      _backgroundTask,
      wakeup: true,
      exact: true,
    );
    
    _isEnabled = true;
    
    _notificationService.showNotification(
      title: 'Zishu Background Active',
      body: 'Listening for commands...',
    );
  }

  Future<void> disableBackgroundListening() async {
    if (!_isEnabled) return;
    
    await FlutterBackground.disableBackgroundExecution();
    await AndroidAlarmManager.cancel(_alarmId);
    
    _isEnabled = false;
  }

  static void _backgroundTask() async {
    // Periodic background check
    // Check for pending commands or notifications
    print('Background task running...');
  }

  bool get isEnabled => _isEnabled;
}
