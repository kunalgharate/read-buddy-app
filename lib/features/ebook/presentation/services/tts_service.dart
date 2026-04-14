import 'dart:ui';

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool isSpeaking = false;
  bool isPaused = false;
  double speed = 0.5; // 0.5 is normal on Android, 0.5 is normal on iOS

  static const Map<String, String> _languageMap = {
    'en': 'en-US',
    'hi': 'hi-IN',
    'mr': 'mr-IN',
  };

  Future<void> init(String languageCode) async {
    final locale = _languageMap[languageCode] ?? 'en-US';
    await _tts.setLanguage(locale);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // Android and iOS have different rate scales.
    // Android: 0.0 (slowest) to 1.0 (fastest), 0.5 = normal
    // iOS: 0.0 (slowest) to 1.0 (fastest), 0.5 = normal
    await _tts.setSpeechRate(speed);

    _tts.setCompletionHandler(() {
      isSpeaking = false;
      isPaused = false;
    });

    _tts.setCancelHandler(() {
      isSpeaking = false;
      isPaused = false;
    });
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    isSpeaking = true;
    isPaused = false;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    isSpeaking = false;
    isPaused = false;
  }

  Future<void> pause() async {
    await _tts.pause();
    isSpeaking = false;
    isPaused = true;
  }

  Future<void> setSpeed(double newSpeed) async {
    speed = newSpeed;
    await _tts.setSpeechRate(newSpeed);
  }

  Future<void> setLanguage(String languageCode) async {
    final locale = _languageMap[languageCode] ?? 'en-US';
    await _tts.setLanguage(locale);
  }

  void dispose() {
    _tts.stop();
  }

  void setCompletionHandler(VoidCallback handler) {
    _tts.setCompletionHandler(handler);
  }
}
