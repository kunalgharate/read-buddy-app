import 'package:flutter/material.dart';

class Mybook extends StatefulWidget {
  const Mybook({super.key});

  @override
  State<Mybook> createState() => _MybookState();
}

class _MybookState extends State<Mybook> with SingleTickerProviderStateMixin {
  static const _textColor = Color(0xFF052E44);
  static const _bgColor = Color(0xFFFDFDFD);
  static const _primary = Color(0xFF2CE07F);

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'My Books',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: _textColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: _primary,
          unselectedLabelColor: const Color(0xFF9E9E9E),
          indicatorColor: _primary,
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Reading'),
            Tab(text: 'Completed'),
            Tab(text: 'Wishlist'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ReadingTab(),
          _CompletedTab(),
          _WishlistTab(),
        ],
      ),
    );
  }
}

// ── Dummy data ──────────────────────────────────────────────

class _BookItem {
  final String title;
  final String author;
  final double progress;
  final String? completedDate;

  const _BookItem({
    required this.title,
    required this.author,
    this.progress = 0.0,
    this.completedDate,
  });
}

const _readingBooks = [
  _BookItem(
    title: 'Atomic Habits',
    author: 'James Clear',
    progress: 0.65,
  ),
  _BookItem(
    title: 'The Psychology of Money',
    author: 'Morgan Housel',
    progress: 0.30,
  ),
  _BookItem(
    title: 'Deep Work',
    author: 'Cal Newport',
    progress: 0.80,
  ),
];

const _completedBooks = [
  _BookItem(
    title: 'Rich Dad Poor Dad',
    author: 'Robert Kiyosaki',
    completedDate: '12 May 2025',
  ),
  _BookItem(
    title: 'The Alchemist',
    author: 'Paulo Coelho',
    completedDate: '28 Apr 2025',
  ),
];

const _wishlistBooks = [
  _BookItem(title: 'Sapiens', author: 'Yuval Noah Harari'),
  _BookItem(
    title: 'The Design of Everyday Things',
    author: 'Don Norman',
  ),
  _BookItem(
    title: 'Thinking, Fast and Slow',
    author: 'Daniel Kahneman',
  ),
];

// ── Tab widgets ─────────────────────────────────────────────

class _ReadingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _readingBooks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _BookCard(
        book: _readingBooks[i],
        trailing: _ProgressIndicator(
          progress: _readingBooks[i].progress,
        ),
      ),
    );
  }
}

class _CompletedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _completedBooks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _BookCard(
        book: _completedBooks[i],
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF2CE07F),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              _completedBooks[i].completedDate ?? '',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _wishlistBooks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _BookCard(
        book: _wishlistBooks[i],
        trailing: const Icon(
          Icons.bookmark_outline,
          color: Color(0xFF052E44),
        ),
      ),
    );
  }
}

// ── Shared widgets ──────────────────────────────────────────

class _BookCard extends StatelessWidget {
  final _BookItem book;
  final Widget trailing;

  const _BookCard({required this.book, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Book cover placeholder
          Container(
            width: 56,
            height: 74,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.menu_book,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF052E44),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final double progress;

  const _ProgressIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF2CE07F),
                ),
              ),
              Center(
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF052E44),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
