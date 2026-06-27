import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/audiobook.dart';
import '../audio_player_service.dart';

/// Full-screen route — starts playback if needed, then shows the player UI.
class AudioBookPlayerPage extends StatefulWidget {
  final AudioBook audioBook;

  const AudioBookPlayerPage({super.key, required this.audioBook});

  @override
  State<AudioBookPlayerPage> createState() => _AudioBookPlayerPageState();
}

class _AudioBookPlayerPageState extends State<AudioBookPlayerPage> {
  @override
  void initState() {
    super.initState();
    final service = AudioPlayerService.instance;
    // Start playback if it's a different book or not playing
    if (service.currentBook?.id != widget.audioBook.id) {
      service.play(widget.audioBook);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _PlayerBody()),
    );
  }
}

/// Bottom sheet version — opened from mini player.
class AudioPlayerBottomSheet extends StatelessWidget {
  const AudioPlayerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.93,
      minChildSize: 0.5,
      maxChildSize: 0.93,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            const Expanded(child: _PlayerBody()),
          ],
        ),
      ),
    );
  }
}

// ─── Shared player body ─────────────────────────────────────────────────────

class _PlayerBody extends StatelessWidget {
  const _PlayerBody();

  @override
  Widget build(BuildContext context) {
    final service = AudioPlayerService.instance;

    return ValueListenableBuilder(
      valueListenable: service.bookNotifier,
      builder: (context, book, _) {
        if (book == null) {
          return const Center(child: Text('No audiobook loaded'));
        }
        return Column(
          children: [
            // Close / minimize
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, size: 28),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const Spacer(),
                  if (book.tracks.length > 1)
                    IconButton(
                      icon: const Icon(Icons.playlist_play),
                      onPressed: () => _showPlaylist(context, book, service),
                    ),
                ],
              ),
            ),
            const Spacer(),
            // Cover image
            _CoverImage(coverUrl: book.coverUrl),
            const SizedBox(height: 24),
            // Title & Author
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ValueListenableBuilder(
                valueListenable: service.trackIndexNotifier,
                builder: (context, trackIndex, _) {
                  final track = book.tracks[trackIndex];
                  return Column(
                    children: [
                      Text(
                        book.title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSubtitle,
                        ),
                      ),
                      if (book.tracks.length > 1) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${track.title} • Part ${trackIndex + 1} of ${book.tracks.length}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Seek bar
            _SeekBar(service: service),
            const SizedBox(height: 16),
            // Controls
            _Controls(service: service, book: book),
            const SizedBox(height: 20),
            // Speed slider
            _SpeedSlider(service: service),
            const Spacer(),
          ],
        );
      },
    );
  }

  void _showPlaylist(
      BuildContext context, AudioBook book, AudioPlayerService service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDFDFD),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
                    color: AppColors.textDark)),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: book.tracks.length,
                itemBuilder: (_, i) {
                  final track = book.tracks[i];
                  return ValueListenableBuilder(
                    valueListenable: service.trackIndexNotifier,
                    builder: (_, currentIdx, __) {
                      final isActive = i == currentIdx;
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: isActive
                              ? AppColors.accent
                              : AppColors.borderLight,
                          child: Text('${track.trackNumber}',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textSubtitle)),
                        ),
                        title: Text(track.title,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isActive
                                    ? AppColors.accent
                                    : AppColors.textDark)),
                        subtitle: Text(_fmt(track.duration),
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppColors.textSubtitle)),
                        trailing: isActive
                            ? const Icon(Icons.equalizer,
                                color: AppColors.accent)
                            : const Icon(Icons.play_circle_outline,
                                color: AppColors.textMuted),
                        onTap: () {
                          Navigator.pop(ctx);
                          service.loadTrack(i);
                        },
                      );
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

// ─── Cover Image ────────────────────────────────────────────────────────────

class _CoverImage extends StatelessWidget {
  final String coverUrl;
  const _CoverImage({required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: coverUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.accent.withValues(alpha: 0.1),
        child: const Icon(Icons.headphones_rounded,
            size: 80, color: AppColors.accent),
      );
}

// ─── Seek Bar ───────────────────────────────────────────────────────────────

class _SeekBar extends StatelessWidget {
  final AudioPlayerService service;
  const _SeekBar({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: service.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = service.duration ?? Duration.zero;
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
                  activeTrackColor: AppColors.accent,
                  inactiveTrackColor: AppColors.borderLight,
                  thumbColor: AppColors.accent,
                  overlayColor: AppColors.accent.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: (v) {
                    service.seekTo(Duration(
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
                            fontSize: 12, color: AppColors.textSubtitle)),
                    Text(_fmt(duration),
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textSubtitle)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Controls ───────────────────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  final AudioPlayerService service;
  final AudioBook book;
  const _Controls({required this.service, required this.book});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: service.trackIndexNotifier,
      builder: (context, trackIndex, _) {
        return StreamBuilder<PlayerState>(
          stream: service.playerStateStream,
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
                  color:
                      trackIndex > 0 ? AppColors.textDark : AppColors.textMuted,
                  onPressed: trackIndex > 0 ? service.skipPrevious : null,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.replay_10_rounded),
                  iconSize: 32,
                  color: AppColors.textDark,
                  onPressed: service.seekBackward,
                ),
                const SizedBox(width: 8),
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle),
                  child: isBuffering
                      ? const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                          iconSize: 36,
                          onPressed: service.playPause,
                        ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.forward_10_rounded),
                  iconSize: 32,
                  color: AppColors.textDark,
                  onPressed: service.seekForward,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded),
                  iconSize: 36,
                  color: trackIndex < book.tracks.length - 1
                      ? AppColors.textDark
                      : AppColors.textMuted,
                  onPressed: trackIndex < book.tracks.length - 1
                      ? service.skipNext
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─── Speed Slider ───────────────────────────────────────────────────────────

class _SpeedSlider extends StatelessWidget {
  final AudioPlayerService service;
  const _SpeedSlider({required this.service});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: service.speedNotifier,
      builder: (context, speed, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Speed',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSubtitle,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${speed}x',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 12),
                  activeTrackColor: AppColors.accent,
                  inactiveTrackColor: AppColors.borderLight,
                  thumbColor: AppColors.accent,
                  overlayColor: AppColors.accent.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: speed,
                  min: 0.5,
                  max: 2.0,
                  divisions: 6,
                  onChanged: (v) {
                    // Snap to nearest 0.25
                    final snapped = (v * 4).round() / 4;
                    service.setSpeed(snapped);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0.5x',
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: AppColors.textMuted)),
                  Text('2.0x',
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

String _fmt(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}
