import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/services/file_cache_service.dart';
import '../../domain/entities/audiobook.dart';
import '../services/playback_state_service.dart';

class AudioBookPlayerPage extends StatefulWidget {
  final AudioBook audioBook;

  const AudioBookPlayerPage({super.key, required this.audioBook});

  @override
  State<AudioBookPlayerPage> createState() => _AudioBookPlayerPageState();
}

class _AudioBookPlayerPageState extends State<AudioBookPlayerPage> {
  late AudioPlayer _player;
  final List<StreamSubscription> _subs = [];
  int _currentTrackIndex = 0;
  double _speed = 1.0;
  String? _error;
  bool _disposed = false;

  static const _textDark = Color(0xFF052E44);
  static const _bg = Color(0xFFFDFDFD);
  static const _green = Color(0xFF2CE07F);
  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  AudioBook get _book => widget.audioBook;
  AudioBookTrack get _currentTrack => _book.tracks[_currentTrackIndex];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _subs.add(
      _player.processingStateStream.listen((state) {
        if (!mounted || _disposed) return;
        if (state == ProcessingState.completed) {
          _autoNext();
        }
      }),
    );

    _subs.add(
      _player.positionStream.listen((pos) {
        if (!mounted || _disposed) return;
        if (_player.playing && pos.inSeconds % 5 == 0) {
          _saveState();
        }
      }),
    );

