import 'package:shared_preferences/shared_preferences.dart';

/// Persists audiobook playback state (track index + position) locally.
/// Key format: `audiobook_<bookId>_track` and `audiobook_<bookId>_position`
class PlaybackStateService {
  static const _prefix = 'audiobook_';

  /// Save current playback state
  static Future<void> save({
    required String bookId,
    required int trackIndex,
    required Duration position,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefix${bookId}_track', trackIndex);
    await prefs.setInt(
      '$_prefix${bookId}_position',
      position.inMilliseconds,
    );
  }

  /// Load saved playback state. Returns null if no saved state.
  static Future<PlaybackState?> load(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final track = prefs.getInt('$_prefix${bookId}_track');
    final posMs = prefs.getInt('$_prefix${bookId}_position');

    if (track == null || posMs == null) return null;

    return PlaybackState(
      trackIndex: track,
      position: Duration(milliseconds: posMs),
    );
  }

  /// Clear saved state for a book
  static Future<void> clear(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix${bookId}_track');
    await prefs.remove('$_prefix${bookId}_position');
  }
}

class PlaybackState {
  final int trackIndex;
  final Duration position;

  const PlaybackState({
    required this.trackIndex,
    required this.position,
  });
}
