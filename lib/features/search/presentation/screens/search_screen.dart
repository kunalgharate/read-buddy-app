import 'dart:async';

import 'package:flutter/material.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/search_book.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<BookCrudEntity> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  int _searchGeneration = 0;

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      _searchGeneration++;
      setState(() {
        _results = [];
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    _searchGeneration++;
    final gen = _searchGeneration;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final usecase = getIt<SearchBookUsecase>();
      final results = await usecase(Uri.encodeComponent(query));
      if (_searchGeneration != gen) return;
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (_searchGeneration != gen) return;
      if (mounted) {
        setState(() {
          _results = [];
          _isLoading = false;
          _hasSearched = true;
          _errorMessage = 'Search failed. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Books'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by title, author, genre...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _debounce?.cancel();
                          _searchGeneration++;
                          _searchController.clear();
                          setState(() {
                            _results = [];
                            _hasSearched = false;
                            _errorMessage = null;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red[300]),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 15),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                final query = _searchController.text.trim();
                                if (query.length >= 2) {
                                  _performSearch(query);
                                }
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _hasSearched && _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off,
                                    size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                Text(
                                  'No books found for "${_searchController.text}"',
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 15),
                                ),
                              ],
                            ),
                          )
                        : !_hasSearched
                            ? _buildSuggestions()
                            : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    const topics = [
      'Education',
      'Fiction',
      'Science',
      'History',
      'Psychology',
      'Biography',
      'Self-Help',
      'Technology',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Topics',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topics.map((topic) {
              return ActionChip(
                label: Text(topic),
                onPressed: () {
                  _debounce?.cancel();
                  _searchController.text = topic;
                  _performSearch(topic);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final book = _results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 50,
              height: 70,
              child: book.coverImageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: book.coverImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.book, color: Colors.grey),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.book, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.book, color: Colors.grey),
                    ),
            ),
          ),
          title: Text(
            book.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            'by ${book.author}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            final model = BookCrudModel.fromEntity(book);
            Navigator.pushNamed(context, '/book-variants', arguments: model);
          },
        );
      },
    );
  }
}
