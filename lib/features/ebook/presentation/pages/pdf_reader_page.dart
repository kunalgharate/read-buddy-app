import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncpdf;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/services/file_cache_service.dart';
import '../services/tts_service.dart';

class PdfReaderPage extends StatefulWidget {
  final String url;
  final String title;
  final String language;

  const PdfReaderPage({
    super.key,
    required this.url,
    required this.title,
    this.language = 'en',
  });

  @override
  State<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends State<PdfReaderPage> {
  late PdfViewerController _pdfController;
  late PdfTextSearchResult _searchResult;
  final TtsService _ttsService = TtsService();
  syncpdf.PdfDocument? _syncPdfDoc;
  File? _cachedFile;
  bool _isFileLoading = true;

  bool _isDarkMode = false;
  bool _isSearching = false;
  bool _isTtsSpeaking = false;
  int _currentPage = 1;
  int _totalPages = 0;
  double _ttsSpeed = 0.5;

  final TextEditingController _searchController = TextEditingController();
  final List<int> _bookmarkedPages = [];
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  String get _ttsSpeedLabel {
    final map = <double, String>{
      0.25: '0.5x',
      0.35: '0.75x',
      0.5: '1x',
      0.65: '1.25x',
      0.8: '1.5x',
      1.0: '2x',
    };
    return map[_ttsSpeed] ?? '1x';
  }

  // Color inversion matrix for dark mode
  static const List<double> _invertMatrix = [
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0, //
  ];

  static const List<double> _identityMatrix = [
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0, //
    0, 0, 1, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    _searchResult = PdfTextSearchResult();
    _ttsService.init(widget.language);
    _loadCachedPdf();
  }

  /// Download and cache the PDF file. On second open, loads from cache instantly.
  Future<void> _loadCachedPdf() async {
    try {
      final file = await FileCacheService.instance.getFile(widget.url);
      if (!mounted) return;
      final bytes = await file.readAsBytes();
      _syncPdfDoc = syncpdf.PdfDocument(inputBytes: bytes);
      setState(() {
        _cachedFile = file;
        _isFileLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isFileLoading = false);
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    _searchController.dispose();
    _searchResult.clear();
    _syncPdfDoc?.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchResult.clear();
        _searchController.clear();
      }
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      _searchResult.clear();
      return;
    }
    _searchResult = _pdfController.searchText(query);
    _searchResult.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _toggleBookmark() {
    setState(() {
      if (_bookmarkedPages.contains(_currentPage)) {
        _bookmarkedPages.remove(_currentPage);
        _showSnackBar('Bookmark removed');
      } else {
        _bookmarkedPages.add(_currentPage);
        _showSnackBar('Page $_currentPage bookmarked');
      }
    });
  }

  void _showBookmarks() {
    if (_bookmarkedPages.isEmpty) {
      _showSnackBar('No bookmarks yet');
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDFDFD),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _BookmarkSheet(
        bookmarks: _bookmarkedPages,
        onTap: (page) {
          Navigator.pop(context);
          _pdfController.jumpToPage(page);
        },
      ),
    );
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

  Future<void> _toggleTts() async {
    if (_isTtsSpeaking) {
      await _ttsService.stop();
      setState(() => _isTtsSpeaking = false);
      return;
    }

    // Extract text from current page using syncfusion_flutter_pdf
    String pageText = '';
    if (_syncPdfDoc != null) {
      try {
        final extractor = syncpdf.PdfTextExtractor(_syncPdfDoc!);
        pageText = extractor
            .extractText(startPageIndex: _currentPage - 1)
            .trim();
      } catch (_) {
        pageText = '';
      }
    }

    if (pageText.isEmpty) {
      _showSnackBar('No readable text found on this page');
      return;
    }

    setState(() => _isTtsSpeaking = true);
    await _ttsService.speak(pageText);
    _ttsService.setCompletionHandler(() {
      if (mounted) setState(() => _isTtsSpeaking = false);
    });
  }

  void _changeTtsSpeed() {
    // Android/iOS: 0.0 = slowest, 0.5 = normal, 1.0 = fastest
    final speeds = [0.25, 0.35, 0.5, 0.65, 0.8, 1.0];
    final labels = ['0.5x', '0.75x', '1x', '1.25x', '1.5x', '2x'];
    final currentIndex = speeds.indexOf(_ttsSpeed);
    final nextIndex =
        currentIndex < 0 ? 2 : (currentIndex + 1) % speeds.length;
    setState(() {
      _ttsSpeed = speeds[nextIndex];
      _ttsService.setSpeed(_ttsSpeed);
    });
    _showSnackBar('TTS speed: ${labels[nextIndex]}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFDFDFD),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_isSearching) _buildSearchBar(),
          Expanded(child: _buildPdfViewer()),
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
          icon: const Icon(Icons.search),
          onPressed: _toggleSearch,
          tooltip: 'Search',
        ),
        IconButton(
          icon: Icon(
            _isDarkMode ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          tooltip: 'Toggle theme',
        ),
        IconButton(
          icon: Icon(
            _bookmarkedPages.contains(_currentPage)
                ? Icons.bookmark
                : Icons.bookmark_border,
            color: _bookmarkedPages.contains(_currentPage)
                ? const Color(0xFF2CE07F)
                : null,
          ),
          onPressed: _toggleBookmark,
          tooltip: 'Bookmark',
        ),
        IconButton(
          icon: const Icon(Icons.bookmarks_outlined),
          onPressed: _showBookmarks,
          tooltip: 'View bookmarks',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _isDarkMode ? Colors.white : const Color(0xFF052E44),
              ),
              decoration: InputDecoration(
                hintText: 'Search in PDF...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF999999),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
              onSubmitted: _performSearch,
            ),
          ),
          if (_searchResult.hasResult) ...[
            const SizedBox(width: 8),
            Text(
              '${_searchResult.currentInstanceIndex}/'
              '${_searchResult.totalInstanceCount}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _isDarkMode ? Colors.white70 : const Color(0xFF666666),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.navigate_before,
                color: _isDarkMode ? Colors.white : const Color(0xFF052E44),
              ),
              onPressed: () => _searchResult.previousInstance(),
              iconSize: 20,
            ),
            IconButton(
              icon: Icon(
                Icons.navigate_next,
                color: _isDarkMode ? Colors.white : const Color(0xFF052E44),
              ),
              onPressed: () => _searchResult.nextInstance(),
              iconSize: 20,
            ),
          ],
          IconButton(
            icon: Icon(
              Icons.close,
              color: _isDarkMode ? Colors.white : const Color(0xFF052E44),
            ),
            onPressed: _toggleSearch,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    // Show loader while file is being cached
    if (_isFileLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF2CE07F)),
            SizedBox(height: 12),
            Text('Loading PDF...'),
          ],
        ),
      );
    }

    // Use cached local file for instant loading on repeat visits
    final Widget viewer;
    if (_cachedFile != null) {
      viewer = SfPdfViewer.file(
        _cachedFile!,
        key: _pdfViewerKey,
        controller: _pdfController,
        canShowScrollHead: true,
        canShowPaginationDialog: true,
        enableTextSelection: true,
        onDocumentLoaded: (details) {
          setState(() => _totalPages = details.document.pages.count);
        },
        onPageChanged: (details) {
          setState(() => _currentPage = details.newPageNumber);
        },
      );
    } else {
      // Fallback to network if caching failed
      viewer = SfPdfViewer.network(
        widget.url,
        key: _pdfViewerKey,
        controller: _pdfController,
        canShowScrollHead: true,
        canShowPaginationDialog: true,
        enableTextSelection: true,
        onDocumentLoaded: (details) {
          setState(() => _totalPages = details.document.pages.count);
        },
        onPageChanged: (details) {
          setState(() => _currentPage = details.newPageNumber);
        },
      );
    }

    return ColorFiltered(
      colorFilter: ColorFilter.matrix(
        _isDarkMode ? _invertMatrix : _identityMatrix,
      ),
      child: viewer,
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
              onPressed:
                  _currentPage > 1 ? () => _pdfController.previousPage() : null,
            ),
            Expanded(
              child: Center(
                child: Text(
                  _totalPages > 0
                      ? 'Page $_currentPage of $_totalPages'
                      : 'Loading...',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color:
                        _isDarkMode ? Colors.white70 : const Color(0xFF052E44),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: _isDarkMode ? Colors.white : const Color(0xFF052E44),
              ),
              onPressed: _currentPage < _totalPages
                  ? () => _pdfController.nextPage()
                  : null,
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 24,
              color: _isDarkMode
                  ? const Color(0xFF444444)
                  : const Color(0xFFEAEAEA),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                _isTtsSpeaking ? Icons.stop_circle : Icons.play_circle,
                color: const Color(0xFF2CE07F),
              ),
              onPressed: _toggleTts,
              tooltip: _isTtsSpeaking ? 'Stop reading' : 'Read aloud',
            ),
            GestureDetector(
              onTap: _changeTtsSpeed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2CE07F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _ttsSpeedLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2CE07F),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkSheet extends StatelessWidget {
  final List<int> bookmarks;
  final ValueChanged<int> onTap;

  const _BookmarkSheet({
    required this.bookmarks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<int>.from(bookmarks)..sort();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bookmarks',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF052E44),
            ),
          ),
          const SizedBox(height: 12),
          ...sorted.map(
            (page) => ListTile(
              leading: const Icon(
                Icons.bookmark,
                color: Color(0xFF2CE07F),
              ),
              title: Text(
                'Page $page',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF052E44),
                ),
              ),
              onTap: () => onTap(page),
            ),
          ),
        ],
      ),
    );
  }
}
