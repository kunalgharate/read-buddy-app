import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_variant_entity.dart';

class BookCrudDetailPage extends StatelessWidget {
  final BookCrudEntity book;

  const BookCrudDetailPage({super.key, required this.book});

  List<BookVariantEntity> get _variants {
    if (book is BookCrudModel) return (book as BookCrudModel).variants;
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF042153),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  book.coverImageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: book.coverImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: const Color(0xFF042153),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _placeholderCover(),
                        )
                      : _placeholderCover(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(200),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (book.author.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'by ${book.author}',
                            style: TextStyle(
                                color: Colors.white.withAlpha(210),
                                fontSize: 14),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Manage Variants Button ────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/book-variants',
                          arguments: BookCrudModel.fromEntity(book),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      label: const Text(
                        'Add / Manage Variants',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF042153),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Book Details ──────────────────────────────────────
                  _sectionTitle('Book Details'),
                  _detailCard([
                    _row(Icons.person_rounded, 'Author', book.author),
                    if (book.publisher.isNotEmpty)
                      _row(Icons.business_rounded, 'Publisher', book.publisher),
                    if (book.category.isNotEmpty)
                      _row(Icons.category_rounded, 'Category', book.category),
                    if (book.genre.isNotEmpty)
                      _row(Icons.local_library_rounded, 'Genre', book.genre),
                  ]),
                  const SizedBox(height: 16),

                  // ── Description ───────────────────────────────────────
                  if (book.description.isNotEmpty) ...[
                    _sectionTitle('Description'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        book.description,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey[800], height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Tags ──────────────────────────────────────────────
                  if (book.tags.isNotEmpty) ...[
                    _sectionTitle('Tags'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: book.tags
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: const Color(0xFF6366F1)),
                                  ),
                                  child: Text(tag,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF4338CA),
                                          fontWeight: FontWeight.w500)),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Variants Section ──────────────────────────────────
                  if (_variants.isNotEmpty) ...[
                    _sectionTitle('Language Variants (${_variants.length})'),
                    ..._variants.map(_buildVariantCard),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Variant Card ─────────────────────────────────────────────────────

  Widget _buildVariantCard(BookVariantEntity variant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF042153).withAlpha(12),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.language_rounded,
                    color: Color(0xFF042153), size: 18),
                const SizedBox(width: 8),
                Text(
                  variant.language.toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF042153)),
                ),
                const Spacer(),
                Text(
                  '${variant.formats.length} format(s)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          // Formats
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children:
                  variant.formats.map((f) => _buildFormatTile(f)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatTile(BookFormatEntity format) {
    final color = _formatColor(format.type);
    final icon = _formatIcon(format.type);

    String subtitle = '';
    if (format.type == 'hardcover' || format.type == 'paperback') {
      final parts = <String>[];
      if (format.isbn != null) parts.add('ISBN: ${format.isbn}');
      if (format.copies != null) parts.add('Copies: ${format.copies}');
      if (format.available == true) parts.add('Available');
      subtitle = parts.join(' • ');
    } else if (format.type == 'ebook') {
      subtitle = format.fileUrl != null ? 'File uploaded ✓' : 'No file';
    } else if (format.type == 'audiobook' || format.type == 'videobook') {
      final partCount = format.parts.length;
      final duration = format.totalDuration ?? 0;
      final mins = (duration / 60).round();
      subtitle = '$partCount part(s)${mins > 0 ? ' • ${mins}min' : ''}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  format.type.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 11, color: color),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _formatColor(String type) {
    switch (type) {
      case 'hardcover':
      case 'paperback':
        return const Color(0xFF4F46E5);
      case 'ebook':
        return const Color(0xFF0D9488);
      case 'audiobook':
        return const Color(0xFFD97706);
      case 'videobook':
        return const Color(0xFF7C3AED);
      default:
        return Colors.grey;
    }
  }

  IconData _formatIcon(String type) {
    switch (type) {
      case 'hardcover':
      case 'paperback':
        return Icons.menu_book_rounded;
      case 'ebook':
        return Icons.book_online_rounded;
      case 'audiobook':
        return Icons.headphones_rounded;
      case 'videobook':
        return Icons.videocam_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Widget _placeholderCover() {
    return Container(
      color: const Color(0xFF042153),
      child: const Center(
        child: Icon(Icons.menu_book_rounded, size: 80, color: Colors.white30),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF042153))),
    );
  }

  Widget _detailCard(List<Widget> rows) {
    final filtered = rows.whereType<Widget>().toList();
    if (filtered.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < filtered.length; i++) ...[
            filtered[i],
            if (i < filtered.length - 1)
              Divider(height: 1, color: Colors.grey.shade100, indent: 52),
          ]
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {Color? valueColor}) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF042153)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        color: valueColor ?? Colors.grey[850],
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
