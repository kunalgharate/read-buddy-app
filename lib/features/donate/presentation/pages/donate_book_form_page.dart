import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/ui_utils.dart';

class DonateBookFormPage extends StatefulWidget {
  const DonateBookFormPage({super.key});

  @override
  State<DonateBookFormPage> createState() => _DonateBookFormPageState();
}

class _DonateBookFormPageState extends State<DonateBookFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedGenre;
  String _bookCondition = 'Good';

  static const _primaryGreen = Color(0xFF2CE07F);
  static const _textDark = Color(0xFF052E44);
  static const _background = Color(0xFFFDFDFD);

  static const _genres = [
    'Fiction',
    'Non-Fiction',
    'Biography',
    'Self-Help',
    'Science',
    'History',
    'Other',
  ];

  static const _conditions = ['New', 'Good', 'Fair'];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    UiUtils.showSuccessSnackBar(
      context,
      message: 'Book donation submitted successfully!',
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
          'Donate a Book',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Title
              _buildLabel('Book Title'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: _inputTextStyle,
                decoration: _inputDecoration('Enter book title'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter the book title'
                    : null,
              ),
              const SizedBox(height: 20),

              // Author Name
              _buildLabel('Author Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _authorController,
                style: _inputTextStyle,
                decoration: _inputDecoration('Enter author name'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter the author name'
                    : null,
              ),
              const SizedBox(height: 20),

              // Genre / Category
              _buildLabel('Genre / Category'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedGenre,
                style: _inputTextStyle,
                decoration: _inputDecoration('Select genre'),
                items: _genres
                    .map(
                      (g) => DropdownMenuItem(
                        value: g,
                        child: Text(g),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedGenre = v),
                validator: (v) => v == null ? 'Please select a genre' : null,
              ),
              const SizedBox(height: 20),

              // Book Condition
              _buildLabel('Book Condition'),
              const SizedBox(height: 8),
              ...List.generate(_conditions.length, (i) {
                final condition = _conditions[i];
                final isSelected = _bookCondition == condition;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _bookCondition = condition),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? _primaryGreen
                                  : const Color(0xFFE0E0E0),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _primaryGreen,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          condition,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Description / Notes
              _buildLabel('Description / Notes'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                style: _inputTextStyle,
                maxLines: 4,
                decoration: _inputDecoration(
                  'Add any notes about the book...',
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Submit Donation',
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
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _textDark,
      ),
    );
  }

  TextStyle get _inputTextStyle => GoogleFonts.poppins(
        fontSize: 14,
        color: _textDark,
      );

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFF999999),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _primaryGreen,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD64545)),
      ),
    );
  }
}
