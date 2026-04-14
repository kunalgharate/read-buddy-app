import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/tts_service.dart';

class EpubReaderPage extends StatefulWidget {
  final String url;
  final String title;
  final String language;

  const EpubReaderPage({
    super.key,
    required this.url,
    required this.title,
    this.language = 'en',
  });

  @override
  State<EpubReaderPage> createState() => _EpubReaderPageState();
}

class _EpubReaderPageState extends State<EpubReaderPage> {
  final EpubController _epubController = EpubController();
  final TtsService _ttsService = TtsService();

  bool _isDarkMode = false;
  bool _isTtsSpeaking = false;
  double _progress = 0.0;
  List<EpubChapter> _chapters = [];
  String? _selectedText;

  @override
  void initState() {
    super.initState();
    _ttsService.init(widget.language);
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  void _showChapters() {
    if (_chapters.isEmpty) {
      _showSnackBar('No chapters loaded yet');
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDFDFD),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ChapterSheet(
        chapters: _chapters,
        onTap: (chapter) {
          Navigator.pop(context);
          _epubController.display(cfi: chapter.href);
        },
      ),
    );
  }

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  void _onTextSelected(EpubTextSelection selection) {
    setState(() => _selectedText = selection.selectedText);
    if (_selectedText != null && _selectedText!.isNotEmpty) {
      _showHighlightOption(selection);
    }
  }

  void _showHighlightOption(EpubTextSelection selection) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDFDFD),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Text',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF052E44),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedText ?? '',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF666666),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _HighlightColorButton(
                  color: Colors.yellow,
                  onTap: () {
                    _epubController.addHighlight(
                      cfi: selection.selectionCfi,
                      color: Colors.yellow,
                    );
                    Navigator.pop(context);
                    _showSnackBar('Highlight added');
                  },
                ),
                const SizedBox(width: 12),
                _HighlightColorButton(
                  color: Colors.greenAccent,
                  onTap: () {
                    _epubController.addHighlight(
                      cfi: selection.selectionCfi,
                      color: Colors.greenAccent,
                    );
                    Navigator.pop(context);
                    _showSnackBar('Highlight added');
                  },
                ),
                const SizedBox(width: 12),
                _HighlightColorButton(
                  color: Colors.lightBlueAccent,
                  onTap: () {
                    _epubController.addHighlight(
                      cfi: selection.selectionCfi,
                      color: Colors.lightBlueAccent,
                    );
                    Navigator.pop(context);
                    _showSnackBar('Highlight added');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleTts() async {
    if (_isTtsSpeaking) {
      await _ttsService.stop();
      setState(() => _isTtsSpeaking = false);
      return;
    }

    // Try to get current page text from the EPUB controller
    String textToSpeak = '';
    try {
      final result = await _epubController.extractCurrentPageText();
      textToSpeak = result.toString().trim();
    } catch (_) {
      textToSpeak = '';
    }

    // Fall back to selected text if page extraction fails
    if (textToSpeak.trim().isEmpty) {
      textToSpeak = _selectedText ?? '';
    }

    if (textToSpeak.trim().isEmpty) {
      _showSnackBar('No readable text on this page. Try selecting text first.');
      return;
    }

    setState(() => _isTtsSpeaking = true);
    await _ttsService.speak(textToSpeak);
    _ttsService.setCompletionHandler(() {
      if (mounted) setState(() => _isTtsSpeaking = false);
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: const Color(0xFF2CE07F),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFDFDFD),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildEpubViewer()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _isDarkMode ? Colors.white : const Color(0xFF052E44),
        ),
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor:
          _isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFDFDFD),
      elevation: 0,
      iconTheme: IconThemeData(
        color: _isDarkMode ? Colors.white : const Color(0xFF052E44),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.list),
          onPressed: _showChapters,
          tooltip: 'Chapters',
        ),
        IconButton(
          icon: Icon(
            _isDarkMode ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: _toggleTheme,
          tooltip: 'Toggle theme',
        ),
      ],
    );
  }

  // Color inversion matrices for dark mode (no page reload)
  static const _invertMatrix = [
    -1.0, 0.0, 0.0, 0.0, 255.0,
    0.0, -1.0, 0.0, 0.0, 255.0,
    0.0, 0.0, -1.0, 0.0, 255.0,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ];
  static const _identityMatrix = [
    1.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ];

  Widget _buildEpubViewer() {
    // No ValueKey — we don't want to rebuild/reload the EPUB on theme toggle.
    // Use ColorFiltered for instant dark mode without reloading the file.
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(
        _isDarkMode ? _invertMatrix : _identityMatrix,
      ),
      child: EpubViewer(
        epubSource: EpubSource.fromUrl(widget.url),
        epubController: _epubController,
        onChaptersLoaded: (chapters) {
          setState(() => _chapters = chapters);
        },
        onEpubLoaded: () {},
        onRelocated: (value) {
          setState(() {
            _progress = value.progress;
          });
        },
        onTextSelected: _onTextSelected,
        displaySettings: EpubDisplaySettings(
          flow: EpubFlow.paginated,
          snap: true,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFFDFDFD),
        border: Border(
          top: BorderSide(
            color:
                _isDarkMode ? const Color(0xFF444444) : const Color(0xFFEAEAEA),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: _isDarkMode ? Colors.white : const Color(0xFF052E44),
              ),
              onPressed: () => _epubController.prev(),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: _isDarkMode
                        ? const Color(0xFF444444)
                        : const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2CE07F),
                    ),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(_progress * 100).toInt()}% complete',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _isDarkMode
                          ? Colors.white70
                          : const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: _isDarkMode ? Colors.white : const Color(0xFF052E44),
              ),
              onPressed: () => _epubController.next(),
            ),
            const SizedBox(width: 4),
            Container(
              width: 1,
              height: 24,
              color: _isDarkMode
                  ? const Color(0xFF444444)
                  : const Color(0xFFEAEAEA),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                _isTtsSpeaking ? Icons.stop_circle : Icons.play_circle,
                color: const Color(0xFF2CE07F),
              ),
              onPressed: _toggleTts,
              tooltip: _isTtsSpeaking ? 'Stop reading' : 'Read aloud',
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterSheet extends StatelessWidget {
  final List<EpubChapter> chapters;
  final ValueChanged<EpubChapter> onTap;

  const _ChapterSheet({
    required this.chapters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chapters',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF052E44),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF2CE07F),
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  title: Text(
                    chapter.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF052E44),
                    ),
                  ),
                  onTap: () => onTap(chapter),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightColorButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _HighlightColorButton({
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFEAEAEA),
            width: 2,
          ),
        ),
      ),
    );
  }
}
