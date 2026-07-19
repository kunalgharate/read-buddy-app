import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/location_service.dart';
import '../../../library/domain/entities/library_entity.dart';
import '../../../library/domain/usecases/library_usecases.dart';
import '../bloc/book_request_bloc.dart';
import '../bloc/book_request_event.dart';
import '../bloc/book_request_state.dart';
import 'book_request_success_page.dart';

class BookRequestFormPage extends StatefulWidget {
  final String bookId;
  final String bookTitle;
  final String coverImageUrl;

  const BookRequestFormPage({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.coverImageUrl,
  });

  @override
  State<BookRequestFormPage> createState() => _BookRequestFormPageState();
}

class _BookRequestFormPageState extends State<BookRequestFormPage> {
  int _currentStep = 0;

  String _fulfillmentMethod = 'pickup'; // default to pickup

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  DateTime? _preferredDate;

  // Library selection for pickup
  List<LibraryEntity> _libraries = [];
  LibraryEntity? _selectedLibrary;
  bool _loadingLibraries = true;

  @override
  void initState() {
    super.initState();
    _fetchLibraries();
  }

  Future<void> _fetchLibraries() async {
    setState(() => _loadingLibraries = true);
    try {
      final getLibraryDetails = getIt<GetLibraryDetails>();
      var libraries = await getLibraryDetails();

      // Filter and sort by distance if location available
      final position = await LocationService.instance.getCurrentLocation();
      if (position != null && libraries.isNotEmpty) {
        // Only show libraries within 25 km
        libraries = libraries.where((lib) {
          if (lib.address.latitude == 0 && lib.address.longitude == 0) {
            return false;
          }
          final km = LocationService.instance.calculateDistanceKm(
            position.latitude,
            position.longitude,
            lib.address.latitude,
            lib.address.longitude,
          );
          return km <= 25;
        }).toList();

        // Sort nearest first
        libraries.sort((a, b) {
          final distA = LocationService.instance.calculateDistanceKm(
            position.latitude,
            position.longitude,
            a.address.latitude,
            a.address.longitude,
          );
          final distB = LocationService.instance.calculateDistanceKm(
            position.latitude,
            position.longitude,
            b.address.latitude,
            b.address.longitude,
          );
          return distA.compareTo(distB);
        });
      }

      // If no nearby libraries, fallback to super libraries
      if (libraries.isEmpty) {
        final getSuperLibraries = getIt<GetSuperLibraries>();
        libraries = await getSuperLibraries();
      }

      setState(() {
        _libraries = libraries;
        _loadingLibraries = false;
        if (libraries.isNotEmpty) _selectedLibrary = libraries.first;
      });
    } catch (e) {
      setState(() => _loadingLibraries = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
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
            primary: Color(0xFF2CE07F),
            onPrimary: AppColors.textPrimary,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _preferredDate = picked);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    final months = [
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
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  bool _validateStep1() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showSnack('Please enter your name');
      return false;
    }
    if (name.length < 2) {
      _showSnack('Name must be at least 2 characters');
      return false;
    }
    if (phone.isEmpty) {
      _showSnack('Please enter your phone number');
      return false;
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      _showSnack('Phone number must be exactly 10 digits');
      return false;
    }

    if (_fulfillmentMethod == 'dropoff') {
      final address = _addressController.text.trim();
      final pincode = _pincodeController.text.trim();

      if (address.isEmpty) {
        _showSnack('Please enter your address');
        return false;
      }
      if (address.length < 10) {
        _showSnack('Address must be at least 10 characters');
        return false;
      }
      if (pincode.isEmpty) {
        _showSnack('Please enter your PIN code');
        return false;
      }
      if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(pincode)) {
        _showSnack('Please enter a valid 6-digit PIN code');
        return false;
      }
      if (_preferredDate == null) {
        _showSnack('Please select a preferred delivery date');
        return false;
      }
    }

    if (_fulfillmentMethod == 'pickup' && _selectedLibrary == null) {
      _showSnack('Please select a library for pickup');
      return false;
    }

    return true;
  }

  void _goToStep2() {
    if (_validateStep1()) {
      setState(() => _currentStep = 1);
    }
  }

