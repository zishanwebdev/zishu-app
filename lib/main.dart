import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zishu_ai/providers/assistant_provider.dart';
import 'package:zishu_ai/providers/settings_provider.dart';
import 'package:zishu_ai/providers/notification_provider.dart';
import 'package:zishu_ai/screens/home_screen.dart';
import 'package:zishu_ai/screens/settings_screen.dart';
import 'package:zishu_ai/screens/about_screen.dart';
import 'package:zishu_ai/screens/support_screen.dart';
import 'package:zishu_ai/models/chat_message.dart';
import 'package:zishu_ai/services/background_service.dart';
import 'package:zishu_ai/services/notification_service.dart';
import 'package:zishu_ai/services/wake_word_service.dart';
import 'package:zishu_ai/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ChatMessageAdapter());
  await Hive.openBox<ChatMessage>('chat_history');
  await Hive.openBox('settings');
  
  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Request Permissions
  await _requestPermissions();
  
  // Initialize Background Service
  await BackgroundService().initialize();
  
  // Initialize Wake Word Service
  await WakeWordService().initialize();
  
  runApp(const ZishuApp());
}

Future<void> _requestPermissions() async {
  final permissions = [
    Permission.microphone,
    Permission.notification,
    Permission.ignoreBatteryOptimizations,
    Permission.vibrate,
    Permission.accessMediaLocation,
  ];
  
  await permissions.request();
}

class ZishuApp extends StatelessWidget {
  const ZishuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AssistantProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: settings.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            home: const HomeScreen(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
              '/about': (context) => const AboutScreen(),
              '/support': (context) => const SupportScreen(),
            },
          );
        },
      ),
    );
  }
}
