import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_buddy_app/features/donate/presentation/widgets/donation_status.dart'
    show resolveDonationStatus;

/// Shared month-name helper for formatting donation dates.
String monthName(int m) {
  const names = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return names[m];
}

/// Shared status badge used across the contribution pages. Reads its color
/// from the single status source of truth so every screen agrees.
Widget buildStatusBadge(String status) {
  final resolved = resolveDonationStatus(status);
  final color = resolved.color;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      resolved.label,
      style: GoogleFonts.poppins(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
