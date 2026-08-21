import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:zishu_ai/models/chat_message.dart';
import 'package:zishu_ai/services/api_service.dart';
import 'package:zishu_ai/services/background_service.dart';
import 'package:zishu_ai/services/wake_word_service.dart';
import 'package:zishu_ai/services/notification_service.dart';
import 'package:zishu_ai/utils/constants.dart';
import 'dart:async';

class AssistantProvider extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final ApiService _apiService = ApiService();
  final BackgroundService _backgroundService = BackgroundService();
  final WakeWordService _wakeWordService = WakeWordService();
  final NotificationService _notificationService = NotificationService();
  
  List<ChatMessage> _messages = [];
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isProcessing = false;
  bool _isAlwaysListening = false;
  bool _isWakeWordEnabled = true;
  String _transcript = '';
  Timer? _inactivityTimer;
  Timer? _proactiveTimer;
  
  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isProcessing => _isProcessing;
  bool get isAlwaysListening => _isAlwaysListening;
  bool get isWakeWordEnabled => _isWakeWordEnabled;
  String get transcript => _transcript;

  AssistantProvider() {
    _initializeSpeech();
    _initializeTTS();
    _initializeWakeWord();
    _startProactiveCheck();
    _loadChatHistory();
  }

  Future<void> _initializeSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' && _isAlwaysListening) {
          _startListening();
        }
      },
      onError: (error) {
        debugPrint('Speech error: $error');
        if (_isAlwaysListening) {
          _startListening();
        }
      },
    );
  }

  Future<void> _initializeTTS() async {
    await _tts.setLanguage('hi-IN');
    await _tts.setSpeechRate(0.9);
    await _tts.setPitch(1.1);
    await _tts.setVolume(1.0);
    
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
      
      if (_isAlwaysListening && !_isProcessing) {
        _startListening();
      }
    });
  }

  Future<void> _initializeWakeWord() async {
    _wakeWordService.initialize();
    _wakeWordService.onWakeWordDetected = () {
      if (_isWakeWordEnabled && !_isListening && !_isSpeaking) {
        _activateAssistant();
      }
    };
  }

  Future<void> _activateAssistant() async {
    await _speakText('Ji boss, sun raha hoon.');
    _startListening();
    _notificationService.showNotification(
      title: 'Zishu Active',
      body: 'Listening for your command',
    );
  }

  // Always Listening Mode
  void toggleAlwaysListening() {
    _isAlwaysListening = !_isAlwaysListening;
    
    if (_isAlwaysListening) {
      _startListening();
      _backgroundService.enableBackgroundListening();
      _notificationService.showNotification(
        title: 'Zishu Always On',
        body: 'Listening for commands...',
      );
    } else {
      _stopListening();
      _backgroundService.disableBackgroundListening();
    }
    
    notifyListeners();
  }

  // Wake Word Toggle
  void toggleWakeWord() {
    _isWakeWordEnabled = !_isWakeWordEnabled;
    if (_isWakeWordEnabled) {
      _wakeWordService.startListening();
      _notificationService.showNotification(
        title: 'Wake Word Active',
        body: 'Say "Zishu" to activate',
      );
    } else {
      _wakeWordService.stopListening();
    }
    notifyListeners();
  }

  void _startListening() {
    if (_isListening || _isSpeaking || _isProcessing) return;
    
    _speech.listen(
      onResult: (result) {
        _transcript = result.recognizedWords;
        notifyListeners();
        
        // Check for wake word in speech
        if (_isWakeWordEnabled) {
          _wakeWordService.checkForWakeWord(_transcript);
        }
        
        if (result.finalResult) {
          _handleUserInput(_transcript);
          _transcript = '';
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: 'hi-IN',
    );
    
    _isListening = true;
    notifyListeners();
    _resetInactivityTimer();
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
      notifyListeners();
    }
  }

  // Inactivity Timer
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: AppConstants.inactivityTimeout), () {
      if (!_isSpeaking && !_isProcessing && _isAlwaysListening) {
        _sendProactiveMessage(AppConstants.proactiveMessages.first);
        Vibration.vibrate(duration: 500);
        _notificationService.showNotification(
          title: 'Zishu Reminder',
          body: 'Boss, aap busy ho?',
        );
      }
    });
  }

  // Proactive Messages
  void _startProactiveCheck() {
    _proactiveTimer = Timer.periodic(
      const Duration(seconds: AppConstants.proactiveCheckInterval), 
      (timer) {
        if (!_isSpeaking && !_isProcessing && _isAlwaysListening) {
          final message = AppConstants.proactiveMessages[
            DateTime.now().millisecondsSinceEpoch % AppConstants.proactiveMessages.length
          ];
          _sendProactiveMessage(message);
        }
      }
    );
  }

  Future<void> _sendProactiveMessage(String text) async {
    _addMessage(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.proactive,
    ));
    
    await _speakText(text);
    Vibration.vibrate(duration: 300);
    _notificationService.showNotification(
      title: 'Zishu',
      body: text,
    );
  }

  // Handle User Input
  Future<void> _handleUserInput(String query) async {
    if (query.trim().isEmpty) {
      _startListening();
      return;
    }

    _stopListening();
    _isProcessing = true;
    notifyListeners();

    _addMessage(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
      type: MessageType.voice,
    ));

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _handleOfflineResponse();
      return;
    }

    try {
      final response = await _apiService.sendMessage(query);
      
      _addMessage(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.text,
      ));
      
      await _speakText(response);
      
    } catch (e) {
      _addMessage(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry boss, kuch problem ho gayi. Phir se try karo.',
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.system,
      ));
      
      await _speakText('Sorry boss, kuch problem ho gayi. Phir se try karo.');
    }

    _isProcessing = false;
    notifyListeners();
    
    if (_isAlwaysListening) {
      _startListening();
    }
  }

  void _handleOfflineResponse() {
    _addMessage(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: 'Boss, internet connection nahi hai. Offline kaam kar sakta hoon?',
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.system,
    ));
    
    _speakText('Boss, internet connection nahi hai. Kuch offline kaam kar sakta hoon?');
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> _speakText(String text) async {
    _isSpeaking = true;
    notifyListeners();
    await _tts.speak(text);
  }

  void _addMessage(ChatMessage message) {
    _messages.insert(0, message);
    if (_messages.length > AppConstants.maxChatHistory) {
      _messages.removeLast();
    }
    _saveChatHistory();
    notifyListeners();
  }

  // Chat History
  Future<void> _loadChatHistory() async {
    try {
      final box = Hive.box<ChatMessage>('chat_history');
      _messages = box.values.toList();
      _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final box = Hive.box<ChatMessage>('chat_history');
      await box.clear();
      for (var message in _messages) {
        await box.add(message);
      }
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  Future<void> clearChatHistory() async {
    _messages.clear();
    final box = Hive.box<ChatMessage>('chat_history');
    await box.clear();
    notifyListeners();
  }

  // Command from Notification/Home Screen
  void processCommand(String command) {
    if (command == 'activate') {
      _activateAssistant();
    } else if (command == 'toggle_listening') {
      toggleAlwaysListening();
    } else if (command == 'stop') {
      if (_isSpeaking || _isProcessing) {
        _stopCurrentResponse();
      }
    } else if (command == 'get_status') {
      String status = '';
      if (_isListening) status = 'Listening...';
      else if (_isSpeaking) status = 'Speaking...';
      else if (_isProcessing) status = 'Processing...';
      else status = 'Idle';
      
      _notificationService.showNotification(
        title: 'Zishu Status',
        body: 'Current: $status',
      );
    }
  }

  void _stopCurrentResponse() {
    _isSpeaking = false;
    _isProcessing = false;
    _tts.stop();
    _speech.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _proactiveTimer?.cancel();
    _wakeWordService.dispose();
    _stopListening();
    _tts.stop();
    super.dispose();
  }
}
