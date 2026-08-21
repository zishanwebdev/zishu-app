import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zishu_ai/utils/constants.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'hi-IN';
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  bool _notificationEnabled = true;

  SettingsProvider() {
    _loadSettings();
  }

  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get notificationEnabled => _notificationEnabled;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(SharedPrefKeys.darkMode) ?? false;
    _language = prefs.getString(SharedPrefKeys.language) ?? 'hi-IN';
    _vibrationEnabled = prefs.getBool(SharedPrefKeys.vibrationEnabled) ?? true;
    _soundEnabled = prefs.getBool(SharedPrefKeys.soundEnabled) ?? true;
    _notificationEnabled = prefs.getBool(SharedPrefKeys.notificationEnabled) ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPrefKeys.darkMode, _isDarkMode);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedPrefKeys.language, language);
    notifyListeners();
  }

  Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPrefKeys.vibrationEnabled, _vibrationEnabled);
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPrefKeys.soundEnabled, _soundEnabled);
    notifyListeners();
  }

  Future<void> toggleNotification() async {
    _notificationEnabled = !_notificationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPrefKeys.notificationEnabled, _notificationEnabled);
    notifyListeners();
  }
}
