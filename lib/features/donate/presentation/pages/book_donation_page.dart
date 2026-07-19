import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/extensions/string_extensions.dart';
import 'package:read_buddy_app/features/books/presentation/bloc/book_bloc.dart';
import 'package:read_buddy_app/features/books/presentation/bloc/book_event.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:read_buddy_app/features/donate/domain/entities/book_donation_request.dart';
import 'package:read_buddy_app/features/library/domain/entities/library_entity.dart';
import 'package:read_buddy_app/features/donate/presentation/bloc/donate_book_bloc.dart';
import 'package:read_buddy_app/features/donated_books/presentation/bloc/donated_books_bloc.dart';
import 'package:read_buddy_app/features/donated_books/presentation/bloc/donated_books_events.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DonateBookBloc>(),
      child: const _DonationPageContent(),
    );
  }
}

class _DonationPageContent extends StatefulWidget {
  const _DonationPageContent();

  @override
  State<_DonationPageContent> createState() => _DonationPageState();
}

class _DonationPageState extends State<_DonationPageContent> {
  int _currentStep = 0;

  // Step 1 controllers
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  CategoryEntity? _selectedCategory;
  final _languageController = TextEditingController();
  final _aboutController = TextEditingController();
  String _bookCondition = 'good';
  File? _bookImage;
  final _categorySearchController = TextEditingController();
  List<CategoryEntity> _filteredCategories = [];

