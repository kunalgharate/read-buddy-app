import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../donate/presentation/pages/book_donation_page.dart';

const _textDark = Color(0xFF052E44);
const _skyBg = Color(0xFFEEF6FF);
const _skyBorder = Color(0xFFB3D9FF);
const _selectedBg = Color(0xFF4A90E2);

class BookFormatBottomSheet extends StatefulWidget {
  const BookFormatBottomSheet({super.key});

  @override
  State<BookFormatBottomSheet> createState() => _BookFormatBottomSheetState();
}

class _BookFormatBottomSheetState extends State<BookFormatBottomSheet> {
  String selectedFormat = '';

  void _showComingSoon() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coming Soon!', style: GoogleFonts.poppins(fontSize: 14)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _textDark,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.03,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.025),

          Text(
            'Choose One Type of Format',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.055,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
          SizedBox(height: size.height * 0.025),

          // ── Row 1: Physical + Digital ──
          Row(
            children: [
              Expanded(
                child: _FormatCard(
                  icon: Icons.menu_book,
                  label: 'Hardcover',
                  description: 'Printed book you own',
                  isSelected: selectedFormat == 'physical',
                  onTap: () {
                    Navigator.pop(context); // close bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DonationPage(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: _FormatCard(
                  icon: Icons.tablet_android,
                  label: 'Digital book',
                  description: 'Share it online & offline',
                  isSelected: selectedFormat == 'digital',
                  onTap: _showComingSoon,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.015),

          // ── Row 2: Audio + Video ──
          Row(
            children: [
              Expanded(
                child: _FormatCard(
                  icon: Icons.headphones,
                  label: 'Audio book',
                  description: 'Listen on the go',
                  isSelected: selectedFormat == 'audio',
                  onTap: _showComingSoon,
                ),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: _FormatCard(
                  icon: Icons.play_circle_outline,
                  label: 'Video book',
                  description: 'Watch & learn visually',
                  isSelected: selectedFormat == 'video',
                  onTap: _showComingSoon,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.03),
        ],
      ),
    );
  }
}

// ─── Format Card ─────────────────────────────────────────────

class _FormatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.022,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _selectedBg : _skyBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _selectedBg : _skyBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _selectedBg.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size.width * 0.12,
              height: size.width * 0.12,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: size.width * 0.07,
                color: isSelected ? Colors.white : _selectedBg,
              ),
            ),
            SizedBox(height: size.height * 0.012),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.036,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.004),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.026,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : const Color(0xFF7A9BB5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
// ─── Razorpay Bottom Sheet ────────────────────────────────────

class RazorpayBottomSheet extends StatefulWidget {
  const RazorpayBottomSheet({super.key});

  @override
  State<RazorpayBottomSheet> createState() => _RazorpayBottomSheetState();
}

class _RazorpayBottomSheetState extends State<RazorpayBottomSheet> {
  int selectedAmount = 1000;
  final List<int> quickAmounts = [500, 1000, 1500, 2000];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 380;
    final hp = size.width * 0.045;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding:
          EdgeInsets.fromLTRB(hp, size.height * 0.02, hp, size.height * 0.03),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),

          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add to Wallet',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _textDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Add via card  |  Send to Bank',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.024,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),

          // Amount box
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.015,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Amount',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.028,
                    color: const Color(0xFF7A9BB5),
                  ),
                ),
                SizedBox(height: size.height * 0.004),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '₹',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.055,
                        fontWeight: FontWeight.w500,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      selectedAmount.toString(),
                      style: GoogleFonts.poppins(
                        fontSize:
                            isSmall ? size.width * 0.07 : size.width * 0.08,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.015),

          // Quick amount chips
          Row(
            children: quickAmounts.map((amt) {
              final isChipSelected = selectedAmount == amt;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => selectedAmount = amt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.03,
                      vertical: size.height * 0.006,
                    ),
                    decoration: BoxDecoration(
                      color: isChipSelected ? _textDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isChipSelected
                            ? _textDark
                            : const Color(0xFFDDDDDD),
                      ),
                    ),
                    child: Text(
                      '+ ₹$amt',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.028,
                        fontWeight: FontWeight.w500,
                        color: isChipSelected ? Colors.white : _textDark,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: size.height * 0.01),

          // Info text
          Row(
            children: [
              Icon(Icons.info_outline,
                  size: size.width * 0.032, color: const Color(0xFF7A9BB5)),
              const SizedBox(width: 4),
              Text(
                'You can add up to ₹1,99,999.00',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.027,
                  color: const Color(0xFF7A9BB5),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.022),

          // Button
          SizedBox(
            width: double.infinity,
            height: size.height * 0.058,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: _textDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Add money to Wallet',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
