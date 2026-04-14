import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/ebook.dart';
import '../data/dummy_ebooks.dart';

class EBookListPage extends StatelessWidget {
  const EBookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: Text(
          'eBooks',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF052E44),
          ),
        ),
        backgroundColor: const Color(0xFFFDFDFD),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF052E44),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dummyEBooks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ebook = dummyEBooks[index];
          return _EBookCard(
            ebook: ebook,
            onTap: () => Navigator.pushNamed(
              context,
              '/ebook-detail',
              arguments: ebook,
            ),
          );
        },
      ),
    );
  }
}

class _EBookCard extends StatelessWidget {
  final EBook ebook;
  final VoidCallback onTap;

  const _EBookCard({
    required this.ebook,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chapterCount = ebook.chapters.length;
    final typeLabel =
        ebook.type == EBookType.single ? 'Single' : '$chapterCount Chapters';

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
            // Book cover placeholder
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF052E44),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            // Book info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ebook.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF052E44),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ebook.author,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Language badges
                      ...ebook.availableLanguages.map(
                        (lang) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _LanguageBadge(
                            label: lang.code.toUpperCase(),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Type indicator
                      Text(
                        typeLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2CE07F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF052E44),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageBadge extends StatelessWidget {
  final String label;

  const _LanguageBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF052E44),
        ),
      ),
    );
  }
}
