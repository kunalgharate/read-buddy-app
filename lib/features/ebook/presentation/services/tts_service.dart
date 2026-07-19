import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

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
  /// Available v3 voices: Pranav (Male, Bold), Kaveri (Female, Confident),
  /// Shubhra (Female, Gentle), Deepak (Male, Grounded/Conversational)
  static const Map<String, String> _gnaniVoiceMap = {
    'hi': 'Deepak',
    'mr': 'Deepak',
  };

  static const Map<String, String> _flutterTtsLanguageMap = {
    'en': 'en-US',
    'hi': 'hi-IN',
    'mr': 'mr-IN',
  };

  /// Normalize language strings from backend (e.g. "Hindi2", "Hindi", "Marathi")
  /// to standard codes ("hi", "mr", "en")
  static String _normalizeLanguageCode(String raw) {
    final lower = raw.toLowerCase().trim();
    if (lower.startsWith('hindi')) return 'hi';
    if (lower.startsWith('marathi')) return 'mr';
    if (lower.startsWith('english')) return 'en';
    // Already a code like "hi", "mr", "en"
    if (lower == 'hi' || lower == 'mr' || lower == 'en') return lower;
    // Default to English
    return lower;
  }

  Future<void> init(String languageCode) async {
    _languageCode = _normalizeLanguageCode(languageCode);
    debugPrint(
        '[TTS] init() called with raw languageCode: "$languageCode" → normalized: "$_languageCode"');
    debugPrint(
        '[TTS] Will use Gnani AI: ${_gnaniLanguages.contains(_languageCode)}');

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
    if (text.trim().isEmpty) {
      debugPrint('[TTS] speak() called with empty text — skipping');
      return;
    }

    debugPrint('[TTS] speak() called — language: "$_languageCode", '
        'text length: ${text.length}, '
        'first 100 chars: "${text.substring(0, text.length.clamp(0, 100))}"');

    isSpeaking = true;
    isPaused = false;

    if (_gnaniLanguages.contains(_languageCode)) {
      debugPrint('[TTS] ➡️ Using GNANI AI for "$_languageCode"');
      await _speakWithGnani(text);
    } else {
      debugPrint('[TTS] ➡️ Using FLUTTER_TTS for "$_languageCode"');
      await _flutterTts.speak(text);
    }
  }

  /// Speak using Gnani AI SSE streaming endpoint via backend proxy
  Future<void> _speakWithGnani(String text) async {
    try {
      // Clean text: remove null characters, corrupted chars, and excessive whitespace
      String cleanText = text
          .replaceAll('\u0000', '')
          .replaceAll(RegExp(r'\r\n'), ' ')
          .replaceAll(RegExp(r'\n'), ' ')
          // Remove non-Devanagari/non-ASCII garbage characters (keep Devanagari, digits, basic punctuation, spaces)
          .replaceAll(RegExp(r'[^\u0900-\u097F\u0020-\u007E।॥]+'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (cleanText.isEmpty) {
        debugPrint('[TTS-Gnani] ⚠️ Clean text is empty — falling back');
        _fallbackToFlutterTts(text);
        return;
      }

      // Split into small chunks (~300 chars) at sentence boundaries
      final chunks = _splitIntoChunks(cleanText, maxLength: 300);
      debugPrint('[TTS-Gnani] Split into ${chunks.length} chunks');

      for (int i = 0; i < chunks.length; i++) {
        if (!isSpeaking) break; // Stop requested

        final chunk = chunks[i];
        debugPrint('[TTS-Gnani] Playing chunk ${i + 1}/${chunks.length} '
            '(${chunk.length} chars)');

        final audioFile = await _fetchGnaniAudio(chunk);
        if (audioFile == null) {
          debugPrint('[TTS-Gnani] ⚠️ Chunk ${i + 1} failed — falling back');
          _fallbackToFlutterTts(chunks.sublist(i).join(' '));
          return;
        }

        await _audioPlayer.setFilePath(audioFile.path);
        await _audioPlayer.setSpeed(_mapSpeedToPlaybackRate());
        await _audioPlayer.play();

        // Wait for this chunk to finish playing
        await _audioPlayer.playerStateStream.firstWhere(
          (state) =>
              state.processingState == ProcessingState.completed || !isSpeaking,
        );
      }

      // All chunks done
      debugPrint('[TTS-Gnani] ✅ All chunks completed');
      isSpeaking = false;
      isPaused = false;
      _onComplete?.call();
    } catch (e, stack) {
      debugPrint('[TTS-Gnani] ❌ Exception: $e');
      debugPrint('[TTS-Gnani] Stack: $stack');
      debugPrint('[TTS-Gnani] Falling back to flutter_tts');
      _fallbackToFlutterTts(text);
    }
  }

  /// Split text into chunks at sentence boundaries (। , . ! ?)
  List<String> _splitIntoChunks(String text, {int maxLength = 300}) {
    final chunks = <String>[];
    // Split at Hindi purna viram (।), period, comma, or other punctuation
    final sentences = text.split(RegExp(r'(?<=[।.!?,;])\s*'));
    var current = StringBuffer();

    for (final sentence in sentences) {
      if (current.length + sentence.length > maxLength && current.isNotEmpty) {
        chunks.add(current.toString().trim());
        current = StringBuffer();
      }
      current.write(sentence);
      current.write(' ');
    }
    if (current.isNotEmpty) {
      chunks.add(current.toString().trim());
    }

    // If any chunk is still too long, force-split it
    final result = <String>[];
    for (final chunk in chunks) {
      if (chunk.length <= maxLength) {
        result.add(chunk);
      } else {
        for (var i = 0; i < chunk.length; i += maxLength) {
          result.add(chunk.substring(
            i,
            (i + maxLength).clamp(0, chunk.length),
          ));
        }
      }
    }

    return result.where((c) => c.trim().isNotEmpty).toList();
  }

  /// Fetch audio from Gnani/Vachana AI directly
  Future<File?> _fetchGnaniAudio(String chunk) async {
    try {
      final voice = _gnaniVoiceMap[_languageCode] ?? 'Deepak';
      debugPrint('[TTS-Gnani] 🎙️ Voice: "$voice", Language: "$_languageCode"');

      _httpClient = HttpClient();
      final uri = Uri.parse('https://api.vachana.ai/api/v1/tts/inference');
      final request = await _httpClient!.postUrl(uri);

      final body = jsonEncode({
        'text': chunk,
        'voice': voice,
        'model': 'vachana-voice-v3',
        'audio_config': {
          'sample_rate': 44100,
          'num_channels': 1,
          'sample_width': 2,
          'bitrate': '192k',
          'encoding': 'linear_pcm',
          'container': 'mp3',
        },
      });
      final bodyBytes = utf8.encode(body);

      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.headers.set('Content-Length', bodyBytes.length.toString());
      request.headers.set('X-API-Key-ID',
          'vach_1ytE2CY5X2OrSqddsJvAvu3O4wNoWFIjyldHw67WjXqEK25XwvpaxAfJLV2491K9cnYPB6bMdulN5N56eaRxQCrnvsO1agNC_784090b017d414bbe6dd034cd399f0c8');

      request.add(bodyBytes);
      final response = await request.close();
      debugPrint('[TTS-Gnani] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final bytes = await _collectResponseBytes(response);
        debugPrint('[TTS-Gnani] Received ${bytes.length} bytes of audio');

        if (bytes.isEmpty) return null;

        final dir = await getTemporaryDirectory();
        final file = File(
          '${dir.path}/gnani_tts_${DateTime.now().millisecondsSinceEpoch}.mp3',
        );
        await file.writeAsBytes(bytes);
        return file;
      } else {
        final errorBytes = await _collectResponseBytes(response);
        final errorBody = utf8.decode(errorBytes, allowMalformed: true);
        debugPrint(
            '[TTS-Gnani] ❌ API error ${response.statusCode}: $errorBody');
        return null;
      }
    } catch (e) {
      debugPrint('[TTS-Gnani] ❌ Fetch error: $e');
      return null;
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
    debugPrint('[TTS-Fallback] Using flutter_tts for "$_languageCode"');
    final locale = _flutterTtsLanguageMap[_languageCode] ?? 'en-US';
    await _flutterTts.setLanguage(locale);
    await _flutterTts.speak(text);
  }

  /// Map our speed (0.0–1.0) to just_audio playback rate
  /// Default 0.5 maps to 0.85x for more natural book reading pace
  double _mapSpeedToPlaybackRate() {
    final map = <double, double>{
      0.25: 0.6,
      0.35: 0.7,
      0.5: 0.85,
      0.65: 1.0,
      0.8: 1.25,
      1.0: 1.5,
    };
    return map[speed] ?? 0.85;
  }

  Future<void> stop() async {
    debugPrint('[TTS] stop() called — language: "$_languageCode"');
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
    _languageCode = _normalizeLanguageCode(languageCode);
    debugPrint(
        '[TTS] setLanguage() called: "$languageCode" → normalized: "$_languageCode"');
    final locale = _flutterTtsLanguageMap[_languageCode] ?? 'en-US';
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
