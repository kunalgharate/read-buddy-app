import 'dart:io';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';

/// Service for Gnani.ai Text-to-Speech via backend proxy.
class TtsService {
  TtsService._();
  static final instance = TtsService._();

  final AudioPlayer _player = AudioPlayer();
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  /// Synthesize text and play audio. Returns when playback completes or is stopped.
  Future<void> speak(String text, {String voice = 'Simran'}) async {
    if (text.trim().isEmpty) return;

    // Limit chunk size
    final chunk = text.length > 5000 ? text.substring(0, 5000) : text;

    try {
      _isSpeaking = true;
      final dio = getIt<Dio>();

      final response = await dio.post(
        ApiConstants.ttsSynthesize,
        data: {'text': chunk, 'voice': voice, 'container': 'mp3'},
        options: Options(responseType: ResponseType.bytes),
      );

      // Write to temp file and play
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/tts_output.mp3');
      await file.writeAsBytes(response.data);

      await _player.setFilePath(file.path);
      await _player.play();

      // Wait for playback to complete
      await _player.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );
    } catch (e) {
      // Silently fail — TTS is a nice-to-have
    } finally {
      _isSpeaking = false;
    }
  }

  /// Stop current playback.
  Future<void> stop() async {
    await _player.stop();
    _isSpeaking = false;
  }

  void dispose() {
    _player.dispose();
  }
}
