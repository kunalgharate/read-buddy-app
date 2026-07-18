import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/book_request/presentation/pages/book_detail_page.dart'
    as request_detail;
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:read_buddy_app/features/books/presentation/bloc/book_bloc.dart';
import 'package:read_buddy_app/features/books/presentation/bloc/book_event.dart';
import 'package:read_buddy_app/features/books/presentation/bloc/book_state.dart';
import 'package:read_buddy_app/features/books/domain/entities/book.dart';

const _primary = Color(0xFF03405B);
const _green = Color(0xFF00C853);

class CategoryTab extends StatefulWidget {
  const CategoryTab({super.key});

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  String _searchQuery = "";
  CategoryEntity? _selectedCategory; // null means 'All' is selected

  @override
  void initState() {
    super.initState();
    // Load categories and books dynamically
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<BookBloc>().add(LoadBooks());
  }

  void _onCategorySelected(CategoryEntity? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Top Bar: Search Bar ─────────────────────────────────────
            _buildSearchBar(),

            // ─── Dynamic Content using both Blocs ────────────────────────
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, categoryState) {
                  return BlocBuilder<BookBloc, BookState>(
                    builder: (context, bookState) {
                      // ─── Loading State ─────────────────────────────────
                      if (categoryState is CategoryLoading ||
                          categoryState is CategoryInitial ||
                          bookState is BookLoading ||
                          bookState is BookInitial) {
                        return const Center(
                          child: CircularProgressIndicator(color: _green),
                        );
                      }

                      // ─── Error State ───────────────────────────────────
                      if (categoryState is CategoryError ||
                          bookState is BookError) {
                        final errMsg = categoryState is CategoryError
                            ? (categoryState).message
                            : (bookState as BookError).message;
                        return _buildErrorWidget(errMsg);
                      }

                      // ─── Loaded State ──────────────────────────────────
                      if (categoryState is CategoryLoaded &&
                          bookState is BookLoaded) {
                        final categories = categoryState.categories;
                        final books = bookState.books;

                        // Separate parents vs children for design structure
                        final parents = categories
                            .where((c) => c.parentCategoryName == null)
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── Pill Chips Navigation Row ───────────────
                            _buildCategoryNavigationRow(parents),

                            // ─── Main Content Toggler ─────────────────────
                            Expanded(
                              child: _selectedCategory == null
                                  ? _buildDefaultAllView(categories, books)
                                  : _buildExploreView(
                                      _selectedCategory!, books),
                            ),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
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

  // ─── Search Bar Widget ─────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search any Books',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: _primary),
              onPressed: () {
                // Future Filter/Sorting implementation
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Horizontal Category Navigation Bar ────────────────────────────────────
  Widget _buildCategoryNavigationRow(List<CategoryEntity> parentCategories) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: parentCategories.length + 1,
        itemBuilder: (context, index) {
          final isAllChip = index == 0;
          final category = isAllChip ? null : parentCategories[index - 1];
          final isSelected = isAllChip
              ? _selectedCategory == null
              : _selectedCategory?.id == category?.id;

          final label = isAllChip ? "All" : _capitalize(category!.title);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _onCategorySelected(category);
                }
              },
              selectedColor: _green.withValues(alpha: 0.12),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? _green : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? _green : Colors.transparent,
                  width: 1.5,
                ),
              ),
              showCheckmark: false,
              elevation: isSelected ? 0 : 2,
              shadowColor: Colors.black.withValues(alpha: 0.05),
            ),
          );
        },
      ),
    );
  }

  // ─── Default All View (Figma Screen 3 - Default category page) ──────────────
  Widget _buildDefaultAllView(
      List<CategoryEntity> allCategories, List<Book> allBooks) {
    // Show 'Popular Genres' using all categories (limit to 6 for premium design)
    final popularGenres = allCategories.take(8).toList();

    // Group books by category and filter by search query
    final filteredBooks = allBooks.where((book) {
      if (_searchQuery.isEmpty) return true;
      return book.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Popular Genres Section ─────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Popular Genres',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: popularGenres.length,
              itemBuilder: (context, index) {
                final category = popularGenres[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: InkWell(
                    onTap: () => _onCategorySelected(category),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Text(
                          _capitalize(category.title),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ─── Category Sections with Horizontal Books Lists ──────────────
          ...allCategories.map((category) {
            final categoryBooks = filteredBooks
                .where((book) => _isBookInCategory(book, category))
                .toList();

            // Only display the category section if it has books matching the search query
            if (categoryBooks.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _capitalize(category.title),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _onCategorySelected(category),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: categoryBooks.length,
                      itemBuilder: (context, index) {
                        return _buildHorizontalBookCard(categoryBooks[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Explore View (Figma Screen 2 - Once user select any category) ──────────
  Widget _buildExploreView(CategoryEntity category, List<Book> allBooks) {
    // Filter books belonging to this category and matching search query
    final categoryBooks = allBooks.where((book) {
      final matchesCategory = _isBookInCategory(book, category);
      final matchesSearch = _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore ${_capitalize(category.title)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                ),
              ),
              Text(
                '${categoryBooks.length} items',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: categoryBooks.isEmpty
              ? _buildNoBooksFound()
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: categoryBooks.length,
                  itemBuilder: (context, index) {
                    return _buildGridBookCard(categoryBooks[index]);
                  },
                ),
        ),
      ],
    );
  }

  // Helper function to check if a book belongs to a category (ID or title match)
  bool _isBookInCategory(Book book, CategoryEntity category) {
    final catName = category.title.toLowerCase().trim();

    // Primary: category object match (when DB has proper category data)
    if (book.bookCategory.id.isNotEmpty &&
        book.bookCategory.id == category.id) {
      return true;
    }
    if (book.bookCategory.categoryName.isNotEmpty &&
        book.bookCategory.categoryName.toLowerCase() == catName) {
      return true;
    }

    // Fallback: genre match (current state — category[] is empty in DB)
    final genre = book.genre.toLowerCase().trim();
    if (genre.isEmpty) return false;

    // Exact match: "fiction" == "fiction"
    if (genre == catName) return true;

    // Partial: "fiction" inside "science fiction", "literary fiction" or vice versa
    if (catName.contains(genre) || genre.contains(catName)) return true;

    return false;
  }

  // ─── Horizontal Book Card Widget ───────────────────────────────────────────
  Widget _buildHorizontalBookCard(Book book) {
    return GestureDetector(
      onTap: () => _showBookDetailsPopup(book),
      child: Container(
        width: 135,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: book.bookimage.isNotEmpty
                    ? Image.network(
                        book.bookimage,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgPlaceholder(),
                      )
                    : _imgPlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Formatted Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'E Book',
                          style: TextStyle(
                            color: _green,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '3 Days',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Grid Book Card Widget (Explore Screen) ────────────────────────────────
  Widget _buildGridBookCard(Book book) {
    return GestureDetector(
      onTap: () => _showBookDetailsPopup(book),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed height image — no more Expanded stretching
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: book.bookimage.isNotEmpty
                  ? Image.network(
                      book.bookimage,
                      height: 160, // fixed
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _imgPlaceholder(height: 160),
                    )
                  : _imgPlaceholder(height: 160),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.genre.isNotEmpty
                        ? _capitalize(book.genre)
                        : _capitalize(book.bookCategory.categoryName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'E Book',
                          style: TextStyle(
                            color: _green,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '3 Days',
                        style:
                            TextStyle(fontSize: 9, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Navigate to Book Detail Page (user-facing) ─────────────────────────
  void _showBookDetailsPopup(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => request_detail.BookDetailPage(bookId: book.id)),
    );
  }

  // ─── Generic Placeholders & Helpers ────────────────────────────────────────
  Widget _imgPlaceholder({double height = 160}) => Container(
        height: height,
        color: const Color(0xFFE8EDF2),
        child: const Center(
          child: Icon(Icons.book, size: 40, color: Color(0xFFB0BEC5)),
        ),
      );
  Widget _buildNoBooksFound() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No books found',
            style: TextStyle(
                color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<CategoryBloc>().add(LoadCategories());
                context.read<BookBloc>().add(LoadBooks());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
