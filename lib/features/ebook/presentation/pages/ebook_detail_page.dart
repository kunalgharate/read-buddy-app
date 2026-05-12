import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/mixins/connectivity_mixin.dart';
import '../../domain/entities/ebook.dart';

class EBookDetailPage extends StatefulWidget {
  final EBook ebook;

  const EBookDetailPage({super.key, required this.ebook});

  @override
  State<EBookDetailPage> createState() => _EBookDetailPageState();
}

class _EBookDetailPageState extends State<EBookDetailPage>
    with ConnectivityMixin {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.ebook.availableLanguages.first.code;
  }

  void _openReader(String url, String title, EBookFormat format) {
    if (!requireConnectivity()) return;
    final route = format == EBookFormat.epub ? '/epub-reader' : '/pdf-reader';
    Navigator.pushNamed(
      context,
      route,
      arguments: {
        'url': url,
        'title': title,
        'language': _selectedLanguage,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ebook = widget.ebook;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: Text(
          ebook.title,
          style: GoogleFonts.poppins(
            fontSize: 18,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover placeholder
            Center(
              child: Container(
                width: 140,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF052E44),
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Center(
              child: Text(
                ebook.title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF052E44),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            // Author
            Center(
              child: Text(
                'by ${ebook.author}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF666666),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Language selector
            Text(
              'Language',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF052E44),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ebook.availableLanguages.map((lang) {
                final isSelected = lang.code == _selectedLanguage;
                return ChoiceChip(
                  label: Text(lang.name),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedLanguage = lang.code;
                    });
                  },
                  selectedColor: const Color(0xFF2CE07F),
                  backgroundColor: const Color(0xFFE0E0E0),
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF052E44),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Content section
            if (ebook.type == EBookType.single)
              _buildSinglePartContent()
            else
              _buildMultiChapterContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSinglePartContent() {
    final chapter = widget.ebook.chapters.first;
    final url = chapter.urlsByLanguage[_selectedLanguage];
    final hasUrl = url != null && url.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: hasUrl
            ? () => _openReader(
                  url,
                  widget.ebook.title,
                  chapter.format,
                )
            : null,
        icon: const Icon(Icons.chrome_reader_mode),
        label: Text(
          'Read Now',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2CE07F),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE0E0E0),
          disabledForegroundColor: const Color(0xFF999999),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiChapterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chapters',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF052E44),
          ),
        ),
        const SizedBox(height: 8),
        ...widget.ebook.chapters.map((chapter) {
          final url = chapter.urlsByLanguage[_selectedLanguage];
          final hasUrl = url != null && url.isNotEmpty;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: hasUrl ? Colors.white : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFEAEAEA),
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 16,
                backgroundColor:
                    hasUrl ? const Color(0xFF2CE07F) : const Color(0xFFE0E0E0),
                child: Text(
                  '${chapter.chapterNumber}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasUrl ? Colors.white : const Color(0xFF999999),
                  ),
                ),
              ),
              title: Text(
                chapter.title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: hasUrl
                      ? const Color(0xFF052E44)
                      : const Color(0xFF999999),
                ),
              ),
              trailing: Icon(
                Icons.play_circle_outline,
                color:
                    hasUrl ? const Color(0xFF2CE07F) : const Color(0xFFE0E0E0),
              ),
              onTap: hasUrl
                  ? () => _openReader(url, chapter.title, chapter.format)
                  : null,
            ),
          );
        }),
      ],
    );
  }
}
