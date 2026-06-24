import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/donated_books/domain/entities/donated_books_entity.dart';

class DonatedBookCard extends StatelessWidget {
  final DonatedBooksEntity book;
  final VoidCallback? onTap;

  const DonatedBookCard({super.key, required this.book, this.onTap});

  void _showBookDetails(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    Navigator.pushNamed(
      context,
      '/donated-book-detail',
      arguments: book,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBookDetails(context),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover placeholder
              Container(
                width: 113,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey.shade300,
                ),
                child: book.coverImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          book.coverImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const AspectRatio(
                            aspectRatio: 113 / 136,
                            child: Icon(Icons.menu_book,
                                color: Colors.grey, size: 40),
                          ),
                        ),
                      )
                    : const AspectRatio(
                        aspectRatio: 113 / 136,
                        child:
                            Icon(Icons.menu_book, color: Colors.grey, size: 40),
                      ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        book.bookTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Badges row
                    Row(
                      children: [
                        _badge(
                          book.format,
                          const Color(0xFF2CE07F),
                          const Color(0xFF052E44),
                        ),
                        const SizedBox(width: 8),
                        _badgeWithIcon(
                          book.language,
                          const Color(0xFF2CE07F),
                          const Color(0xFF052E44),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${book.status}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF052E44),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Donation info text
                    Text(
                      'Donated by ${book.donorName}.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF052E44),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Right side: time + 3-dot menu
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    book.timeAgo,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF141414),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // const Icon(Icons.more_vert, color: Color(0xFF141414), size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _badgeWithIcon(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
