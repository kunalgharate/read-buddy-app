import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── File-level color constants ──────────────────────────────
const _primaryGreen = Color(0xFF2CE07F);
const _textDark = Color(0xFF052E44);
const _background = Color(0xFFFDFDFD);
const _accentBlue = Color(0xFF4A90E2);

class BookFormatScreen extends StatefulWidget {
  const BookFormatScreen({super.key});

  @override
  State<BookFormatScreen> createState() => _BookFormatScreenState();
}

class _BookFormatScreenState extends State<BookFormatScreen> {
  String selectedFormat = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose One Type of Format',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 30),

            // Format Selection Cards
            Row(
              children: [
                Expanded(
                  child: _FormatCard(
                    icon: Icons.menu_book,
                    label: 'Physical book',
                    description: 'Printed book you own',
                    isSelected: selectedFormat == 'physical',
                    onTap: () {
                      setState(() => selectedFormat = 'physical');
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _FormatCard(
                    icon: Icons.tablet_android,
                    label: 'Digital book',
                    description: 'Ebook, online and offline',
                    isSelected: selectedFormat == 'digital',
                    onTap: () {
                      setState(() => selectedFormat = 'digital');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.add_circle_outline,
                    label: 'Add Book',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/donate-book-form',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.volunteer_activism,
                    label: 'Donate Money',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/donate-money',
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Private Widgets ─────────────────────────────────────────

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? _accentBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _accentBlue : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.white : _accentBlue,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _textDark,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: _primaryGreen,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
