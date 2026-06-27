import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/app_colors.dart';
import '../audio_player_service.dart';
import '../pages/audiobook_player_page.dart';

/// A persistent mini player widget shown at the bottom of ALL screens
/// when audio is active. Tapping expands to full player bottom sheet.
class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AudioPlayerService.instance;

    return ValueListenableBuilder(
      valueListenable: service.bookNotifier,
      builder: (context, book, _) {
        if (book == null) return const SizedBox.shrink();

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => AudioBookPlayerPage(audioBook: book),
              ),
            );
          },
          child: Container(
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Cover image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(12)),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: book.coverUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: book.coverUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _coverPlaceholder(),
                          )
                        : _coverPlaceholder(),
                  ),
                ),
                const SizedBox(width: 12),
                // Title and track info
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: service.trackIndexNotifier,
                    builder: (context, trackIndex, _) {
                      final track = book.tracks[trackIndex];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            track.title,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSubtitle,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Play/Pause
                StreamBuilder<PlayerState>(
                  stream: service.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return IconButton(
                      icon: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.accent,
                        size: 32,
                      ),
                      onPressed: service.playPause,
                    );
                  },
                ),
                // Stop & dismiss
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.textMuted, size: 20),
                  onPressed: service.stop,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _coverPlaceholder() => Container(
        color: AppColors.accent.withValues(alpha: 0.1),
        child: const Icon(Icons.headphones, color: AppColors.accent, size: 28),
      );
}
