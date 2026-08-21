class AppConstants {
  static const String appName = 'Zishu AI';
  static const String appVersion = '1.0.0';
  static const String apiUrl = 'https://zishu-backend.onrender.com/api/chat';
  static const int maxChatHistory = 100;
  static const int inactivityTimeout = 120; // seconds
  static const int proactiveCheckInterval = 300; // seconds
  
  // Wake Words
  static const List<String> wakeWords = [
    'zishu',
    'hey zishu',
    'hi zishu',
    'hello zishu',
    'ok zishu',
    'जिशु',
    'हे जिशु'
  ];
  
  // Proactive Messages
  static const List<String> proactiveMessages = [
    'Boss, aaj kya busy ho? Mujhse baat nahi karoge?',
    'Hey boss! Kya chal raha hai? Kuch help chahiye?',
    'Namaste boss! Aaj ka din kaisa chal raha hai?',
    'Boss, main yahan hoon. Kuch kaam hai kya?',
    'Zishu active hai boss! Kya aapko kuch chahiye?',
    'Boss, aapne mujhe yaad kiya? Kuch help kar sakta hoon.',
    'Good to see you boss! Kya aaj kuch special karna hai?',
  ];
}

class SharedPrefKeys {
  static const String darkMode = 'darkMode';
  static const String language = 'language';
  static const String alwaysListening = 'alwaysListening';
  static const String vibrationEnabled = 'vibrationEnabled';
  static const String soundEnabled = 'soundEnabled';
  static const String notificationEnabled = 'notificationEnabled';
  static const String wakeWordEnabled = 'wakeWordEnabled';
}
