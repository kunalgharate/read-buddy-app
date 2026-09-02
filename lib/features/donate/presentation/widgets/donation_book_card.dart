import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/donate/domain/entities/donation_stats.dart';
import 'package:read_buddy_app/features/donate/presentation/widgets/donation_status.dart'
    show resolveDonationStatus;

export 'package:read_buddy_app/features/donate/presentation/widgets/donation_status.dart'
    show allBooksSorted, confirmedBooksSorted;

/// Returns ALL donations (pending and confirmed) newest first, so a just
/// submitted donation is always visible to the user with its current status.
/// Definition moved to `donation_status.dart`; re-exported here for
/// backward-compatible imports.
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
