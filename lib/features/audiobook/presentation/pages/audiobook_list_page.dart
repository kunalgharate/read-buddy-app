import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/audiobook.dart';
import '../data/dummy_audiobooks.dart';

class AudioBookListPage extends StatelessWidget {
  const AudioBookListPage({super.key});

  static const _textDark = Color(0xFF052E44);
  static const _bg = Color(0xFFFDFDFD);

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
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
          'Audiobooks',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dummyAudioBooks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final book = dummyAudioBooks[index];
          return _AudioBookCard(
            book: book,
            formatDuration: _formatDuration,
            onTap: () => Navigator.pushNamed(
              context,
              '/audiobook-player',
              arguments: book,
            ),
          );
        },
      ),
    );
  }
}

class _AudioBookCard extends StatelessWidget {
  final AudioBook book;
  final String Function(Duration) formatDuration;
  final VoidCallback onTap;

  const _AudioBookCard({
    required this.book,
    required this.formatDuration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final trackLabel =
        book.isSinglePart ? 'Single Part' : '${book.tracks.length} Parts';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEAEAEA)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF2CE07F).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.headphones_rounded,
                color: Color(0xFF2CE07F),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF052E44),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatDuration(book.totalDuration),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.playlist_play,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trackLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF2CE07F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.play_circle_filled,
              color: Color(0xFF2CE07F),
              size: 36,
            ),
          ],
        ),
      ),
    );
  }
}
