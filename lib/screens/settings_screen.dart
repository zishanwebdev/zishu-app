import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zishu_ai/providers/settings_provider.dart';
import 'package:zishu_ai/providers/assistant_provider.dart';
import 'package:zishu_ai/services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final assistantProvider = Provider.of<AssistantProvider>(context);
    final notificationService = NotificationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Voice Settings
          _buildSectionTitle('Voice Settings'),
          SwitchListTile(
            title: const Text('Always Listening'),
            subtitle: const Text('Background listening for commands'),
            value: assistantProvider.isAlwaysListening,
            onChanged: (_) => assistantProvider.toggleAlwaysListening(),
          ),
          SwitchListTile(
            title: const Text('Wake Word'),
            subtitle: const Text('Say "Zishu" to activate'),
            value: assistantProvider.isWakeWordEnabled,
            onChanged: (_) => assistantProvider.toggleWakeWord(),
          ),
          const Divider(),
          
          // Appearance
          _buildSectionTitle('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark/light theme'),
            value: settingsProvider.isDarkMode,
            onChanged: (_) => settingsProvider.toggleTheme(),
          ),
          const Divider(),
          
          // Language
          _buildSectionTitle('Language'),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(settingsProvider.language),
            onTap: () => _showLanguageDialog(context),
          ),
          const Divider(),
          
          // Notifications
          _buildSectionTitle('Notifications'),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive notifications from Zishu'),
            value: true,
            onChanged: (value) async {
              if (value) {
                await notificationService.initialize();
              } else {
                await notificationService.cancelAllNotifications();
              }
            },
          ),
          const Divider(),
          
          // About
          _buildSectionTitle('About'),
          ListTile(
            title: const Text('About Zishu'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          ListTile(
            title: const Text('Support'),
            subtitle: const Text('Get help with Zishu'),
            onTap: () {
              Navigator.pushNamed(context, '/support');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Hindi'),
              onTap: () {
                context.read<SettingsProvider>().setLanguage('hi-IN');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                context.read<SettingsProvider>().setLanguage('en-US');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
