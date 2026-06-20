import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../domain/entities/library_entity.dart';
import '../bloc/book_request_bloc.dart';
import '../bloc/book_request_event.dart';
import '../bloc/book_request_state.dart';

// ─── Page ─────────────────────────────────────────────────────────────────────

class BookOrderPage extends StatelessWidget {
  final BookRequestEntity request;
  final int initialTab;

  const BookOrderPage({
    super.key,
    required this.request,
    this.initialTab = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookRequestBloc>()..add(LoadLibraryDetails()),
      child: _BookOrderView(request: request, initialTab: initialTab),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────

class _BookOrderView extends StatefulWidget {
  final BookRequestEntity request;
  final int initialTab;

  const _BookOrderView({required this.request, required this.initialTab});

  @override
  State<_BookOrderView> createState() => _BookOrderViewState();
}

class _BookOrderViewState extends State<_BookOrderView> {
  late int _currentTab;
  LibraryEntity? _library;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  String get _appBarTitle =>
      _currentTab == 0 ? 'Book Order' : 'Delivery Details';

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF052E44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _appBarTitle,
          style: const TextStyle(
            color: Color(0xFF1E2939),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        ),
      ),
      body: BlocListener<BookRequestBloc, BookRequestState>(
        listener: (context, state) {
          if (state is LibraryDetailsLoaded) {
            setState(() => _library = state.library);
          }
          if (state is DeliveryScheduled) {
            setState(() => _currentTab = 1);
          }
          if (state is DeliveryPaymentDone) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order placed! Your book is on its way 🚚'),
                backgroundColor: Color(0xFF2CE07F),
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          if (state is DeliveryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Column(
          children: [
            _OrderStepper(currentStep: _currentTab),
            Expanded(
              child: _currentTab == 0
                  ? _BookOrderTab(
                      request: widget.request,
                      nameController: _nameController,
                      phoneController: _phoneController,
                      addressController: _addressController,
                      pincodeController: _pincodeController,
                      selectedDate: _selectedDate,
                      selectedTime: _selectedTime,
                      onDatePicked: (d) => setState(() => _selectedDate = d),
                      onTimePicked: (t) => setState(() => _selectedTime = t),
                    )
                  : _DeliveryDetailsTab(
                      library: _library,
                      deliveryName: _nameController.text.trim(),
                      deliveryPhone: _phoneController.text.trim(),
                      deliveryAddress: _addressController.text.trim(),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          16, 12, 16,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: BlocBuilder<BookRequestBloc, BookRequestState>(
            builder: (context, state) {
              final isLoading = state is DeliveryScheduling ||
                  state is DeliveryPaymentLoading;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_currentTab == 0) {
                          final name = _nameController.text.trim();
                          final phone = _phoneController.text.trim();
                          final address = _addressController.text.trim();
                          final pincode = _pincodeController.text.trim();
                          if (name.isEmpty || phone.isEmpty || address.isEmpty || pincode.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill in all fields')),
                            );
                            return;
                          }
                          if (phone.length != 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Phone number must be exactly 10 digits')),
                            );
                            return;
                          }
                          if (address.length < 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid address')),
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
                          if (pincode.length != 6 || pincode[0] == '0') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid 6-digit pincode')),
                            );
                            return;
                          }
                          if (_selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a preferred date')),
                            );
                            return;
                          }
                          if (_selectedTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a preferred time')),
                            );
                            return;
                          }
                          context.read<BookRequestBloc>().add(
                                ScheduleDelivery(
                                  requestId: widget.request.id,
                                  name: name,
                                  phone: phone,
                                  address: address,
                                  pincode: pincode,
                                  preferredDate: _formatDate(_selectedDate!),
                                  preferredTime: _formatTime(_selectedTime!),
                                ),
                              );
                        } else {
                          context.read<BookRequestBloc>().add(
                                ConfirmDeliveryPayment(
                                  requestId: widget.request.id,
                                  name: _nameController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                  address: _addressController.text.trim(),
                                  pincode: _pincodeController.text.trim(),
                                  preferredDate: _formatDate(_selectedDate!),
                                  preferredTime: _formatTime(_selectedTime!),
                                ),
                              );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2CE07F),
                  disabledBackgroundColor:
                      const Color(0xFF2CE07F).withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Color(0xFF1E2939),
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _currentTab == 0 ? 'Proceed' : 'Proceed to Pay',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E2939),
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── 2-step stepper ───────────────────────────────────────────────────────────

class _OrderStepper extends StatelessWidget {
  final int currentStep;

  const _OrderStepper({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const steps = ['Book Order', 'Delivery Details'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final isCompleted = (index ~/ 2) < currentStep;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  height: 1.5,
                  color: isCompleted
                      ? const Color(0xFF052E44)
                      : const Color(0xFFDDDDDD),
                ),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isActive = stepIndex == currentStep;
          final isCompleted = stepIndex < currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isActive || isCompleted
                        ? const Color(0xFF052E44)
                        : const Color(0xFFCCCCCC),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check,
                          size: 16, color: Color(0xFF052E44))
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? const Color(0xFF052E44)
                                : const Color(0xFFAAAAAA),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                  color: isActive
                      ? const Color(0xFF052E44)
                      : const Color(0xFFAAAAAA),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Tab 1: Book Order ────────────────────────────────────────────────────────

class _BookOrderTab extends StatelessWidget {
  final BookRequestEntity request;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController pincodeController;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime> onDatePicked;
  final ValueChanged<TimeOfDay> onTimePicked;

  const _BookOrderTab({
    required this.request,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.pincodeController,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDatePicked,
    required this.onTimePicked,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2CE07F),
            onPrimary: Color(0xFF1E2939),
            onSurface: Color(0xFF1E2939),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onDatePicked(picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2CE07F),
            onPrimary: Color(0xFF1E2939),
            onSurface: Color(0xFF1E2939),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onTimePicked(picked);
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return 'Select Date';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _fmtTime(TimeOfDay? t) {
    if (t == null) return 'Select Time';
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BookCard(request: request),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 20),
          const Text(
            'Delivery Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2939),
            ),
          ),
          const SizedBox(height: 16),
          const _FieldLabel(label: 'Full Name'),
          const SizedBox(height: 8),
          _InputField(
            controller: nameController,
            hint: 'Enter Name',
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 16),
          const _FieldLabel(label: 'Phone Number'),
          const SizedBox(height: 8),
          _InputField(
            controller: phoneController,
            hint: 'Enter phone number',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 16),
          const _FieldLabel(label: 'Address'),
          const SizedBox(height: 8),
          _InputField(
            controller: addressController,
            hint: 'e.g. Flat 12, Sunrise Apartments, MG Road, Mumbai',
            keyboardType: TextInputType.streetAddress,
            maxLines: 3,
            helperText: 'Include flat/house no., street, area  •  min 10 characters  •  must include letters and numbers',
          ),
          const SizedBox(height: 16),
          const _FieldLabel(label: 'Pincode'),
          const SizedBox(height: 8),
          _InputField(
            controller: pincodeController,
            hint: 'Enter pincode',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Preferred Date'),
                    const SizedBox(height: 8),
                    _DateTimePickerButton(
                      icon: Icons.calendar_month_outlined,
                      label: _fmtDate(selectedDate),
                      isPlaceholder: selectedDate == null,
                      onTap: () => _pickDate(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Preferred Time'),
                    const SizedBox(height: 8),
                    _DateTimePickerButton(
                      icon: Icons.access_time_outlined,
                      label: _fmtTime(selectedTime),
                      isPlaceholder: selectedTime == null,
                      onTap: () => _pickTime(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Tab 2: Delivery Details ──────────────────────────────────────────────────

class _DeliveryDetailsTab extends StatelessWidget {
  final LibraryEntity? library;
  final String deliveryName;
  final String deliveryPhone;
  final String deliveryAddress;

  const _DeliveryDetailsTab({
    required this.library,
    required this.deliveryName,
    required this.deliveryPhone,
    required this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DeliveryTimelineV2(
            library: library,
            deliveryName: deliveryName,
            deliveryPhone: deliveryPhone,
            deliveryAddress: deliveryAddress,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── From / To delivery timeline ─────────────────────────────────────────────
//
// Layout (matches screenshot):
//   • "From" circle (green, ~52px diameter) left-aligned
//   • thin dark line from bottom of circle down to top of pickup card
//   • pickup card (full width)
//   • thin dark line from bottom of card down to "To" circle
//   • "To" circle
//   • thin dark line from bottom of "To" circle to top of dropoff card
//   • dropoff card

class _DeliveryTimelineV2 extends StatelessWidget {
  final LibraryEntity? library;
  final String deliveryName;
  final String deliveryPhone;
  final String deliveryAddress;

  const _DeliveryTimelineV2({
    required this.library,
    required this.deliveryName,
    required this.deliveryPhone,
    required this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    final libName = library?.name ?? '—';
    final libPhone = library?.contactNumber ?? '—';
    final libAddress = library?.address.fullAddress ?? '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TimelineCircle(label: 'From'),
        const _TimelineLine(height: 14),
        _TimelineCard(
          icon: Icons.local_shipping_outlined,
          description: 'Your book will be picked up from',
          boldLines: ['$libName - $libPhone', libAddress],
        ),
        const _TimelineLine(height: 14),
        const _TimelineCircle(label: 'To'),
        const _TimelineLine(height: 14),
        _TimelineCard(
          icon: Icons.home_outlined,
          description: 'Your book will be delivered to',
          boldLines: [deliveryName, deliveryPhone, deliveryAddress],
        ),
      ],
    );
  }
}

class _TimelineCircle extends StatelessWidget {
  final String label;
  const _TimelineCircle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFF2CE07F),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E2939),
          ),
        ),
      ),
    );
  }
}

class _TimelineLine extends StatelessWidget {
  final double height;
  const _TimelineLine({required this.height});

  @override
  Widget build(BuildContext context) {
    // Centered under the 52px circle
    return SizedBox(
      width: 36,
      height: height,
      child: Center(
        child: Container(
          width: 2,
          height: height,
          color: const Color(0xFF1A3C4A),
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final IconData icon;
  final String description;
  final List<String> boldLines;

  const _TimelineCard({
    required this.icon,
    required this.description,
    required this.boldLines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: const Color(0xFF1E2939)),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF444444),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          ...boldLines.where((l) => l.isNotEmpty).map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    line,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2939),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// ─── Book info card ───────────────────────────────────────────────────────────

class _BookCard extends StatelessWidget {
  final BookRequestEntity request;

  const _BookCard({required this.request});

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: request.bookCoverUrl != null &&
                  request.bookCoverUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: request.bookCoverUrl!,
                  width: 90,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _placeholder(),
                  errorWidget: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                request.bookTitle ?? 'Unknown Book',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2939),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Donated By  ${request.donorName ?? 'Unknown'}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 4),
              if (request.bookFormat != null && request.bookFormat!.isNotEmpty)
                Text(
                  'Format - ${_capitalize(request.bookFormat!)}',
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF555555)),
                ),
              const SizedBox(height: 4),
              const Text(
                'Quantity - 1',
                style: TextStyle(fontSize: 13, color: Color(0xFF555555)),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Color(0xFF888888), size: 22),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 90,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.menu_book, size: 36, color: Colors.grey),
    );
  }
}

// ─── Field label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1E2939),
      ),
    );
  }
}

// ─── Date / Time picker button ────────────────────────────────────────────────

class _DateTimePickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPlaceholder;
  final VoidCallback onTap;

  const _DateTimePickerButton({
    required this.icon,
    required this.label,
    required this.isPlaceholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF555555)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isPlaceholder
                      ? const Color(0xFFAAAAAA)
                      : const Color(0xFF1E2939),
                  fontWeight:
                      isPlaceholder ? FontWeight.normal : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ─── Text input field ─────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? helperText;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1E2939)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
        helperText: helperText,
        helperMaxLines: 3,
        helperStyle: const TextStyle(
          fontSize: 11,
          color: Color(0xFF999999),
          height: 1.4,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2CE07F), width: 1.5),
        ),
      ),
    );
  }
}
