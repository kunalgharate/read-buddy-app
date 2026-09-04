import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';

/// Bottom sheet dialog to add a book to a library's inventory.
/// Steps: search book → pick variant → pick format → enter copies → submit.
class AddBookToLibraryDialog extends StatefulWidget {
  final String libraryId;
  final String libraryName;

  const AddBookToLibraryDialog({
    super.key,
    required this.libraryId,
    required this.libraryName,
  });

  /// Show this dialog and return the created inventory data on success.
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required String libraryId,
    required String libraryName,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddBookToLibraryDialog(
        libraryId: libraryId,
        libraryName: libraryName,
      ),
    );
  }

  @override
  State<AddBookToLibraryDialog> createState() =>
      _AddBookToLibraryDialogState();
}

class _AddBookToLibraryDialogState extends State<AddBookToLibraryDialog> {
  final _searchCtrl = TextEditingController();
  final _copiesCtrl = TextEditingController(text: '1');

  // Search results
  List<Map<String, dynamic>> _books = [];
  bool _searching = false;

  // Selected book
  Map<String, dynamic>? _selectedBook;

  // Variants for selected book
  List<Map<String, dynamic>> _variants = [];
  bool _loadingVariants = false;

  // Selected variant & format
  Map<String, dynamic>? _selectedVariant;
  String? _selectedFormatType;

  bool _submitting = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _copiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchBooks(String query) async {
    if (query.trim().length < 2) {
      setState(() => _books = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final dio = getIt<Dio>();
      final response = await dio.get(
        ApiConstants.searchBooks,
        queryParameters: {'q': query.trim(), 'limit': 15},
      );
      final data = response.data;
      final list = data['books'] ?? data['data'] ?? data;
      setState(() {
        _books = list is List ? List<Map<String, dynamic>>.from(list) : [];
        _searching = false;
      });
    } catch (e) {
      setState(() => _searching = false);
    }
  }

  Future<void> _selectBook(Map<String, dynamic> book) async {
    setState(() {
      _selectedBook = book;
      _books = [];
      _searchCtrl.text = book['title']?.toString() ?? '';
      _variants = [];
      _selectedVariant = null;
      _selectedFormatType = null;
      _loadingVariants = true;
    });

    // Fetch variants for this book
    try {
      final dio = getIt<Dio>();
      final bookId = book['_id'] ?? book['id'];
      final response = await dio.get(
        '${ApiConstants.bookVariants}/book/$bookId',
      );
      final data = response.data;
      final list = data['variants'] ?? data['data'] ?? data;
      setState(() {
        _variants =
            list is List ? List<Map<String, dynamic>>.from(list) : [];
        _loadingVariants = false;
      });
    } catch (e) {
      setState(() => _loadingVariants = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load variants: $e')),
        );
      }
    }
  }

  List<String> _getPhysicalFormats() {
    if (_selectedVariant == null) return [];
    final formats = _selectedVariant!['formats'] as List<dynamic>? ?? [];
    return formats
        .where((f) =>
            f['type'] == 'hardcover' || f['type'] == 'paperback')
        .map((f) => f['type'].toString())
        .toList();
  }

  Future<void> _submit() async {
    if (_selectedBook == null ||
        _selectedVariant == null ||
        _selectedFormatType == null) {
      return;
    }

    final copies = int.tryParse(_copiesCtrl.text);
    if (copies == null || copies < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least 1 copy')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final dio = getIt<Dio>();
      final response = await dio.post(
        ApiConstants.libraryInventory,
        data: {
          'libraryId': widget.libraryId,
          'bookId': _selectedBook!['_id'] ?? _selectedBook!['id'],
          'variantId': _selectedVariant!['_id'] ?? _selectedVariant!['id'],
          'formatType': _selectedFormatType,
          'totalCopies': copies,
        },
      );

      if (mounted) {
        Navigator.pop(context, response.data);
      }
    } on DioException catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        final msg =
            e.response?.data?['error']?.toString() ?? 'Failed to add book';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                'Add Book to ${widget.libraryName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Step 1: Search book
            const Text('Search Book',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by title...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: _selectedBook != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedBook = null;
                            _variants = [];
                            _selectedVariant = null;
                            _selectedFormatType = null;
                            _searchCtrl.clear();
                          });
                        },
                      )
                    : null,
              ),
              enabled: _selectedBook == null,
              onChanged: _searchBooks,
            ),

            // Search results
            if (_searching)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            if (_books.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.book, size: 20),
                      title: Text(book['title']?.toString() ?? ''),
                      subtitle: Text(
                        book['author']?.toString() ?? '',
                        style: const TextStyle(fontSize: 11),
                      ),
                      onTap: () => _selectBook(book),
                    );
                  },
                ),
              ),

            // Step 2: Select variant
            if (_selectedBook != null) ...[
              const SizedBox(height: 16),
              const Text('Select Language Variant',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              if (_loadingVariants)
                const Center(
                    child: CircularProgressIndicator(strokeWidth: 2))
              else if (_variants.isEmpty)
                const Text(
                  'No variants found. Create a variant for this book first.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                )
              else
                Wrap(
                  spacing: 8,
                  children: _variants.map((v) {
                    final lang = v['language']?.toString() ?? 'Unknown';
                    final isSelected = _selectedVariant == v;
                    return ChoiceChip(
                      label: Text(lang),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedVariant = v;
                          _selectedFormatType = null;
                        });
                      },
                    );
                  }).toList(),
                ),
            ],

            // Step 3: Select format
            if (_selectedVariant != null) ...[
              const SizedBox(height: 16),
              const Text('Select Format',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Builder(builder: (context) {
                final formats = _getPhysicalFormats();
                if (formats.isEmpty) {
                  return const Text(
                    'No physical formats (hardcover/paperback) in this variant.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  );
                }
                return Wrap(
                  spacing: 8,
                  children: formats.map((f) {
                    return ChoiceChip(
                      label: Text(f),
                      selected: _selectedFormatType == f,
                      onSelected: (_) {
                        setState(() => _selectedFormatType = f);
                      },
                    );
                  }).toList(),
                );
              }),
            ],

            // Step 4: Copies count
            if (_selectedFormatType != null) ...[
              const SizedBox(height: 16),
              const Text('Number of Copies',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _copiesCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 10',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],

            // Submit button
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    _selectedFormatType != null && !_submitting
                        ? _submit
                        : null,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add to Library'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
