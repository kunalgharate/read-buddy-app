import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../domain/entities/library_entity.dart';
import '../../domain/entities/pickup_details_entity.dart';
import '../bloc/book_request_bloc.dart';
import '../bloc/book_request_event.dart';
import '../bloc/book_request_state.dart';

// ─── Page ─────────────────────────────────────────────────────────────────────

class CollectFromLibraryPage extends StatelessWidget {
  final BookRequestEntity request;
  final int initialTab;

  const CollectFromLibraryPage({
    super.key,
    required this.request,
    this.initialTab = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookRequestBloc>()..add(LoadLibraryDetails()),
      child: _CollectFromLibraryView(request: request, initialTab: initialTab),
    );
  }
}

class _CollectFromLibraryView extends StatefulWidget {
  final BookRequestEntity request;
  final int initialTab;

  const _CollectFromLibraryView({
    required this.request,
    required this.initialTab,
  });

  @override
  State<_CollectFromLibraryView> createState() =>
      _CollectFromLibraryViewState();
}

class _CollectFromLibraryViewState extends State<_CollectFromLibraryView> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
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
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'DD/MM/YYYY';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '00:00 PM/AM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  void _onConfirm() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pickup date')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pickup time')),
      );
      return;
    }

    final timeStr =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    context.read<BookRequestBloc>().add(
          SchedulePickup(
            PickupDetailsEntity(
              requestId: widget.request.id,
              userName: name,
              phoneNumber: phone,
              address: address,
              pickupDate: _selectedDate!,
              pickupTime: timeStr,
            ),
          ),
        );
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2939)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Pick-Up & Drop',
          style: TextStyle(
            color: Color(0xFF1E2939),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<BookRequestBloc, BookRequestState>(
        listenWhen: (_, state) =>
            state is PickupScheduled || state is PickupScheduleError,
        listener: (context, state) {
          if (state is PickupScheduled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pickup scheduled! See you at the library 📚'),
                backgroundColor: Color(0xFF2CE07F),
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is PickupScheduleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Column(
        children: [
          // ── Tab row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _PickupTabRow(
              selected: _selectedTab,
              initialTab: widget.initialTab,
              onChanged: (i) => setState(() => _selectedTab = i),
            ),
          ),

          // ── Scrollable body ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Book info card ─────────────────────────────────
                  _BookCard(request: widget.request),

                  const SizedBox(height: 20),

                  // ── Section header ─────────────────────────────────
                  Text(
                    _selectedTab == 0
                        ? 'Pickup Location & Details'
                        : 'Drop Off Location & Details',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2939),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Library card ───────────────────────────────────
                  BlocBuilder<BookRequestBloc, BookRequestState>(
                    builder: (context, state) {
                      if (state is LibraryDetailsLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF2CE07F)),
                        );
                      }
                      if (state is LibraryDetailsLoaded) {
                        return _LibraryCard(library: state.library);
                      }
                      if (state is LibraryDetailsError) {
                        return Center(
                          child: Text(state.message,
                              style: const TextStyle(color: Colors.grey)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 28),

                  // ── User Details header ────────────────────────────
                  const Text(
                    'User Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2939),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const _FieldLabel(label: 'User Name'),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _nameController,
                    hint: 'Enter Name',
                    keyboardType: TextInputType.name,
                  ),

                  const SizedBox(height: 16),

                  const _FieldLabel(label: 'Phone Number'),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _phoneController,
                    hint: 'Enter phone number',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  const SizedBox(height: 16),

                  const _FieldLabel(label: 'Address'),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _addressController,
                    hint: 'Enter home address',
                    keyboardType: TextInputType.streetAddress,
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF888888),
                      size: 20,
                    ),
                    maxLines: 3,
                    minLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // ── Date + Time row ────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel(label: 'Select Date'),
                            const SizedBox(height: 8),
                            _DateTimePickerButton(
                              icon: Icons.calendar_month_outlined,
                              label: _formatDate(_selectedDate),
                              isPlaceholder: _selectedDate == null,
                              onTap: _pickDate,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel(label: 'Time'),
                            const SizedBox(height: 8),
                            _DateTimePickerButton(
                              icon: Icons.access_time_outlined,
                              label: _formatTime(_selectedTime),
                              isPlaceholder: _selectedTime == null,
                              onTap: _pickTime,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ), // end Column (BlocListener child)
      ), // end BlocListener
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: BlocBuilder<BookRequestBloc, BookRequestState>(
            builder: (context, state) {
              final isLoading = state is PickupScheduling;
              return ElevatedButton(
                onPressed: isLoading ? null : _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2CE07F),
                  disabledBackgroundColor: const Color(0xFF2CE07F).withValues(alpha: 0.6),
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
                        _selectedTab == 0 ? 'Confirm Pick Up' : 'Confirm Drop Off',
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

// ─── Tab row ──────────────────────────────────────────────────────────────────

class _PickupTabRow extends StatelessWidget {
  final int selected;
  final int initialTab;
  final ValueChanged<int> onChanged;

  const _PickupTabRow({
    required this.selected,
    required this.initialTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PickupTabButton(
            label: 'Pick Up',
            icon: Icons.menu_book_outlined,
            isSelected: selected == 0,
            isDisabled: initialTab != 0,
            onTap: () => onChanged(0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PickupTabButton(
            label: 'Drop Off',
            icon: Icons.menu_book_outlined,
            isSelected: selected == 1,
            isDisabled: initialTab != 1,
            onTap: () => onChanged(1),
          ),
        ),
      ],
    );
  }
}

class _PickupTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _PickupTabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isDisabled
              ? const Color(0xFFF0F0F0)
              : isSelected
                  ? const Color(0xFF2CE07F)
                  : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDisabled
                ? const Color(0xFFE0E0E0)
                : isSelected
                    ? const Color(0xFF2CE07F)
                    : const Color(0xFFDDDDDD),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDisabled
                  ? const Color(0xFFCCCCCC)
                  : isSelected
                      ? const Color(0xFF1E2939)
                      : const Color(0xFFAAAAAA),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDisabled
                    ? const Color(0xFFCCCCCC)
                    : isSelected
                        ? const Color(0xFF1E2939)
                        : const Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Book info card ─────────────────────────────────────────────────────

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
          child: request.bookCoverUrl != null && request.bookCoverUrl!.isNotEmpty
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
                'Donated By ${request.donorName ?? 'Unknown'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 4),
              if (request.bookFormat != null && request.bookFormat!.isNotEmpty)
                Text(
                  _capitalize(request.bookFormat!),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                  ),
                ),
            ],
          ),
        ),
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

// ─── Library card ─────────────────────────────────────────────────────────────

class _LibraryCard extends StatelessWidget {
  final LibraryEntity library;

  const _LibraryCard({required this.library});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Name + Start Now ─────────────────────────────────────
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                ),
                child: const Icon(Icons.location_city,
                    size: 26, color: Color(0xFF888888)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  library.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E2939),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Address ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Color(0xFF888888)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  library.address.fullAddress,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF555555), height: 1.4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Phone ─────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.phone_outlined,
                  size: 16, color: Color(0xFF888888)),
              const SizedBox(width: 8),
              Text(
                library.contactNumber,
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF555555)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Hours ─────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.access_time_outlined,
                  size: 16, color: Color(0xFF888888)),
              const SizedBox(width: 8),
              Text(
                library.openHours,
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF555555)),
              ),
            ],
          ),
        ],
      ),
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

// ─── Text input field ─────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int minLines;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1E2939)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
        prefixIcon: prefixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixIcon != null ? 0 : 16,
          vertical: 14,
        ),
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
