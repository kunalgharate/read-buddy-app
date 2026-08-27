import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';

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

/// Shared status badge used across the contribution pages.
Widget buildStatusBadge(String status) {
  Color color;
  switch (status.toLowerCase()) {
    case 'completed':
    case 'success':
      color = const Color(0xFF4CAF50);
      break;
    case 'donation_created':
    case 'pickup_requested':
    case 'pending':
      color = const Color(0xFF2196F3);
      break;
    default:
      color = AppColors.textSecondary;
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status.replaceAll('_', ' '),
      style: GoogleFonts.poppins(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
