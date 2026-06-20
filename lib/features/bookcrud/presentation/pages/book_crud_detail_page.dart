import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';

class BookCrudDetailPage extends StatelessWidget {
  final BookCrudEntity book;

  const BookCrudDetailPage({super.key, required this.book});

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
                  // Cover image
                  book.coverImageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: book.coverImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: const Color(0xFF042153),
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _placeholderCover(),
                        )
                      : _placeholderCover(),
                  // Dark gradient overlay
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
                  // Title & Author at bottom
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
                              fontSize: 14,
                            ),
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
                  // ── Status Chips ──────────────────────────────────────
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _chip(book.format, Icons.menu_book_rounded, Colors.indigo),
                      _chip(book.condition, Icons.verified_rounded, Colors.teal),
                      if (book.category.isNotEmpty)
                        _chip(book.category, Icons.category_rounded, Colors.orange),
                      if (book.language.isNotEmpty)
                        _chip(book.language, Icons.language_rounded, Colors.purple),
                      _chip(
                        book.isAvailable ? 'Available' : 'Unavailable',
                        book.isAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        book.isAvailable ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Add Variant Button ────────────────────────────────
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
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF042153),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Book Details Section ──────────────────────────────
                  _sectionTitle('Book Details'),
                  _detailCard([
                    if (book.subtitle.isNotEmpty)
                      _row(Icons.title_rounded, 'Subtitle', book.subtitle),
                    _row(Icons.person_rounded, 'Author', book.author),
                    if (book.publisher.isNotEmpty)
                      _row(Icons.business_rounded, 'Publisher', book.publisher),
                    if (book.edition.isNotEmpty)
                      _row(Icons.layers_rounded, 'Edition', book.edition),
                    if (book.isbn.isNotEmpty)
                      _row(Icons.qr_code_rounded, 'ISBN', book.isbn),
                    if (book.publicationYear > 0)
                      _row(Icons.calendar_today_rounded, 'Publication Year',
                          book.publicationYear.toString()),
                    if (book.genre.isNotEmpty)
                      _row(Icons.local_library_rounded, 'Genre', book.genre),
                    _row(Icons.menu_book_rounded, 'Format', book.format),
                    _row(Icons.language_rounded, 'Language', book.language),
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
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Availability & Condition ──────────────────────────
                  _sectionTitle('Availability & Condition'),
                  _detailCard([
                    _row(Icons.verified_rounded, 'Condition', book.condition),
                    _row(
                      book.isAvailable
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      'Available',
                      book.isAvailable ? 'Yes' : 'No',
                      valueColor:
                          book.isAvailable ? Colors.green : Colors.red,
                    ),
                    _row(Icons.info_rounded, 'Status', book.status),
                    if (book.numberOfCopies > 0)
                      _row(Icons.copy_rounded, 'Number of Copies',
                          book.numberOfCopies.toString()),
                  ]),
                  const SizedBox(height: 16),

                  // ── Owner & Location ──────────────────────────────────
                  _sectionTitle('Source Information'),
                  _detailCard([
                    if ((book.ownerName ?? '').isNotEmpty)
                      _row(Icons.person_pin_rounded, 'Owner',
                          book.ownerName ?? ''),
                    if (book.location.isNotEmpty)
                      _row(Icons.location_on_rounded, 'Location', book.location),
                    if (book.notes.isNotEmpty)
                      _row(Icons.notes_rounded, 'Notes', book.notes),
                  ]),
                  const SizedBox(height: 16),

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
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFF6366F1),
                                      width: 1),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF4338CA),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
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

  // ── Helper Widgets ───────────────────────────────────────────────────

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
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF042153),
        ),
      ),
    );
  }

  Widget _detailCard(List<Widget> rows) {
    // Remove empty rows
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

  Widget _row(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: valueColor ?? Colors.grey[850],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
