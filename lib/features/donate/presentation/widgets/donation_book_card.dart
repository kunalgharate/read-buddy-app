import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/donate/domain/entities/donation_stats.dart';

({String label, Color color}) resolveDonationStatus(String apiStatus) {
  switch (apiStatus.toLowerCase()) {
    case 'donation_created':
    case 'pickup_requested':
    case 'pending':
      return (label: 'Pending', color: const Color(0xFFFFC107));
    case 'accepted':
    case 'processing':
    case 'out_for_pickup':
    case 'picked_up':
      return (label: 'In Progress', color: const Color(0xFF2196F3));
    case 'completed':
    case 'delivered':
    case 'success':
    case 'received':
      return (label: 'Completed', color: const Color(0xFF4CAF50));
    case 'cancelled':
    case 'rejected':
      return (label: 'Cancelled', color: const Color(0xFFF44336));
    default:
      return (
        label: apiStatus.replaceAll('_', ' ').toUpperCase(),
        color: const Color(0xFF9E9E9E),
      );
  }
}

/// Filter to only admin-confirmed donations, sorted newest first.
List<BookStatusItem> confirmedBooksSorted(List<BookStatusItem> all) {
  const confirmed = {
    'accepted',
    'processing',
    'out_for_pickup',
    'picked_up',
    'completed',
    'delivered',
    'success',
    'received',
  };
  final filtered =
      all.where((b) => confirmed.contains(b.status.toLowerCase())).toList()
        ..sort((a, b) {
          final da = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
          final db = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
          return db.compareTo(da);
        });
  return filtered;
}

class DonationBookCard extends StatelessWidget {
  final BookStatusItem book;
  final VoidCallback? onTap;

  const DonationBookCard({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    final resolved = resolveDonationStatus(book.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimaryColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.categoryName == null || book.categoryName!.isEmpty
                        ? book.format
                        : '${book.categoryName} \u2022 ${book.format}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: resolved.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                resolved.label,
                style: GoogleFonts.poppins(
                  color: resolved.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
