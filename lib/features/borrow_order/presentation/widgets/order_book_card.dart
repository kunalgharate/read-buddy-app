import 'package:flutter/material.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import '../../domain/entities/borrow_order_entity.dart';

class OrderBookCard extends StatelessWidget {
  final OrderBookItem book;
  final bool showRemoveButton;
  final VoidCallback? onRemove;

  const OrderBookCard({
    super.key,
    required this.book,
    this.showRemoveButton = true,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Cover Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: book.bookCoverUrl.isNotEmpty
                  ? Image.network(
                      book.bookCoverUrl,
                      width: 60,
                      height: 85,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _coverPlaceholder(),
                    )
                  : _coverPlaceholder(),
            ),
            const SizedBox(width: 12),
            // Book Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.bookTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.bookAuthor,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${book.bookPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${book.bookPages} pages',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Remove button
            if (showRemoveButton)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                  color: AppColors.error,
                ),
                tooltip: 'Remove from cart',
              ),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: 60,
      height: 85,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }
}