    _restoreState();
  }

  Future<void> _restoreState() async {
    if (!mounted || _disposed) return;
    final saved = await PlaybackStateService.load(_book.id);
    if (!mounted || _disposed) return;
    if (saved != null && saved.trackIndex < _book.tracks.length) {
      await _loadTrack(saved.trackIndex, seekTo: saved.position);
    } else {
      await _loadTrack(0);
    }
  }

  Future<void> _saveState() async {
    if (_disposed) return;
    try {
      await PlaybackStateService.save(
        bookId: _book.id,
        trackIndex: _currentTrackIndex,
        position: _player.position,
      );
    } catch (_) {}
  }

  Future<void> _loadTrack(int index, {Duration? seekTo}) async {
    if (!mounted || _disposed) return;
    setState(() {
      _error = null;
      _currentTrackIndex = index;
    });
    try {
      await _player.stop();
      if (!mounted || _disposed) return;

      final cached = FileCacheService.instance.getCachedPath(
        _book.tracks[index].url,
      );
      if (cached != null) {
        await _player.setFilePath(cached);
      } else {
        await _player.setUrl(_book.tracks[index].url);
        FileCacheService.instance.prefetch(_book.tracks[index].url);
      }
      if (!mounted || _disposed) return;
      await _player.setSpeed(_speed);
      if (seekTo != null) {
        await _player.seek(seekTo);
      }
      if (seekTo == null) {
        await _player.play();
      }
      _prefetchNext(index);
    } catch (e) {
      if (!mounted || _disposed) return;
      setState(() {
        _error = 'Failed to load audio. Check your connection.';
      });
    }
  }

  void _prefetchNext(int currentIndex) {
    if (currentIndex + 1 < _book.tracks.length) {
      FileCacheService.instance.prefetch(
        _book.tracks[currentIndex + 1].url,
      );
    }
  }

  void _autoNext() {
    if (!mounted || _disposed) return;
    if (_currentTrackIndex < _book.tracks.length - 1) {
      _loadTrack(_currentTrackIndex + 1);
    }
  }

  Future<void> _playPause() async {
    if (_player.playing) {
      await _player.pause();
      await _saveState();
    } else {
      await _player.play();
    }
  }

  Future<void> _skipNext() async {
    if (_currentTrackIndex < _book.tracks.length - 1) {
      await _saveState();
      _loadTrack(_currentTrackIndex + 1);
    }
  }

  Future<void> _skipPrevious() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (_currentTrackIndex > 0) {
      await _saveState();
      _loadTrack(_currentTrackIndex - 1);
    } else {
      await _player.seek(Duration.zero);
    }
  }

  void _cycleSpeed() {
    final idx = _speeds.indexOf(_speed);
    final next = (idx + 1) % _speeds.length;
    setState(() => _speed = _speeds[next]);
    _player.setSpeed(_speed);
  }

  Future<void> _seekForward() async {
    final pos = _player.position + const Duration(seconds: 15);
    final dur = _player.duration ?? Duration.zero;
    await _player.seek(pos > dur ? dur : pos);
  }

  Future<void> _seekBackward() async {
    final pos = _player.position - const Duration(seconds: 15);
    await _player.seek(pos < Duration.zero ? Duration.zero : pos);
  }

  @override
  void dispose() {
    _disposed = true;
    _saveState();
    for (final sub in _subs) {
      sub.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textDark),
        title: Text(
          _book.title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_book.tracks.length > 1)
            IconButton(
              icon: const Icon(Icons.playlist_play),
              onPressed: _showPlaylist,
              tooltip: 'Playlist',
            ),
        ],
      ),
      body: _error != null ? _buildError() : _buildPlayer(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFD64545), size: 48),
            const SizedBox(height: 12),
            Text(_error!,
                style: GoogleFonts.poppins(fontSize: 14, color: _textDark),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadTrack(_currentTrackIndex),
              style: ElevatedButton.styleFrom(backgroundColor: _green),
              child: Text('Retry',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return Column(
      children: [
        const Spacer(),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24)),
          child: const Icon(Icons.headphones_rounded, size: 80, color: _green),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(_currentTrack.title,
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600, color: _textDark),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(height: 4),
        Text(_book.author,
            style: GoogleFonts.poppins(
                fontSize: 14, color: const Color(0xFF666666))),
        if (_book.tracks.length > 1) ...[
          const SizedBox(height: 4),
          Text('Part ${_currentTrackIndex + 1} of ${_book.tracks.length}',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: _green, fontWeight: FontWeight.w500)),
        ],
        const SizedBox(height: 8),
        // Buffering indicator
        _buildBufferingIndicator(),
        const SizedBox(height: 16),
        _buildSeekBar(),
        const SizedBox(height: 16),
        _buildControls(),
        const SizedBox(height: 16),
        _buildSpeedControl(),
        const Spacer(),
        if (_book.tracks.length > 1) _buildPlaylistPreview(),
      ],
    );
  }

  /// Shows buffering status so user knows audio is loading
  Widget _buildBufferingIndicator() {
    return StreamBuilder<ProcessingState>(
      stream: _player.processingStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? ProcessingState.idle;
        if (state == ProcessingState.loading ||
            state == ProcessingState.buffering) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _green)),
                const SizedBox(width: 8),
                Text(
                  state == ProcessingState.loading
                      ? 'Loading...'
                      : 'Buffering...',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: const Color(0xFF666666)),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSeekBar() {
    return StreamBuilder<Duration>(
      stream: _player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = _player.duration ?? Duration.zero;
        final progress = duration.inMilliseconds > 0
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: _green,
                  inactiveTrackColor: const Color(0xFFE0E0E0),
                  thumbColor: _green,
                  overlayColor: _green.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: (v) {
                    _player.seek(Duration(
                        milliseconds: (v * duration.inMilliseconds).round()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmt(position),
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: const Color(0xFF666666))),
                    Text(_fmt(duration),
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: const Color(0xFF666666))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final isPlaying = state?.playing ?? false;
        final processing = state?.processingState ?? ProcessingState.idle;
        final isBuffering = processing == ProcessingState.loading ||
            processing == ProcessingState.buffering;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: const Icon(Icons.skip_previous_rounded),
                iconSize: 36,
                color: _currentTrackIndex > 0
                    ? _textDark
                    : const Color(0xFFCCCCCC),
                onPressed: _currentTrackIndex > 0 ? _skipPrevious : null),
            const SizedBox(width: 8),
            IconButton(
                icon: const Icon(Icons.replay_10_rounded),
                iconSize: 32,
                color: _textDark,
                onPressed: _seekBackward),
            const SizedBox(width: 8),
            Container(
              width: 64,
              height: 64,
              decoration:
                  const BoxDecoration(color: _green, shape: BoxShape.circle),
              child: isBuffering
                  ? const Center(
                      child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3)))
                  : IconButton(
                      icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white),
                      iconSize: 36,
                      onPressed: _playPause),
            ),
            const SizedBox(width: 8),
            IconButton(
                icon: const Icon(Icons.forward_10_rounded),
                iconSize: 32,
                color: _textDark,
                onPressed: _seekForward),
            const SizedBox(width: 8),
            IconButton(
                icon: const Icon(Icons.skip_next_rounded),
                iconSize: 36,
                color: _currentTrackIndex < _book.tracks.length - 1
                    ? _textDark
                    : const Color(0xFFCCCCCC),
                onPressed: _currentTrackIndex < _book.tracks.length - 1
                    ? _skipNext
                    : null),
          ],
        );
      },
    );
  }

  Widget _buildSpeedControl() {
    return GestureDetector(
      onTap: _cycleSpeed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20)),
        child: Text('Speed: ${_speed}x',
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600, color: _green)),
      ),
    );
  }

  Widget _buildPlaylistPreview() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEAEAEA)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Playlist',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textDark)),
              TextButton(
                  onPressed: _showPlaylist,
                  child: Text('View All',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: _green,
                          fontWeight: FontWeight.w500))),
            ],
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _book.tracks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final isActive = i == _currentTrackIndex;
                return GestureDetector(
                  onTap: () {
                    _loadTrack(i);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        color: isActive ? _green : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(24)),
                    child: Center(
                        child: Text('Part ${i + 1}',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isActive ? Colors.white : _textDark))),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaylist() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Playlist',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textDark)),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _book.tracks.length,
                itemBuilder: (_, i) {
                  final track = _book.tracks[i];
                  final isActive = i == _currentTrackIndex;
                  return ListTile(
                    leading: CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            isActive ? _green : const Color(0xFFE0E0E0),
                        child: Text('${track.trackNumber}',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? Colors.white
                                    : const Color(0xFF666666)))),
                    title: Text(track.title,
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive ? _green : _textDark)),
                    subtitle: Text(_fmt(track.duration),
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: const Color(0xFF666666))),
                    trailing: isActive
                        ? const Icon(Icons.equalizer, color: _green)
                        : const Icon(Icons.play_circle_outline,
                            color: Color(0xFFCCCCCC)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _loadTrack(i);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
