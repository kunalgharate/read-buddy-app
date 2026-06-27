import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/services/file_cache_service.dart';
import '../domain/entities/audiobook.dart';
import 'services/playback_state_service.dart';

/// Global singleton that manages audio playback across the app.
/// Supports background playback with notification controls.
class AudioPlayerService {
  AudioPlayerService._();
  static final instance = AudioPlayerService._();

  AudioPlayer? _player;
  AudioBook? _currentBook;
  int _currentTrackIndex = 0;
  double _speed = 1.0;

  final _bookNotifier = ValueNotifier<AudioBook?>(null);
  final _trackIndexNotifier = ValueNotifier<int>(0);
  final _speedNotifier = ValueNotifier<double>(1.0);

  ValueNotifier<AudioBook?> get bookNotifier => _bookNotifier;
  ValueNotifier<int> get trackIndexNotifier => _trackIndexNotifier;
  ValueNotifier<double> get speedNotifier => _speedNotifier;

  AudioPlayer get player {
    _player ??= AudioPlayer();
    return _player!;
  }

  AudioBook? get currentBook => _currentBook;
  int get currentTrackIndex => _currentTrackIndex;
  double get speed => _speed;
  bool get isPlaying => _player?.playing ?? false;
  bool get hasBook => _currentBook != null;

  Stream<Duration> get positionStream => player.positionStream;
  Stream<PlayerState> get playerStateStream => player.playerStateStream;
  Stream<ProcessingState> get processingStateStream =>
      player.processingStateStream;
  Duration? get duration => player.duration;
  Duration get position => player.position;

  StreamSubscription? _completionSub;
  _AudioHandler? _audioHandler;

  /// Initialize audio service for background playback. Call once at app start.
  Future<void> init() async {
    try {
      _audioHandler = await AudioService.init(
        builder: () => _AudioHandler(this),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'app.thecodershub.read_buddy.audio',
          androidNotificationChannelName: 'ReadBuddy Audio',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );
      debugPrint('✅ AudioService initialized successfully');
    } catch (e) {
      debugPrint('⚠️ AudioService init failed: $e');
    }
  }

  void _updateMediaItem() {
    if (_currentBook == null || _audioHandler == null) return;
    final track = _currentBook!.tracks[_currentTrackIndex];
    _audioHandler!.mediaItem.add(MediaItem(
      id: track.url,
      title: track.title,
      album: _currentBook!.title,
      artist: _currentBook!.author,
      artUri: _currentBook!.coverUrl.isNotEmpty
          ? Uri.parse(_currentBook!.coverUrl)
          : null,
      duration: track.duration,
    ));
  }

  void _updatePlaybackState() {
    if (_audioHandler == null) return;
    _audioHandler!.playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _mapProcessingState(player.processingState),
      playing: player.playing,
      updatePosition: player.position,
      speed: _speed,
    ));
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  Future<void> play(AudioBook book, {int trackIndex = 0}) async {
    // Lazy init audio service on first play
    if (_audioHandler == null) await init();

    debugPrint(
        '🎵 AudioPlayerService.play: ${book.title}, tracks: ${book.tracks.length}');
    _currentBook = book;

    // Defer notifier update to avoid triggering rebuild during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bookNotifier.value = book;
    });

    _completionSub?.cancel();
    _completionSub = player.processingStateStream.listen((state) {
      _updatePlaybackState();
      if (state == ProcessingState.completed) {
        _autoNext();
      }
    });

    // Also listen to play/pause changes for notification
    player.playingStream.listen((_) => _updatePlaybackState());

    // Restore saved state if same book and no explicit track
    if (trackIndex == 0) {
      final saved = await PlaybackStateService.load(book.id);
      if (saved != null && saved.trackIndex < book.tracks.length) {
        await _loadTrack(saved.trackIndex, seekTo: saved.position);
        return;
      }
    }
    await _loadTrack(trackIndex);
  }

  Future<void> _loadTrack(int index, {Duration? seekTo}) async {
    _currentTrackIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackIndexNotifier.value = index;
    });

    try {
      await player.stop();
      final url = _currentBook!.tracks[index].url;
      final cached = FileCacheService.instance.getCachedPath(url);
      if (cached != null) {
        await player.setFilePath(cached);
      } else {
        await player.setUrl(url);
        FileCacheService.instance.prefetch(url);
      }
      await player.setSpeed(_speed);
      if (seekTo != null) {
        await player.seek(seekTo);
      }
      _updateMediaItem();
      await player.play();
      _prefetchNext(index);
    } catch (_) {}
  }

  void _prefetchNext(int index) {
    if (_currentBook != null && index + 1 < _currentBook!.tracks.length) {
      FileCacheService.instance.prefetch(_currentBook!.tracks[index + 1].url);
    }
  }

  void _autoNext() {
    if (_currentBook != null &&
        _currentTrackIndex < _currentBook!.tracks.length - 1) {
      _loadTrack(_currentTrackIndex + 1);
    }
  }

  Future<void> playPause() async {
    if (player.playing) {
      await player.pause();
      await _saveState();
    } else {
      await player.play();
    }
  }

  Future<void> skipNext() async {
    if (_currentBook != null &&
        _currentTrackIndex < _currentBook!.tracks.length - 1) {
      await _saveState();
      await _loadTrack(_currentTrackIndex + 1);
    }
  }

  Future<void> skipPrevious() async {
    if (player.position.inSeconds > 3) {
      await player.seek(Duration.zero);
    } else if (_currentTrackIndex > 0) {
      await _saveState();
      await _loadTrack(_currentTrackIndex - 1);
    } else {
      await player.seek(Duration.zero);
    }
  }

  Future<void> seekTo(Duration position) async {
    await player.seek(position);
  }

  Future<void> seekForward() async {
    final pos = player.position + const Duration(seconds: 15);
    final dur = player.duration ?? Duration.zero;
    await player.seek(pos > dur ? dur : pos);
  }

  Future<void> seekBackward() async {
    final pos = player.position - const Duration(seconds: 15);
    await player.seek(pos < Duration.zero ? Duration.zero : pos);
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed;
    _speedNotifier.value = speed;
    await player.setSpeed(speed);
    _updatePlaybackState();
  }

  Future<void> loadTrack(int index) async {
    await _saveState();
    await _loadTrack(index);
  }

  Future<void> stop() async {
    await _saveState();
    await player.stop();
    _currentBook = null;
    _bookNotifier.value = null;
    _completionSub?.cancel();
    _audioHandler?.playbackState.add(PlaybackState(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }

  Future<void> _saveState() async {
    if (_currentBook == null) return;
    try {
      await PlaybackStateService.save(
        bookId: _currentBook!.id,
        trackIndex: _currentTrackIndex,
        position: player.position,
      );
    } catch (_) {}
  }
}

/// Audio handler that bridges audio_service notification controls
/// to our AudioPlayerService.
class _AudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayerService _service;

  _AudioHandler(this._service);

  @override
  Future<void> play() async => _service.playPause();

  @override
  Future<void> pause() async => _service.playPause();

  @override
  Future<void> stop() async => _service.stop();

  @override
  Future<void> seek(Duration position) async => _service.seekTo(position);

  @override
  Future<void> skipToNext() async => _service.skipNext();

  @override
  Future<void> skipToPrevious() async => _service.skipPrevious();

  @override
  Future<void> fastForward() async => _service.seekForward();

  @override
  Future<void> rewind() async => _service.seekBackward();
}
