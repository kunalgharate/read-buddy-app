import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/bookcrud/data/dataresources/book_crud_remote_resources.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _pageSize = 50;
  static const _formatValues = <String>['', 'physical', 'ebook', 'audio', 'video'];
  static const _formatLabels = <String>['All', 'Physical', 'E-Book', 'Audio', 'Video'];

  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  Timer? _debounce;
  List<BookCrudEntity> _results = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasSearched = false;
  String? _errorMessage;
  int _searchGeneration = 0;
  String _activeQuery = '';
  int _page = 1;
  int _totalPages = 1;
  int _formatIndex = 0;

  String? get _formatValue {
    final value = _formatValues[_formatIndex];
    return value.isEmpty ? null : value;
  }

  bool get _hasMore => _page < _totalPages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 300) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _resetSearch() {
    _searchGeneration++;
    setState(() {
      _results = [];
      _hasSearched = false;
      _errorMessage = null;
      _isLoading = false;
      _isLoadingMore = false;
      _activeQuery = '';
      _page = 1;
      _totalPages = 1;
    });
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      _resetSearch();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return;
    _searchGeneration++;
    final gen = _searchGeneration;
    _activeQuery = trimmed;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isLoadingMore = false;
    });
    try {
      final ds = getIt<BookCrudRemoteDataSource>();
      final result = await ds.searchBooksPaged(
        query: RegExp.escape(trimmed),
        format: _formatValue,
        page: 1,
        limit: _pageSize,
      );
      if (_searchGeneration != gen) return;
      if (mounted) {
        setState(() {
          _results = result.books;
          _page = result.page;
          _totalPages = result.totalPages;
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

  Future<void> _loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _activeQuery.isEmpty) {
      return;
    }
    final gen = _searchGeneration;
    setState(() => _isLoadingMore = true);
    try {
      final ds = getIt<BookCrudRemoteDataSource>();
      final result = await ds.searchBooksPaged(
        query: RegExp.escape(_activeQuery),
        format: _formatValue,
        page: _page + 1,
        limit: _pageSize,
      );
      if (_searchGeneration != gen) return;
      if (mounted) {
        setState(() {
          _results.addAll(result.books);
          _page = result.page;
          _totalPages = result.totalPages;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted && _searchGeneration == gen) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onFormatSelected(int index) {
    setState(() => _formatIndex = index);
    final query = _searchController.text.trim();
    if (query.length >= 2) {
      _debounce?.cancel();
      _performSearch(query);
    }
  }

  void _onClearPressed() {
    _debounce?.cancel();
    _searchController.clear();
    _resetSearch();
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by title, author...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _onClearPressed,
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
          if (_hasSearched) _buildFormatChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
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
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No books found for "${_searchController.text}"',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 15,
                                  ),
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

  Widget _buildFormatChips() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _formatLabels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final selected = _formatIndex == index;
            return ChoiceChip(
              label: Text(_formatLabels[index]),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => _onFormatSelected(index),
              labelStyle: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : Colors.grey[700],
              ),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.grey[100],
            );
          },
        ),
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
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildResultTile(_results[index]),
          ),
        ),
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (!_hasMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'End of results',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultTile(BookCrudEntity book) {
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
  }
}