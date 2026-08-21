import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:zishu_ai/utils/constants.dart';

class WakeWordService {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _isInitialized = false;
  
  Function? onWakeWordDetected;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isInitialized = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' && _isListening) {
          _startListening();
        }
      },
    );
    
    if (_isInitialized) {
      _startListening();
    }
  }

  void startListening() {
    if (_isListening || !_isInitialized) return;
    _startListening();
  }

  void _startListening() {
    _speech.listen(
      onResult: (result) {
        final text = result.recognizedWords.toLowerCase();
        checkForWakeWord(text);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: 'hi-IN',
    );
    _isListening = true;
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  void checkForWakeWord(String text) {
    final lowerText = text.toLowerCase();
    for (final word in AppConstants.wakeWords) {
      if (lowerText.contains(word.toLowerCase())) {
        onWakeWordDetected?.call();
        break;
      }
    }
  }

  void dispose() {
    stopListening();
  }
}
