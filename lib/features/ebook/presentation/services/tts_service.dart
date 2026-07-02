import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';

/// TTS service that uses:
/// - flutter_tts for English (device TTS)
/// - Gnani/Vachana AI SSE streaming for Hindi & Marathi (high-quality)
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  HttpClient? _httpClient;

  bool isSpeaking = false;
  bool isPaused = false;
  double speed = 0.5;
  String _languageCode = 'en';

  VoidCallback? _onComplete;

  /// Languages that use Gnani AI TTS (SSE streaming)
  static const Set<String> _gnaniLanguages = {'hi', 'mr'};

  /// Voice mapping for Gnani AI
  static const Map<String, String> _gnaniVoiceMap = {
    'hi': 'sia',
    'mr': 'sia',
  };

  static const Map<String, String> _flutterTtsLanguageMap = {
    'en': 'en-US',
    'hi': 'hi-IN',
    'mr': 'mr-IN',
  };

  Future<void> init(String languageCode) async {
    _languageCode = languageCode;

    // Always init flutter_tts as fallback
    final locale = _flutterTtsLanguageMap[languageCode] ?? 'en-US';
    await _flutterTts.setLanguage(locale);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(speed);

    _flutterTts.setCompletionHandler(() {
      isSpeaking = false;
      isPaused = false;
      _onComplete?.call();
    });

    _flutterTts.setCancelHandler(() {
      isSpeaking = false;
      isPaused = false;
    });
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    isSpeaking = true;
    isPaused = false;

    if (_gnaniLanguages.contains(_languageCode)) {
      await _speakWithGnani(text);
    } else {
      await _flutterTts.speak(text);
    }
  }

  /// Speak using Gnani AI SSE streaming endpoint via backend proxy
  Future<void> _speakWithGnani(String text) async {
    try {
      // Limit text chunk size for TTS
      final chunk = text.length > 5000 ? text.substring(0, 5000) : text;
      final voice = _gnaniVoiceMap[_languageCode] ?? 'sia';

      // Get auth token for backend proxy
      final token = await getIt<SecureStorageUtil>().getAccessToken();

      // Call backend TTS proxy (returns audio bytes)
      _httpClient = HttpClient();
      final uri = Uri.parse(ApiConstants.ttsSynthesize);
      final request = await _httpClient!.postUrl(uri);

      request.headers.set('Content-Type', 'application/json');
      if (token != null) {
        request.headers.set('Authorization', 'Bearer $token');
      }

      request.write(jsonEncode({
        'text': chunk,
        'voice': voice,
        'container': 'mp3',
      }));

      final response = await request.close();

      if (response.statusCode == 200) {
        // Collect all bytes from the response
        final bytes = await _collectResponseBytes(response);

        if (bytes.isEmpty) {
          _fallbackToFlutterTts(text);
          return;
        }

        // Write to temp file and play with just_audio
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/gnani_tts_output.mp3');
        await file.writeAsBytes(bytes);

        await _audioPlayer.setFilePath(file.path);
        await _audioPlayer.setSpeed(_mapSpeedToPlaybackRate());
        await _audioPlayer.play();

        // Listen for completion
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            isSpeaking = false;
            isPaused = false;
            _onComplete?.call();
          }
        });
      } else {
        // Fallback to flutter_tts if backend fails
        _fallbackToFlutterTts(text);
      }
    } catch (e) {
      // Fallback to flutter_tts on any error
      _fallbackToFlutterTts(text);
    }
  }

  Future<Uint8List> _collectResponseBytes(HttpClientResponse response) async {
    final completer = Completer<Uint8List>();
    final chunks = <List<int>>[];

    response.listen(
      (chunk) => chunks.add(chunk),
      onDone: () {
        final totalLength = chunks.fold<int>(0, (sum, c) => sum + c.length);
        final result = Uint8List(totalLength);
        var offset = 0;
        for (final chunk in chunks) {
          result.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }
        completer.complete(result);
      },
      onError: (e) => completer.completeError(e),
    );

    return completer.future;
  }

  /// Fallback to device TTS if Gnani AI is unavailable
  Future<void> _fallbackToFlutterTts(String text) async {
    final locale = _flutterTtsLanguageMap[_languageCode] ?? 'en-US';
    await _flutterTts.setLanguage(locale);
    await _flutterTts.speak(text);
  }

  /// Map our speed (0.0–1.0) to just_audio playback rate (0.5–2.0)
  double _mapSpeedToPlaybackRate() {
    final map = <double, double>{
      0.25: 0.5,
      0.35: 0.75,
      0.5: 1.0,
      0.65: 1.25,
      0.8: 1.5,
      1.0: 2.0,
    };
    return map[speed] ?? 1.0;
  }

  Future<void> stop() async {
    if (_gnaniLanguages.contains(_languageCode)) {
      await _audioPlayer.stop();
      _httpClient?.close(force: true);
      _httpClient = null;
    }
    await _flutterTts.stop();
    isSpeaking = false;
    isPaused = false;
  }

  Future<void> pause() async {
    if (_gnaniLanguages.contains(_languageCode) && isSpeaking) {
      await _audioPlayer.pause();
    } else {
      await _flutterTts.pause();
    }
    isSpeaking = false;
    isPaused = true;
  }

  Future<void> resume() async {
    if (_gnaniLanguages.contains(_languageCode) && isPaused) {
      await _audioPlayer.play();
      isSpeaking = true;
      isPaused = false;
    }
  }

  Future<void> setSpeed(double newSpeed) async {
    speed = newSpeed;
    await _flutterTts.setSpeechRate(newSpeed);
    // Update just_audio playback rate if currently playing via Gnani
    if (_gnaniLanguages.contains(_languageCode)) {
      await _audioPlayer.setSpeed(_mapSpeedToPlaybackRate());
    }
  }

  Future<void> setLanguage(String languageCode) async {
    _languageCode = languageCode;
    final locale = _flutterTtsLanguageMap[languageCode] ?? 'en-US';
    await _flutterTts.setLanguage(locale);
  }

  void setCompletionHandler(VoidCallback handler) {
    _onComplete = handler;
    _flutterTts.setCompletionHandler(() {
      isSpeaking = false;
      isPaused = false;
      handler();
    });
  }

  void dispose() {
    _flutterTts.stop();
    _audioPlayer.dispose();
    _httpClient?.close(force: true);
  }
}
