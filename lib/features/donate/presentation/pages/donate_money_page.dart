import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/ui_utils.dart';

class DonateMoneyPage extends StatefulWidget {
  const DonateMoneyPage({super.key});

  @override
  State<DonateMoneyPage> createState() => _DonateMoneyPageState();
}

class _DonateMoneyPageState extends State<DonateMoneyPage> {
  int? _selectedAmount;
  final _customAmountController = TextEditingController();

  static const _primaryGreen = Color(0xFF2CE07F);
  static const _textDark = Color(0xFF052E44);
  static const _background = Color(0xFFFDFDFD);

  static const _presetAmounts = [50, 100, 200, 500];

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _onDonate() {
    final custom = _customAmountController.text.trim();
    final hasAmount = _selectedAmount != null || custom.isNotEmpty;

    if (!hasAmount) {
      UiUtils.showErrorSnackBar(
        context,
        message: 'Please select or enter an amount.',
      );
      return;
    }

    UiUtils.showSuccessSnackBar(
      context,
      message: 'Thank you for your generous donation!',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Donate Money',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(
          children: [
            // Illustration placeholder
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: _primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.volunteer_activism,
                size: 72,
                color: _primaryGreen,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "Support ReadBuddy's Mission",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your donation helps us deliver books to '
              'students who need them most.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Preset amount chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _presetAmounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                return ChoiceChip(
                  label: Text(
                    '₹$amount',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : _textDark,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: _primaryGreen,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? _primaryGreen : const Color(0xFFE0E0E0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedAmount = isSelected ? null : amount;
                      if (!isSelected) {
                        _customAmountController.clear();
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Custom amount field
            TextField(
              controller: _customAmountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Enter custom amount',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF999999),
                ),
                prefixText: '₹ ',
                prefixStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: _textDark,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE0E0E0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE0E0E0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: _primaryGreen,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (_) {
                if (_selectedAmount != null) {
                  setState(() => _selectedAmount = null);
                }
              },
            ),
            const SizedBox(height: 32),

            // Donate Now button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _onDonate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Donate Now',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
