import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/donate/domain/entities/donation_stats.dart';

/// Single source of truth for donation statuses.
///
/// Every screen/widget that shows a donation status must read label, color and
/// the "confirmed" flag from here so they can never drift out of sync.
///
/// - [label] is a user-friendly status name.
/// - [color] is the badge color used consistently across the app.
/// - [confirmed] marks statuses that count toward "Books Donated" totals and
///   the confirmed-donations list.
class DonationStatusInfo {
  const DonationStatusInfo({
    required this.label,
    required this.color,
    required this.confirmed,
  });

  final String label;
  final Color color;
  final bool confirmed;
}

/// Maps a raw status string to display info. Unknown statuses fall back to a
/// safe, non-confirmed (pending-like) default so they are never treated as
/// confirmed and never crash.
DonationStatusInfo resolveDonationStatus(String apiStatus) {
  switch (apiStatus.toLowerCase().trim()) {
    case 'donation_created':
    case 'pickup_requested':
    case 'pending':
      return const DonationStatusInfo(
        label: 'Pending',
        color: Color(0xFFFFC107),
        confirmed: false,
      );
    case 'accepted':
    case 'approved':
    case 'processing':
    case 'out_for_pickup':
    case 'pickup_scheduled':
    case 'book_shipped':
    case 'in_transit':
    case 'picked_up':
      return const DonationStatusInfo(
        label: 'In Progress',
        color: Color(0xFF2196F3),
        confirmed: true,
      );
    case 'completed':
    case 'done':
    case 'delivered':
    case 'success':
    case 'received':
      return const DonationStatusInfo(
        label: 'Completed',
        color: Color(0xFF4CAF50),
        confirmed: true,
      );
    case 'cancelled':
    case 'rejected':
      return const DonationStatusInfo(
        label: 'Cancelled',
        color: Color(0xFFF44336),
        confirmed: false,
      );
    default:
      return DonationStatusInfo(
        label: apiStatus.replaceAll('_', ' ').toUpperCase(),
        color: const Color(0xFF9E9E9E),
        confirmed: false,
      );
  }
}

/// Statuses that represent an admin-confirmed donation. Derived from the
/// canonical definition so it always stays in sync with the badge logic.
final Set<String> kConfirmedDonationStatuses = {
  for (final s in _allStatusStrings)
    if (resolveDonationStatus(s).confirmed) s,
};

// All status strings the backend can send. When the backend adds a NEW status:
//   1. add its string here, and
//   2. give it a matching `case` in [resolveDonationStatus] above
//      (setting `confirmed: true` if it should count toward totals/lists).
// Everything else (badge colors, labels, confirmed-counting, counters) updates
// automatically from this single definition.
const List<String> _allStatusStrings = [
  'donation_created',
  'pickup_requested',
  'pending',
  'accepted',
  'approved',
  'processing',
  'out_for_pickup',
  'pickup_scheduled',
  'book_shipped',
  'in_transit',
  'picked_up',
  'completed',
  'done',
  'delivered',
  'success',
  'received',
  'cancelled',
  'rejected',
];

/// Returns ALL donations (pending and confirmed) newest first, so a just
/// submitted donation is always visible to the user with its current status.
List<BookStatusItem> allBooksSorted(List<BookStatusItem> all) {
  final sorted = List<BookStatusItem>.from(all)
    ..sort((a, b) {
      final da = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
      final db = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
      return db.compareTo(da);
    });
  return sorted;
}

/// Filter to only admin-confirmed donations, sorted newest first.
/// Uses the shared confirmed-status definition so the list can never disagree
/// with the "Books Donated" impact counter.
List<BookStatusItem> confirmedBooksSorted(List<BookStatusItem> all) {
  final confirmed = kConfirmedDonationStatuses;
  final filtered = all
      .where((b) => confirmed.contains(b.status.toLowerCase().trim()))
      .toList()
    ..sort((a, b) {
      final da = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
      final db = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
      return db.compareTo(da);
    });
  return filtered;
}
