import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DonationTab extends StatelessWidget {
  const DonationTab({super.key});

  static const _primaryGreen = Color(0xFF2CE07F);
  static const _textDark = Color(0xFF052E44);
  static const _background = Color(0xFFFDFDFD);
  static const _cardShadow = Color(0x0D000000); // ~5% black

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Donate',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Your Impact ---
            Text(
              'Your Impact',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _ImpactCard(
                    icon: Icons.book,
                    iconColor: Color(0xFF2CE07F),
                    iconBgColor: Color(0x1A2CE07F),
                    count: '04',
                    label: 'Books Donated',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _ImpactCard(
                    icon: Icons.people,
                    iconColor: Color(0xFF2196F3),
                    iconBgColor: Color(0x1A2196F3),
                    count: '20+',
                    label: 'Students Helped',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // --- Your Book Status ---
            Text(
              'Your Book Status',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(12)),
                boxShadow: [
                  BoxShadow(
                    color: _cardShadow,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  _BookStatusRow(
                    title: 'The Jungle Book',
                    format: 'E-Book',
                    status: 'Completed',
                    statusColor: Color(0xFF4CAF50),
                  ),
                  SizedBox(height: 16),
                  _BookStatusRow(
                    title: 'The Jungle Book',
                    format: 'E-Book',
                    status: 'Pending',
                    statusColor: Color(0xFFFFC107),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Donate Book Button ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/book-format');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Donate a Book',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Private Widgets ─────────────────────────────────────────

class _ImpactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String count;
  final String label;

  const _ImpactCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: DonationTab._cardShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DonationTab._textDark,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookStatusRow extends StatelessWidget {
  final String title;
  final String format;
  final String status;
  final Color statusColor;

  const _BookStatusRow({
    required this.title,
    required this.format,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DonationTab._textDark,
                ),
              ),
              Text(
                format,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            status,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