  // Step 2
  String _deliveryType = 'pickup';
  final _addressController = TextEditingController();
  final _pinController = TextEditingController();
  final _contractController = TextEditingController();
  DateTime? _preferredDate;
  LibraryEntity? _selectedLibrary;
  File? _receiptImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isBookImage) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isBookImage) {
          _bookImage = File(image.path);
        } else {
          _receiptImage = File(image.path);
        }
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _primaryGreen,
            onPrimary: Colors.white,
            onSurface: _textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _preferredDate = picked);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year;
    return '$d/$m/$y';
  }

  static const _primaryGreen = Color(0xFF2CE07F);
  static const _textDark = Color(0xFF052E44);
  static const _background = Color(0xFFFDFDFD);
  static const _conditions = ['New', 'Like New', 'Good', 'Old', 'Other'];

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<DonateBookBloc>().add(LoadNearestLibraries());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _languageController.dispose();
    _aboutController.dispose();
    _addressController.dispose();
    _pinController.dispose();
    _contractController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Basic Validation
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the book title')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    if (_deliveryType == 'pickup') {
      final address = _addressController.text.trim();
      final pin = _pinController.text.trim();
      final phone = _contractController.text.trim();

      if (address.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your pickup address')),
        );
        return;
      }
      // Bug 4: address minimum 10 chars + must contain both letters and digits
      if (address.length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address must be at least 10 characters'),
          ),
        );
        return;
      }
      final hasLetter = address.contains(RegExp(r'[a-zA-Z]'));
      final hasDigit = address.contains(RegExp(r'[0-9]'));
      if (!hasLetter || !hasDigit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter a valid address (include street name and number)',
            ),
          ),
        );
        return;
      }

      // Bug 2: PIN must be exactly 6 digits, first digit non-zero
      if (pin.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your PIN code')),
        );
        return;
      }
      if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(pin)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter a valid 6-digit PIN code (e.g. 400001)',
            ),
          ),
        );
        return;
      }

      // Bug 3: contact number must be exactly 10 digits
      if (phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your contact number')),
        );
        return;
      }
      if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact number must be exactly 10 digits'),
          ),
        );
        return;
      }

      if (_preferredDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a preferred pickup date')),
        );
        return;
      }
    }
    if (_deliveryType == 'dropoff' && _selectedLibrary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a library for drop-off')),
      );
      return;
    }

    final request = BookDonationRequest(
      fulfillmentType: _deliveryType == 'dropoff' ? 'DROP_OFF' : 'PICKUP',
      bookDetails: BookDetails(
        bookName: _titleController.text.trim(), // ✅ was 'title'
        category: _selectedCategory?.id ?? '',
        condition: _bookCondition.toLowerCase().replaceAll(' ', '_'),
        description: _aboutController.text.trim(),
        language: _languageController.text.trim(),
        format: 'physical',
      ),
      bookImagePath: _bookImage?.path,
      receiptImagePath: _receiptImage?.path,
      pickupDetails: _deliveryType == 'pickup'
          ? PickupDetails(
              name: _nameController.text.trim(),
              address: _addressController.text.trim(),
              pincode: _pinController.text.trim(),
              mobile: _contractController.text.trim(), // ✅ was 'phoneNumber'
              preferredDate: _preferredDate != null
                  ? '${_preferredDate!.day.toString().padLeft(2, '0')}'
                      '/${_preferredDate!.month.toString().padLeft(2, '0')}'
                      '/${_preferredDate!.year}'
                  : null,
            )
          : null,
      dropoffDetails: _deliveryType == 'dropoff' && _selectedLibrary != null
          ? DropoffDetails(libraryId: _selectedLibrary!.id)
          : null,
    );
    context.read<DonateBookBloc>().add(SubmitBookDonationEvent(request));
  }

  // ─── Category Search Dialog (improved, no images) ─────────

  void _showCategorySearchDialog(
      BuildContext context, List<CategoryEntity> categories) {
    // Reset search when opening
    _categorySearchController.clear();
    _filteredCategories = categories;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              elevation: 8,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- Fixed Header Area ---
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom: BorderSide(color: Colors.grey.shade100)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Select Category',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _textDark,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  icon: const Icon(Icons.close, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _categorySearchController,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: _textDark),
                              decoration: InputDecoration(
                                hintText: 'Search genres...',
                                hintStyle: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color(0xFF94A3B8)),
                                prefixIcon: const Icon(Icons.search,
                                    size: 20, color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFF1F5F9)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: _primaryGreen, width: 1.5),
                                ),
                              ),
                              onChanged: (value) {
                                setDialogState(() {
                                  _filteredCategories = value.isEmpty
                                      ? categories
                                      : categories
                                          .where((cat) => cat.title
                                              .toLowerCase()
                                              .contains(value.toLowerCase()))
                                          .toList();
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      // --- Scrollable List ---
                      Flexible(
                        child: _filteredCategories.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.search_off_rounded,
                                          size: 48,
                                          color: Colors.grey.shade200),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No genres found',
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: const Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(12),
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _filteredCategories.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 4),
                                itemBuilder: (context, index) {
                                  final category = _filteredCategories[index];
                                  final isSelected =
                                      _selectedCategory?.id == category.id;

                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setState(
                                            () => _selectedCategory = category);
                                        Navigator.pop(dialogContext);
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? _primaryGreen.withValues(
                                                  alpha: 0.08)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? _primaryGreen.withValues(
                                                        alpha: 0.2)
                                                    : const Color(0xFFF1F5F9),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  category.title.isNotEmpty
                                                      ? category.title
                                                          .capitalizeFirst[0]
                                                      : '?',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: isSelected
                                                        ? _primaryGreen
                                                        : const Color(
                                                            0xFF64748B),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                category
                                                    .title.capitalizeEachWord,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? _textDark
                                                      : const Color(0xFF334155),
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 20,
                                                  color: _primaryGreen),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final paddingH = size.width * 0.05;

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
          'Donate Your Book',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<DonateBookBloc, DonateBookState>(
        listener: (context, state) {
          if (state is BookDonationCreated) {
            // Refresh book pages so new donation appears
            context.read<BookBloc>().add(RefreshBooks());
            context.read<DonatedBooksBloc>().add(LoadDonatedBooks());

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Book donated successfully! ',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
                ),
                backgroundColor: _primaryGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.pop(context);
          } else if (state is DonateBookError) {
            debugPrint('❌ Donation error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to submit. Please try again.',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        child: Column(
          children: [
            _StepperHeader(
              currentStep: _currentStep,
              onStepTapped: (step) {
                if (step <= _currentStep) {
                  setState(() => _currentStep = step);
                }
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(horizontal: paddingH, vertical: 16),
                child: _currentStep == 0
                    ? _buildStep1()
                    : _currentStep == 1
                        ? _buildStep2()
                        : _buildStep3(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 1: Physical Book Details ───────────────────────

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _sectionSubtitle('Physical Book Details'),
        const SizedBox(height: 20),
        _label('Your Name'),
        const SizedBox(height: 8),
        _textField(_nameController, 'Enter your name'),
        const SizedBox(height: 16),
        _label('Book Title'),
        const SizedBox(height: 8),
        _textField(_titleController, 'Enter book title'),
        const SizedBox(height: 16),
        _label('Category'),
        const SizedBox(height: 8),

        // ✅ Improved category selector trigger (no images)
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            print(
                '📂 [BookDonationPage] CategoryBloc state: ${state.runtimeType}');
            List<CategoryEntity> categories = [];
            if (state is CategoryLoaded) {
              categories = state.categories;
              print(
                  '📂 [BookDonationPage] Categories count: ${categories.length}');
              if (_filteredCategories.isEmpty &&
                  _categorySearchController.text.isEmpty) {
                _filteredCategories = categories;
              }
            } else if (state is CategoryError) {
              print('📂 [BookDonationPage] CategoryError: ${state.message}');
            }

            return GestureDetector(
              onTap: () => _showCategorySearchDialog(context, categories),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedCategory != null
                        ? _primaryGreen
                        : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Row(
                  children: [
                    // ✅ Letter avatar (same style as dialog list items)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _selectedCategory != null
                            ? _primaryGreen.withValues(alpha: 0.12)
                            : const Color(0xFFF0F4F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _selectedCategory != null
                              ? _selectedCategory!.title.capitalizeFirst[0]
                              : '#',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _selectedCategory != null
                                ? _primaryGreen
                                : const Color(0xFF7A9BB5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedCategory?.title.capitalizeEachWord ??
                            'Select Category',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _selectedCategory != null
                              ? _textDark
                              : const Color(0xFF999999),
                        ),
                      ),
                    ),
                    // ✅ Clear button if selected, else dropdown arrow
                    if (_selectedCategory != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedCategory = null),
                        child: const Icon(Icons.close,
                            size: 18, color: Color(0xFF7A9BB5)),
                      )
                    else
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF7A9BB5)),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),
        _label('Language'),
        const SizedBox(height: 8),
        _textField(_languageController, 'Enter language'),
        const SizedBox(height: 16),
        _label('Book Condition'),
        const SizedBox(height: 8),
        _conditionChips(),
        const SizedBox(height: 16),
        _label('Upload Cover Image (Optional)'),
        const SizedBox(height: 8),
        _uploadBox(
          label: _bookImage == null ? 'Upload Images' : 'Image Selected',
          icon: _bookImage == null
              ? Icons.cloud_upload_outlined
              : Icons.check_circle,
          imageFile: _bookImage,
          onTap: () => _pickImage(true),
        ),
        const SizedBox(height: 16),
        _label('About Book'),
        const SizedBox(height: 8),
        _textField(_aboutController, 'Write about the book...', maxLines: 4),
        const SizedBox(height: 32),
        _primaryButton('Next', () => setState(() => _currentStep = 1)),
        const SizedBox(height: 24),
      ],
    );
  }

  // ─── Step 2: Pickup / Dropoff ─────────────────────────────

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _deliveryButton(
                label: 'Pick up',
                icon: Icons.directions_car_outlined,
                isSelected: _deliveryType == 'pickup',
                onTap: () => setState(() => _deliveryType = 'pickup'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _deliveryButton(
                label: 'Drop off',
                icon: Icons.storefront_outlined,
                isSelected: _deliveryType == 'dropoff',
                onTap: () => setState(() => _deliveryType = 'dropoff'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _sectionSubtitle(
          _deliveryType == 'pickup' ? 'Pick up Details' : 'Drop off Details',
        ),
        const SizedBox(height: 16),
        if (_deliveryType == 'pickup') ...[
          _label('Your Address'),
          const SizedBox(height: 8),
          _textField(
            _addressController,
            'e.g. Flat 12, Sunrise Apartments, MG Road, Mumbai',
            prefixIcon: Icons.location_on_outlined,
            maxLines: 3,
            helperText:
                'Include flat/house no., street, area • min 10 characters • must include letters and numbers',
          ),
          const SizedBox(height: 16),
          _label('Pin Code'),
          const SizedBox(height: 8),
          _textField(
            _pinController,
            'Enter Code',
            prefixIcon: Icons.pin_drop_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
          const SizedBox(height: 16),
          _label('Contact Number'),
          const SizedBox(height: 8),
          _textField(
            _contractController,
            'Enter Number',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 16),
          _label('Preferred Pickup Date'),
          const SizedBox(height: 8),
          _dateTimeButton(
            icon: Icons.calendar_month_outlined,
            label: _formatDate(_preferredDate),
            isPlaceholder: _preferredDate == null,
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
        ] else ...[
          BlocBuilder<DonateBookBloc, DonateBookState>(
            builder: (context, state) {
              if (state is DonateBookLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is NearestLibrariesLoaded) {
                if (state.libraries.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No libraries found nearby"),
                    ),
                  );
                }

                if (_selectedLibrary == null && state.libraries.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _selectedLibrary == null) {
                      setState(() => _selectedLibrary = state.libraries.first);
                    }
                  });
                }

                return Column(
                  children: state.libraries.map((library) {
                    final isSelected = _selectedLibrary?.id == library.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedLibrary = library),
                        child: _LibraryCard(
                          library: library,
                          isSelected: isSelected,
                          onUploadReceipt: () => _pickImage(false),
                          hasReceipt: _receiptImage != null,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }

              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("Loading library details..."),
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 32),
        _primaryButton('Next', _goToStep3),
        const SizedBox(height: 12),
        _outlineButton('Back', () => setState(() => _currentStep = 0)),
        const SizedBox(height: 24),
      ],
    );
  }

  bool _validateStep2() {
    if (_deliveryType == 'pickup') {
      final address = _addressController.text.trim();
      final pin = _pinController.text.trim();
      final phone = _contractController.text.trim();

      if (address.isEmpty) {
        _showSnack('Please enter your pickup address');
        return false;
      }
      if (address.length < 10) {
        _showSnack('Address must be at least 10 characters');
        return false;
      }
      final hasLetter = address.contains(RegExp(r'[a-zA-Z]'));
      final hasDigit = address.contains(RegExp(r'[0-9]'));
      if (!hasLetter || !hasDigit) {
        _showSnack(
            'Please enter a valid address (include street name and number)');
        return false;
      }
      if (pin.isEmpty) {
        _showSnack('Please enter your PIN code');
        return false;
      }
      if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(pin)) {
        _showSnack('Please enter a valid 6-digit PIN code (e.g. 400001)');
        return false;
      }
      if (phone.isEmpty) {
        _showSnack('Please enter your contact number');
        return false;
      }
      if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
        _showSnack('Contact number must be exactly 10 digits');
        return false;
      }
      if (_preferredDate == null) {
        _showSnack('Please select a preferred pickup date');
        return false;
      }
    }
    if (_deliveryType == 'dropoff' && _selectedLibrary == null) {
      _showSnack('Please select a library for drop-off');
      return false;
    }
    return true;
  }

  void _goToStep3() {
    if (_validateStep2()) {
      setState(() => _currentStep = 2);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Step 3: Confirmation ─────────────────────────────────

  Widget _buildStep3() {
    final isPickup = _deliveryType == 'pickup';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _sectionSubtitle('Review Your Donation'),
        const SizedBox(height: 20),

        // ── Book details card ──────────────────────────────────
        _confirmCard([
          _confirmRow('Book Title', _titleController.text.trim()),
          _confirmRow(
              'Category', _selectedCategory?.title.capitalizeEachWord ?? '—'),
          _confirmRow('Condition',
              _bookCondition.replaceAll('_', ' ').capitalizeEachWord),
          _confirmRow('Language', _languageController.text.trim()),
          _confirmRow('Donor Name', _nameController.text.trim()),
        ]),
        const SizedBox(height: 16),

        // ── Fulfillment details card ────────────────────────────
        _confirmCard([
          _confirmRow('Method', isPickup ? 'Pickup' : 'Drop Off'),
          if (isPickup) ...[
            _confirmRow('Address', _addressController.text.trim()),
            _confirmRow('PIN Code', _pinController.text.trim()),
            _confirmRow('Phone', _contractController.text.trim()),
            _confirmRow('Preferred Date', _formatDate(_preferredDate)),
          ],
          if (!isPickup && _selectedLibrary != null)
            _confirmRow('Library', _selectedLibrary!.name),
        ]),
        const SizedBox(height: 16),

        // ── Image indicators ────────────────────────────────────
        if (_bookImage != null)
          _confirmCard([
            _confirmRow('Cover Image', 'Attached ✓'),
          ]),
        if (_receiptImage != null)
          _confirmCard([
            _confirmRow('Receipt Image', 'Attached ✓'),
          ]),

        const SizedBox(height: 32),
        BlocBuilder<DonateBookBloc, DonateBookState>(
          builder: (context, state) {
            final isLoading = state is DonateBookLoading;
            return _primaryButton(
              'Submit',
              isLoading ? null : _submitForm,
              isLoading: isLoading,
            );
          },
        ),
        const SizedBox(height: 12),
        _outlineButton('Back', () => setState(() => _currentStep = 1)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _confirmCard(List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: rows,
      ),
    );
  }

  Widget _confirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF7A9BB5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Reusable Widgets ─────────────────────────────────────

  Widget _sectionSubtitle(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF7A9BB5),
        ),
      );

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _textDark,
        ),
      );

  Widget _textField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: GoogleFonts.poppins(fontSize: 14, color: _textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF999999)),
        helperText: helperText,
        helperMaxLines: 3,
        helperStyle: GoogleFonts.poppins(
          fontSize: 11,
          color: const Color(0xFF999999),
          height: 1.4,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: const Color(0xFF7A9BB5))
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderSide: const BorderSide(color: _primaryGreen, width: 2),
        ),
      ),
    );
  }

  Widget _conditionChips() {
    return Wrap(
      spacing: 8,
      children: _conditions.map((c) {
        final isSelected =
            _bookCondition == c.toLowerCase().replaceAll(' ', '_');
        return GestureDetector(
          onTap: () => setState(
              () => _bookCondition = c.toLowerCase().replaceAll(' ', '_')),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? _primaryGreen : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? _primaryGreen : const Color(0xFFE0E0E0),
              ),
            ),
            child: Text(
              c,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : _textDark,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _uploadBox({
    required String label,
    required IconData icon,
    File? imageFile,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  imageFile != null ? _primaryGreen : const Color(0xFFE0E0E0)),
        ),
        child: imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(imageFile, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 28, color: const Color(0xFF7A9BB5)),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: const Color(0xFF7A9BB5)),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _deliveryButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? _primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryGreen : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20,
                color: isSelected ? Colors.white : const Color(0xFF7A9BB5)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeButton({
    required IconData icon,
    required String label,
    required bool isPlaceholder,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF7A9BB5)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isPlaceholder ? const Color(0xFF999999) : _textDark,
                  fontWeight:
                      isPlaceholder ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback? onPressed,
      {bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                label,
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _outlineButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _textDark,
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─── Custom Stepper Header ────────────────────────────────────

class _StepperHeader extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int> onStepTapped;

  const _StepperHeader({
    required this.currentStep,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _StepCircle(
            number: 1,
            label: 'Book Details',
            isActive: currentStep >= 0,
            isDone: currentStep > 0,
            onTap: () => onStepTapped(0),
          ),
          _StepLine(isActive: currentStep > 0),
          _StepCircle(
            number: 2,
            label: 'Pickup',
            isActive: currentStep >= 1,
            isDone: currentStep > 1,
            onTap: () => onStepTapped(1),
          ),
          _StepLine(isActive: currentStep > 1),
          _StepCircle(
            number: 3,
            label: 'Confirm',
            isActive: currentStep >= 2,
            isDone: false,
            onTap: () => onStepTapped(2),
          ),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isDone;
  final VoidCallback onTap;

  const _StepCircle({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isDone,
    required this.onTap,
  });

  static const _primaryGreen = Color(0xFF2CE07F);
  static const _textDark = Color(0xFF052E44);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? _primaryGreen : const Color(0xFFE0E0E0),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '$number',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isActive ? Colors.white : const Color(0xFF999999),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isActive ? _textDark : const Color(0xFF999999),
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isActive;
  const _StepLine({required this.isActive});

  static const _primaryGreen = Color(0xFF2CE07F);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: isActive ? _primaryGreen : const Color(0xFFE0E0E0),
      ),
    );
  }
}

// ─── Library Card (Drop off) ──────────────────────────────────

class _LibraryCard extends StatelessWidget {
  final LibraryEntity library;
  final bool isSelected;
  final VoidCallback onUploadReceipt;
  final bool hasReceipt;

  const _LibraryCard({
    required this.library,
    this.isSelected = false,
    required this.onUploadReceipt,
    this.hasReceipt = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                isSelected ? const Color(0xFF2CE07F) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance,
                size: 22, color: Color(0xFF4A90E2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  library.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF052E44),
                  ),
                ),
                Text(
                  library.address.fullAddress,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: const Color(0xFF7A9BB5)),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _infoRow(Icons.phone_outlined, library.contactNumber),
                    _infoRow(Icons.access_time, library.openHours),
                    _infoRow(Icons.location_on_outlined, '${''} km'),
                    _infoRow(Icons.star_outline, ''),
                    _infoRow(Icons.local_shipping_outlined, ''),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onUploadReceipt,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: hasReceipt ? Colors.blue : const Color(0xFF2CE07F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hasReceipt ? 'Receipt Selected ✅' : 'Upload receipt',
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF7A9BB5)),
        const SizedBox(width: 4),
        Text(
          text,
          style:
              GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF7A9BB5)),
        ),
      ],
    );
  }
}