  void _submit(BuildContext blocContext) {
    final isDropoff = _fulfillmentMethod == 'dropoff';
    blocContext.read<BookRequestBloc>().add(
      CreateBookRequest(
        widget.bookId,
        fulfillmentMethod: _fulfillmentMethod,
        deliveryName: isDropoff ? _nameController.text.trim() : null,
        deliveryPhone: isDropoff ? _phoneController.text.trim() : null,
        deliveryAddress: isDropoff ? _addressController.text.trim() : null,
        deliveryPincode: isDropoff ? _pincodeController.text.trim() : null,
        deliveryPreferredDate: isDropoff ? _formatDate(_preferredDate) : null,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookRequestBloc>(),
      child: BlocConsumer<BookRequestBloc, BookRequestState>(
        listenWhen: (_, current) =>
            current is BookRequestCreated || current is BookRequestError,
        listener: (context, state) {
          if (state is BookRequestCreated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BookRequestSuccessPage(
                  bookTitle: widget.bookTitle,
                  coverImageUrl: widget.coverImageUrl,
                ),
              ),
            );
          } else if (state is BookRequestError) {
            _showSnack(state.message);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                _currentStep == 0 ? 'Fulfillment Details' : 'Confirmation',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            body: SafeArea(
              child: state is BookRequestCreating
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF2CE07F)))
                  : _currentStep == 0
                      ? _buildStep1()
                      : _buildStep2(context),
            ),
          );
        },
      ),
    );
  }

  // ─── Step 1: Fulfillment Details ──────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.bookTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'How would you like to receive this book?',
            style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 20),

          // Fulfillment method toggle
          Row(
            children: [
              Expanded(
                child: _methodCard(
                  icon: Icons.store_outlined,
                  label: 'Pickup',
                  subtitle: 'I will collect from library',
                  isSelected: _fulfillmentMethod == 'pickup',
                  onTap: () => setState(() => _fulfillmentMethod = 'pickup'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _methodCard(
                  icon: Icons.local_shipping_outlined,
                  label: 'Drop-off',
                  subtitle: 'Deliver to my address',
                  isSelected: _fulfillmentMethod == 'dropoff',
                  onTap: () => setState(() => _fulfillmentMethod = 'dropoff'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Contact Info
          const _SectionLabel('Contact Information'),
          const SizedBox(height: 12),
          _textField(_nameController, 'Full Name',
              prefixIcon: Icons.person_outline),
          const SizedBox(height: 12),
          _textField(
            _phoneController,
            'Phone Number',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),

          if (_fulfillmentMethod == 'dropoff') ...[
            const SizedBox(height: 20),
            const _SectionLabel('Delivery Address'),
            const SizedBox(height: 12),
            _textField(
              _addressController,
              'Street / Area / Landmark',
              prefixIcon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _textField(
              _pincodeController,
              'PIN Code',
              prefixIcon: Icons.pin_drop_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionLabel('Preferred Delivery Date'),
            const SizedBox(height: 12),
            _dateTimeButton(
              icon: Icons.calendar_month_outlined,
              label: _formatDate(_preferredDate),
              isPlaceholder: _preferredDate == null,
              onTap: _pickDate,
            ),
          ],

          if (_fulfillmentMethod == 'pickup') ...[
            const SizedBox(height: 20),
            const _SectionLabel('Select Library for Pickup'),
            const SizedBox(height: 12),
            if (_loadingLibraries)
              const Center(child: CircularProgressIndicator(strokeWidth: 2))
            else if (_libraries.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.location_off,
                        color: Colors.amber, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'No libraries nearby or in your city',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Please choose the Drop-off (delivery) option instead.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () =>
                          setState(() => _fulfillmentMethod = 'dropoff'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2CE07F),
                        side: const BorderSide(color: Color(0xFF2CE07F)),
                      ),
                      child: const Text('Switch to Delivery'),
                    ),
                  ],
                ),
              )
            else
              ..._libraries.map((lib) => _libraryTile(lib)),
          ],

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _goToStep2,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2CE07F),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _methodCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2CE07F).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF2CE07F) : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 32,
                color: isSelected
                    ? const Color(0xFF2CE07F)
                    : const Color(0xFF999999)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.textPrimary
                    : const Color(0xFF999999),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? AppColors.textPrimary
                    : const Color(0xFFBBBBBB),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 2: Confirmation ─────────────────────────────────

  Widget _buildStep2(BuildContext blocContext) {
    final isDropoff = _fulfillmentMethod == 'dropoff';
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Your Request',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7A9BB5),
            ),
          ),
          const SizedBox(height: 20),
          _confirmCard([
            _confirmRow('Book', widget.bookTitle),
            _confirmRow('Name', _nameController.text.trim()),
            _confirmRow('Phone', _phoneController.text.trim()),
            _confirmRow(
                'Method', isDropoff ? 'Delivery' : 'Pickup from Library'),
            if (isDropoff) ...[
              _confirmRow('Address', _addressController.text.trim()),
              _confirmRow('PIN Code', _pincodeController.text.trim()),
              _confirmRow('Preferred Date', _formatDate(_preferredDate)),
            ],
            if (!isDropoff && _selectedLibrary != null) ...[
              _confirmRow('Library', _selectedLibrary!.name),
              _confirmRow('Location', _selectedLibrary!.address.fullAddress),
              if (_selectedLibrary!.openHours.isNotEmpty)
                _confirmRow('Hours', _selectedLibrary!.openHours),
            ],
          ]),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _submit(blocContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2CE07F),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Submit Request',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => setState(() => _currentStep = 0),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: Color(0xFFDDDDDD)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Back',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7A9BB5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Reusable Widgets ─────────────────────────────────────

  Widget _textField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF999999)),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: const Color(0xFF999999))
            : null,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF999999)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isPlaceholder
                    ? const Color(0xFF999999)
                    : AppColors.textPrimary,
                fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _libraryTile(LibraryEntity lib) {
    final isSelected = _selectedLibrary?.id == lib.id;
    final position = LocationService.instance.lastPosition;
    String? distanceText;
    if (position != null && lib.address.latitude != 0) {
      final km = LocationService.instance.calculateDistanceKm(
        position.latitude,
        position.longitude,
        lib.address.latitude,
        lib.address.longitude,
      );
      distanceText = LocationService.instance.formatDistance(km);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedLibrary = lib),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2CE07F)
                  : const Color(0xFFE0E0E0),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? const Color(0xFF2CE07F).withValues(alpha: 0.05)
                : Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: lib.isSuperLibrary
                      ? Colors.amber.withValues(alpha: 0.15)
                      : const Color(0xFF2CE07F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  lib.isSuperLibrary ? Icons.star : Icons.local_library,
                  size: 20,
                  color: lib.isSuperLibrary
                      ? Colors.amber
                      : const Color(0xFF2CE07F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lib.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lib.address.fullAddress,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lib.openHours.isNotEmpty)
                      Text(
                        lib.openHours,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFBBBBBB),
                        ),
                      ),
                  ],
                ),
              ),
              if (distanceText != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2CE07F).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    distanceText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2CE07F),
                    ),
                  ),
                ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle,
                    color: Color(0xFF2CE07F), size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
